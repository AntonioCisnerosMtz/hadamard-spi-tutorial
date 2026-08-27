function S06_reconstruct_tval3()
%% S06 - Reconstruct the simulated measurements with TVAL3
% TVAL3 reconstructs an image by promoting low total variation while
% enforcing agreement with the measured Hadamard coefficients.
%
% Unlike FDRI, this route does not build a dense M x N sensing matrix.
% Instead, TVAL3 receives a function handle A_M that can apply:
%
%   mode = 1 : A_M x
%   mode = 2 : A_M^T z
%
% The first M GCS+S measurements are exactly the same values generated in S02.
%
% The manuscript benchmark used anisotropic TV (TVnorm = 1), a nonnegative
% image constraint, and the fixed settings listed below.

config = section7_8_config();
addpath(config.functionsFolder);

measurementFile = fullfile(config.resultsFolder, ...
    'hadamard_measurements.mat');
if exist(measurementFile, 'file') ~= 2
    error('Run S02_generate_hadamard_measurements first.');
end

data = load(measurementFile, ...
    'Hseq', 'gcssLinearIndex', 'yFull', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'n', 'N', 'ordering');

Hseq = data.Hseq;
gcssLinearIndex = data.gcssLinearIndex;
yFull = data.yFull;
samplingPercents = double(data.samplingPercents(:).');
Mvalues = double(data.Mvalues(:).');
actualSamplingRatios = double(data.actualSamplingRatios(:).');
n = double(data.n);
N = double(data.N);
ordering = data.ordering;

%% TVAL3 settings used in the manuscript simulation benchmark
options = struct();
options.mu = 256;
options.beta = 32;
options.tol = 1e-4;
options.maxit = 300;
options.maxcnt = 50;
options.TVnorm = 1;      % anisotropic total variation
options.nonneg = true;   % nonnegative reconstructed image
options.TVL2 = false;    % equality-constrained TV model

% These values are fixed benchmark settings, not universal recommendations.

%% Make the preserved TVAL3 implementation visible to MATLAB
tval3Folder = fullfile(config.projectFolder, ...
    'third_party', 'TVAL3_beta2.4');

solverFolder = fullfile(tval3Folder, 'Solver');
utilitiesFolder = fullfile(tval3Folder, 'Utilities');

assert(exist(fullfile(solverFolder, 'TVAL3.m'), 'file') == 2, ...
    'The preserved TVAL3 solver was not found.');
assert(exist(fullfile(utilitiesFolder, 'defDDt.m'), 'file') == 2, ...
    'The preserved TVAL3 utilities were not found.');

addpath(solverFolder, '-begin');
addpath(utilitiesFolder, '-begin');

numRatios = numel(samplingPercents);
tval3Reconstructions = zeros(n, n, numRatios);
solverSeconds = zeros(1, numRatios);
iterations = NaN(1, numRatios);
convergenceStatus = strings(1, numRatios);
finalRelativeChanges = NaN(1, numRatios);
finalObjectives = NaN(1, numRatios);
finalRelativeMeasurementResiduals = NaN(1, numRatios);
warningIds = strings(1, numRatios);
warningMessages = strings(1, numRatios);

solverLogFolder = fullfile(config.resultsFolder, 'solver_logs');
if ~exist(solverLogFolder, 'dir')
    mkdir(solverLogFolder);
end

fprintf('\nS06 - TVAL3 reconstruction.\n');
fprintf(['Parameters: mu=%g, beta=%g, tol=%.1e, maxit=%d, ' ...
    'maxcnt=%d, TVnorm=%d, nonneg=%d, TVL2=%d\n'], ...
    options.mu, options.beta, options.tol, options.maxit, ...
    options.maxcnt, options.TVnorm, options.nonneg, options.TVL2);
fprintf('Detailed TVAL3 solver output is saved under results/solver_logs.\n\n');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);

    %% Step 1 - Use the same first M Hadamard measurements
    b = yFull(1:M);

    %% Step 2 - Give TVAL3 the forward/adjoint Hadamard operator
    A_M = @(x, mode) gcss_prefix_operator( ...
        x, mode, Hseq, gcssLinearIndex, M, N);

    %% Step 3 - Solve the total-variation reconstruction
    lastwarn('');
    solverTimer = tic;

    [solverConsoleText, Xtval3, solverOutput] = evalc( ...
        'TVAL3(A_M, b, n, n, options)');

    solverSeconds(r) = toc(solverTimer);
    [warningMessage, warningId] = lastwarn;

    logFile = fullfile(solverLogFolder, ...
        sprintf('tval3_%03g_percent.txt', samplingPercent));
    fid = fopen(logFile, 'w');
    if fid ~= -1
        fwrite(fid, solverConsoleText);
        fclose(fid);
    end

    Xtval3 = double(Xtval3);

    assert(isequal(size(Xtval3), [n n]), ...
        'TVAL3 returned an image with an unexpected size.');
    assert(all(isfinite(Xtval3), 'all'), ...
        'TVAL3 returned non-finite values.');

    %% Step 4 - Record solver diagnostics
    predictedMeasurements = A_M(Xtval3(:), 1);
    finalRelativeMeasurementResiduals(r) = ...
        norm(predictedMeasurements - b) / max(norm(b), eps);

    if isfield(solverOutput, 'itr') && ~isempty(solverOutput.itr)
        reportedIterations = solverOutput.itr(end);

        % TVAL3 initializes out.itr = Inf and replaces it with a finite
        % iteration count only when its stopping criterion is reached.
        % Therefore Inf means that the solver returned after exhausting
        % options.maxit, not that an infinite number of iterations occurred.
        if isfinite(reportedIterations)
            iterations(r) = reportedIterations;
            convergenceStatus(r) = "stopping criterion reached";
        else
            iterations(r) = options.maxit;
            convergenceStatus(r) = "maximum iteration limit reached";
        end
    else
        convergenceStatus(r) = "iteration status not reported";
    end
    if isfield(solverOutput, 'reer') && ~isempty(solverOutput.reer)
        finalRelativeChanges(r) = solverOutput.reer(end);
    end
    if isfield(solverOutput, 'obj') && ~isempty(solverOutput.obj)
        finalObjectives(r) = solverOutput.obj(end);
    end

    warningIds(r) = string(warningId);
    warningMessages(r) = string(warningMessage);
    tval3Reconstructions(:, :, r) = Xtval3;

    fprintf(['  %5.1f %%: M=%5d | solver %.3f s | iterations %g | ' ...
        '%s | relative residual %.3e\n'], ...
        samplingPercent, M, solverSeconds(r), iterations(r), ...
        convergenceStatus(r), finalRelativeMeasurementResiduals(r));
end

%% Save reconstructions and benchmark settings
methodLabel = 'TVAL3';
implementation = 'TVAL3 beta 2.4';
tvType = 'anisotropic';
nonnegativity = true;
parameterScope = 'fixed across sampling ratios; benchmark-specific';

outputFile = fullfile(config.resultsFolder, ...
    'tval3_reconstructions.mat');

save(outputFile, ...
    'tval3Reconstructions', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'solverSeconds', 'iterations', 'convergenceStatus', ...
    'finalRelativeChanges', 'finalObjectives', ...
    'finalRelativeMeasurementResiduals', ...
    'warningIds', 'warningMessages', ...
    'options', 'methodLabel', 'implementation', ...
    'tvType', 'nonnegativity', 'parameterScope', ...
    'n', 'N', 'ordering');

fprintf('\nOutput: %s\n\n', outputFile);
end

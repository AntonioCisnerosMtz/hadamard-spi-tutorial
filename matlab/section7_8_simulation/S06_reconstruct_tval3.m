function S06_reconstruct_tval3()
%% S06 - Reconstruct the simulated measurements with TVAL3
% TVAL3 reconstructs an image by promoting low total variation while
% enforcing agreement with the measured Hadamard coefficients.
%
% The release configuration uses isotropic TV and nonnegative images. The
% complete option set below is fixed to reproduce the revised tutorial
% benchmark; it is not a universal tuning recommendation.

config = section7_8_config();
addpath(config.functionsFolder);

measurementFile = fullfile(config.resultsFolder, 'hadamard_measurements.mat');
if exist(measurementFile, 'file') ~= 2
    error('Run S02_generate_hadamard_measurements first.');
end

data = load(measurementFile, 'Hseq', 'gcssLinearIndex', 'yFull', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', 'n', 'N', 'ordering');
Hseq = data.Hseq;
gcssLinearIndex = data.gcssLinearIndex;
yFull = data.yFull;
samplingPercents = double(data.samplingPercents(:).');
Mvalues = double(data.Mvalues(:).');
actualSamplingRatios = double(data.actualSamplingRatios(:).');
n = double(data.n);
N = double(data.N);
ordering = data.ordering;

%% TVAL3 settings used for the revised tutorial benchmark
options = struct();
options.mu         = 256;
options.beta       = 32;
options.TVnorm     = 2;      % isotropic total variation
options.nonneg     = true;   % nonnegative reconstructed image
options.TVL2       = false;  % equality-constrained TV model
options.tol        = 1e-6;   % outer relative-change stopping control
options.maxcnt     = 50;
options.tol_inn    = 1e-3;
options.maxit      = 300;
options.init       = 1;
options.scale_A    = true;
options.scale_b    = true;
options.consist_mu = false;
options.mu0        = 256;
options.beta0      = 32;
options.rate_ctn   = 2;
options.c          = 1e-5;
options.gamma      = 0.6;
options.gam        = 0.9995;
options.rate_gam   = 0.9;
options.tau        = 1.8;
options.isreal     = false;
options.disp       = false;

%% Make the preserved TVAL3 implementation visible to MATLAB
tval3Folder = fullfile(config.projectFolder, 'third_party', 'TVAL3_beta2.4');
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
continuationUpdates = zeros(1, numRatios);
terminationStatus = strings(1, numRatios);
finalRelativeChanges = NaN(1, numRatios);
finalObjectives = NaN(1, numRatios);
finalRelativeMeasurementResiduals = NaN(1, numRatios);
warningIds = strings(1, numRatios);
warningMessages = strings(1, numRatios);

solverLogFolder = fullfile(config.resultsFolder, 'solver_logs');
if ~exist(solverLogFolder, 'dir'), mkdir(solverLogFolder); end

fprintf('\nS06 - TVAL3 reconstruction.\n');
fprintf('Isotropic TV, nonnegative image, outer tol %.1e, maxcnt %d, maxit %d.\n', ...
    options.tol, options.maxcnt, options.maxit);
fprintf('The outer tol is not a measurement-residual tolerance.\n\n');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);
    b = yFull(1:M);
    A_M = @(x, mode) gcss_prefix_operator(x, mode, Hseq, gcssLinearIndex, M, N);

    lastwarn('');
    solverTimer = tic;
    [solverConsoleText, Xtval3, solverOutput] = evalc('TVAL3(A_M, b, n, n, options)');
    solverSeconds(r) = toc(solverTimer);
    [warningMessage, warningId] = lastwarn;

    logFile = fullfile(solverLogFolder, sprintf('tval3_%03g_percent.txt', samplingPercent));
    fid = fopen(logFile, 'w');
    if fid ~= -1, fwrite(fid, solverConsoleText); fclose(fid); end

    Xtval3 = double(Xtval3);
    assert(isequal(size(Xtval3), [n n]), 'TVAL3 returned an image with an unexpected size.');
    assert(all(isfinite(Xtval3), 'all'), 'TVAL3 returned non-finite values.');

    predictedMeasurements = A_M(Xtval3(:), 1);
    finalRelativeMeasurementResiduals(r) = norm(predictedMeasurements - b) / max(norm(b), eps);

    [iterations(r), continuationUpdates(r), terminationStatus(r), ...
        finalRelativeChanges(r), finalObjectives(r)] = ...
        summarize_tval3_output(solverOutput, options);

    warningIds(r) = string(warningId);
    warningMessages(r) = string(warningMessage);
    tval3Reconstructions(:, :, r) = Xtval3;

    fprintf('  %5.1f %%: M=%5d | %.3f s | %s | relative residual %.3e\n', ...
        samplingPercent, M, solverSeconds(r), terminationStatus(r), ...
        finalRelativeMeasurementResiduals(r));
end

methodLabel = 'TVAL3';
implementation = 'TVAL3 beta 2.4';
tvType = 'isotropic';
nonnegativity = true;
parameterScope = 'fixed across sampling ratios; tutorial benchmark-specific';
outputFile = fullfile(config.resultsFolder, 'tval3_reconstructions.mat');
save(outputFile, 'tval3Reconstructions', 'samplingPercents', 'Mvalues', ...
    'actualSamplingRatios', 'solverSeconds', 'iterations', ...
    'continuationUpdates', 'terminationStatus', 'finalRelativeChanges', ...
    'finalObjectives', 'finalRelativeMeasurementResiduals', 'warningIds', ...
    'warningMessages', 'options', 'methodLabel', 'implementation', 'tvType', ...
    'nonnegativity', 'parameterScope', 'n', 'N', 'ordering');
fprintf('\nOutput: %s\n\n', outputFile);
end

function [iterationCount, continuationCount, cause, finalRelChange, finalObjective] = summarize_tval3_output(out, options)
iterationCount = NaN;
continuationCount = 0;
finalRelChange = NaN;
finalObjective = NaN;
if isfield(out, 'itrs') && ~isempty(out.itrs)
    continuationCount = numel(out.itrs);
    iterationCount = sum(double(out.itrs(:)));
elseif isfield(out, 'itr') && ~isempty(out.itr) && isfinite(out.itr(end))
    iterationCount = double(out.itr(end));
end
if isfield(out, 'reer') && ~isempty(out.reer), finalRelChange = double(out.reer(end)); end
if isfield(out, 'obj') && ~isempty(out.obj), finalObjective = double(out.obj(end)); end
if isfinite(finalRelChange) && finalRelChange < options.tol
    cause = "outer relative-change tolerance reached";
elseif continuationCount >= options.maxcnt
    cause = "maximum continuation updates reached";
elseif isfield(out, 'itr') && ~isempty(out.itr) && isinf(out.itr(end))
    iterationCount = options.maxit;
    cause = "maximum iteration limit reached";
else
    cause = "solver returned without a classified limit";
end
end

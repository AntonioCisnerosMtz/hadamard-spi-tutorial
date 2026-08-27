function S07_reconstruct_tv_qc()
%% S07 - Reconstruct the simulated measurements with TV-QC
% TV-QC minimizes total variation while allowing the predicted measurements
% to remain inside an l2 data-fidelity ball:
%
%       minimize TV(X)
%       subject to ||A_M x - b||_2 <= epsilon.
%
% The implementation used here is L1-Magic's tvqc_logbarrier.
%
% The measurement operator is the same first-M GCS+S Hadamard operator used
% by the other methods. As in the canonical benchmark, A_M and b are scaled
% by 1/sqrt(N) before they are passed to the solver.
%
% L1-Magic is an external dependency and is not redistributed in the final
% reader-facing release.

config = section7_8_config();
addpath(config.functionsFolder);

measurementFile = fullfile(config.resultsFolder, ...
    'hadamard_measurements.mat');
if exist(measurementFile, 'file') ~= 2
    error('Run S02_generate_hadamard_measurements first.');
end

%% Locate the external L1-Magic dependency
optimizationFolder = fullfile(config.l1magicFolder, 'Optimization');

requiredFiles = { ...
    'tvqc_logbarrier.m', ...
    'tvqc_newton.m', ...
    'cgsolve.m'};

dependencyComplete = true;
for k = 1:numel(requiredFiles)
    if exist(fullfile(optimizationFolder, requiredFiles{k}), 'file') ~= 2
        dependencyComplete = false;
    end
end

if ~dependencyComplete
    fprintf('\nS07 - TV-QC SKIPPED.\n');
    fprintf('L1-Magic TV-QC files were not found in:\n%s\n', ...
        optimizationFolder);
    fprintf('See external_dependencies/README.md.\n\n');
    return;
end

addpath(optimizationFolder, '-begin');

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

%% TV-QC settings used in the manuscript benchmark
epsilonRelative = 1e-4;
epsilonAbsoluteFloor = 1e-10;
lbtol = 1e-3;
mu = 10;
cgtol = 1e-4;
cgmaxiter = 200;

% No nonnegativity constraint is imposed in this TV-QC route.

numRatios = numel(samplingPercents);
tvqcReconstructions = zeros(n, n, numRatios);
solverSeconds = zeros(1, numRatios);
epsilonValues = zeros(1, numRatios);
finalRelativeResiduals = zeros(1, numRatios);
finalObjectives = zeros(1, numRatios);
totalNewtonIterations = NaN(1, numRatios);
totalCgIterations = NaN(1, numRatios);
maximumCgIterations = NaN(1, numRatios);

solverLogFolder = fullfile(config.resultsFolder, 'solver_logs');
if ~exist(solverLogFolder, 'dir')
    mkdir(solverLogFolder);
end

fprintf('\nS07 - TV-QC reconstruction with L1-Magic.\n');
fprintf(['Parameters: epsilonRel=%.1e, lbtol=%.1e, mu=%g, ' ...
    'cgtol=%.1e, cgmaxiter=%d\n'], ...
    epsilonRelative, lbtol, mu, cgtol, cgmaxiter);
fprintf('Nonnegativity constraint: none\n');
fprintf('Detailed L1-Magic iteration output is saved under results/solver_logs.\n\n');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);

    %% Step 1 - Scale the first M measurements by 1/sqrt(N)
    scale = sqrt(N);
    b = yFull(1:M) / scale;

    %% Step 2 - Define the normalized forward and adjoint operators
    A_M = @(x) hadamard_prefix_forward( ...
        reshape(x, [n n]), Hseq, gcssLinearIndex, M) / scale;

    At_M = @(z) reshape( ...
        hadamard_prefix_adjoint( ...
            z, Hseq, gcssLinearIndex, M, N), ...
        [], 1) / scale;

    %% Step 3 - Use the adjoint solution as a strictly feasible start
    x0 = At_M(b);

    epsilonValue = max( ...
        epsilonRelative * norm(b), ...
        epsilonAbsoluteFloor);

    initialResidual = norm(A_M(x0) - b);
    assert(initialResidual < epsilonValue, ...
        'TV-QC initial point is not strictly feasible.');

    %% Step 4 - Solve the TV-constrained problem
    solverTimer = tic;

    [solverConsoleText, xHat, tHat] = evalc( ...
        'tvqc_logbarrier(x0, A_M, At_M, b, epsilonValue, lbtol, mu, cgtol, cgmaxiter)');

    solverSeconds(r) = toc(solverTimer);

    logFile = fullfile(solverLogFolder, ...
        sprintf('tv_qc_%03g_percent.txt', samplingPercent));
    fid = fopen(logFile, 'w');
    if fid ~= -1
        fwrite(fid, solverConsoleText);
        fclose(fid);
    end

    %% Step 5 - Restore the 2-D image and record diagnostics
    Xtvqc = reshape(xHat, [n n]);

    finalResidual = norm(A_M(xHat) - b);
    finalRelativeResiduals(r) = finalResidual / max(norm(b), eps);
    finalObjectives(r) = sum(tHat);
    epsilonValues(r) = epsilonValue;

    newtonTotals = regexp(solverConsoleText, ...
        'total newton iter\s*=\s*(\d+)', ...
        'tokens');
    if ~isempty(newtonTotals)
        totalNewtonIterations(r) = ...
            str2double(newtonTotals{end}{1});
    end

    cgMatches = regexp(solverConsoleText, ...
        'CG Iter\s*=\s*(\d+)', ...
        'tokens');
    if ~isempty(cgMatches)
        cgValues = cellfun(@(c) str2double(c{1}), cgMatches);
        totalCgIterations(r) = sum(cgValues);
        maximumCgIterations(r) = max(cgValues);
    end

    assert(all(isfinite(Xtvqc), 'all'), ...
        'TV-QC reconstruction contains non-finite values.');
    assert(finalResidual <= epsilonValue * (1 + 1e-8), ...
        'TV-QC result does not satisfy the declared data tolerance.');

    tvqcReconstructions(:, :, r) = Xtvqc;

    fprintf(['  %5.1f %%: M=%5d | solver %.3f s | ' ...
        'relative residual %.3e | TV objective %.3f\n'], ...
        samplingPercent, M, solverSeconds(r), ...
        finalRelativeResiduals(r), finalObjectives(r));
end

%% Save reconstructions and benchmark settings
methodLabel = 'TV-QC';
implementation = 'L1-Magic 1.11 tvqc_logbarrier';
tvType = 'isotropic TV-QC as implemented by L1-Magic';
nonnegativity = false;
parameterScope = 'fixed across sampling ratios; benchmark-specific';

outputFile = fullfile(config.resultsFolder, ...
    'tv_qc_reconstructions.mat');

save(outputFile, ...
    'tvqcReconstructions', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'solverSeconds', 'epsilonValues', ...
    'finalRelativeResiduals', 'finalObjectives', ...
    'totalNewtonIterations', 'totalCgIterations', ...
    'maximumCgIterations', ...
    'epsilonRelative', 'epsilonAbsoluteFloor', ...
    'lbtol', 'mu', 'cgtol', 'cgmaxiter', ...
    'methodLabel', 'implementation', 'tvType', ...
    'nonnegativity', 'parameterScope', ...
    'n', 'N', 'ordering');

fprintf('\nOutput: %s\n\n', outputFile);
end

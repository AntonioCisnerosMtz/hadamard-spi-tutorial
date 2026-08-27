function S05_reconstruct_dct_l1()
%% S05 - Reconstruct the simulated measurements with DCT-l1
% This method assumes that the image can be represented by a sparse set of
% coefficients in an orthonormal 2-D DCT basis.
%
% The unknown is the DCT coefficient vector alpha. L1-Magic solves
%
%       minimize ||alpha||_1
%       subject to ||B(alpha) - b||_2 <= epsilon.
%
% B first synthesizes an image from alpha and then applies the first M
% GCS+S Hadamard measurements.
%
% L1-Magic is an external dependency and is NOT redistributed in the final
% reader-facing release. See external_dependencies/README.md.

config = section7_8_config();
addpath(config.functionsFolder);

measurementFile = fullfile(config.resultsFolder, ...
    'hadamard_measurements.mat');
if exist(measurementFile, 'file') ~= 2
    error('Run S02_generate_hadamard_measurements first.');
end

%% Locate the external L1-Magic dependency
l1magicFolder = config.l1magicFolder;
optimizationFolder = fullfile(l1magicFolder, 'Optimization');

requiredFiles = { ...
    'l1qc_logbarrier.m', ...
    'l1qc_newton.m', ...
    'cgsolve.m'};

dependencyComplete = true;
for k = 1:numel(requiredFiles)
    if exist(fullfile(optimizationFolder, requiredFiles{k}), 'file') ~= 2
        dependencyComplete = false;
    end
end

if ~dependencyComplete
    fprintf('\nS05 - DCT-l1 SKIPPED.\n');
    fprintf('L1-Magic 1.11 was not found in:\n%s\n', optimizationFolder);
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

%% DCT-l1 settings used in the manuscript benchmark
epsilonRelative = 1e-4;
epsilonAbsoluteFloor = 1e-10;
lbtol = 1e-3;
mu = 10;
cgtol = 1e-4;
cgmaxiter = 200;

% No nonnegativity constraint was used for DCT-l1.

%% Build the orthonormal DCT-II basis
D = orthonormal_dct_matrix(n);

numRatios = numel(samplingPercents);
dctL1Reconstructions = zeros(n, n, numRatios);
solverSeconds = zeros(1, numRatios);
epsilonValues = zeros(1, numRatios);
finalRelativeResiduals = zeros(1, numRatios);
finalL1Objectives = zeros(1, numRatios);
solverConsoleCharacters = zeros(1, numRatios);

solverLogFolder = fullfile(config.resultsFolder, 'solver_logs');
if ~exist(solverLogFolder, 'dir')
    mkdir(solverLogFolder);
end

fprintf('\nS05 - DCT-l1 reconstruction with L1-Magic.\n');
fprintf('Representation: orthonormal 2-D DCT-II\n');
fprintf(['Parameters: epsilonRel=%.1e, lbtol=%.1e, mu=%g, ' ...
    'cgtol=%.1e, cgmaxiter=%d\n'], ...
    epsilonRelative, lbtol, mu, cgtol, cgmaxiter);
fprintf('Nonnegativity constraint: none\n');
fprintf('Detailed L1-Magic iteration output is saved under results/solver_logs.\n\n');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);

    %% Step 1 - Use the same first M Hadamard measurements
    scale = sqrt(N);
    b = yFull(1:M) / scale;

    %% Step 2 - Define the forward operator in the DCT coefficient domain
    B = @(alpha) hadamard_prefix_forward( ...
        dct_synthesis(alpha, D, n), ...
        Hseq, gcssLinearIndex, M) / scale;

    %% Step 3 - Define the adjoint operator
    Bt = @(z) dct_analysis( ...
        hadamard_prefix_adjoint( ...
            z, Hseq, gcssLinearIndex, M, N), ...
        D) / scale;

    %% Step 4 - Choose the feasible starting point and data tolerance
    alpha0 = Bt(b);

    epsilonValue = max( ...
        epsilonRelative * norm(b), ...
        epsilonAbsoluteFloor);

    initialResidual = norm(B(alpha0) - b);
    assert(initialResidual < epsilonValue, ...
        'DCT-l1 initial point is not strictly feasible.');

    %% Step 5 - Solve the l1-constrained reconstruction
    % L1-Magic prints every Newton/CG iteration. Capture that verbose output
    % so the normal tutorial run remains readable while the full solver log
    % is still preserved for auditing.
    solverTimer = tic;

    [solverConsoleText, alphaHat] = evalc( ...
        'l1qc_logbarrier(alpha0, B, Bt, b, epsilonValue, lbtol, mu, cgtol, cgmaxiter)');

    solverSeconds(r) = toc(solverTimer);

    logFile = fullfile(solverLogFolder, ...
        sprintf('dct_l1_%03g_percent.txt', samplingPercent));
    fid = fopen(logFile, 'w');
    if fid ~= -1
        fwrite(fid, solverConsoleText);
        fclose(fid);
    end

    %% Step 6 - Synthesize the reconstructed image
    XdctL1 = dct_synthesis(alphaHat, D, n);

    finalResidual = norm(B(alphaHat) - b);
    finalRelativeResiduals(r) = finalResidual / max(norm(b), eps);
    epsilonValues(r) = epsilonValue;
    finalL1Objectives(r) = sum(abs(alphaHat));
    solverConsoleCharacters(r) = strlength(string(solverConsoleText));

    assert(all(isfinite(XdctL1), 'all'), ...
        'DCT-l1 reconstruction contains non-finite values.');
    assert(finalResidual <= epsilonValue * (1 + 1e-8), ...
        'DCT-l1 result does not satisfy the declared data tolerance.');

    dctL1Reconstructions(:, :, r) = XdctL1;

    fprintf(['  %5.1f %%: M=%5d | solver %.3f s | ' ...
        'relative residual %.3e | ||alpha||_1 %.3f\n'], ...
        samplingPercent, M, solverSeconds(r), ...
        finalRelativeResiduals(r), finalL1Objectives(r));
end

%% Save the reconstructions and solver settings
methodLabel = 'DCT-l1';
implementation = 'L1-Magic 1.11 l1qc_logbarrier';
representation = 'orthonormal 2-D DCT-II';
nonnegativity = false;
parameterScope = 'fixed across sampling ratios; benchmark-specific';

outputFile = fullfile(config.resultsFolder, ...
    'dct_l1_reconstructions.mat');

save(outputFile, ...
    'dctL1Reconstructions', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'solverSeconds', 'epsilonValues', 'finalRelativeResiduals', ...
    'finalL1Objectives', 'solverConsoleCharacters', ...
    'epsilonRelative', 'epsilonAbsoluteFloor', ...
    'lbtol', 'mu', 'cgtol', 'cgmaxiter', ...
    'methodLabel', 'implementation', 'representation', ...
    'nonnegativity', 'parameterScope', ...
    'n', 'N', 'ordering');

fprintf('\nOutput: %s\n\n', outputFile);
end

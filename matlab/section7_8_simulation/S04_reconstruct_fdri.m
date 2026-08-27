function S04_reconstruct_fdri()
%% S04 - Reconstruct the simulated measurements with FDRI
% FDRI first constructs a reusable reconstruction matrix P_M and then applies
% it with:
%
%                         x = P_M * y
%
% The external FDRI package is intentionally not bundled. Run
% INSTALL_EXTERNAL_DEPENDENCIES.m and select the ZIP downloaded from the
% public FDRI repository.

config = section7_8_config();

measurementFile = fullfile(config.resultsFolder, ...
    'hadamard_measurements.mat');
if exist(measurementFile, 'file') ~= 2
    error('Run S02_generate_hadamard_measurements first.');
end

fdriFolder = config.fdriFolder;
wrapperFile = fullfile(fdriFolder, ...
    'fdri_public_wrapper_cpu_gcss_v01.m');
originalFdriFile = fullfile(fdriFolder, 'private', 'fdri.m');

if exist(wrapperFile, 'file') ~= 2 || exist(originalFdriFile, 'file') ~= 2
    fprintf('\nS04 - FDRI SKIPPED.\n');
    fprintf('FDRI has not been installed in:\n%s\n', fdriFolder);
    fprintf('Run INSTALL_EXTERNAL_DEPENDENCIES.m.\n\n');
    return;
end

addpath(fdriFolder, '-begin');

data = load(measurementFile, ...
    'Hseq', 'gcssCoordinates', 'yFull', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'n', 'N', 'ordering');

Hseq = data.Hseq;
gcssCoordinates = data.gcssCoordinates;
yFull = data.yFull;
samplingPercents = double(data.samplingPercents(:).');
Mvalues = double(data.Mvalues(:).');
actualSamplingRatios = double(data.actualSamplingRatios(:).');
n = double(data.n);
N = double(data.N);
ordering = data.ordering;

%% Benchmark settings used in the tutorial
mi = 0.5;
ep = 1e-5;
method = 0;

numRatios = numel(samplingPercents);
fdriReconstructions = zeros(n, n, numRatios);
measurementMatrixBuildSeconds = zeros(1, numRatios);
fdriSetupSeconds = zeros(1, numRatios);
fdriApplicationSeconds = zeros(1, numRatios);

fprintf('\nS04 - FDRI reconstruction.\n');
fprintf('Parameters: mi=%.3g, ep=%.1e, method=%d\n', mi, ep, method);
fprintf('Setup and per-image application are timed separately.\n\n');

XrefData = load(fullfile(config.resultsFolder, ...
    'reference_image.mat'), 'Xref');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);
    y = yFull(1:M);

    %% Step 1 - Build explicit A_M
    matrixTimer = tic;

    A_M = zeros(M, N);
    for k = 1:M
        u = gcssCoordinates(k, 1);
        v = gcssCoordinates(k, 2);
        A_M(k, :) = kron(Hseq(v, :), Hseq(u, :));
    end

    measurementMatrixBuildSeconds(r) = toc(matrixTimer);

    yCheck = A_M * XrefData.Xref(:);
    conventionError = norm(yCheck - y) / max(norm(y), eps);
    assert(conventionError <= 1e-12, ...
        'FDRI A_M does not match the S02 measurement convention.');

    %% Step 2 - Build reusable P_M
    setupTimer = tic;
    P_M = fdri_public_wrapper_cpu_gcss_v01( ...
        A_M, n, n, mi, ep, method);
    fdriSetupSeconds(r) = toc(setupTimer);

    assert(all(isfinite(P_M), 'all'), ...
        'FDRI precomputation produced non-finite values.');

    %% Step 3 - Apply P_M
    applicationTimer = tic;
    Xfdri = reshape(P_M * y, [n n]);
    fdriApplicationSeconds(r) = toc(applicationTimer);

    assert(all(isfinite(Xfdri), 'all'), ...
        'FDRI reconstruction contains non-finite values.');

    fdriReconstructions(:, :, r) = Xfdri;

    fprintf(['  %5.1f %%: M=%5d | A_M %.3f s | ' ...
        'P_M setup %.3f s | P_M*y %.4f s\n'], ...
        samplingPercent, M, ...
        measurementMatrixBuildSeconds(r), ...
        fdriSetupSeconds(r), ...
        fdriApplicationSeconds(r));

    clear A_M P_M
end

methodLabel = 'FDRI';
implementation = 'external public FDRI MATLAB/Octave package';
parameterScope = 'fixed across sampling ratios; tutorial benchmark settings';

outputFile = fullfile(config.resultsFolder, ...
    'fdri_reconstructions.mat');

save(outputFile, ...
    'fdriReconstructions', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'measurementMatrixBuildSeconds', ...
    'fdriSetupSeconds', 'fdriApplicationSeconds', ...
    'mi', 'ep', 'method', 'methodLabel', ...
    'implementation', 'parameterScope', ...
    'n', 'N', 'ordering');

fprintf('\nOutput: %s\n\n', outputFile);
end

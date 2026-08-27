function S03_reconstruct_direct()
%% S03 - Reconstruct the simulated measurements with the Direct inverse
% This module implements the separable Direct reconstruction from Section 7.
%
% For each requested sampling ratio:
%   1. keep the first M measurements in GCS+S order;
%   2. place zeros at all unmeasured Hadamard coefficients;
%   3. restore the n x n coefficient array C_M;
%   4. evaluate
%
%          Xdirect = (Hseq^T * C_M * Hseq) / N.
%
% The zeros are placeholders for unmeasured coefficients. They are not
% estimates of the missing coefficients.

config = section7_8_config();

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

assert(isequal(size(Hseq), [n n]), ...
    'The Hadamard matrix in hadamard_measurements.mat has the wrong size.');
assert(numel(yFull) == N, ...
    'The complete measurement vector yFull must contain N coefficients.');
assert(numel(gcssLinearIndex) == N, ...
    'The GCS+S index must contain exactly N coefficient positions.');

numRatios = numel(samplingPercents);
directReconstructions = zeros(n, n, numRatios);

fprintf('\nS03 - Direct separable reconstruction.\n');
fprintf('Ordering: %s\n', ordering);
fprintf('Unmeasured coefficient policy: zero\n\n');

for r = 1:numRatios
    samplingPercent = samplingPercents(r);
    M = Mvalues(r);

    %% Step 1 - Keep the first M measured Hadamard coefficients
    y = yFull(1:M);

    %% Step 2 - Zero-fill the unmeasured coefficient positions
    y_zf = zeros(N, 1);
    y_zf(1:M) = y;

    %% Step 3 - Restore the complete n x n Hadamard coefficient array
    C_M = zeros(n, n);
    C_M(gcssLinearIndex) = y_zf;

    %% Step 4 - Apply the separable Direct inverse
    % This line mirrors the equation in the tutorial:
    %
    %          Xdirect = (Hseq^T * C_M * Hseq) / N
    %
    Xdirect = (Hseq.' * C_M * Hseq) / N;

    assert(all(isfinite(Xdirect), 'all'), ...
        'Direct reconstruction contains non-finite values.');

    directReconstructions(:, :, r) = Xdirect;

    fprintf('  %5.1f %%: M=%5d -> reconstructed %d x %d image\n', ...
        samplingPercent, M, n, n);
end

%% Save the reconstructed images and the settings needed to interpret them
method = 'Direct separable';
unmeasuredCoefficientPolicy = 'zero';
inverseNormalization = '1/N';

outputFile = fullfile(config.resultsFolder, ...
    'direct_reconstructions.mat');

save(outputFile, ...
    'directReconstructions', ...
    'samplingPercents', 'Mvalues', 'actualSamplingRatios', ...
    'n', 'N', 'ordering', 'method', ...
    'unmeasuredCoefficientPolicy', 'inverseNormalization');

fprintf('\nOutput: %s\n\n', outputFile);
end

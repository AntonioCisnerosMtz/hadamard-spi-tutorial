function S02_generate_hadamard_measurements(samplingPercents)
%% S02 - Generate GCS+S-ordered Hadamard measurements
% This module makes the forward model visible:
%
%   known image Xref
%        -> 2-D Hadamard coefficient array Cfull
%        -> GCS+S coefficient order yFull
%        -> first M measurements for each requested sampling percentage
%
% Every reconstruction method uses a common prefix of the SAME yFull vector.

if nargin < 1 || isempty(samplingPercents)
    samplingPercents = [5 20 50];
end

samplingPercents = double(samplingPercents(:).');
if any(~isfinite(samplingPercents)) || ...
        any(samplingPercents <= 0) || any(samplingPercents > 100)
    error('samplingPercents must contain finite values greater than 0 and at most 100.');
end

config = section7_8_config();
addpath(config.functionsFolder);

referenceFile = fullfile(config.resultsFolder, 'reference_image.mat');
if exist(referenceFile, 'file') ~= 2
    error('Run S01_prepare_reference_image first.');
end

referenceData = load(referenceFile, 'Xref', 'n', 'N');
Xref = referenceData.Xref;
n = double(referenceData.n);
N = double(referenceData.N);

assert(isequal(size(Xref), [n n]), ...
    'reference_image.mat does not contain an n-by-n Xref image.');
assert(N == n^2, 'reference_image.mat contains inconsistent n and N values.');

%% Step 1 - Build the one-dimensional sequency Hadamard basis
Hseq = sequency_hadamard(n);

%% Step 2 - Compute the complete two-dimensional Hadamard coefficient array
% This is the separable 2-D transform used throughout the tutorial:
%
%                 Cfull = Hseq * Xref * Hseq^T
%
Cfull = Hseq * Xref * Hseq.';

%% Step 3 - Read the coefficients in GCS+S order
[gcssLinearIndex, gcssCoordinates] = gcss_order(n);
yFull = Cfull(gcssLinearIndex);
yFull = yFull(:);

%% Step 4 - Keep the first M coefficients for each requested percentage
numRatios = numel(samplingPercents);
Mvalues = zeros(1, numRatios);
actualSamplingRatios = zeros(1, numRatios);

for r = 1:numRatios
    samplingPercent = samplingPercents(r);

    % M must be an integer, so the actual retained fraction may differ very
    % slightly from the nominal percentage printed in a figure or table.
    M = round((samplingPercent / 100) * N);
    M = max(1, min(N, M));

    Mvalues(r) = M;
    actualSamplingRatios(r) = M / N;
end

%% Save one complete ordered vector instead of duplicating every prefix
% Later reconstruction modules use yFull(1:M). This makes it explicit that
% all methods and all sampling ratios share the same ordered measurement data.
ordering = config.measurementOrdering;
retentionPolicy = 'common ordered prefix';
measurementNoise = config.measurementNoise;

outputFile = fullfile(config.resultsFolder, 'hadamard_measurements.mat');
save(outputFile, 'Hseq', 'gcssLinearIndex', 'gcssCoordinates', ...
    'Cfull', 'yFull', 'samplingPercents', 'Mvalues', ...
    'actualSamplingRatios', 'n', 'N', 'ordering', ...
    'retentionPolicy', 'measurementNoise');

%% Report the retained measurement counts
fprintf('\nS02 - Hadamard measurements generated.\n');
fprintf('Ordering: %s\n', ordering);
fprintf('Complete measurement count N: %d\n', N);
fprintf('Artificial measurement noise: none\n\n');
fprintf(' Nominal sampling    M retained    Actual sampling\n');
fprintf(' ----------------    ----------    ---------------\n');
for r = 1:numRatios
    fprintf(' %7.2f %%          %6d        %8.4f %%\n', ...
        samplingPercents(r), Mvalues(r), 100*actualSamplingRatios(r));
end
fprintf('\nOutput: %s\n\n', outputFile);
end

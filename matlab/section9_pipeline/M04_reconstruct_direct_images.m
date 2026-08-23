function M04_reconstruct_direct_images(selectedDataset)
%% Reconstruct the measurement vectors with the Direct Hadamard inverse
% This script follows the separable Direct reconstruction in Section 7.
% For each sampling ratio and measurement formulation:
%   1. keep the first M measurements in GCS+S order;
%   2. set every unmeasured Hadamard coefficient to zero;
%   3. place the N coefficients in the n x n grid C_M;
%   4. evaluate
%          X_direct = (H_n^T * C_M * H_n) / N.
%
% No normalization, clipping, filtering, hot-pixel removal, or display
% scaling is applied to the numerical reconstruction.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end
selectedDataset = string(selectedDataset);

%% Locate files and project functions
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
addpath(fullfile(scriptFolder, 'functions'));
config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;
resultsFolder = config.resultsFolder;
measurementFile = fullfile(resultsFolder, 'measurement_vectors.mat');
manifestFile = config.patternManifestFile;
outputFile = fullfile(resultsFolder, 'direct_reconstructions.mat');

assert(exist(measurementFile, 'file') == 2, ...
    'Run M03_form_measurement_vectors(selectedDataset) first.');
assert(exist(manifestFile, 'file') == 2, ...
    'pattern_manifest.csv was not found in the data folder.');

%% Load the selected measurement vectors
inputData = load(measurementFile, 'measurementCases', ...
    'measurementTypes', 'samplingPercents', 'N', 'selectedDataset');
assert(isfield(inputData, 'selectedDataset') && ...
    string(inputData.selectedDataset) == selectedDataset, ...
    'measurement_vectors.mat belongs to a different dataset. Rerun M03.');
measurementCases = inputData.measurementCases;
measurementTypes = string(inputData.measurementTypes(:).');
samplingPercents = double(inputData.samplingPercents(:).');
N = double(inputData.N);

numRatios = numel(samplingPercents);
numTypes = numel(measurementTypes);

% N = n^2 for the square reconstruction grid.
n = round(sqrt(N));
assert(n*n == N, 'N must be a perfect square.');

%% Recover the GCS+S coefficient positions from the manifest
patternManifest = readtable(manifestFile);
requiredColumns = {'sequence_index','u','v'};
assert(all(ismember(requiredColumns, patternManifest.Properties.VariableNames)), ...
    'pattern_manifest.csv must contain sequence_index, u, and v.');
assert(height(patternManifest) == N, ...
    'pattern_manifest.csv must contain exactly N rows.');

sequenceIndex = double(patternManifest.sequence_index(:));
u = double(patternManifest.u(:));
v = double(patternManifest.v(:));
assert(isequal(sequenceIndex, (1:N).'), ...
    'The manifest sequence indices must run from 1 to N.');

gcssLinearIndex = sub2ind([n n], u, v);
assert(isequal(sort(gcssLinearIndex), (1:N).'), ...
    'The GCS+S coordinates must visit every coefficient exactly once.');

% Hseq is H_n^seq from the tutorial.
Hseq = sequency_hadamard(n);

resultTemplate = struct( ...
    'samplingPercent', [], ...
    'measurementType', "", ...
    'reconstructedImage', [], ...
    'reconstructionInfo', []);
directResults = repmat(resultTemplate, numRatios, numTypes);

%% Direct reconstruction for every selected case
for r = 1:numRatios
    M = double(measurementCases(r).M);

    for t = 1:numTypes
        measurementType = measurementTypes(t);
        y = measurementCases(r).(char(measurementType));
        y = y(:);

        % y_zf^(M): measured coefficients followed by zeros. The zeros are
        % placeholders for unmeasured coefficients; they are not estimates.
        y_zf = zeros(N, 1);
        y_zf(1:M) = y;

        % C_M: complete n x n Hadamard-coefficient grid in the same GCS+S
        % coordinate convention used to generate the DMD patterns.
        C_M = zeros(n, n);
        C_M(gcssLinearIndex) = y_zf;

        % Section 7 separable inverse:
        %       X_direct = (H_n^T * C_M * H_n) / N
        Xdirect = (Hseq.' * C_M * Hseq) / N;

        assert(all(isfinite(Xdirect), 'all'), ...
            'Direct reconstruction contains non-finite values.');

        reconstructionInfo = struct();
        reconstructionInfo.method = "Direct";
        reconstructionInfo.measurementType = measurementType;
        reconstructionInfo.ordering = "GCS+S";
        reconstructionInfo.imageSideLength = n;
        reconstructionInfo.N = N;
        reconstructionInfo.M = M;
        reconstructionInfo.nominalSamplingRatio = ...
            double(measurementCases(r).samplingRatio);
        reconstructionInfo.actualSamplingRatio = M / N;
        reconstructionInfo.unmeasuredCoefficientPolicy = "zero";
        reconstructionInfo.inverseNormalization = "1/N";

        directResults(r,t).samplingPercent = samplingPercents(r);
        directResults(r,t).measurementType = measurementType;
        directResults(r,t).reconstructedImage = Xdirect;
        directResults(r,t).reconstructionInfo = reconstructionInfo;
    end

    fprintf('Direct: completed %g%% (%d of %d sampling ratios).\n', ...
        samplingPercents(r), r, numRatios);
end

save(outputFile, 'directResults', 'measurementTypes', ...
    'samplingPercents', 'N', 'selectedDataset', '-v7.3');

fprintf('\nDirect reconstruction grid completed for dataset: %s\n', ...
    char(selectedDataset));
fprintf('Images saved: %d.\n', numRatios * numTypes);
fprintf('Output: %s\n', outputFile);
end

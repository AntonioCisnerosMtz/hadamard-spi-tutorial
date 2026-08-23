function M03_form_measurement_vectors(selectedDataset)
%% Form yDiff, yRef, and yAvg for the selected sampling ratios
% This script follows the measurement-vector definitions in Section 3 and
% the sampling-ratio definition in Section 6 of the tutorial.
%
% Tutorial notation -> MATLAB variable
%   y^(+)       -> yPositive
%   y^(-)       -> yComplementary
%   y^diff      -> yDiff
%   y^ref       -> yRef
%   y^avg       -> yAvg
%   rho = M/N   -> samplingRatio
%
% For yAvg, only the first M AVAILABLE positive measurements are averaged.
% Measurements M+1,...,N are never used to form a partial-acquisition case.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end
selectedDataset = string(selectedDataset);

%% Published sampling settings
% Keep this grid unchanged to reproduce the released workflow. Change it
% only when exploring a different sampling schedule.
samplingPercents = 5:5:100;

%% Input and output files
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;
resultsFolder = config.resultsFolder;
inputFile = fullfile(resultsFolder, 'bucket_measurements.mat');
outputFile = fullfile(resultsFolder, 'measurement_vectors.mat');

assert(exist(inputFile, 'file') == 2, ...
    'Input file not found. Run M02_extract_bucket_measurements(selectedDataset) first.');

bucketData = load(inputFile, 'yPositive', 'yComplementary', 'selectedDataset');
assert(isfield(bucketData, 'selectedDataset') && ...
    string(bucketData.selectedDataset) == selectedDataset, ...
    'bucket_measurements.mat belongs to a different dataset. Rerun M02.');
yPositive = bucketData.yPositive(:);
yComplementary = bucketData.yComplementary(:);

assert(numel(yPositive) == numel(yComplementary), ...
    'yPositive and yComplementary must have the same length.');
assert(all(isfinite(yPositive)) && all(isfinite(yComplementary)), ...
    'Bucket measurements must contain only finite values.');

N = numel(yPositive);
yDC = yPositive(1);  % All-one positive mask in the supplied GCS+S sequence.

samplingPercents = double(samplingPercents(:).');
assert(~isempty(samplingPercents) && all(isfinite(samplingPercents)) && ...
    all(samplingPercents > 0 & samplingPercents <= 100), ...
    'samplingPercents must contain values in (0,100].');
assert(numel(unique(samplingPercents)) == numel(samplingPercents), ...
    'samplingPercents must not contain duplicate values.');

measurementTypes = ["yDiff", "yRef", "yAvg"];
numRatios = numel(samplingPercents);

caseTemplate = struct( ...
    'samplingPercent', [], ...
    'samplingRatio', [], ...
    'M', [], ...
    'actualSamplingRatio', [], ...
    'yDiff', [], ...
    'yRef', [], ...
    'yAvg', [], ...
    'yDC', [], ...
    'meanPositive', []);
measurementCases = repmat(caseTemplate, numRatios, 1);

%% Form the three measurement vectors at each sampling ratio
for k = 1:numRatios
    % Section 6: rho = M/N. Here the user specifies rho and M is the nearest
    % integer number of measurements. The complete case is forced to M = N.
    samplingRatio = samplingPercents(k) / 100;
    M = round(samplingRatio * N);
    if samplingPercents(k) == 100
        M = N;
    end

    assert(M >= 1 && M <= N, 'The selected sampling ratio produced invalid M.');

    % Partial acquisition uses the first M measurements in the established
    % GCS+S acquisition order.
    yPositive_M = yPositive(1:M);
    yComplementary_M = yComplementary(1:M);

    % Section 3: complementary differential measurement
    %       y^diff = y^(+) - y^(-)
    yDiff = yPositive_M - yComplementary_M;

    % Section 3: positive-only correction using the all-one DC reference
    %       y_i^ref = 2*y_i^(+) - y_dc
    yRef = 2*yPositive_M - yDC;

    % Section 3: positive-only correction using the available-data mean
    %       ybar^(+) = mean(y_1^(+),...,y_M^(+))
    %       y_i^avg  = 2*(y_i^(+) - ybar^(+))
    meanPositive = mean(yPositive_M);
    yAvg = 2*(yPositive_M - meanPositive);

    measurementCases(k).samplingPercent = samplingPercents(k);
    measurementCases(k).samplingRatio = samplingRatio;
    measurementCases(k).M = M;
    measurementCases(k).actualSamplingRatio = M / N;
    measurementCases(k).yDiff = yDiff;
    measurementCases(k).yRef = yRef;
    measurementCases(k).yAvg = yAvg;
    measurementCases(k).yDC = yDC;
    measurementCases(k).meanPositive = meanPositive;
end

%% Save the interface used by M04 and M05
measurementVectorInfo = struct();
measurementVectorInfo.N = N;
measurementVectorInfo.measurementTypes = measurementTypes;
measurementVectorInfo.samplingPercents = samplingPercents;
measurementVectorInfo.yDiffDefinition = ...
    'yPositive(1:M) - yComplementary(1:M)';
measurementVectorInfo.yRefDefinition = ...
    '2*yPositive(1:M) - yPositive(1)';
measurementVectorInfo.yAvgDefinition = ...
    '2*(yPositive(1:M) - mean(yPositive(1:M)))';
measurementVectorInfo.yAvgUsesFutureMeasurements = false;
measurementVectorInfo.selectedDataset = selectedDataset;

save(outputFile, 'measurementCases', 'measurementTypes', ...
    'samplingPercents', 'N', 'measurementVectorInfo', 'selectedDataset', '-v7.3');

fprintf('\nMeasurement-vector formation completed for dataset: %s\n', ...
    char(selectedDataset));
fprintf('N = %d measurements at 100%% sampling.\n', N);
fprintf('Sampling grid: ');
fprintf('%g ', samplingPercents);
fprintf('%%\n');
fprintf('Output: %s\n', outputFile);
end

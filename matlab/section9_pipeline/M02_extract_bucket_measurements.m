function M02_extract_bucket_measurements(selectedDataset)
%% Convert raw detector signals into one bucket value per displayed mask
% This script follows Section 5 of the tutorial:
%   raw detector samples r[k]
%       -> transition indicator Delta r[k] = |r[k+1] - r[k]|
%       -> mask intervals I_i
%       -> central averaging windows W_i
%       -> bucket values y_i^(+) and y_i^(-)
%
% The superscript (-) in the tutorial means COMPLEMENTARY; it does not mean
% that the detector voltage is negative. The MATLAB variables therefore use
% the names yPositive and yComplementary.
%
% This script does not form yDiff, yRef, or yAvg and does not reconstruct
% an image. RUN_SECTION9_ANALYSIS.m passes selectedDataset explicitly. If this function
% is called without an argument, paw_print is used by default.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end
selectedDataset = string(selectedDataset);

%% Published processing settings
% Keep these values unchanged to reproduce the released detector records.
% Change them only when adapting the code to a different acquisition.
N = 16384;                   % Number of signed Hadamard patterns: N = n^2
fs_Hz = 100000;              % Detector sampling frequency in hertz
fDMD_Hz = 960;               % DMD mask rate in hertz
centralFraction = 0.60;      % Central fraction of each interval used for W_i

%% Locate this package, its functions, and the selected dataset
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
functionsFolder = fullfile(scriptFolder, 'functions');
addpath(functionsFolder);

config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;
resultsFolder = config.resultsFolder;
positiveSignalFile = config.positiveSignalFile;
complementarySignalFile = config.complementarySignalFile;
positiveFilePath = config.positiveSignalPath;
complementaryFilePath = config.complementarySignalPath;

%% Expected number of detector samples per displayed mask
samplesPerPattern = fs_Hz / fDMD_Hz;
minimumPeakDistance_samples = round(0.75 * samplesPerPattern);

%% Read the two raw detector records r^(+)[k] and r^(-)[k]
% read_numeric_column uses fscanf because the supplied TXT files contain
% leading tab characters that can produce an empty/NaN column with readmatrix.
rawPositive = read_numeric_column(positiveFilePath);
rawComplementary = read_numeric_column(complementaryFilePath);

%% Detect transitions using Delta r[k] = |r[k+1] - r[k]|
% Section 5 uses a threshold equal to the median difference plus six median
% absolute deviations. The threshold is estimated independently for the two
% raw detector records.
[positiveTransitionsAll, positiveDetection] = detect_pattern_transitions( ...
    rawPositive, minimumPeakDistance_samples);
[complementaryTransitionsAll, complementaryDetection] = ...
    detect_pattern_transitions(rawComplementary, minimumPeakDistance_samples);

%% Define the N mask intervals I_i
% IMPORTANT FOR OTHER EXPERIMENTS:
% The following start/end convention is specific to the detector files
% supplied with this tutorial. The positive recording contains N complete
% intervals between N+1 detected transitions. In the complementary recording,
% raw sample 1 is already the start of the first interval, so the first N
% detected transitions close the N intervals.
%
% A different trigger, acquisition start time, or synchronization scheme may
% require a different definition of the first interval. The remaining bucket
% extraction procedure is unchanged.
if numel(positiveTransitionsAll) < N + 1
    error('Not enough positive transitions were detected.');
end

if numel(complementaryTransitionsAll) < N
    error('Not enough complementary transitions were detected.');
end

positiveTransitionsUsed = positiveTransitionsAll(1:N + 1);
positiveIntervalStartSamples = positiveTransitionsUsed(1:end-1);
positiveIntervalEndSamples = positiveTransitionsUsed(2:end) - 1;

complementaryTransitionsUsed = complementaryTransitionsAll(1:N);
complementaryIntervalStartSamples = ...
    [1; complementaryTransitionsUsed(1:end-1)];
complementaryIntervalEndSamples = complementaryTransitionsUsed - 1;

%% Average the central window W_i of every interval
% For each interval, the helper function implements
%       y_i = mean(r[k]) for k in W_i,
% where W_i is the central 60% by default. No baseline subtraction,
% normalization, or sign change is applied in this step.
[yPositive, positiveAveragingWindows, positiveWindowLengths] = ...
    average_central_intervals(rawPositive, positiveIntervalStartSamples, ...
    positiveIntervalEndSamples, centralFraction);

[yComplementary, complementaryAveragingWindows, complementaryWindowLengths] = ...
    average_central_intervals(rawComplementary, ...
    complementaryIntervalStartSamples, complementaryIntervalEndSamples, ...
    centralFraction);

assert(isequal(size(yPositive), [N 1]), ...
    'yPositive does not contain exactly N bucket values.');
assert(isequal(size(yComplementary), [N 1]), ...
    'yComplementary does not contain exactly N bucket values.');
assert(all(isfinite(yPositive)) && all(isfinite(yComplementary)), ...
    'The extracted bucket vectors contain non-finite values.');

%% Store extraction information used for diagnostics and optional figures
settings = struct();
settings.N = N;
settings.fs_Hz = fs_Hz;
settings.fDMD_Hz = fDMD_Hz;
settings.samplesPerPattern = samplesPerPattern;
settings.centralFraction = centralFraction;
settings.minimumPeakDistance_samples = minimumPeakDistance_samples;
settings.positiveThreshold_V = positiveDetection.threshold_V;
settings.complementaryThreshold_V = complementaryDetection.threshold_V;

transitions = struct();
transitions.positiveAllSamples = positiveTransitionsAll;
transitions.complementaryAllSamples = complementaryTransitionsAll;
transitions.positiveUsedSamples = positiveTransitionsUsed;
transitions.complementaryUsedSamples = complementaryTransitionsUsed;

intervals = struct();
intervals.positiveStartSamples = positiveIntervalStartSamples;
intervals.positiveEndSamples = positiveIntervalEndSamples;
intervals.complementaryStartSamples = complementaryIntervalStartSamples;
intervals.complementaryEndSamples = complementaryIntervalEndSamples;
intervals.positiveAveragingWindows = positiveAveragingWindows;
intervals.complementaryAveragingWindows = complementaryAveragingWindows;
intervals.positiveAveragingWindowLengths = positiveWindowLengths;
intervals.complementaryAveragingWindowLengths = complementaryWindowLengths;

correlationMatrix = corrcoef(yPositive, yComplementary);
sameIndexCorrelation = correlationMatrix(1, 2);

diagnostics = struct();
diagnostics.sameIndexCorrelation = sameIndexCorrelation;
diagnostics.positiveDetection = positiveDetection;
diagnostics.complementaryDetection = complementaryDetection;

sourceFiles = struct();
sourceFiles.dataset = selectedDataset;
sourceFiles.positive = positiveSignalFile;
sourceFiles.complementary = complementarySignalFile;

%% Save the interface used by M03
outputFile = fullfile(resultsFolder, 'bucket_measurements.mat');
save(outputFile, 'yPositive', 'yComplementary', 'settings', 'transitions', ...
    'intervals', 'diagnostics', 'sourceFiles', 'selectedDataset');

fprintf('\nBucket extraction completed for dataset: %s\n', char(selectedDataset));
fprintf('yPositive:      %d x %d\n', size(yPositive, 1), size(yPositive, 2));
fprintf('yComplementary: %d x %d\n', ...
    size(yComplementary, 1), size(yComplementary, 2));
fprintf('Same-index correlation: %.9f\n', sameIndexCorrelation);
fprintf('Output: %s\n', outputFile);
end

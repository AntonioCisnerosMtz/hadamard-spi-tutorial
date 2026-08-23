function config = section9_config(selectedDataset)
%SECTION9_CONFIG Resolve paths for one published experimental dataset.
%
% The normal reader interface is RUN_SECTION9_ANALYSIS.m, where the dataset
% is selected in the User settings section. Direct calls are also supported:
%   section9_config("paw_print")
%   section9_config("USAF")
%   section9_config("logo")
%
% If no input is supplied, paw_print is used by default. The input "usaf"
% is accepted case-insensitively and normalized to the published folder name
% "USAF". Derived outputs are written to results/<dataset>/.

%% Normalize dataset selection
if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
else
    selectedDataset = string(selectedDataset);
end
selectedDataset = selectedDataset(1);

switch lower(selectedDataset)
    case "paw_print"
        selectedDataset = "paw_print";
    case "usaf"
        selectedDataset = "USAF";
    case "logo"
        selectedDataset = "logo";
    otherwise
        error('Unknown selectedDataset "%s". Choose paw_print, USAF, or logo.', ...
            char(selectedDataset));
end

%% Package paths and input discovery
packageFolder = fileparts(mfilename('fullpath'));
availableDatasets = ["paw_print", "USAF", "logo"];
rawFolder = fullfile(packageFolder, 'raw', char(selectedDataset));
resultsFolder = fullfile(packageFolder, 'results', char(selectedDataset));
figuresFolder = fullfile(packageFolder, 'figures', char(selectedDataset));
sharedDataFolder = fullfile(packageFolder, 'data');
patternManifestFile = fullfile(sharedDataFolder, 'pattern_manifest.csv');

assert(exist(rawFolder, 'dir') == 7, ...
    'Raw-data folder not found for selectedDataset "%s": %s', ...
    char(selectedDataset), rawFolder);
assert(exist(patternManifestFile, 'file') == 2, ...
    'Shared pattern_manifest.csv was not found: %s', patternManifestFile);

positiveMatches = dir(fullfile(rawFolder, '*_pos_*_F.txt'));
complementaryMatches = dir(fullfile(rawFolder, '*_neg_*_F.txt'));
assert(numel(positiveMatches) == 1, ...
    'Expected exactly one *_pos_*_F.txt file in %s; found %d.', ...
    rawFolder, numel(positiveMatches));
assert(numel(complementaryMatches) == 1, ...
    'Expected exactly one *_neg_*_F.txt file in %s; found %d.', ...
    rawFolder, numel(complementaryMatches));

if exist(resultsFolder, 'dir') ~= 7
    mkdir(resultsFolder);
end

config = struct();
config.selectedDataset = selectedDataset;
config.availableDatasets = availableDatasets;
config.packageFolder = packageFolder;
config.rawFolder = rawFolder;
config.resultsFolder = resultsFolder;
config.figuresFolder = figuresFolder;
config.sharedDataFolder = sharedDataFolder;
config.patternManifestFile = patternManifestFile;
config.positiveSignalFile = positiveMatches(1).name;
config.complementarySignalFile = complementaryMatches(1).name;
config.positiveSignalPath = fullfile(rawFolder, positiveMatches(1).name);
config.complementarySignalPath = fullfile(rawFolder, complementaryMatches(1).name);
end

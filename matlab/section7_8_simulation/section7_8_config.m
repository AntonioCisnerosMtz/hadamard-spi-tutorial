function config = section7_8_config()
%SECTION7_8_CONFIG Common paths and canonical simulation settings.
%
% The reader-facing package intentionally keeps this configuration shallow.
% Solver-specific parameters remain visible inside S04-S07.

projectFolder = fileparts(mfilename('fullpath'));

config.projectFolder = projectFolder;
config.functionsFolder = fullfile(projectFolder, 'functions');
config.resultsFolder = fullfile(projectFolder, 'results');
config.figuresFolder = fullfile(projectFolder, 'figures');
config.frozenResultsFolder = fullfile(projectFolder, 'frozen_results');

config.l1magicFolder = fullfile(projectFolder, ...
    'external_dependencies', 'l1magic');
config.fdriFolder = fullfile(projectFolder, ...
    'external_dependencies', 'FDRI-single-pixel-imaging');

% Canonical Sections 7-8 simulation settings.
config.n = 128;
config.referenceImageName = 'cameraman.tif';
config.resizeMethod = 'bicubic';
config.measurementOrdering = 'GCS+S';
config.measurementNoise = 'none';
end

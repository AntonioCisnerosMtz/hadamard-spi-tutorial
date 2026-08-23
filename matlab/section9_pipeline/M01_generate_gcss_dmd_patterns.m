%% Generate GCS+S positive and complementary masks for a binary DMD
% This script implements the pattern-generation route described in the
% tutorial. It is a PRE-ACQUISITION step and is intentionally excluded from
% RUN_SECTION9_ANALYSIS.m.
%
% Main stages:
%   1. build H_n^seq, the one-dimensional Hadamard basis in sequency order;
%   2. visit the two-dimensional (u,v) coordinates in GCS+S zigzag order;
%   3. generate the signed pattern P_{u,v};
%   4. split P_{u,v} into positive and complementary binary masks;
%   5. resize and center each mask in the DMD frame;
%   6. save the frames as 1-bit PNG files and record their acquisition order.
%
% Edit only the parameters in the next section, and then press Run.

clear;
clc;

%% Pattern-generation settings
% These settings define a NEW pre-acquisition pattern set. They do not alter
% the published experimental data or its installed pattern manifest.
n = 128;                     % Logical pattern size: n x n
activeRegionSize = 880;      % Square active region in DMD pixels
dmdResolution = [1080 1920]; % Full DMD frame: [rows columns]

% Examples:
%   '%d.png'                  -> 1.png, 2.png, 3.png
%   '%02d.png'                -> 01.png, 02.png, 03.png
%   'gcss_pos_%05d.png'       -> gcss_pos_00001.png
positiveNameFormat = 'gcss_pos_%05d.png';
complementaryNameFormat = 'gcss_comp_%05d.png';

%% Locate this package, its functions, and the generated-pattern folder
scriptFolder = fileparts(mfilename('fullpath'));
functionsFolder = fullfile(scriptFolder, 'functions');
generatedPatternsFolder = fullfile(scriptFolder, 'generated_patterns');
sharedDataFolder = fullfile(scriptFolder, 'data');
addpath(functionsFolder);

if ~exist(generatedPatternsFolder, 'dir')
    mkdir(generatedPatternsFolder);
end

%% Check the parameters
if n < 2 || mod(log2(n), 1) ~= 0
    error('n must be a power of two: 2, 4, 8, 16, 32, 64, 128, ...');
end

if activeRegionSize < 1 || mod(activeRegionSize, 1) ~= 0
    error('activeRegionSize must be a positive integer.');
end

if numel(dmdResolution) ~= 2 || any(dmdResolution < 1) || ...
        any(mod(dmdResolution, 1) ~= 0)
    error('dmdResolution must be [rows columns] with positive integers.');
end

if activeRegionSize > dmdResolution(1) || ...
        activeRegionSize > dmdResolution(2)
    error('The active region does not fit inside the DMD frame.');
end

if exist('imresize', 'file') ~= 2
    error('This script requires imresize from the Image Processing Toolbox.');
end

%% Number of signed patterns
% The tutorial uses N = n^2 Hadamard patterns for an n x n image.
N = n^2;

dmdRows = dmdResolution(1);
dmdColumns = dmdResolution(2);

%% Create the output folders
orderingFolder = fullfile(generatedPatternsFolder, 'GCSplusS');
logicalFolder = fullfile(orderingFolder, sprintf('n%d_N%d', n, N));
dmdFolder = fullfile(logicalFolder, ...
    sprintf('DMD%dx%d', dmdRows, dmdColumns));
activeFolder = fullfile(dmdFolder, ...
    sprintf('active%dx%d', activeRegionSize, activeRegionSize));

positiveFolder = fullfile(activeFolder, 'positive');
complementaryFolder = fullfile(activeFolder, 'complementary');

if exist(activeFolder, 'dir')
    error(['The output folder already exists:\n%s\n' ...
        'Delete it or move it before running the script again.'], ...
        activeFolder);
end

mkdir(positiveFolder);
mkdir(complementaryFolder);

%% Build the GCS+S order
% HnSeq corresponds to H_n^seq in the tutorial. Its rows are ordered from
% low to high sequency (number of sign changes).
HnSeq = sequency_hadamard(n);

% The zigzag path gives the GCS+S acquisition order on the (u,v) grid.
[uList, vList] = zigzag_coordinates(n);

positiveFilename = strings(N, 1);
complementaryFilename = strings(N, 1);

fprintf('Generating %d positive and %d complementary masks.\n', N, N);
fprintf('Output folder:\n%s\n\n', activeFolder);

%% Generate and save one positive/complementary pair at a time
for i = 1:N
    u = uList(i);
    v = vList(i);

    % P_{u,v} is the outer product of the corresponding one-dimensional
    % Hadamard vectors. This is the same signed pattern used in the tutorial.
    hu = HnSeq(u, :).';
    hv = HnSeq(v, :);
    Puv = hu * hv;

    % A binary DMD cannot display -1. Split the signed pattern into the
    % positive mask P_i^(+) and complementary mask P_i^(-).
    PiPositive = Puv == 1;
    PiComplementary = Puv == -1;

    % For the first all-one signed pattern, the positive mask is all one and
    % the complementary mask is all zero.
    if i == 1
        assert(all(PiPositive(:)), ...
            'The first positive mask is not all one.');
        assert(~any(PiComplementary(:)), ...
            'The first complementary mask is not all zero.');
    end

    % Resize each logical mask and center it in the full DMD frame.
    positiveFrame = make_centered_dmd_frame( ...
        PiPositive, activeRegionSize, dmdResolution);
    complementaryFrame = make_centered_dmd_frame( ...
        PiComplementary, activeRegionSize, dmdResolution);

    % Save both frames as 1-bit PNG files.
    positiveName = sprintf(positiveNameFormat, i);
    complementaryName = sprintf(complementaryNameFormat, i);

    imwrite(positiveFrame, fullfile(positiveFolder, positiveName), ...
        'png', 'BitDepth', 1);
    imwrite(complementaryFrame, ...
        fullfile(complementaryFolder, complementaryName), ...
        'png', 'BitDepth', 1);

    positiveFilename(i) = string(positiveName);
    complementaryFilename(i) = string(complementaryName);

    if mod(i, 500) == 0 || i == N
        fprintf('Saved %d of %d pattern pairs.\n', i, N);
    end
end

%% Save the acquisition order
% Each row links acquisition index i to its GCS+S coordinate (u,v) and the
% matching positive/complementary DMD files.
patternManifest = table( ...
    (1:N).', uList, vList, positiveFilename, complementaryFilename, ...
    'VariableNames', { ...
    'sequence_index', 'u', 'v', ...
    'positive_filename', 'complementary_filename'});

writetable(patternManifest, fullfile(activeFolder, 'pattern_manifest.csv'));

% The installed experimental manifest at data/pattern_manifest.csv is intentionally
% NOT modified here. This prevents a pre-acquisition pattern-generation run
% from replacing the manifest that accompanies the published detector data.
% For a new acquisition, use the manifest saved in activeFolder and install it
% explicitly with that new dataset only after verifying its acquisition order.

%% Save the generation settings
firstRow = floor((dmdRows - activeRegionSize) / 2) + 1;
firstColumn = floor((dmdColumns - activeRegionSize) / 2) + 1;
lastRow = firstRow + activeRegionSize - 1;
lastColumn = firstColumn + activeRegionSize - 1;

settingsFile = fopen(fullfile(activeFolder, 'generation_settings.txt'), 'w');
if settingsFile == -1
    error('Could not create generation_settings.txt.');
end

fprintf(settingsFile, 'ordering = GCS+S\n');
fprintf(settingsFile, 'n = %d\n', n);
fprintf(settingsFile, 'logical_pattern_size = %d x %d\n', n, n);
fprintf(settingsFile, 'N = %d\n', N);
fprintf(settingsFile, 'dmd_resolution = %d x %d\n', dmdRows, dmdColumns);
fprintf(settingsFile, 'active_region_size = %d x %d\n', ...
    activeRegionSize, activeRegionSize);
fprintf(settingsFile, 'active_rows_matlab = %d:%d\n', firstRow, lastRow);
fprintf(settingsFile, 'active_columns_matlab = %d:%d\n', ...
    firstColumn, lastColumn);
fprintf(settingsFile, 'png_bit_depth = 1\n');
fprintf(settingsFile, 'positive_name_format = %s\n', positiveNameFormat);
fprintf(settingsFile, 'complementary_name_format = %s\n', ...
    complementaryNameFormat);
fclose(settingsFile);

%% Verify the first saved pair
firstPositiveInfo = imfinfo(fullfile(positiveFolder, ...
    sprintf(positiveNameFormat, 1)));
firstComplementaryInfo = imfinfo(fullfile(complementaryFolder, ...
    sprintf(complementaryNameFormat, 1)));

assert(firstPositiveInfo.BitDepth == 1, ...
    'The first positive PNG was not saved with a 1-bit depth.');
assert(firstComplementaryInfo.BitDepth == 1, ...
    'The first complementary PNG was not saved with a 1-bit depth.');

fprintf('\nPattern generation completed.\n');
fprintf('Output folder:\n%s\n', activeFolder);
fprintf('Generated %d positive and %d complementary masks.\n', N, N);
fprintf('Generated manifest: %s\n', fullfile(activeFolder, 'pattern_manifest.csv'));
installedManifest = fullfile(sharedDataFolder, 'pattern_manifest.csv');
if exist(installedManifest, 'file') == 2
    fprintf('Installed experimental manifest left unchanged: %s\n', installedManifest);
end

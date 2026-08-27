function S01_prepare_reference_image(imageMode)
%% S01 - Prepare the reference image
% imageMode = "tutorial"  -> reproduce the tutorial input exactly
% imageMode = "choose"    -> select a reader-supplied image
%
% Tutorial mode:
%   MATLAB cameraman.tif
%       -> double, without normalization
%       -> bicubic resize to 128 x 128
%
% Reader-selected mode:
%   selected image
%       -> convert to 8-bit grayscale
%       -> double, without further normalization
%       -> bicubic resize to 128 x 128
%
% The custom-image conversion keeps the rest of the tutorial in the same
% 0-255 gray-level convention used by the Section 8 metrics.

if nargin < 1
    imageMode = "tutorial";
end
imageMode = string(imageMode);

config = section7_8_config();

if ~exist(config.resultsFolder, 'dir')
    mkdir(config.resultsFolder);
end

assert(exist('imresize', 'file') == 2, ...
    'S01 requires imresize from Image Processing Toolbox.');

%% Resolve the source image
switch lower(imageMode)
    case "tutorial"
        sourceFile = which(config.referenceImageName);

        if isempty(sourceFile)
            candidateFile = fullfile(matlabroot, ...
                'toolbox', 'images', 'imdata', ...
                config.referenceImageName);
            if exist(candidateFile, 'file') == 2
                sourceFile = candidateFile;
            end
        end

        if isempty(sourceFile) || exist(sourceFile, 'file') ~= 2
            error(['Could not locate MATLAB''s cameraman.tif. ' ...
                'Use imageMode = "choose" to select another image.']);
        end

        [Xsource, map] = imread(sourceFile);
        assert(isempty(map), ...
            'The tutorial cameraman.tif was unexpectedly indexed.');

        if ndims(Xsource) ~= 2
            error('The tutorial reference image must be grayscale.');
        end

        sourceName = config.referenceImageName;
        customImageConvertedToUint8 = false;

    case "choose"
        [fileName, filePath] = uigetfile( ...
            {'*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp', ...
             'Image files (*.png, *.jpg, *.tif, *.bmp)'; ...
             '*.*', 'All files'}, ...
            'Select an image for the Hadamard SPI simulation');

        if isequal(fileName, 0)
            error('Image selection was cancelled.');
        end

        sourceFile = fullfile(filePath, fileName);
        [Xsource, map] = imread(sourceFile);

        % Convert indexed images through their colormap first.
        if ~isempty(map)
            Xsource = ind2rgb(Xsource, map);
        end

        % Convert RGB or other color images to grayscale.
        if ndims(Xsource) == 3
            if size(Xsource, 3) > 3
                Xsource = Xsource(:, :, 1:3);
            end
            Xsource = im2gray(Xsource);
        elseif ndims(Xsource) ~= 2
            error('The selected file could not be interpreted as a 2-D image.');
        end

        % Put arbitrary input types into the same 8-bit gray-level convention
        % used by the tutorial before converting to double.
        Xsource = im2uint8(Xsource);

        sourceName = fileName;
        customImageConvertedToUint8 = true;

    otherwise
        error('imageMode must be "tutorial" or "choose".');
end

originalSize = size(Xsource);

%% Convert to double BEFORE bicubic resize
% double(...) changes numeric type only. It does not divide by 255.
Xsource = double(Xsource);

n = config.n;
N = n^2;
Xref = imresize(Xsource, [n n], config.resizeMethod);

% Bicubic interpolation can produce small values outside [0,255].
% They are retained; no clipping is applied.

resizeMethod = config.resizeMethod;
inputNormalized = false;
measurementNoiseAdded = false;

outputFile = fullfile(config.resultsFolder, 'reference_image.mat');

save(outputFile, ...
    'Xref', 'n', 'N', ...
    'sourceName', 'sourceFile', 'imageMode', ...
    'originalSize', 'resizeMethod', ...
    'inputNormalized', 'measurementNoiseAdded', ...
    'customImageConvertedToUint8');

fprintf('\nS01 - Reference image prepared.\n');
fprintf('Image mode: %s\n', imageMode);
fprintf('Reference image: %s\n', sourceName);
fprintf('Original size: %d x %d\n', originalSize(1), originalSize(2));
fprintf('Simulation size: %d x %d\n', n, n);
fprintf('Resize method: %s\n', resizeMethod);

if imageMode == "choose"
    fprintf('Custom-image convention: 8-bit grayscale before double conversion\n');
else
    fprintf('Tutorial-image convention: native cameraman.tif gray levels\n');
end

fprintf('Input normalization: none after gray-level preparation\n');
fprintf('Artificial measurement noise: none\n');
fprintf('Output: %s\n\n', outputFile);
end

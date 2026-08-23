%% Check the public Section 9 installation
% Run this script after copying the companion dataset payload into the
% section9_pipeline folder. It checks software visibility and the files
% required to start the reader workflow. It does not reconstruct an image.

clc;
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
addpath(fullfile(scriptFolder, 'functions'));
addpath(genpath(fullfile(scriptFolder, 'third_party', 'TVAL3_beta2.4')), '-begin');

fprintf('Hadamard SPI tutorial installation check\n');
fprintf('----------------------------------------\n');
allPassed = true;

% MATLAB
try
    v = ver('MATLAB');
    if isempty(v)
        matlabLabel = version;
    else
        matlabLabel = v(1).Release;
    end
    fprintf('MATLAB ................................ PASS  %s\n', matlabLabel);
catch
    fprintf('MATLAB ................................ PASS\n');
end

% Required functions/toolboxes
checks = { ...
    'Image Processing Toolbox: imresize', 'imresize'; ...
    'Image Processing Toolbox: ssim',     'ssim'; ...
    'Signal Processing Toolbox: findpeaks','findpeaks'; ...
    'TVAL3 beta 2.4',                     'TVAL3'};
for k = 1:size(checks,1)
    ok = exist(checks{k,2}, 'file') == 2;
    fprintf('%-38s %s\n', checks{k,1}, passfail(ok));
    allPassed = allPassed && ok;
end

% Shared pattern manifest
manifestFile = fullfile(scriptFolder, 'data', 'pattern_manifest.csv');
manifestOK = exist(manifestFile, 'file') == 2;
if manifestOK
    try
        manifest = readtable(manifestFile);
        requiredColumns = {'sequence_index','u','v'};
        manifestOK = height(manifest) == 16384 && ...
            all(ismember(requiredColumns, manifest.Properties.VariableNames));
    catch
        manifestOK = false;
    end
end
fprintf('%-38s %s\n', 'Published pattern manifest', passfail(manifestOK));
allPassed = allPassed && manifestOK;

% Three published raw signal pairs
publishedDatasets = ["paw_print", "USAF", "logo"];
for k = 1:numel(publishedDatasets)
    d = publishedDatasets(k);
    rawFolder = fullfile(scriptFolder, 'raw', char(d));
    pos = dir(fullfile(rawFolder, '*_pos_*_F.txt'));
    neg = dir(fullfile(rawFolder, '*_neg_*_F.txt'));
    ok = exist(rawFolder, 'dir') == 7 && numel(pos) == 1 && ...
        numel(neg) == 1 && pos(1).bytes > 0 && neg(1).bytes > 0;
    fprintf('%-38s %s\n', sprintf('%s raw positive/complementary', char(d)), ...
        passfail(ok));
    allPassed = allPassed && ok;
end

fprintf('----------------------------------------\n');
if allPassed
    fprintf('Installation ready.\n');
else
    error(['Installation check failed. Review the FAIL entries above and ' ...
        'docs/INSTALLATION.md before running the analysis.']);
end

function label = passfail(ok)
if ok
    label = 'PASS';
else
    label = 'FAIL';
end
end

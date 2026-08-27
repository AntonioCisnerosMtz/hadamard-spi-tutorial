%% Check the reader-facing Sections 7-8 installation

clear;
clc;

config = section7_8_config();
addpath(config.functionsFolder);

fprintf('Hadamard SPI Sections 7-8 installation check\n');
fprintf('============================================\n\n');

%% Core MATLAB requirements
simulationCoreReady = true;

if exist('imresize', 'file') ~= 2
    fprintf('Image Processing Toolbox / imresize: MISSING\n');
    simulationCoreReady = false;
else
    fprintf('Image Processing Toolbox / imresize: available\n');
end

if exist('ssim', 'file') ~= 2
    fprintf('Image Processing Toolbox / ssim: MISSING\n');
    simulationCoreReady = false;
else
    fprintf('Image Processing Toolbox / ssim: available\n');
end

tutorialImage = which(config.referenceImageName);
if isempty(tutorialImage)
    tutorialImage = fullfile(matlabroot, ...
        'toolbox', 'images', 'imdata', config.referenceImageName);
end

if exist(tutorialImage, 'file') == 2
    fprintf('Tutorial image cameraman.tif: available\n');
else
    fprintf('Tutorial image cameraman.tif: not found (custom-image mode still possible)\n');
end

%% Frozen reproduction requires no external solver
frozenReady = ...
    exist(fullfile(config.frozenResultsFolder, ...
        'reference_and_selected_reconstructions.mat'), 'file') == 2 && ...
    exist(fullfile(config.frozenResultsFolder, ...
        'quality_metrics_manuscript.csv'), 'file') == 2 && ...
    exist(fullfile(config.frozenResultsFolder, ...
        'timing_ranges_figure14.csv'), 'file') == 2;

if frozenReady
    fprintf('Frozen tutorial results: available\n');
else
    fprintf('Frozen tutorial results: MISSING\n');
end

%% TVAL3 is bundled with its preserved upstream license notice
tval3Ready = ...
    exist(fullfile(config.projectFolder, ...
        'third_party', 'TVAL3_beta2.4', 'Solver', 'TVAL3.m'), 'file') == 2 && ...
    exist(fullfile(config.projectFolder, ...
        'third_party', 'TVAL3_beta2.4', 'Solver', 'readme.txt'), 'file') == 2;

if tval3Ready
    fprintf('TVAL3: available\n');
else
    fprintf('TVAL3: MISSING\n');
end

%% L1-Magic
optimizationFolder = fullfile(config.l1magicFolder, 'Optimization');
l1Ready = ...
    exist(fullfile(optimizationFolder, 'l1qc_logbarrier.m'), 'file') == 2 && ...
    exist(fullfile(optimizationFolder, 'l1qc_newton.m'), 'file') == 2 && ...
    exist(fullfile(optimizationFolder, 'tvqc_logbarrier.m'), 'file') == 2 && ...
    exist(fullfile(optimizationFolder, 'tvqc_newton.m'), 'file') == 2 && ...
    exist(fullfile(optimizationFolder, 'cgsolve.m'), 'file') == 2;

if l1Ready
    tvqcText = fileread(fullfile(optimizationFolder, 'tvqc_newton.m'));
    patchReady = contains(tvqcText, 'applyH11p') && ...
        contains(tvqcText, 'H11pMatrix');

    if patchReady
        fprintf('L1-Magic: installed; TV-QC compatibility patch present\n');
    else
        fprintf('L1-Magic: installed, but TV-QC compatibility patch is MISSING\n');
        l1Ready = false;
    end
else
    fprintf('L1-Magic: not installed\n');
end

%% FDRI
fdriReady = ...
    exist(fullfile(config.fdriFolder, ...
        'fdri_public_wrapper_cpu_gcss_v01.m'), 'file') == 2 && ...
    exist(fullfile(config.fdriFolder, ...
        'private', 'fdri.m'), 'file') == 2;

if fdriReady
    fprintf('FDRI: installed\n');
else
    fprintf('FDRI: not installed\n');
end

fprintf('\n');

if frozenReady
    fprintf('Frozen tutorial reproduction: READY\n');
else
    fprintf('Frozen tutorial reproduction: NOT READY\n');
end

if simulationCoreReady && tval3Ready && l1Ready && fdriReady
    fprintf('Full five-method simulation: READY\n');
else
    fprintf('Full five-method simulation: NOT YET READY\n');
    fprintf('Run INSTALL_EXTERNAL_DEPENDENCIES.m for missing L1-Magic/FDRI packages.\n');
end

if simulationCoreReady && tval3Ready
    fprintf('Partial simulation (Direct + TVAL3, plus installed methods): READY\n');
end

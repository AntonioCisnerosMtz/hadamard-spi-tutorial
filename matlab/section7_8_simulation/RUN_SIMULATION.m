%% Run the Hadamard SPI simulation
% This is the main script for readers who want to rerun the numerical
% experiment or try another image.
%
% External solvers are installed with:
%   INSTALL_EXTERNAL_DEPENDENCIES.m
%
% Frozen tutorial figures are reproduced separately with:
%   REPRODUCE_TUTORIAL_RESULTS.m

clear;
clc;

config = section7_8_config();
addpath(config.functionsFolder);

%% ---------------------------------------------------------------------
% READER SETTINGS
% ----------------------------------------------------------------------

% "tutorial" -> MATLAB cameraman.tif, matching the tutorial benchmark input
% "choose"   -> MATLAB opens a file-selection dialog for your own image
imageMode = "tutorial";

% A short default run. Change these values freely.
samplingPercents = [5 20 50];

% Turn individual methods on/off.
runFDRI = true;
runDCTL1 = true;
runTVAL3 = true;
runTVQC = true;

%% ---------------------------------------------------------------------
% START A CLEAN RUN
% ----------------------------------------------------------------------
reset_generated_outputs;

S01_prepare_reference_image(imageMode);
S02_generate_hadamard_measurements(samplingPercents);

S03_reconstruct_direct;

if runFDRI
    S04_reconstruct_fdri;
end

if runDCTL1
    S05_reconstruct_dct_l1;
end

if runTVAL3
    S06_reconstruct_tval3;
end

if runTVQC
    S07_reconstruct_tv_qc;
end

S08_evaluate_quality;
generate_simulation_summary;

fprintf('\nSimulation completed.\n');
fprintf('Metrics: %s\n', ...
    fullfile(config.resultsFolder, 'quality_metrics_generated.csv'));
fprintf('Figures: %s\n', ...
    fullfile(config.figuresFolder, 'simulation'));

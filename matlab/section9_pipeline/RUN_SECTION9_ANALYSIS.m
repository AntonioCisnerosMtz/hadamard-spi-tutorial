%% Run the complete Section 9 analysis from raw detector signals
% This convenience script runs the reader-facing scientific pipeline:
%
%   M02(selectedDataset) raw detector signals -> bucket values
%   M03(selectedDataset) bucket values        -> yDiff / yRef / yAvg
%   M04(selectedDataset) measurement vectors  -> Direct reconstructions
%   M05(selectedDataset) measurement vectors  -> TVAL3 reconstructions
%   M06(selectedDataset) reconstructions      -> quality metrics
%
% M01 is intentionally excluded because DMD-mask generation is a
% pre-acquisition step. After M02--M06 finish, the same selected dataset is
% passed explicitly to the single public figure exporter.

%% User settings
% Available datasets: "paw_print", "USAF", and "logo".
% paw_print is the worked example used in Section 9 of the tutorial.
selectedDataset = "paw_print";
generateFigures = true;          % true: export figures for this dataset

%% Resolve and report the selected dataset
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
configPreview = section9_config(selectedDataset);
selectedDataset = configPreview.selectedDataset;
fprintf('\nSection 9 selected dataset: %s\n', char(selectedDataset));
fprintf('Raw folder: %s\n', configPreview.rawFolder);
fprintf('Results folder: %s\n\n', configPreview.resultsFolder);
clear configPreview;

%% Run M02 -> M06
M02_extract_bucket_measurements(selectedDataset);
M03_form_measurement_vectors(selectedDataset);
M04_reconstruct_direct_images(selectedDataset);
M05_reconstruct_tval3_images(selectedDataset);
M06_evaluate_reconstruction_quality(selectedDataset);

%% Generate figures from the same selected dataset
if generateFigures
    generate_section9_figures(selectedDataset);
end

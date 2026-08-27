function reset_generated_outputs()
%RESET_GENERATED_OUTPUTS Remove results from a previous simulation run.
%
% This prevents stale reconstruction files from an earlier image or dependency
% state from being included in a new S08 evaluation.

config = section7_8_config();

if ~exist(config.resultsFolder, 'dir')
    mkdir(config.resultsFolder);
end

generatedFiles = { ...
    'reference_image.mat', ...
    'hadamard_measurements.mat', ...
    'direct_reconstructions.mat', ...
    'fdri_reconstructions.mat', ...
    'dct_l1_reconstructions.mat', ...
    'tval3_reconstructions.mat', ...
    'tv_qc_reconstructions.mat', ...
    'quality_metrics_generated.csv', ...
    'absolute_error_maps.mat'};

for k = 1:numel(generatedFiles)
    fileName = fullfile(config.resultsFolder, generatedFiles{k});
    if exist(fileName, 'file') == 2
        delete(fileName);
    end
end

solverLogFolder = fullfile(config.resultsFolder, 'solver_logs');
if exist(solverLogFolder, 'dir') == 7
    rmdir(solverLogFolder, 's');
end

simulationFigureFolder = fullfile(config.figuresFolder, 'simulation');
if exist(simulationFigureFolder, 'dir') == 7
    rmdir(simulationFigureFolder, 's');
end
mkdir(simulationFigureFolder);
end

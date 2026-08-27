function generate_simulation_summary()
%% Generate reader-friendly reconstruction summary figures
% One figure is generated for each sampling percentage. Each figure contains
% the reference plus every reconstruction method that was available.

config = section7_8_config();

referenceFile = fullfile(config.resultsFolder, 'reference_image.mat');
measurementFile = fullfile(config.resultsFolder, 'hadamard_measurements.mat');

assert(exist(referenceFile, 'file') == 2, ...
    'Reference image is missing.');
assert(exist(measurementFile, 'file') == 2, ...
    'Measurement metadata is missing.');

ref = load(referenceFile, 'Xref', 'sourceName');
measurement = load(measurementFile, ...
    'samplingPercents', 'Mvalues');

samplingPercents = double(measurement.samplingPercents(:).');
Mvalues = double(measurement.Mvalues(:).');

methods = struct( ...
    'label', {'Direct','FDRI','DCT-l1','TVAL3','TV-QC'}, ...
    'file', { ...
        'direct_reconstructions.mat', ...
        'fdri_reconstructions.mat', ...
        'dct_l1_reconstructions.mat', ...
        'tval3_reconstructions.mat', ...
        'tv_qc_reconstructions.mat'}, ...
    'field', { ...
        'directReconstructions', ...
        'fdriReconstructions', ...
        'dctL1Reconstructions', ...
        'tval3Reconstructions', ...
        'tvqcReconstructions'});

figureFolder = fullfile(config.figuresFolder, 'simulation');
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder);
end

for r = 1:numel(samplingPercents)
    p = samplingPercents(r);

    fig = figure('Visible', 'off');
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    nexttile;
    imagesc(ref.Xref, [0 255]);
    axis image off;
    title(sprintf('Reference: %s', ref.sourceName), 'Interpreter', 'none');

    for m = 1:numel(methods)
        nexttile;

        resultFile = fullfile(config.resultsFolder, methods(m).file);

        if exist(resultFile, 'file') == 2
            data = load(resultFile);
            stack = double(data.(methods(m).field));
            methodPercents = double(data.samplingPercents(:).');
            index = find(abs(methodPercents - p) < 1e-12, 1);

            if ~isempty(index)
                imagesc(stack(:, :, index), [0 255]);
                axis image off;
                title(methods(m).label);
            else
                axis off;
                text(0.5, 0.5, 'not available', ...
                    'HorizontalAlignment', 'center');
                title(methods(m).label);
            end
        else
            axis off;
            text(0.5, 0.5, 'skipped', ...
                'HorizontalAlignment', 'center');
            title(methods(m).label);
        end
    end

    colormap(gray(256));
    sgtitle(sprintf('Hadamard SPI simulation: %.1f%% sampling, M=%d', ...
        p, Mvalues(r)));

    outputFile = fullfile(figureFolder, ...
        sprintf('simulation_%03g_percent.png', p));

    exportgraphics(fig, outputFile, 'Resolution', 180);
    close(fig);
end

fprintf('Simulation summary figures: %s\n', figureFolder);
end

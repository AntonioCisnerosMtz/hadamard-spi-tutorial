%% Reproduce the tutorial numerical results from frozen validated data
% This script does NOT execute FDRI, L1-Magic, TVAL3, or any reconstruction
% solver. It uses the frozen arrays and tables supplied with the repository.
%
% Outputs:
%   figures/tutorial_reproduction/figure13_reproduced.png
%   figures/tutorial_reproduction/figure14_reproduced.png
%   figures/tutorial_reproduction/figure15_reproduced.png
%   figures/tutorial_reproduction/figure16_reproduced.png
%
% The numerical content follows the validated tutorial results. The layout is
% reader-facing rather than a pixel-for-pixel copy of the submission artwork.

clear;
clc;

config = section7_8_config();

figureFolder = fullfile(config.figuresFolder, 'tutorial_reproduction');
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder);
end

frozenData = load(fullfile(config.frozenResultsFolder, ...
    'reference_and_selected_reconstructions.mat'));
frozen = frozenData.frozen;

metricsTable = readtable(fullfile(config.frozenResultsFolder, ...
    'quality_metrics_manuscript.csv'), ...
    'TextType', 'string');

timingTable = readtable(fullfile(config.frozenResultsFolder, ...
    'timing_ranges_figure14.csv'), ...
    'TextType', 'string');

Xref = double(frozen.reference_image);

routeIds = [ ...
    "direct_separable_cpu", ...
    "fdri_cpu", ...
    "bpdn_dct_l1magic_cpu", ...
    "tval3_cpu", ...
    "tvqc_l1magic_cpu"];

methodLabels = ["Direct","FDRI","DCT-l1","TVAL3","TV-QC"];
selectedPercents = [5 10 15 20 30 40 50];

%% Figure 13 - representative reconstructions
% Row labels are deliberately kept visible so the reader can identify each
% reconstruction method. All images use the same [0,255] display scale.

fig = figure('Visible', 'off', ...
    'Position', [100 100 1500 980]);

layout = tiledlayout( ...
    numel(routeIds), numel(selectedPercents), ...
    'TileSpacing', 'compact', 'Padding', 'compact');

for m = 1:numel(routeIds)
    stack = double(frozen.routes.(char(routeIds(m))));

    for j = 1:numel(selectedPercents)
        p = selectedPercents(j);
        index = find(frozen.sampling_percentages == p, 1);

        ax = nexttile(layout);
        imagesc(ax, stack(:, :, index), [0 255]);
        axis(ax, 'image');
        set(ax, 'XTick', [], 'YTick', [], 'Box', 'off');

        if m == 1
            title(ax, sprintf('%g%%', p));
        end

        if j == 1
            ylabel(ax, methodLabels(m), ...
                'FontWeight', 'bold', ...
                'Rotation', 0, ...
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'middle');
        end
    end
end

colormap(fig, gray(256));
title(layout, 'Figure 13 reproduction: selected reconstructions');

exportgraphics(fig, ...
    fullfile(figureFolder, 'figure13_reproduced.png'), ...
    'Resolution', 180);
close(fig);

%% Figure 14 - reconstruction-time ranges
% Each horizontal segment and its endpoints share one color. This avoids the
% misleading mixed-color endpoint markers produced by separate plot calls.

fig = figure('Visible', 'off', ...
    'Position', [100 100 1500 850]);
ax = axes(fig);
hold(ax, 'on');

numberOfRoutes = height(timingTable);

for k = 1:numberOfRoutes
    y = numberOfRoutes - k + 1;

    plot(ax, ...
        [timingTable.lower_time_s(k), timingTable.upper_time_s(k)], ...
        [y y], ...
        '-o', ...
        'LineWidth', 2, ...
        'MarkerSize', 7);
end

set(ax, 'XScale', 'log');
yticks(ax, 1:numberOfRoutes);
yticklabels(ax, flip(timingTable.display_label));
xlabel(ax, 'Reconstruction time (s)');
ylabel(ax, 'Method');
title(ax, 'Figure 14 reproduction: timing ranges');
grid(ax, 'on');
hold(ax, 'off');

exportgraphics(fig, ...
    fullfile(figureFolder, 'figure14_reproduced.png'), ...
    'Resolution', 180);
close(fig);

%% Figure 15 - quality metrics over sampling percentage
% Method colors remain consistent across all four panels.
%
% The PSNR panel is limited to 95% because the Direct reconstruction becomes
% exact at 100%, making its PSNR infinite. This follows the tutorial figure
% convention rather than mixing finite iterative-method points with an omitted
% infinite Direct point at 100%.

fig = figure('Visible', 'off', ...
    'Position', [100 100 1500 920]);

layout = tiledlayout(2, 2, ...
    'TileSpacing', 'compact', 'Padding', 'compact');

metricFields = { ...
    'rmse_normalized', ...
    'tutorial_nrmse_relative_l2', ...
    'psnr_section8_db', ...
    'ssim_section8'};

metricTitles = { ...
    'RMSE', ...
    'NRMSE', ...
    'PSNR (dB)', ...
    'SSIM'};

for metricIndex = 1:numel(metricFields)
    ax = nexttile(layout);
    hold(ax, 'on');

    for m = 1:numel(routeIds)
        mask = metricsTable.route_id == routeIds(m) & ...
            metricsTable.completion_status == "completed";

        p = metricsTable.sampling_percentage(mask);
        values = metricsTable.(metricFields{metricIndex})(mask);

        finiteMask = isfinite(values);

        if metricIndex == 3
            finiteMask = finiteMask & (p <= 95);
        end

        plot(ax, p(finiteMask), values(finiteMask), '-o', ...
            'DisplayName', methodLabels(m));
    end

    xlabel(ax, 'Sampling percentage (%)');
    ylabel(ax, metricTitles{metricIndex});
    title(ax, metricTitles{metricIndex});
    grid(ax, 'on');

    if metricIndex == 3
        xlim(ax, [5 95]);
    else
        xlim(ax, [5 100]);
    end

    if metricIndex == 1
        legend(ax, 'Location', 'best');
    end

    hold(ax, 'off');
end

title(layout, 'Figure 15 reproduction: image-quality metrics');

exportgraphics(fig, ...
    fullfile(figureFolder, 'figure15_reproduced.png'), ...
    'Resolution', 180);
close(fig);

%% Figure 16 - absolute-error maps at 5% and 20%
% Every map uses the same [0,160] gray-level scale. Row labels identify the
% sampling percentage and a shared colorbar makes the scale explicit.

errorPercents = [5 20];

fig = figure('Visible', 'off', ...
    'Position', [100 100 1550 700]);

layout = tiledlayout( ...
    numel(errorPercents), numel(routeIds), ...
    'TileSpacing', 'compact', 'Padding', 'compact');

for row = 1:numel(errorPercents)
    p = errorPercents(row);
    index = find(frozen.sampling_percentages == p, 1);

    for m = 1:numel(routeIds)
        Xrecon = double( ...
            frozen.routes.(char(routeIds(m)))(:, :, index));
        absoluteError = abs(Xrecon - Xref);

        ax = nexttile(layout);
        imagesc(ax, absoluteError, [0 160]);
        axis(ax, 'image');
        set(ax, 'XTick', [], 'YTick', [], 'Box', 'off');

        if row == 1
            title(ax, methodLabels(m));
        end

        if m == 1
            ylabel(ax, sprintf('%g%%', p), ...
                'FontWeight', 'bold', ...
                'Rotation', 0, ...
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'middle');
        end
    end
end

colormap(fig, gray(256));

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Limits = [0 160];
ylabel(cb, 'Absolute error (gray levels)');

title(layout, ...
    'Figure 16 reproduction: absolute error');

exportgraphics(fig, ...
    fullfile(figureFolder, 'figure16_reproduced.png'), ...
    'Resolution', 180);
close(fig);


fprintf('\nFrozen tutorial results reproduced.\n');
fprintf('No external solver was executed.\n');
fprintf('Output folder: %s\n\n', figureFolder);

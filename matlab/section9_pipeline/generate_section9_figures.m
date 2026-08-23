function generate_section9_figures(selectedDataset)
%GENERATE_SECTION9_FIGURES Generate Section 9-style figures for one dataset.
%
% Reader-facing figure exporter. The selected dataset is passed explicitly:
%
%   generate_section9_figures("paw_print")
%   generate_section9_figures("USAF")
%   generate_section9_figures("logo")
%
% If no input is supplied, paw_print is used by default. The paw_print
% outputs reproduce the figure family used in Section 9 of the tutorial.
% USAF and logo use the same layouts as reader-facing diagnostic figures.
%
% This function reads existing M02--M06 outputs from results/<dataset>/ and
% writes figures to figures/<dataset>/. It does not recalculate bucket
% values, measurement vectors, reconstructions, or quality metrics.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end

scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);
addpath(fullfile(scriptDir,'functions'));
config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;

fprintf('\nGenerating figures for dataset: %s\n', char(selectedDataset));
fprintf('Results folder: %s\n', config.resultsFolder);
fprintf('Figures folder: %s\n\n', config.figuresFolder);

generate_figure18(selectedDataset, scriptDir);
generate_figures_19_22(selectedDataset, scriptDir);

fprintf('\nFigure export complete for dataset: %s\n', char(selectedDataset));
fprintf('Output folder: %s\n', config.figuresFolder);
end

function generate_figure18(selectedDataset, scriptDir)
%% Generate detector-record and measurement-vector figure
% Figure layout used for the Section 9 detector-record and measurement-vector figure.
% This script regenerates ONLY S9_01_detector_and_measurement_vectors.
% It uses already saved bucket measurements and measurement vectors; it does
% not reconstruct images, recalculate metrics, or scan historical folders.
%
% For paw_print, this preserves the manuscript figure content and geometry.
% It increases only Figure 18 mean-annotation text (10.8 -> 12.0 pt)
% and legend text (11.5 -> 12.5 pt) for manuscript-size readability.
% Signal traces, axes, ticks, axis labels, panel labels, limits, units, colors,
% positions, and scientific values are unchanged.

addpath(fullfile(scriptDir,'functions'));

resultsDir = fullfile(scriptDir,'results',char(selectedDataset));
figuresDir = fullfile(scriptDir,'figures',char(selectedDataset));
rawFolder = fullfile(scriptDir,'raw',char(selectedDataset));
if ~exist(figuresDir,'dir')
    mkdir(figuresDir);
end

bucketFile = fullfile(resultsDir,'bucket_measurements.mat');
vectorFile = fullfile(resultsDir,'measurement_vectors.mat');
assert(exist(bucketFile,'file') == 2,'Local bucket_measurements.mat not found.');
assert(exist(vectorFile,'file') == 2,'Local measurement_vectors.mat not found.');
assert(exist(rawFolder,'dir') == 7,'Local raw-data folder not found for the selected dataset.');

bucketData = load(bucketFile,'settings','sourceFiles','selectedDataset', ...
    'yPositive','yComplementary');
vectorData = load(vectorFile,'measurementCases','samplingPercents','selectedDataset');
assert(string(bucketData.selectedDataset) == selectedDataset && ...
    string(vectorData.selectedDataset) == selectedDataset, ...
    'Saved inputs belong to a different dataset.');
assert(string(bucketData.sourceFiles.dataset) == selectedDataset, ...
    'bucket_measurements.mat identifies a different raw dataset.');

positiveRawFile = fullfile(rawFolder,bucketData.sourceFiles.positive);
complementaryRawFile = fullfile(rawFolder,bucketData.sourceFiles.complementary);
assert(exist(positiveRawFile,'file') == 2,'Positive raw detector file not found.');
assert(exist(complementaryRawFile,'file') == 2,'Complementary raw detector file not found.');

rawPositive = read_numeric_column(positiveRawFile);
rawComplementary = read_numeric_column(complementaryRawFile);
yPositive = bucketData.yPositive(:);
yComplementary = bucketData.yComplementary(:);
N = numel(yPositive);
assert(numel(yComplementary) == N,'Positive/complementary bucket vectors differ in length.');

rawPatternsToShow = 40;
rawSamplesToShow = round(rawPatternsToShow * bucketData.settings.samplesPerPattern);
rawSamplesToShow = min([rawSamplesToShow,numel(rawPositive),numel(rawComplementary)]);
timeMs = (0:rawSamplesToShow-1).' / bucketData.settings.fs_Hz * 1000;

vectorSamplingPercents = double(vectorData.samplingPercents(:).');
fullVectorIndex = find(vectorSamplingPercents == 100,1);
assert(~isempty(fullVectorIndex),'The 100%% measurement-vector case was not found.');
yDiffFull = vectorData.measurementCases(fullVectorIndex).yDiff(:);
yRefFull = vectorData.measurementCases(fullVectorIndex).yRef(:);
yAvgFull = vectorData.measurementCases(fullVectorIndex).yAvg(:);
assert(numel(yDiffFull) == N && numel(yRefFull) == N && numel(yAvgFull) == N, ...
    'Complete corrected measurement vectors must contain N values.');

% Joint robust display window for y^(+) and y^(-); visualization only.
bucketDisplayLimits = robust_display_limits([yPositive;yComplementary],0.05,99.95);
bucketMeans = [mean(yPositive),mean(yComplementary)];
bucketDisplayLimits(1) = min([bucketDisplayLimits(1),bucketMeans]);
bucketDisplayLimits(2) = max([bucketDisplayLimits(2),bucketMeans]);
bucketSpan = diff(bucketDisplayLimits);
if bucketSpan <= eps(max(abs([bucketDisplayLimits 1])))
    bucketSpan = max(abs([bucketDisplayLimits 1]));
end
bucketDisplayLimits = bucketDisplayLimits + [-0.04 0.04] * bucketSpan;

% Corrected vectors are displayed in mV only by unit conversion.
yDiff_mV = 1000 * yDiffFull;
yRef_mV = 1000 * yRefFull;
yAvg_mV = 1000 * yAvgFull;
correctedVectors_mV = {yDiff_mV,yRef_mV,yAvg_mV};
correctedMeans_mV = [mean(yDiff_mV),mean(yRef_mV),mean(yAvg_mV)];
correctedDisplayLimits_mV = robust_display_limits([yDiff_mV;yRef_mV;yAvg_mV],0.05,99.95);
correctedDisplayLimits_mV(1) = min([correctedDisplayLimits_mV(1),0,correctedMeans_mV]);
correctedDisplayLimits_mV(2) = max([correctedDisplayLimits_mV(2),0,correctedMeans_mV]);
correctedSpan_mV = diff(correctedDisplayLimits_mV);
if correctedSpan_mV <= eps(max(abs([correctedDisplayLimits_mV 1])))
    correctedSpan_mV = max(abs([correctedDisplayLimits_mV 1]));
end
correctedDisplayLimits_mV = correctedDisplayLimits_mV + [-0.04 0.04] * correctedSpan_mV;

fontName = 'Arial';
signalAxesFontSize = 13.0;
signalYLabelFontSize = 12.5;
signalLegendFontSize = 12.5;
signalPanelFontSize = 14.0;

fig = figure('Name','Section 9 detector records and measurement-chain voltages', ...
    'Color','w','Position',[70 45 1180 820]);
posA = [0.075 0.700 0.900 0.260];
posB = [0.075 0.395 0.900 0.220];
posC = [0.075 0.090 0.900 0.220];

% (a) Representative raw detector records.
ax = axes(fig,'Position',posA);
hold(ax,'on');
plot(ax,timeMs,rawPositive(1:rawSamplesToShow),'LineWidth',1.05, ...
    'DisplayName','Positive record');
plot(ax,timeMs,rawComplementary(1:rawSamplesToShow),'LineWidth',1.05, ...
    'DisplayName','Complementary record');
hold(ax,'off');
grid(ax,'on');
set(ax,'FontName',fontName,'FontSize',signalAxesFontSize,'LineWidth',0.8,'TickDir','out');
ylabel(ax,'Voltage (V)','FontSize',signalYLabelFontSize);
xlabel(ax,'Time from record start (ms)','FontSize',signalAxesFontSize);
legend(ax,'Location','northeast','NumColumns',2,'FontName',fontName, ...
    'FontSize',signalLegendFontSize);
text(ax,-0.045,1.015,'(a)','Units','normalized','HorizontalAlignment','left', ...
    'VerticalAlignment','bottom','FontWeight','bold','FontName',fontName, ...
    'FontSize',signalPanelFontSize,'Clipping','off');

% (b) Complete positive and complementary bucket measurements.
ax = axes(fig,'Position',posB);
hold(ax,'on');
bucketColors = lines(2);
bucketVectors = {yPositive,yComplementary};
bucketNames = {'$y^{(+)}$','$y^{(-)}$'};
markerInset = 0.012 * diff(bucketDisplayLimits);
for p = 1:2
    y = bucketVectors{p};
    yDisplay = min(max(y,bucketDisplayLimits(1)),bucketDisplayLimits(2));
    plot(ax,1:N,yDisplay,'LineWidth',0.90,'Color',bucketColors(p,:), ...
        'DisplayName',bucketNames{p});
    yline(ax,bucketMeans(p),'--','LineWidth',1.00,'Color',bucketColors(p,:), ...
        'HandleVisibility','off');
    above = find(y > bucketDisplayLimits(2));
    below = find(y < bucketDisplayLimits(1));
    if ~isempty(above)
        plot(ax,above,repmat(bucketDisplayLimits(2)-markerInset,size(above)), ...
            '^','LineStyle','none','MarkerSize',3.0,'Color',bucketColors(p,:), ...
            'MarkerFaceColor',bucketColors(p,:),'HandleVisibility','off');
    end
    if ~isempty(below)
        plot(ax,below,repmat(bucketDisplayLimits(1)+markerInset,size(below)), ...
            'v','LineStyle','none','MarkerSize',3.0,'Color',bucketColors(p,:), ...
            'MarkerFaceColor',bucketColors(p,:),'HandleVisibility','off');
    end
end
hold(ax,'off');
grid(ax,'on');
xlim(ax,[1 N]);
ylim(ax,bucketDisplayLimits);
set(ax,'FontName',fontName,'FontSize',signalAxesFontSize,'LineWidth',0.8,'TickDir','out');
xlabel(ax,'GCS+S coefficient index','FontSize',signalAxesFontSize);
ylabel(ax,'Voltage (V)','FontSize',signalYLabelFontSize);
legend(ax,'Location','northeast','Interpreter','latex','NumColumns',2, ...
    'FontName',fontName,'FontSize',signalLegendFontSize);
text(ax,-0.045,1.015,'(b)','Units','normalized','HorizontalAlignment','left', ...
    'VerticalAlignment','bottom','FontWeight','bold','FontName',fontName, ...
    'FontSize',signalPanelFontSize,'Clipping','off');
% IMPORTANT: sprintf interprets backslash escapes. Double backslashes here
% produce the single LaTeX backslashes required by the text interpreter.
bucketMeanText = { ...
    sprintf('$\\bar{y}^{(+)} = %.4f\\,\\mathrm{V}$',bucketMeans(1)), ...
    sprintf('$\\bar{y}^{(-)} = %.4f\\,\\mathrm{V}$',bucketMeans(2))};
text(ax,0.985,0.070,bucketMeanText,'Units','normalized','Interpreter','latex', ...
    'HorizontalAlignment','right','VerticalAlignment','bottom','FontName',fontName, ...
    'FontSize',12.0,'BackgroundColor','w','Margin',2.5);

% (c) Complete corrected measurement vectors in millivolts.
ax = axes(fig,'Position',posC);
hold(ax,'on');
pathColors = lines(3);
correctedNames = {'$y^{\mathrm{diff}}$','$y^{\mathrm{ref}}$','$y^{\mathrm{avg}}$'};
correctedStyles = {'-','--',':'};
markerInset = 0.012 * diff(correctedDisplayLimits_mV);
for p = 1:3
    y = correctedVectors_mV{p};
    yDisplay = min(max(y,correctedDisplayLimits_mV(1)),correctedDisplayLimits_mV(2));
    plot(ax,1:N,yDisplay,'LineWidth',0.95,'LineStyle',correctedStyles{p}, ...
        'Color',pathColors(p,:),'DisplayName',correctedNames{p});
    yline(ax,correctedMeans_mV(p),'--','LineWidth',1.00,'Color',pathColors(p,:), ...
        'HandleVisibility','off');
    above = find(y > correctedDisplayLimits_mV(2));
    below = find(y < correctedDisplayLimits_mV(1));
    if ~isempty(above)
        plot(ax,above,repmat(correctedDisplayLimits_mV(2)-markerInset,size(above)), ...
            '^','LineStyle','none','MarkerSize',3.0,'Color',pathColors(p,:), ...
            'MarkerFaceColor',pathColors(p,:),'HandleVisibility','off');
    end
    if ~isempty(below)
        plot(ax,below,repmat(correctedDisplayLimits_mV(1)+markerInset,size(below)), ...
            'v','LineStyle','none','MarkerSize',3.0,'Color',pathColors(p,:), ...
            'MarkerFaceColor',pathColors(p,:),'HandleVisibility','off');
    end
end
yline(ax,0,'-','LineWidth',0.9,'Color',[0.35 0.35 0.35],'HandleVisibility','off');
hold(ax,'off');
grid(ax,'on');
xlim(ax,[1 N]);
ylim(ax,correctedDisplayLimits_mV);
set(ax,'FontName',fontName,'FontSize',signalAxesFontSize,'LineWidth',0.8,'TickDir','out');
xlabel(ax,'GCS+S coefficient index','FontSize',signalAxesFontSize);
ylabel(ax,'Voltage (mV)','FontSize',signalYLabelFontSize);
legend(ax,'Location','northeast','Interpreter','latex','NumColumns',3, ...
    'FontName',fontName,'FontSize',signalLegendFontSize);
text(ax,-0.045,1.015,'(c)','Units','normalized','HorizontalAlignment','left', ...
    'VerticalAlignment','bottom','FontWeight','bold','FontName',fontName, ...
    'FontSize',signalPanelFontSize,'Clipping','off');
correctedMeanText = { ...
    sprintf('$\\bar{y}^{\\mathrm{diff}} = %+.2f\\,\\mathrm{mV}$',correctedMeans_mV(1)), ...
    sprintf('$\\bar{y}^{\\mathrm{ref}} = %+.2f\\,\\mathrm{mV}$',correctedMeans_mV(2))};
if abs(correctedMeans_mV(3)) < 0.005
    correctedMeanText{end+1} = '$\bar{y}^{\mathrm{avg}} \approx 0\,\mathrm{mV}$';
else
    correctedMeanText{end+1} = sprintf('$\\bar{y}^{\\mathrm{avg}} = %+.2f\\,\\mathrm{mV}$',correctedMeans_mV(3));
end
text(ax,0.985,0.070,correctedMeanText,'Units','normalized','Interpreter','latex', ...
    'HorizontalAlignment','right','VerticalAlignment','bottom','FontName',fontName, ...
    'FontSize',12.0,'BackgroundColor','w','Margin',2.5);

fileBase = 'S9_01_detector_and_measurement_vectors';
exportgraphics(fig,fullfile(figuresDir,[fileBase '.png']),'Resolution',300);
exportgraphics(fig,fullfile(figuresDir,[fileBase '.pdf']),'ContentType','vector');
exportgraphics(fig,fullfile(figuresDir,[fileBase '.eps']),'ContentType','vector');
close(fig);

fprintf('\nFigure 18 generated for dataset: %s\n',char(selectedDataset));
fprintf('  S9_01_detector_and_measurement_vectors.[png|pdf|eps]\n');
fprintf('No reconstructions or quality metrics were recalculated.\n');
fprintf('Output folder: %s\n',figuresDir);

end

function generate_figures_19_22(selectedDataset, scriptDir)
%% Generate reconstruction and quality figures
% Figure layouts used for the Section 9 reconstruction and metric figures.
% This script regenerates ONLY S9_02--S9_05 from already saved
% Direct/TVAL3 reconstruction arrays and quality metrics. It does not read
% historical folders, reconstruct images, or recalculate metrics.
%
% Figures 19--21 preserve the v09/v07 approved header-band geometry:
% panel letters are left-aligned with their own reconstruction, while
% sampling percentage and M are centered in two lines above each image.
% Figure 22 preserves the centered shared legend.

addpath(fullfile(scriptDir,'functions'));
resultsDir = fullfile(scriptDir,'results',char(selectedDataset));
figuresDir = fullfile(scriptDir,'figures',char(selectedDataset));
if ~exist(figuresDir,'dir')
    mkdir(figuresDir);
end
assert(exist(resultsDir,'dir') == 7,'Local saved-results folder not found: %s',resultsDir);

directFile = fullfile(resultsDir,'direct_reconstructions.mat');
tval3File = fullfile(resultsDir,'tval3_reconstructions.mat');
metricsFile = fullfile(resultsDir,'quality_metrics.csv');
assert(exist(directFile,'file') == 2,'Local direct_reconstructions.mat not found.');
assert(exist(tval3File,'file') == 2,'Local tval3_reconstructions.mat not found.');
assert(exist(metricsFile,'file') == 2,'Local quality_metrics.csv not found.');

directData = load(directFile,'directResults','measurementTypes','samplingPercents','N','selectedDataset');
tval3Data = load(tval3File,'tval3Results','measurementTypes','samplingPercents','selectedDataset');
assert(string(directData.selectedDataset) == selectedDataset && ...
    string(tval3Data.selectedDataset) == selectedDataset, ...
    'Saved reconstruction files belong to a different dataset.');
metricsTable = readtable(metricsFile,'TextType','string');

measurementTypes = string(directData.measurementTypes(:).');
samplingPercents = double(directData.samplingPercents(:).');
assert(isequal(samplingPercents,5:5:100), ...
    'The Section 9 editorial figures expect the published 5:5:100 grid.');
assert(all(ismember(["yDiff","yRef","yAvg"],measurementTypes)), ...
    'The three Section 9 measurement formulations were not found.');
N = double(directData.N);
selectedPercents = [5 10 15 20 30 50];
selectedIndices = zeros(size(selectedPercents));
selectedM = zeros(size(selectedPercents));
for k = 1:numel(selectedPercents)
    selectedIndices(k) = find(samplingPercents == selectedPercents(k),1);
    assert(selectedIndices(k) > 0,'Requested sampling percentage is not available.');
    selectedM(k) = round(N * selectedPercents(k) / 100);
end
orderedTypes = ["yDiff","yRef","yAvg"];

fontName = 'Arial';
mosaicAnnotationFontSize = 15.0;
mosaicPanelFontSize = 16.0;
mosaicRowFontSize = 15.5;
qualityAxesFontSize = 12.5;
qualityPanelFontSize = 14.0;
qualityLegendFontSize = 10.5;

%% One common robust display range for all reconstruction panels

% A single 1st-99th percentile window is calculated from every image that
% appears in S9_02-S9_04 (three measurement paths, two reconstruction
% methods, six sampling ratios). Reusing one display range avoids hidden
% per-panel contrast normalization while preventing isolated extreme pixels
% from dominating the grayscale display.
allDisplayPixels = [];
for t = 1:numel(orderedTypes)
    typeIndex = find(measurementTypes == orderedTypes(t), 1);
    for k = 1:numel(selectedIndices)
        r = selectedIndices(k);
        xDirect = directData.directResults(r,typeIndex).reconstructedImage;
        xTval3 = tval3Data.tval3Results(r,typeIndex).reconstructedImage;
        allDisplayPixels = [allDisplayPixels; xDirect(:); xTval3(:)]; %#ok<AGROW>
    end
end
commonDisplayLimits = robust_display_limits(allDisplayPixels, 1, 99);

%% S9_02-S9_04: reconstruction paths at partial sampling
% Each figure has the same layout and the same display limits. Only the
% measurement-vector path changes. This makes the three routes directly
% comparable while keeping Direct and TVAL3 visible at the sampling ratios
% where reconstruction is most challenging.
for t = 1:numel(orderedTypes)
    measurementType = orderedTypes(t);
    typeIndex = find(measurementTypes == measurementType, 1);

    % Manual axes are used here instead of tiledlayout so every reconstruction
    % has a physically reserved header band above it. This prevents panel
    % identifiers and sampling metadata from overlapping the image content.
    fig = figure('Name',sprintf('Section 9 %s reconstruction progression', ...
        measurementType), 'Color','w','Position',[35 70 1450 660]);

    nCols = numel(selectedPercents);
    leftMargin = 0.075;
    rightMargin = 0.025;
    colGap = 0.010;
    axisWidth = (1 - leftMargin - rightMargin - (nCols-1)*colGap) / nCols;
    axisHeight = 0.300;
    topAxisBottom = 0.540;
    bottomAxisBottom = 0.070;
    headerHeight = 0.075;
    topHeaderBottom = topAxisBottom + axisHeight + 0.012;
    bottomHeaderBottom = bottomAxisBottom + axisHeight + 0.012;

    for c = 1:nCols
        r = selectedIndices(c);
        axisLeft = leftMargin + (c-1)*(axisWidth + colGap);

        % Direct row.
        xDirect = directData.directResults(r,typeIndex).reconstructedImage;
        ax = axes(fig,'Position',[axisLeft topAxisBottom axisWidth axisHeight]);
        imagesc(ax,xDirect);
        caxis(ax,commonDisplayLimits);
        axis(ax,'image','off');
        colormap(ax,gray(256));

        panelLetter = char('a' + c - 1);
        annotation(fig,'textbox',[axisLeft topHeaderBottom 0.040 headerHeight], ...
            'String',sprintf('(%c)',panelLetter), ...
            'HorizontalAlignment','left','VerticalAlignment','middle', ...
            'FontName',fontName,'FontSize',mosaicPanelFontSize, ...
            'FontWeight','normal','LineStyle','none','Margin',0);
        annotation(fig,'textbox',[axisLeft topHeaderBottom axisWidth headerHeight], ...
            'String',sprintf('%g%%\nM = %d',selectedPercents(c),selectedM(c)), ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontName',fontName,'FontSize',mosaicAnnotationFontSize, ...
            'FontWeight','normal','LineStyle','none','Margin',0);

        if c == 1
            text(ax,-0.18,0.50,'Direct','Units','normalized', ...
                'HorizontalAlignment','center','VerticalAlignment','middle', ...
                'Rotation',90,'FontWeight','bold','FontName',fontName, ...
                'FontSize',mosaicRowFontSize,'Clipping','off');
        end

        % TVAL3 row.
        xTval3 = tval3Data.tval3Results(r,typeIndex).reconstructedImage;
        ax = axes(fig,'Position',[axisLeft bottomAxisBottom axisWidth axisHeight]);
        imagesc(ax,xTval3);
        caxis(ax,commonDisplayLimits);
        axis(ax,'image','off');
        colormap(ax,gray(256));

        panelLetter = char('g' + c - 1);
        annotation(fig,'textbox',[axisLeft bottomHeaderBottom 0.040 headerHeight], ...
            'String',sprintf('(%c)',panelLetter), ...
            'HorizontalAlignment','left','VerticalAlignment','middle', ...
            'FontName',fontName,'FontSize',mosaicPanelFontSize, ...
            'FontWeight','normal','LineStyle','none','Margin',0);
        annotation(fig,'textbox',[axisLeft bottomHeaderBottom axisWidth headerHeight], ...
            'String',sprintf('%g%%\nM = %d',selectedPercents(c),selectedM(c)), ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontName',fontName,'FontSize',mosaicAnnotationFontSize, ...
            'FontWeight','normal','LineStyle','none','Margin',0);

        if c == 1
            text(ax,-0.18,0.50,'TVAL3','Units','normalized', ...
                'HorizontalAlignment','center','VerticalAlignment','middle', ...
                'Rotation',90,'FontWeight','bold','FontName',fontName, ...
                'FontSize',mosaicRowFontSize,'Clipping','off');
        end
    end

    switch measurementType
        case "yDiff"
            fileBase = 'S9_02_ydiff_direct_vs_tval3_partial';
        case "yRef"
            fileBase = 'S9_03_yref_direct_vs_tval3_partial';
        case "yAvg"
            fileBase = 'S9_04_yavg_direct_vs_tval3_partial';
    end

    exportgraphics(fig,fullfile(figuresDir,[fileBase '.png']), ...
        'Resolution',300);
    exportgraphics(fig,fullfile(figuresDir,[fileBase '.pdf']), ...
        'ContentType','vector');
    exportgraphics(fig,fullfile(figuresDir,[fileBase '.eps']), ...
        'ContentType','vector');
    close(fig);
end

%% S9_05: NRMSE and SSIM for all three measurement-vector paths
% Section 8 introduced the complete metric definitions. Section 9 places
% NRMSE and SSIM together because they expose complementary information:
% NRMSE reflects numerical/amplitude disagreement with the common internal
% reference, while SSIM emphasizes structural agreement.
%
% Color identifies the measurement-vector path. Line style identifies the
% reconstruction method. All six curves therefore appear together in each
% metric panel.
fig = figure('Name','Section 9 quality comparison', ...
    'Color','w','Position',[80 100 1180 500]);
tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');

colors = lines(3);
methodNames = ["Direct","TVAL3"];
lineStyles = {'-','--'};
markers = {'o','s'};
metricNames = {'nrmse_relative_l2','ssim'};
metricLabels = {'NRMSE','SSIM'};

for q = 1:2
    ax = nexttile(tl,q);
    hold(ax,'on');

    for t = 1:numel(orderedTypes)
        for m = 1:numel(methodNames)
            rows = metricsTable.measurement_type == orderedTypes(t) & ...
                metricsTable.reconstruction_method == methodNames(m);
            x = metricsTable.nominal_sampling_percent(rows);
            y = metricsTable.(metricNames{q})(rows);
            [x, order] = sort(x);
            y = y(order);

            plot(ax,x,y, ...
                'Color',colors(t,:), ...
                'LineStyle',lineStyles{m}, ...
                'Marker',markers{m}, ...
                'LineWidth',1.60, ...
                'MarkerSize',4.6, ...
                'DisplayName',sprintf('%s - %s',orderedTypes(t),methodNames(m)));
        end
    end

    hold(ax,'off');
    grid(ax,'on');
    xlim(ax,[5 100]);
    xticks(ax,[5 10 20 30 50 70 100]);
    set(ax,'FontName',fontName,'FontSize',qualityAxesFontSize, ...
        'LineWidth',0.8,'TickDir','out');
    xlabel(ax,'Sampling (%)');
    ylabel(ax,metricLabels{q});

    panelLetter = char('a' + q - 1);
    text(ax,0.00,1.02,sprintf('(%c)',panelLetter), ...
        'Units','normalized','HorizontalAlignment','left', ...
        'VerticalAlignment','bottom','FontWeight','bold', ...
        'FontName',fontName,'FontSize',qualityPanelFontSize, ...
        'Clipping','off');

    if q == 1
        nrmseValues = metricsTable.nrmse_relative_l2;
        finiteValues = nrmseValues(isfinite(nrmseValues));
        upperLimit = max(finiteValues) * 1.05;
        if upperLimit <= 0
            upperLimit = 1;
        end
        ylim(ax,[0 upperLimit]);
    else
        ssimValues = metricsTable.ssim;
        finiteValues = ssimValues(isfinite(ssimValues));
        lowerLimit = max(0,min(finiteValues)-0.02);
        if lowerLimit >= 1
            lowerLimit = 0;
        end
        ylim(ax,[lowerLimit 1]);
        lgd = legend(ax,'Location','southoutside','NumColumns',2, ...
            'FontName',fontName,'FontSize',qualityLegendFontSize);
        % Use the tiled-layout south region so the shared six-entry legend is
        % centered beneath both metric panels instead of under panel (b) only.
        lgd.Layout.Tile = 'south';
    end
end

fileBase = 'S9_05_all_paths_quality_nrmse_ssim';
exportgraphics(fig,fullfile(figuresDir,[fileBase '.png']), ...
    'Resolution',300);
exportgraphics(fig,fullfile(figuresDir,[fileBase '.pdf']), ...
    'ContentType','vector');
exportgraphics(fig,fullfile(figuresDir,[fileBase '.eps']), ...
    'ContentType','vector');
close(fig);

fprintf('\nSection 9 Figures 19--22 generated for dataset: %s\n', ...
    char(selectedDataset));
fprintf('  S9_02_ydiff_direct_vs_tval3_partial.[png|pdf|eps]\n');
fprintf('  S9_03_yref_direct_vs_tval3_partial.[png|pdf|eps]\n');
fprintf('  S9_04_yavg_direct_vs_tval3_partial.[png|pdf|eps]\n');
fprintf('  S9_05_all_paths_quality_nrmse_ssim.[png|pdf|eps]\n');
fprintf('Reconstruction ratios: 5, 10, 15, 20, 30, and 50%%.\n');
fprintf('All metric ratios: 5:5:100%%.\n');
fprintf('Output folder: %s\n', figuresDir);

end

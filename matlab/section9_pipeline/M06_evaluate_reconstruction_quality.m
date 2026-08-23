function M06_evaluate_reconstruction_quality(selectedDataset)
%% Evaluate all reconstructions against one common internal reference
% This script applies the full-reference metrics introduced in Section 8.
% For the Section 9 experiment, every image is compared with the same
% INTERNAL reference:
%
%       Direct + yDiff + 100% sampling
%
% This reference is not ground truth and is not an independent image of the
% physical object. The metrics quantify agreement with this declared internal
% reference only.
%
% Metrics: RMSE, NRMSE, PSNR, SSIM, and absolute-error maps.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end
selectedDataset = string(selectedDataset);

%% Locate files and the metric helper function
scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
addpath(fullfile(scriptFolder, 'functions'));
config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;
resultsFolder = config.resultsFolder;
directFile = fullfile(resultsFolder, 'direct_reconstructions.mat');
tval3File = fullfile(resultsFolder, 'tval3_reconstructions.mat');
csvFile = fullfile(resultsFolder, 'quality_metrics.csv');
matFile = fullfile(resultsFolder, 'quality_evaluation.mat');

assert(exist(directFile, 'file') == 2, ...
    'Run M04_reconstruct_direct_images(selectedDataset) first.');
assert(exist(tval3File, 'file') == 2, ...
    'Run M05_reconstruct_tval3_images(selectedDataset) first.');
assert(exist('ssim', 'file') == 2, ...
    'MATLAB ssim was not found. Image Processing Toolbox is required.');

%% Load Direct and TVAL3 results
Direct = load(directFile, 'directResults', ...
    'measurementTypes', 'samplingPercents', 'selectedDataset');
TVAL3data = load(tval3File, 'tval3Results', ...
    'measurementTypes', 'samplingPercents', 'selectedDataset');
assert(isfield(Direct, 'selectedDataset') && ...
    string(Direct.selectedDataset) == selectedDataset, ...
    'direct_reconstructions.mat belongs to a different dataset. Rerun M04.');
assert(isfield(TVAL3data, 'selectedDataset') && ...
    string(TVAL3data.selectedDataset) == selectedDataset, ...
    'tval3_reconstructions.mat belongs to a different dataset. Rerun M05.');

measurementTypes = string(Direct.measurementTypes(:).');
samplingPercents = double(Direct.samplingPercents(:).');

assert(isequal(measurementTypes, string(TVAL3data.measurementTypes(:).')), ...
    'Direct and TVAL3 measurement types do not match.');
assert(isequal(samplingPercents, double(TVAL3data.samplingPercents(:).')), ...
    'Direct and TVAL3 sampling grids do not match.');

numRatios = numel(samplingPercents);
numTypes = numel(measurementTypes);

%% Declare the common internal reference
refRatioIndex = find(samplingPercents == 100, 1);
refTypeIndex = find(measurementTypes == "yDiff", 1);
assert(~isempty(refRatioIndex) && ~isempty(refTypeIndex), ...
    'The grid must contain Direct + yDiff + 100%%.');

referenceRaw = double( ...
    Direct.directResults(refRatioIndex, refTypeIndex).reconstructedImage);
assert(ismatrix(referenceRaw) && all(isfinite(referenceRaw), 'all'), ...
    'The internal reference must be a finite two-dimensional image.');

% Use the actual reference size instead of assuming 128 x 128. This keeps
% the same Section 9 calculation while allowing the scripts to be reused for
% another square image size.
[nRows, nColumns] = size(referenceRaw);

%% Allocate the metric table and absolute-error maps
methodNames = ["Direct", "TVAL3"];
numMethods = numel(methodNames);
numCases = numMethods * numRatios * numTypes;

reconstructionMethod = strings(numCases,1);
measurementTypeColumn = strings(numCases,1);
Mcolumn = zeros(numCases,1);
nominalSamplingPercent = zeros(numCases,1);
actualSamplingPercent = zeros(numCases,1);
internalReference = repmat("Direct-yDiff-100pct", numCases, 1);
rmseColumn = zeros(numCases,1);
nrmseColumn = zeros(numCases,1);
psnrColumn = zeros(numCases,1);
ssimColumn = zeros(numCases,1);

absoluteErrorMaps = zeros( ...
    nRows, nColumns, numRatios, numTypes, numMethods);

row = 0;
lastEvaluationSpace = struct();

%% Evaluate every reconstruction using exactly the same reference and scale
for m = 1:numMethods
    for r = 1:numRatios
        for t = 1:numTypes
            row = row + 1;

            if methodNames(m) == "Direct"
                result = Direct.directResults(r,t);
            else
                result = TVAL3data.tval3Results(r,t);
            end

            imageRaw = double(result.reconstructedImage);
            assert(isequal(size(imageRaw), [nRows nColumns]), ...
                'All reconstructions must have the same size as the reference.');

            [metrics, absoluteErrorMap, evaluationSpace] = ...
                compute_quality_metrics(imageRaw, referenceRaw);
            lastEvaluationSpace = evaluationSpace;

            info = result.reconstructionInfo;
            reconstructionMethod(row) = methodNames(m);
            measurementTypeColumn(row) = measurementTypes(t);
            Mcolumn(row) = double(info.M);
            nominalSamplingPercent(row) = ...
                100 * double(info.nominalSamplingRatio);
            actualSamplingPercent(row) = ...
                100 * double(info.actualSamplingRatio);
            rmseColumn(row) = metrics.rmse;
            nrmseColumn(row) = metrics.nrmse;
            psnrColumn(row) = metrics.psnr_dB;
            ssimColumn(row) = metrics.ssim;
            absoluteErrorMaps(:,:,r,t,m) = absoluteErrorMap;
        end
    end
end

metricsTable = table(reconstructionMethod, measurementTypeColumn, Mcolumn, ...
    nominalSamplingPercent, actualSamplingPercent, internalReference, ...
    rmseColumn, nrmseColumn, psnrColumn, ssimColumn, ...
    'VariableNames', {'reconstruction_method','measurement_type','M', ...
    'nominal_sampling_percent','actual_sampling_percent', ...
    'internal_reference','rmse','nrmse_relative_l2','psnr_db','ssim'});

%% Record the evaluation convention used for every case
evaluationInfo = struct();
evaluationInfo.internalReference = "Direct-yDiff-100pct";
evaluationInfo.internalReferenceIsGroundTruth = false;
evaluationInfo.interpretation = [ ...
    'Metrics quantify agreement with Direct-yDiff-100%, not absolute ', ...
    'fidelity to the unknown physical object.'];
evaluationInfo.referenceImage = referenceRaw;
evaluationInfo.imageSize = [nRows nColumns];
evaluationInfo.referenceMinRaw = lastEvaluationSpace.referenceMinRaw;
evaluationInfo.referenceMaxRaw = lastEvaluationSpace.referenceMaxRaw;
evaluationInfo.referenceRangeRaw = lastEvaluationSpace.referenceRangeRaw;
evaluationInfo.metricScale = lastEvaluationSpace.scaleDefinition;
evaluationInfo.psnrImax = 1;
evaluationInfo.ssimDynamicRange = 1;
evaluationInfo.ssimRadius = 1.5;
evaluationInfo.ssimExponents = [1 1 1];
evaluationInfo.ssimRegularizationConstants = [0.0001 0.0009 0.00045];
evaluationInfo.clippingApplied = false;
evaluationInfo.filteringApplied = false;
evaluationInfo.perImageNormalizationApplied = false;
evaluationInfo.hotPixelRemovalApplied = false;
evaluationInfo.samplingPercents = samplingPercents;
evaluationInfo.measurementTypes = measurementTypes;
evaluationInfo.methodNames = methodNames;
evaluationInfo.selectedDataset = selectedDataset;

writetable(metricsTable, csvFile);
save(matFile, 'metricsTable', 'absoluteErrorMaps', 'evaluationInfo', ...
    'samplingPercents', 'measurementTypes', 'methodNames', ...
    'selectedDataset', '-v7.3');

fprintf('\nQuality evaluation completed for dataset: %s\n', ...
    char(selectedDataset));
fprintf('Internal reference: Direct + yDiff + 100%%.\n');
fprintf('Reference size: %d x %d.\n', nRows, nColumns);
fprintf('Evaluated reconstructions: %d.\n', height(metricsTable));
fprintf('CSV: %s\n', csvFile);
fprintf('MAT: %s\n', matFile);
end

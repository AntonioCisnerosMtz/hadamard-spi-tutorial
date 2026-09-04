function M05_reconstruct_tval3_images(selectedDataset)
%% Reconstruct the measurement vectors with TVAL3
% This script reconstructs the same yDiff, yRef, and yAvg cases as M04.
% It does not calculate image-quality metrics or generate tutorial figures.

if nargin < 1 || strlength(string(selectedDataset)) == 0
    selectedDataset = "paw_print";
end
selectedDataset = string(selectedDataset);

scriptFolder = fileparts(mfilename('fullpath'));
addpath(scriptFolder);
addpath(fullfile(scriptFolder, 'functions'));
addpath(genpath(fullfile(scriptFolder, 'third_party', 'TVAL3_beta2.4')), '-begin');
config = section9_config(selectedDataset);
selectedDataset = config.selectedDataset;
resultsFolder = config.resultsFolder;
measurementFile = fullfile(resultsFolder, 'measurement_vectors.mat');
manifestFile = config.patternManifestFile;
outputFile = fullfile(resultsFolder, 'tval3_reconstructions.mat');
assert(exist(measurementFile, 'file') == 2, 'Run M03_form_measurement_vectors(selectedDataset) first.');
assert(exist(manifestFile, 'file') == 2, 'pattern_manifest.csv was not found in the data folder.');
assert(exist('TVAL3', 'file') == 2, 'TVAL3.m is not visible on the MATLAB path.');

inputData = load(measurementFile, 'measurementCases', 'measurementTypes', ...
    'samplingPercents', 'N', 'selectedDataset');
assert(isfield(inputData, 'selectedDataset') && string(inputData.selectedDataset) == selectedDataset, ...
    'measurement_vectors.mat belongs to a different dataset. Rerun M03.');
measurementCases = inputData.measurementCases;
measurementTypes = string(inputData.measurementTypes(:).');
samplingPercents = double(inputData.samplingPercents(:).');
N = double(inputData.N);
n = round(sqrt(N));
assert(n*n == N, 'N must be a perfect square.');

patternManifest = readtable(manifestFile);
requiredColumns = {'sequence_index','u','v'};
assert(all(ismember(requiredColumns, patternManifest.Properties.VariableNames)), ...
    'pattern_manifest.csv must contain sequence_index, u, and v.');
assert(height(patternManifest) == N, 'pattern_manifest.csv must contain exactly N rows.');
sequenceIndex = double(patternManifest.sequence_index(:));
u = double(patternManifest.u(:));
v = double(patternManifest.v(:));
assert(isequal(sequenceIndex, (1:N).'), 'The manifest sequence indices must run from 1 to N.');
gcssLinearIndex = sub2ind([n n], u, v);
assert(isequal(sort(gcssLinearIndex), (1:N).'), 'The GCS+S coordinates must visit every coefficient exactly once.');
Hseq = sequency_hadamard(n);

%% TVAL3 settings used for the revised tutorial results
options = struct();
options.mu         = 256;
options.beta       = 32;
options.TVnorm     = 2;
options.nonneg     = true;
options.TVL2       = false;
options.tol        = 1e-6;
options.maxcnt     = 50;
options.tol_inn    = 1e-3;
options.maxit      = 300;
options.init       = 1;
options.scale_A    = true;
options.scale_b    = true;
options.consist_mu = false;
options.mu0        = 256;
options.beta0      = 32;
options.rate_ctn   = 2;
options.c          = 1e-5;
options.gamma      = 0.6;
options.gam        = 0.9995;
options.rate_gam   = 0.9;
options.tau        = 1.8;
options.isreal     = false;
options.disp       = false;

numRatios = numel(samplingPercents);
numTypes = numel(measurementTypes);
resultTemplate = struct('samplingPercent', [], 'measurementType', "", ...
    'reconstructedImage', [], 'reconstructionInfo', [], 'solverOutput', []);
tval3Results = repmat(resultTemplate, numRatios, numTypes);

for r = 1:numRatios
    M = double(measurementCases(r).M);
    A_M = @(x, mode) gcss_prefix_operator(x, mode, Hseq, gcssLinearIndex, M);
    for t = 1:numTypes
        measurementType = measurementTypes(t);
        y = measurementCases(r).(char(measurementType));
        y = y(:);
        lastwarn('');
        timerValue = tic;
        [Xtval3, solverOutput] = TVAL3(A_M, y, n, n, options);
        elapsedSeconds = toc(timerValue);
        [warningMessage, warningId] = lastwarn;
        Xtval3 = double(Xtval3);
        assert(isequal(size(Xtval3), [n n]), 'TVAL3 returned an image with an unexpected size.');
        assert(all(isfinite(Xtval3), 'all'), 'TVAL3 returned non-finite values.');
        predictedMeasurements = A_M(Xtval3(:), 1);
        relativeMeasurementResidual = norm(predictedMeasurements - y) / max(norm(y), eps);
        [iterationCount, continuationUpdates, terminationCause, ...
            finalRelativeChange, finalObjective] = summarize_tval3_output(solverOutput, options);

        reconstructionInfo = struct();
        reconstructionInfo.method = "TVAL3";
        reconstructionInfo.measurementType = measurementType;
        reconstructionInfo.ordering = "GCS+S";
        reconstructionInfo.imageSideLength = n;
        reconstructionInfo.N = N;
        reconstructionInfo.M = M;
        reconstructionInfo.nominalSamplingRatio = double(measurementCases(r).samplingRatio);
        reconstructionInfo.actualSamplingRatio = M / N;
        reconstructionInfo.options = options;
        reconstructionInfo.elapsedSeconds = elapsedSeconds;
        reconstructionInfo.relativeMeasurementResidual = relativeMeasurementResidual;
        reconstructionInfo.iterationCount = iterationCount;
        reconstructionInfo.continuationUpdates = continuationUpdates;
        reconstructionInfo.terminationCause = terminationCause;
        reconstructionInfo.finalRelativeChange = finalRelativeChange;
        reconstructionInfo.finalObjective = finalObjective;
        reconstructionInfo.warningId = string(warningId);
        reconstructionInfo.warningMessage = string(warningMessage);
        reconstructionInfo.minimum = min(Xtval3, [], 'all');
        reconstructionInfo.maximum = max(Xtval3, [], 'all');
        reconstructionInfo.mean = mean(Xtval3, 'all');
        reconstructionInfo.negativePixelFraction = mean(Xtval3(:) < 0);

        tval3Results(r,t).samplingPercent = samplingPercents(r);
        tval3Results(r,t).measurementType = measurementType;
        tval3Results(r,t).reconstructedImage = Xtval3;
        tval3Results(r,t).reconstructionInfo = reconstructionInfo;
        tval3Results(r,t).solverOutput = solverOutput;
    end
    fprintf('TVAL3: completed %g%% (%d of %d sampling ratios).\n', samplingPercents(r), r, numRatios);
end

save(outputFile, 'tval3Results', 'measurementTypes', 'samplingPercents', ...
    'N', 'options', 'selectedDataset', '-v7.3');
fprintf('\nTVAL3 reconstruction grid completed for dataset: %s\n', char(selectedDataset));
fprintf('Images saved: %d.\n', numRatios * numTypes);
fprintf('Output: %s\n', outputFile);
end

function [iterationCount, continuationCount, cause, finalRelChange, finalObjective] = summarize_tval3_output(out, options)
iterationCount = NaN;
continuationCount = 0;
finalRelChange = NaN;
finalObjective = NaN;
if isfield(out, 'itrs') && ~isempty(out.itrs)
    continuationCount = numel(out.itrs);
    iterationCount = sum(double(out.itrs(:)));
elseif isfield(out, 'itr') && ~isempty(out.itr) && isfinite(out.itr(end))
    iterationCount = double(out.itr(end));
end
if isfield(out, 'reer') && ~isempty(out.reer), finalRelChange = double(out.reer(end)); end
if isfield(out, 'obj') && ~isempty(out.obj), finalObjective = double(out.obj(end)); end
if isfinite(finalRelChange) && finalRelChange < options.tol
    cause = "outer relative-change tolerance reached";
elseif continuationCount >= options.maxcnt
    cause = "maximum continuation updates reached";
elseif isfield(out, 'itr') && ~isempty(out.itr) && isinf(out.itr(end))
    iterationCount = options.maxit;
    cause = "maximum iteration limit reached";
else
    cause = "solver returned without a classified limit";
end
end

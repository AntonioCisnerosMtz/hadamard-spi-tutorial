function [metrics, absoluteErrorMap, evaluationSpace] = compute_quality_metrics(imageRaw, referenceRaw)
%COMPUTE_QUALITY_METRICS Compute the validated Section 9 image metrics.
%
% The affine evaluation scale is defined only by the internal reference and
% is then applied unchanged to the reconstruction being evaluated. No
% clipping, filtering, hot-pixel removal, robust scaling, or per-image
% normalization is applied.

imageRaw = double(imageRaw);
referenceRaw = double(referenceRaw);

assert(isequal(size(imageRaw), size(referenceRaw)), ...
    'Reconstruction and reference must have the same dimensions.');
assert(all(isfinite(imageRaw(:))) && all(isfinite(referenceRaw(:))), ...
    'Reconstruction and reference must contain only finite values.');

referenceMinRaw = min(referenceRaw(:));
referenceMaxRaw = max(referenceRaw(:));
referenceRangeRaw = referenceMaxRaw - referenceMinRaw;
assert(referenceRangeRaw > 0 && isfinite(referenceRangeRaw), ...
    'The internal-reference intensity range must be positive and finite.');

referenceMetric = (referenceRaw - referenceMinRaw) / referenceRangeRaw;
imageMetric = (imageRaw - referenceMinRaw) / referenceRangeRaw;

difference = imageMetric - referenceMetric;
absoluteErrorMap = abs(difference);
mseValue = mean(difference(:).^2);
rmseValue = sqrt(mseValue);

referenceNorm = norm(referenceMetric(:), 2);
assert(referenceNorm > 0 && isfinite(referenceNorm), ...
    'The metric-space reference norm must be positive and finite.');
nrmseValue = norm(difference(:), 2) / referenceNorm;

if mseValue == 0
    psnrValue = Inf;
else
    psnrValue = 10 * log10(1 / mseValue);
end

ssimValue = ssim(imageMetric, referenceMetric, ...
    'DynamicRange', 1, ...
    'Radius', 1.5, ...
    'Exponents', [1 1 1], ...
    'RegularizationConstants', [0.0001 0.0009 0.00045]);

metrics = struct;
metrics.rmse = rmseValue;
metrics.nrmse = nrmseValue;
metrics.psnr_dB = psnrValue;
metrics.ssim = ssimValue;

evaluationSpace = struct;
evaluationSpace.referenceMinRaw = referenceMinRaw;
evaluationSpace.referenceMaxRaw = referenceMaxRaw;
evaluationSpace.referenceRangeRaw = referenceRangeRaw;
evaluationSpace.referenceMetric = referenceMetric;
evaluationSpace.imageMetric = imageMetric;
evaluationSpace.scaleDefinition = ...
    '(x - referenceMinRaw) / referenceRangeRaw; no clipping';
end

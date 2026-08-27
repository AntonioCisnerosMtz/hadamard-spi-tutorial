function [metrics, absoluteErrorGray] = compute_section8_metrics(Xrecon, Xref)
%COMPUTE_SECTION8_METRICS Compute the quality metrics used in Section 8.
%
% Metric policy used by the manuscript:
%
%   X_metric = double(X) / 255
%
% with:
%   - no clipping;
%   - no per-method normalization;
%   - RMSE in normalized intensity units;
%   - NRMSE = ||Xrecon-Xref||_2 / ||Xref||_2 in metric space;
%   - PSNR with I_max = 1;
%   - MATLAB SSIM with the explicitly declared Section 8 settings.
%
% The absolute-error map is returned in the original gray-level scale:
%
%   absoluteErrorGray = abs(Xrecon - Xref)

Xrecon = double(Xrecon);
Xref = double(Xref);

assert(isequal(size(Xrecon), size(Xref)), ...
    'Reconstruction and reference must have the same dimensions.');
assert(all(isfinite(Xrecon(:))) && all(isfinite(Xref(:))), ...
    'Reconstruction and reference must contain only finite values.');

%% Convert both images to the fixed Section 8 metric scale
XrefMetric = Xref / 255;
XreconMetric = Xrecon / 255;

difference = XreconMetric - XrefMetric;
mseValue = mean(difference(:).^2);

rmseNormalized = sqrt(mseValue);
rmseGrayLevels = 255 * rmseNormalized;

referenceNorm = norm(XrefMetric(:), 2);
assert(referenceNorm > 0, ...
    'Reference-image norm must be positive.');

nrmseRelativeL2 = norm(difference(:), 2) / referenceNorm;

if mseValue == 0
    psnrDb = Inf;
else
    psnrDb = 10 * log10(1 / mseValue);
end

ssimValue = ssim( ...
    XreconMetric, XrefMetric, ...
    'DynamicRange', 1, ...
    'Radius', 1.5, ...
    'Exponents', [1 1 1], ...
    'RegularizationConstants', [0.0001 0.0009 0.00045]);

absoluteErrorGray = abs(Xrecon - Xref);

metrics = struct();
metrics.rmseNormalized = rmseNormalized;
metrics.rmseGrayLevels = rmseGrayLevels;
metrics.nrmseRelativeL2 = nrmseRelativeL2;
metrics.psnrDb = psnrDb;
metrics.ssim = ssimValue;
metrics.metricScaleDivisor = 255;
metrics.ssimDynamicRange = 1;
metrics.clippingApplied = false;
metrics.perMethodNormalizationApplied = false;
end

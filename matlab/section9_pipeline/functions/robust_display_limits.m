function limits = robust_display_limits(imageData, lowerPercent, upperPercent)
%ROBUST_DISPLAY_LIMITS Percentile limits for visualization only.
% This function never changes the numerical image. It only returns display
% limits based on sorted pixel values, avoiding an additional toolbox
% dependency for percentile calculation.

validateattributes(imageData, {'numeric'}, {'real','finite','nonempty'});
validateattributes(lowerPercent, {'numeric'}, ...
    {'scalar','real','finite','>=',0,'<',100});
validateattributes(upperPercent, {'numeric'}, ...
    {'scalar','real','finite','>',0,'<=',100});
assert(lowerPercent < upperPercent, ...
    'lowerPercent must be smaller than upperPercent.');

values = sort(double(imageData(:)));
numValues = numel(values);

lowerIndex = 1 + round((numValues - 1) * lowerPercent / 100);
upperIndex = 1 + round((numValues - 1) * upperPercent / 100);

lowerValue = values(lowerIndex);
upperValue = values(upperIndex);

if upperValue <= lowerValue
    lowerValue = min(values);
    upperValue = max(values);
end
if upperValue <= lowerValue
    upperValue = lowerValue + eps(max(abs(lowerValue),1));
end

limits = [lowerValue upperValue];
end

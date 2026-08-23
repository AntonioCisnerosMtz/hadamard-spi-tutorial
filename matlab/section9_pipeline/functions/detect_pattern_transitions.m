function [transitionSamples, details] = detect_pattern_transitions(rawSignal, minimumPeakDistance_samples)
%DETECT_PATTERN_TRANSITIONS Detect temporal transitions in a raw SPI signal.
%
% The threshold is median(|diff|) + 6 * median absolute deviation from that
% median. Peaks are then accepted with the specified minimum peak distance.

rawSignal = rawSignal(:);
absoluteDifference = abs(diff(rawSignal));
medianDifference = median(absoluteDifference);
medianAbsoluteDeviation = median(abs(absoluteDifference - medianDifference));
threshold_V = medianDifference + 6 * medianAbsoluteDeviation;

[peakHeights, peakLocations] = findpeaks(absoluteDifference, ...
    'MinPeakHeight', threshold_V, ...
    'MinPeakDistance', minimumPeakDistance_samples);

% peakLocations indexes diff(rawSignal). The corresponding transition begins
% at the next raw-signal sample.
transitionSamples = peakLocations(:) + 1;

if numel(transitionSamples) > 1
    spacingSamples = diff(transitionSamples);
else
    spacingSamples = zeros(0, 1);
end

details = struct();
details.threshold_V = threshold_V;
details.medianDifference = medianDifference;
details.medianAbsoluteDeviation = medianAbsoluteDeviation;
details.minimumPeakDistance_samples = minimumPeakDistance_samples;
details.peakHeights = peakHeights(:);
details.peakLocationsInDifference = peakLocations(:);
details.transitionSamples = transitionSamples;
details.spacingSamples = spacingSamples;
end

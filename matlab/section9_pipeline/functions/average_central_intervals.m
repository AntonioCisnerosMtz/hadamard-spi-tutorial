function [bucketValues, averagingWindows, windowLengths] = average_central_intervals( ...
    rawSignal, intervalStartSamples, intervalEndSamples, centralFraction)
%AVERAGE_CENTRAL_INTERVALS Average the central stable portion of intervals.

rawSignal = rawSignal(:);
intervalStartSamples = intervalStartSamples(:);
intervalEndSamples = intervalEndSamples(:);

assert(numel(intervalStartSamples) == numel(intervalEndSamples), ...
    'Interval start and end vectors must have equal length.');
assert(centralFraction > 0 && centralFraction <= 1, ...
    'centralFraction must be in (0,1].');

numberOfIntervals = numel(intervalStartSamples);
bucketValues = zeros(numberOfIntervals, 1);
averagingWindows = zeros(numberOfIntervals, 2);
windowLengths = zeros(numberOfIntervals, 1);

for k = 1:numberOfIntervals
    firstSample = intervalStartSamples(k);
    lastSample = intervalEndSamples(k);

    assert(firstSample >= 1 && lastSample <= numel(rawSignal), ...
        'Interval exceeds raw-signal bounds.');
    assert(lastSample >= firstSample, 'Invalid interval bounds.');

    intervalLength = lastSample - firstSample + 1;
    windowLength = max(1, round(centralFraction * intervalLength));
    leftTrim = floor((intervalLength - windowLength) / 2);

    averagingStart = firstSample + leftTrim;
    averagingEnd = averagingStart + windowLength - 1;

    bucketValues(k) = mean(rawSignal(averagingStart:averagingEnd));
    averagingWindows(k, :) = [averagingStart averagingEnd];
    windowLengths(k) = windowLength;
end
end

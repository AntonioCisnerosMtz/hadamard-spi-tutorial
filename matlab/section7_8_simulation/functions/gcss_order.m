function [gcssLinearIndex, gcssCoordinates] = gcss_order(n)
%GCSS_ORDER Return the GCS+S alternating-diagonal coefficient order.
%
% Coordinates are MATLAB 1-based [u v] positions in the n-by-n Hadamard
% coefficient array. The path begins
%
%   (1,1), (1,2), (2,1), (3,1), (2,2), (1,3), ...
%
% and reverses direction on every diagonal. This is the same GCS+S path used
% to generate the DMD-pattern sequence in the experimental workflow.

assert(n >= 1 && mod(n,1) == 0, 'n must be a positive integer.');

N = n^2;
gcssCoordinates = zeros(N, 2);
nextIndex = 1;

%% Visit one diagonal at a time
for diagonal = 2:(2*n)
    firstU = max(1, diagonal - n);
    lastU = min(n, diagonal - 1);

    % Consecutive diagonals are traversed in opposite directions.
    if mod(diagonal, 2) == 1
        uValues = firstU:lastU;
    else
        uValues = lastU:-1:firstU;
    end

    for u = uValues
        v = diagonal - u;
        gcssCoordinates(nextIndex, :) = [u v];
        nextIndex = nextIndex + 1;
    end
end

%% Convert the [u v] coordinates to MATLAB column-major linear indices
gcssLinearIndex = sub2ind([n n], ...
    gcssCoordinates(:,1), gcssCoordinates(:,2));

% Every Hadamard coefficient must appear exactly once.
assert(nextIndex == N + 1, 'GCS+S path length is incorrect.');
assert(isequal(sort(gcssLinearIndex), (1:N).'), ...
    'GCS+S path does not visit every coefficient exactly once.');
end

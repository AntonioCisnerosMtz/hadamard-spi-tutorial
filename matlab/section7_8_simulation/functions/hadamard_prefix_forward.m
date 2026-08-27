function y = hadamard_prefix_forward(X, Hseq, gcssLinearIndex, M)
%HADAMARD_PREFIX_FORWARD Apply the first M GCS+S Hadamard measurements.
%
% The complete coefficient array is
%
%                  C = Hseq * X * Hseq^T
%
% and the measurement vector contains the first M coefficients after the
% array is read in GCS+S order.

C = Hseq * X * Hseq.';
orderedCoefficients = C(gcssLinearIndex);
y = orderedCoefficients(1:M);
end

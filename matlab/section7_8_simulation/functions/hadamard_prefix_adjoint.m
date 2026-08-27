function Xadjoint = hadamard_prefix_adjoint(z, Hseq, gcssLinearIndex, M, N)
%HADAMARD_PREFIX_ADJOINT Adjoint of the first-M GCS+S Hadamard operator.
%
% This is the adjoint operator, not the normalized Direct inverse. The first
% M values are placed back in the GCS+S coefficient positions and all
% unmeasured positions are set to zero.

n = size(Hseq, 1);

orderedCoefficients = zeros(N, 1);
orderedCoefficients(1:M) = z(:);

C = zeros(n, n);
C(gcssLinearIndex) = orderedCoefficients;

Xadjoint = Hseq.' * C * Hseq;
end

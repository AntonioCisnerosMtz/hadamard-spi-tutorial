function y = gcss_prefix_operator(x, mode, Hseq, gcssLinearIndex, M)
%GCSS_PREFIX_OPERATOR Apply A_M or its adjoint without a dense M x N matrix.
%
% mode = 1: image vector -> first M GCS+S Hadamard measurements (A_M*x)
% mode = 2: M measurements -> image vector using the adjoint (A_M^T*y)
%
% This helper exists because TVAL3 requires both operations. The Direct
% reconstruction remains written explicitly in M04 for pedagogical clarity.

n = size(Hseq, 1);
N = n^2;

assert(isequal(size(Hseq), [n n]), 'Hseq must be square.');
assert(numel(gcssLinearIndex) == N, ...
    'gcssLinearIndex must contain N entries.');
assert(M >= 1 && M <= N, 'M is outside the valid range.');

if mode == 1
    X = reshape(x, [n n]);
    C = Hseq * X * Hseq.';
    yOrdered = C(gcssLinearIndex);
    y = yOrdered(1:M);

elseif mode == 2
    yOrdered = zeros(N, 1);
    yOrdered(1:M) = x(:);

    C = zeros(n, n);
    C(gcssLinearIndex) = yOrdered;

    X = Hseq.' * C * Hseq;
    y = X(:);

else
    error('Unknown operator mode: %d', mode);
end
end

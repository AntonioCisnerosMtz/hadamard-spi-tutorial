function D = orthonormal_dct_matrix(n)
%ORTHONORMAL_DCT_MATRIX Build the orthonormal 1-D DCT-II matrix.
%
% Applying the matrix in both image dimensions gives the 2-D DCT
% coefficient representation used by the DCT-l1 reconstruction.

j = 0:(n - 1);
k = (0:(n - 1)).';

D = sqrt(2 / n) * cos(pi * (k * (2*j + 1)) / (2*n));
D(1, :) = 1 / sqrt(n);

orthogonalityError = norm(D * D.' - eye(n), 'fro');
assert(orthogonalityError <= 1e-11, ...
    'Orthonormal DCT-II construction failed.');
end

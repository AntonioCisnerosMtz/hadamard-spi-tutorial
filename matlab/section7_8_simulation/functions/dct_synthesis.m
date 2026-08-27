function X = dct_synthesis(alpha, D, n)
%DCT_SYNTHESIS Convert vectorized 2-D DCT coefficients into an image.

coefficients = reshape(alpha, [n n]);
X = D.' * coefficients * D;
end

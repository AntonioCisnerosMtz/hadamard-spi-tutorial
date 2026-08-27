function alpha = dct_analysis(X, D)
%DCT_ANALYSIS Convert an image into vectorized orthonormal 2-D DCT coefficients.

coefficients = D * X * D.';
alpha = coefficients(:);
end

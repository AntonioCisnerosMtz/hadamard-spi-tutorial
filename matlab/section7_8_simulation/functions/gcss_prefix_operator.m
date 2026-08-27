function y = gcss_prefix_operator(x, mode, Hseq, gcssLinearIndex, M, N)
%GCSS_PREFIX_OPERATOR Apply the first-M Hadamard operator or its adjoint.
%
% mode = 1:
%   image vector -> first M GCS+S Hadamard measurements
%
% mode = 2:
%   M measurement-domain values -> image-domain adjoint vector
%
% The helper exists only because TVAL3 expects one two-mode function handle.
% The scientific operations remain the same ones introduced in S02.

n = size(Hseq, 1);

if mode == 1
    X = reshape(x, [n n]);
    y = hadamard_prefix_forward( ...
        X, Hseq, gcssLinearIndex, M);

elseif mode == 2
    Xadjoint = hadamard_prefix_adjoint( ...
        x, Hseq, gcssLinearIndex, M, N);
    y = Xadjoint(:);

else
    error('mode must be 1 (forward) or 2 (adjoint).');
end
end

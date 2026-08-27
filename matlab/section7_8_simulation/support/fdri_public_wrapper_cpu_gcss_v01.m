function P = fdri_public_wrapper_cpu_gcss_v01(M, Nx, Ny, mi, ep, method)
%FDRI_PUBLIC_WRAPPER_CPU_GCSS_V01 Thin wrapper around the public FDRI code.
%
% The upstream fdri.m is kept inside the package's private/ directory, which
% means MATLAB requires a function in the parent directory to invoke it.

if nargin < 6, method = 0; end
if nargin < 5, ep = 1e-5; end
if nargin < 4, mi = 0.5; end

P = fdri(M, Nx, Ny, mi, ep, method);
end

# Dependencies

## MATLAB / MathWorks

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- Signal Processing Toolbox (`findpeaks`)

Tested clean-room environment: MATLAB R2026a Update 4, Windows 64-bit. This does not establish the minimum supported release.

## TVAL3 beta 2.4

M05 uses the preserved MATLAB-source subset under `matlab/section9_pipeline/third_party/TVAL3_beta2.4/`. Historical platform-specific MEX files are not required by the reader pipeline.

The preserved upstream README grants redistribution/modification under the GNU General Public License but does not state a GPL version. TVAL3 is therefore kept outside the BSD-3-Clause scope of the original tutorial code. The upstream notice is retained verbatim; see `LICENSE_SCOPE.md`, `THIRD_PARTY_NOTICES.md`, `LICENSES/TVAL3_UPSTREAM_NOTICE.txt`, and `LICENSES/TVAL3_LICENSE_INFO.md`.

## Not bundled

L1-Magic and FDRI are not required for the minimum real-data Section 9 workflow and are not bundled.

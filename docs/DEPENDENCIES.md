# Dependencies

## MATLAB / MathWorks

### Sections 7–8

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)

### Section 9

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- Signal Processing Toolbox (`findpeaks`)

The scripts were tested on a fresh installation with MATLAB R2026a on Windows 64-bit. This does not establish the minimum supported release.

## TVAL3 beta 2.4 — bundled

Both sections use the preserved MATLAB-source subset supplied under their respective `third_party/TVAL3_beta2.4/` directories. Historical platform-specific MEX files are not required by these scripts.

TVAL3 remains outside the BSD-3-Clause scope of the original tutorial code. See `LICENSE_SCOPE.md`, `THIRD_PARTY_NOTICES.md`, `LICENSES/TVAL3_UPSTREAM_NOTICE.txt`, and `LICENSES/TVAL3_LICENSE_INFO.md`.

## L1-Magic — reader installed for the complete Sections 7–8 simulation

Repository:

https://github.com/scgt/l1magic

Download with **Code → Download ZIP**. Keep the ZIP compressed and select it when `INSTALL_EXTERNAL_DEPENDENCIES` asks for the L1-Magic archive.

L1-Magic is used for the DCT-l1 and TV-QC stages. It is not required for frozen-result reproduction, Direct + TVAL3 simulation, or Section 9.

## FDRI — reader installed for the complete Sections 7–8 simulation

Repository:

https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

Download with **Code → Download ZIP**. Keep the ZIP compressed and select it when `INSTALL_EXTERNAL_DEPENDENCIES` asks for the FDRI archive.

FDRI is used only for the FDRI stage of the complete Sections 7–8 simulation. It is not required for frozen-result reproduction, Direct + TVAL3 simulation, or Section 9.

## Companion experimental dataset — separate download

Section 9 requires the companion detector-record dataset. It is intentionally not bundled with the software repository.

Reserved companion dataset DOI: `10.5281/zenodo.22070080` — dataset publication pending.

After obtaining the dataset, copy the **contents** of its `payload/` directory into `matlab/section9_pipeline/` and run `CHECK_INSTALLATION` before reconstruction.

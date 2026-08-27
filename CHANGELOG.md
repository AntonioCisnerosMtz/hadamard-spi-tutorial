# Changelog

## 1.1.0

- Add the reader-facing Sections 7–8 MATLAB simulation workflow under
  `matlab/section7_8_simulation/`.
- Add frozen-data reproduction of the tutorial results and reviewed
  reader-facing reproductions of Figures 13–16.
- Add reader-selectable simulation input images and editable sampling ratios.
- Add Direct, FDRI, DCT-l1, TVAL3, and TV-QC reconstruction routes with the
  tutorial benchmark settings exposed in readable MATLAB code.
- Add public-ZIP installation of L1-Magic and FDRI; neither dependency is
  redistributed by the repository.
- Add RMSE, NRMSE, PSNR, SSIM, and absolute-error evaluation for reader
  simulations.
- Preserve Section 9 as the experimental detector-signal workflow and update
  root navigation to distinguish simulation from experimental processing.
- Extend repository licensing and third-party notices for the Sections 7–8
  workflow.
- Keep the existing v1.0.0 release and Zenodo record unchanged until a new
  public software release is intentionally prepared.

## 1.0.0

- Initial reader-facing MATLAB workflow for the Hadamard SPI tutorial.
- Includes M01--M06, one Section 9 figure exporter, helper functions, and the
  preserved TVAL3 beta 2.4 MATLAB source required by M05.
- Supports the three published experimental signals: `paw_print`, `USAF`, and
  `logo`.
- Places the dataset selector in the `User settings` section of
  `RUN_SECTION9_ANALYSIS.m` and passes it explicitly to M02--M06 and figure
  generation.
- Keeps immutable `paw_print` checkpoints separate from reader-generated
  `results/` and `figures/`.
- Adds `CHECK_INSTALLATION.m` for dependency and data-payload checks.
- Stores optional M01 outputs under `generated_patterns/` so pre-acquisition
  pattern generation cannot overwrite the installed experimental manifest.
- The `paw_print` M02--M06 workflow passed clean-room numerical regression on
  MATLAB R2026a Update 4 (Windows 64-bit).
- The `USAF` and `logo` selections completed the same reader workflow and
  generated dataset-specific outputs and figures in functional testing.

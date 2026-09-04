# Changelog

## 1.2.1

Documentation update. Simplified the installation and usage instructions. No scientific code, parameters, data, or reference results were changed.

- Clarify the commands, dependency downloads, image selection, and output folders.
- Store the existing numerical check files under `validation/` without changing their contents.

## 1.2.0

- Standardize the manuscript TVAL3 configuration to isotropic TV (`TVnorm=2`) with the complete fixed option set used for the tutorial reconstructions.
- Record TVAL3 continuation/iteration stopping information and relative measurement residuals without describing limit-terminated runs as having converged to the outer tolerance.
- Replace the Sections 7–8 frozen numerical reference data with the updated simulation results used for the revised Figures 13–16.
- Preserve the Section 9 detector-to-bucket and measurement-vector steps; M02–M04 are unchanged from v1.1.0.
- Keep the companion experimental dataset as a separate download. The dataset DOI remains reserved until explicit publication.
- Keep v1.1.0 unchanged.
- Add commands, download links, dataset installation checks, expected outputs, and example figures to the README and section guides.

## 1.1.0

- Add the Sections 7–8 MATLAB simulation scripts under
  `matlab/section7_8_simulation/`.
- Add frozen-data reproduction of the tutorial results and reproductions of Figures 13–16.
- Add reader-selectable simulation input images and editable sampling ratios.
- Add Direct, FDRI, DCT-l1, TVAL3, and TV-QC reconstruction routes with the
  tutorial benchmark settings exposed in readable MATLAB code.
- Add public-ZIP installation of L1-Magic and FDRI; neither dependency is
  redistributed by the repository.
- Add RMSE, NRMSE, PSNR, SSIM, and absolute-error evaluation for reader
  simulations.
- Preserve Section 9 as the experimental detector-signal analysis and update
  root navigation to distinguish simulation from experimental processing.
- Extend repository licensing and third-party notices for the Sections 7–8
  simulation.
- Keep the existing v1.0.0 release and Zenodo record unchanged until a new
  public software release is intentionally prepared.

## 1.0.0

- Initial MATLAB scripts for the Hadamard SPI tutorial.
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
- The `paw_print` M02--M06 scripts passed numerical regression tests on a fresh installation with
  MATLAB R2026a Update 4 (Windows 64-bit).
- The `USAF` and `logo` selections completed the same analysis and
  generated dataset-specific outputs and figures in functional testing.

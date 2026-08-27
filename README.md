# Hadamard-based single-pixel imaging tutorial — MATLAB workflows

This repository contains the reader-facing MATLAB workflows supporting
**“Hadamard-Based Single-Pixel Imaging: From Detector Signals to Image Reconstruction.”**

The repository now provides two complementary numerical workflows:

1. **Sections 7–8 — simulation and reconstruction comparison**
2. **Section 9 — reconstruction of published experimental detector signals**

## Start here

### Sections 7–8: simulation and reconstruction comparison

Directory:

```text
matlab/section7_8_simulation/
```

Use this workflow to:

- view or regenerate the tutorial-result reproductions for Figures 13–16;
- rerun the Hadamard simulation with MATLAB `cameraman.tif`;
- select a different image and run the same simulation;
- compare Direct, FDRI, DCT-l1, TVAL3, and TV-QC;
- compute RMSE, NRMSE, PSNR, SSIM, and absolute-error maps.

For immediate reproduction from the supplied frozen numerical results:

```matlab
REPRODUCE_TUTORIAL_RESULTS
```

No external reconstruction solver is executed in this mode.

To rerun the simulation:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

L1-Magic and FDRI are not bundled. Their public repository ZIPs are selected
locally by `INSTALL_EXTERNAL_DEPENDENCIES.m`. TVAL3 beta 2.4 is preserved
inside the module with its upstream license notice.

Detailed instructions are in:

`matlab/section7_8_simulation/README.md`

### Section 9: experimental detector-signal reconstruction

Directory:

```text
matlab/section9_pipeline/
```

The normal reader entry point is:

```matlab
RUN_SECTION9_ANALYSIS
```

Readers normally change only `selectedDataset` and, if desired,
`generateFigures` in the **User settings** section.

The workflow follows the experimental chain described in the tutorial:

1. optional pre-acquisition generation of GCS+S Hadamard DMD masks (`M01`);
2. raw detector signal → one bucket value per displayed mask (`M02`);
3. formation of `yDiff`, `yRef`, and `yAvg` (`M03`);
4. Direct Hadamard reconstruction (`M04`);
5. TVAL3 reconstruction (`M05`);
6. image-quality evaluation using the declared internal reference (`M06`).

Detailed instructions are in:

`matlab/section9_pipeline/README.md`

## Published experimental signals

The companion dataset contains three positive/complementary detector-record pairs:

- `paw_print` — the worked experimental example used in Section 9 and the
  dataset with frozen reference results;
- `USAF` — an additional experimental signal for the same processing chain;
- `logo` — an additional experimental signal for the same processing chain.

`paw_print` is the manuscript case. `USAF` and `logo` are additional
reader-executable examples rather than manuscript reference cases.

## Requirements

### Sections 7–8

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- public L1-Magic ZIP for DCT-l1 and TV-QC
- public FDRI ZIP for FDRI
- bundled TVAL3 beta 2.4 for TVAL3

The validated workflow was exercised on MATLAB R2026a. Timing and iterative
solver trajectories can vary with hardware and MATLAB update level.

### Section 9

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- Signal Processing Toolbox (`findpeaks`)
- bundled TVAL3 beta 2.4

The Section 9 clean-room workflow was tested with MATLAB R2026a Update 4 on
Windows 64-bit; this is a tested environment, not a minimum-version claim.

## Section 9 data installation

Large experimental data are distributed separately as the companion Zenodo dataset:

**Dataset v1.0.0 DOI:** https://doi.org/10.5281/zenodo.22070080

Copy the **contents** of that dataset's `payload/` directory into:

```text
matlab/section9_pipeline/
```

After copying, the pipeline directory should contain:

```text
raw/USAF/
raw/logo/
raw/paw_print/
data/pattern_manifest.csv
reference_results/paw_print/
reference_figures/paw_print/
```

Generated Section 9 files remain separate under `results/<dataset>/`,
`figures/<dataset>/`, and optional `generated_patterns/`.

## Reproducibility structure

The two workflows intentionally separate:

- frozen tutorial-result reproduction;
- reader-generated simulation results;
- experimental raw-data processing;
- third-party solver code;
- reader-installed external solver dependencies.

This keeps manuscript reference results distinct from newly generated outputs.

## Licensing

Original tutorial code is released under the **BSD 3-Clause License**.

Bundled TVAL3 beta 2.4 is third-party software and is not covered by the BSD
3-Clause License. L1-Magic and FDRI are not redistributed by this repository;
readers install those dependencies from their public repositories for the
Sections 7–8 simulation workflow.

See `LICENSE_SCOPE.md`, `THIRD_PARTY_NOTICES.md`, and `LICENSES/` for exact
scope and provenance.

The companion experimental dataset is released separately under **CC BY 4.0**.

## Citation

Citation metadata for the software are provided in `CITATION.cff`.

- Software v1.0.0: https://doi.org/10.5281/zenodo.22070980
- Companion dataset v1.0.0: https://doi.org/10.5281/zenodo.22070080

The tutorial/article DOI will be added when it exists.

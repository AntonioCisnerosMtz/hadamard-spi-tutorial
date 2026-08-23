# Installation

## Software

1. Clone or extract the software repository.
2. Obtain the companion experimental-data record.
3. Copy the **contents** of the data record's `payload/` folder into `matlab/section9_pipeline/`.
4. Open MATLAB with `matlab/section9_pipeline/` as the current folder.
5. Run `CHECK_INSTALLATION.m`.

No private project directory is required. TVAL3 beta 2.4 source needed by M05 is already bundled under `third_party/`.

## MATLAB requirements

The clean-room reference test used MATLAB R2026a Update 4 on Windows 64-bit. The minimum supported MATLAB release has not been established.

Required toolboxes/functions used by the reader workflow:

- Image Processing Toolbox: `imresize`, `ssim`
- Signal Processing Toolbox: `findpeaks`

## Verify the data installation

The following folders/files should exist before running M02→M06:

```text
raw/USAF/
raw/logo/
raw/paw_print/
data/pattern_manifest.csv
reference_results/paw_print/
reference_figures/paw_print/
```

`reference_results/` and `reference_figures/` are read-only checkpoints supplied by the dataset. The pipeline writes newly generated outputs to `results/` and `figures/`, so reproduction does not overwrite the reference copies.

## Select and run a dataset

Open `RUN_SECTION9_ANALYSIS.m`. Near the top, edit only:

```matlab
selectedDataset = "paw_print";  % "paw_print", "USAF", or "logo"
```

Then press **Run** in `RUN_SECTION9_ANALYSIS.m`. That launcher is the normal reader entry point: it passes the selected dataset explicitly to M02--M06 and, when enabled, to the single figure exporter. `section9_config.m` resolves paths internally and normally does not need to be edited.

M01 is optional pre-acquisition pattern generation and is not part of the reconstruction quick start.

## Figure generation

`RUN_SECTION9_ANALYSIS.m` uses the same `selectedDataset` for analysis and figure export. Keep `generateFigures = true` to create `figures/<dataset>/`.

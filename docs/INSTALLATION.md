# Installation

The repository contains two reader workflows with different installation needs.

## Sections 7–8 — simulation

Open MATLAB in:

```text
matlab/section7_8_simulation/
```

For frozen tutorial-result reproduction or a new Direct + TVAL3 simulation, no external solver download is required. Run:

```matlab
CHECK_INSTALLATION
```

For the complete five-method simulation, download the repository ZIPs for:

- L1-Magic: https://github.com/scgt/l1magic
- FDRI-single-pixel-imaging: https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

On each repository page choose **Code → Download ZIP** and keep the downloads as ZIP files. Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
```

Do not manually extract the L1-Magic/FDRI ZIP files; the installer asks you to select them and installs the required files locally.

See `matlab/section7_8_simulation/README.md` for the three reader paths.

## Section 9 — experimental data

The experimental detector records are distributed separately from the software.

1. Obtain and extract the companion experimental dataset.
2. Copy the **contents** of its `payload/` directory into `matlab/section9_pipeline/`.
3. Do not leave an extra `payload/` directory level.
4. Open MATLAB with `matlab/section9_pipeline/` as the current folder.
5. Run `CHECK_INSTALLATION`.
6. Continue only when the final line reports `Installation ready.`

The following paths should exist before running M02–M06:

```text
raw/paw_print/
raw/USAF/
raw/logo/
data/pattern_manifest.csv
reference_results/paw_print/
reference_figures/paw_print/
```

The reference folders are read-only checkpoints supplied by the companion dataset. Reader-generated outputs go to `results/` and `figures/`.

To reproduce the manuscript case, keep:

```matlab
selectedDataset = "paw_print";
generateFigures = true;
```

in `RUN_SECTION9_ANALYSIS.m`, then run:

```matlab
RUN_SECTION9_ANALYSIS
```

M01 is optional pre-acquisition pattern generation and is not part of the reconstruction quick start.

See `matlab/section9_pipeline/README.md` for the complete step-by-step procedure and expected outputs.

## MATLAB requirements

### Sections 7–8

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- bundled TVAL3 beta 2.4
- L1-Magic and FDRI only for the full five-method run

### Section 9

- MATLAB
- Image Processing Toolbox (`imresize`, `ssim`)
- Signal Processing Toolbox (`findpeaks`)
- bundled TVAL3 beta 2.4
- companion experimental dataset

The reader workflows have been clean-room exercised with MATLAB R2026a on Windows 64-bit. This is a tested environment, not a minimum-version claim.

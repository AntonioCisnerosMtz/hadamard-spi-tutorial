# Hadamard SPI — Sections 7-8 reader simulation

This MATLAB module has two independent reader workflows.

## 1. Reproduce the tutorial results immediately

Run:

```matlab
REPRODUCE_TUTORIAL_RESULTS
```

No external solver is needed. The script uses the supplied frozen canonical
data and creates reader-facing reproductions of Figures 13-16 under:

```text
figures/tutorial_reproduction/
```

This is the fastest way to verify the numerical results reported in the
tutorial.

## 2. Rerun the simulation

To execute the reconstruction methods again, first download the two public
repository ZIPs:

- L1-Magic: https://github.com/scgt/l1magic
- FDRI: https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

On GitHub choose **Code -> Download ZIP**.

Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

The installer asks only for the L1-Magic ZIP and FDRI ZIP downloaded from their public repositories.

TVAL3 is already supplied under `third_party/` with its license notice.

## Choose the image

At the top of `RUN_SIMULATION.m`:

```matlab
imageMode = "tutorial";
```

uses MATLAB's `cameraman.tif`.

Change it to:

```matlab
imageMode = "choose";
```

and MATLAB opens a file-selection dialog.

Reader-selected images are converted to 8-bit grayscale before the same
128 x 128 Hadamard SPI workflow is applied.

## Choose the sampling percentages

The default is intentionally short:

```matlab
samplingPercents = [5 20 50];
```

You may change it, for example, to:

```matlab
samplingPercents = [5 10 15 20 30 40 50];
```

FDRI forms large explicit matrices, so high sampling percentages can require
substantial RAM.

## Reconstruction sequence

```text
S01  prepare the reference image
S02  generate GCS+S Hadamard measurements
S03  Direct
S04  FDRI
S05  DCT-l1
S06  TVAL3
S07  TV-QC
S08  RMSE / NRMSE / PSNR / SSIM / error maps
```

The code favors readable, sequential implementations that mirror the tutorial
equations.

## If an external dependency is missing

The workflow does not fail unnecessarily:

- missing FDRI -> S04 is skipped;
- missing L1-Magic -> S05 and S07 are skipped;
- Direct and TVAL3 remain available.

S08 evaluates only reconstruction files created during the current clean run.

## Important distinction

`REPRODUCE_TUTORIAL_RESULTS.m` reproduces the **reported tutorial results from
frozen canonical data**.

`RUN_SIMULATION.m` creates a **new numerical run** using the tutorial image or
a reader-selected image. Timing and iterative-solver trajectories can vary
with computer and MATLAB version.


## Iterative solvers with a reader-selected image

The solver settings shown in S05-S07 reproduce the tutorial benchmark and are
not universal tuning recommendations.

For a different image, an iterative solver may reach its maximum iteration
limit before satisfying its internal stopping criterion. In particular, TVAL3
uses `out.itr = Inf` internally as a sentinel when `maxit` is exhausted.

The reader-facing S06 converts that internal sentinel into an explicit message
such as:

```text
iterations 300 | maximum iteration limit reached
```

The reconstructed image is still returned and evaluated, but the message tells
the reader that the benchmark settings may need retuning for that new image.


## Included tutorial figures

The repository includes the visually reviewed reader-facing
reproductions generated from the frozen tutorial data:

```text
figures/tutorial_reproduction/
├── figure13_reproduced.png
├── figure14_reproduced.png
├── figure15_reproduced.png
└── figure16_reproduced.png
```

Readers can view these immediately or regenerate them with
`REPRODUCE_TUTORIAL_RESULTS.m`.


## Repository use

This directory is intended to live at:

```text
matlab/section7_8_simulation/
```

The normal reader files are the four entry points at the top of this README
plus S01-S08. Files under `functions/` and `support/` are called
automatically and do not need to be edited for a normal run.

Downloaded L1-Magic and FDRI files are created locally under
`external_dependencies/` and are intentionally excluded from version control.

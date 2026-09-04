# Hadamard SPI — Sections 7–8 reader simulation

This module separates **reproduction of the validated tutorial results** from **new simulations**. Choose the path that matches what you want to do.

## Quick start

| Goal | Commands | External downloads |
|---|---|---|
| A. Reproduce validated tutorial figures | `CHECK_INSTALLATION`, `REPRODUCE_TUTORIAL_RESULTS` | None |
| B. New Direct + TVAL3 simulation | `CHECK_INSTALLATION`, `RUN_SIMULATION` | None |
| C. New five-method simulation | `INSTALL_EXTERNAL_DEPENDENCIES`, `CHECK_INSTALLATION`, `RUN_SIMULATION` | L1-Magic + FDRI |

## A. Reproduce the validated tutorial results

From this directory run:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

`REPRODUCE_TUTORIAL_RESULTS` reads the supplied frozen revised numerical results. **No reconstruction solver is executed in this mode.** It creates reader-facing reproductions of Figures 13–16 under:

```text
figures/tutorial_reproduction/
```

This is the fastest way to verify the numerical results reported in the tutorial.

A representative expected output is included in the repository:

<img src="../../docs/assets/sections7_8_expected_output.png" alt="Representative Sections 7–8 reconstruction comparison" width="900">

## B. Run a new Direct + TVAL3 simulation

Direct and TVAL3 are available without installing L1-Magic or FDRI. Run:

```matlab
CHECK_INSTALLATION
RUN_SIMULATION
```

If external dependencies are absent, the workflow reports them as unavailable and skips the corresponding stages:

- missing FDRI → S04 is skipped;
- missing L1-Magic → S05 and S07 are skipped;
- Direct (S03) and TVAL3 (S06) still run;
- S08 evaluates only reconstruction files created in the current clean run.

New-run numerical files are written under:

```text
results/
```

and summary figures are written under:

```text
figures/simulation/
```

## C. Run a new five-method simulation

The five-method workflow uses Direct, FDRI, DCT-l1, TVAL3, and TV-QC. TVAL3 is already supplied under `third_party/`. L1-Magic and FDRI must be downloaded by the reader.

Download the repository ZIPs from:

- **L1-Magic:** https://github.com/scgt/l1magic
- **FDRI-single-pixel-imaging:** https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

On each GitHub page choose **Code → Download ZIP**. Keep the downloaded ZIP files as ZIPs; **do not extract them manually**.

Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
```

The installer opens file-selection dialogs. Select the L1-Magic ZIP and the FDRI ZIP you downloaded. The installer finds the required files and creates the local dependency folders automatically under `external_dependencies/`.

Next run:

```matlab
CHECK_INSTALLATION
```

For a complete five-method run, confirm that it reports:

```text
TVAL3: available
L1-Magic: available
FDRI: available
Full five-method simulation: READY
```

If it reports `Full five-method simulation: NOT YET READY`, read the missing-dependency lines above it and rerun `INSTALL_EXTERNAL_DEPENDENCIES` if needed.

Finally run:

```matlab
RUN_SIMULATION
```

## Choose the image

At the top of `RUN_SIMULATION.m`:

```matlab
imageMode = "tutorial";
```

uses MATLAB's `cameraman.tif` and the same image-preparation convention used for the tutorial benchmark.

Change it to:

```matlab
imageMode = "choose";
```

and MATLAB opens a file-selection dialog. Reader-selected images are converted to 8-bit grayscale before the same 128 × 128 Hadamard SPI workflow is applied.

## Choose the sampling percentages

The default is intentionally short:

```matlab
samplingPercents = [5 20 50];
```

You may change it, for example, to:

```matlab
samplingPercents = [5 10 15 20 30 40 50];
```

FDRI forms large explicit matrices, so high sampling percentages can require substantial RAM.

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

The code favors readable, sequential implementations that mirror the tutorial equations.

## What `CHECK_INSTALLATION` means

`CHECK_INSTALLATION` does not run a reconstruction. It reports which reader workflows are ready:

- `Frozen tutorial reproduction: READY` means Path A can be run.
- `Partial simulation (Direct + TVAL3, plus installed methods): READY` means Path B can be run.
- `Full five-method simulation: READY` means Path C can be run.

`NOT YET READY` is a status message, not an error. It identifies a missing requirement for that specific path.

## Important distinction: frozen reproduction vs new simulation

`REPRODUCE_TUTORIAL_RESULTS.m` regenerates the tutorial figures from **frozen validated numerical results**. It does not rerun the reconstruction algorithms.

`RUN_SIMULATION.m` performs a **new numerical run**. Timing and iterative-solver trajectories can vary with computer, MATLAB version, and selected image. The generated results are kept separate from the frozen tutorial results.

## Iterative solvers with a reader-selected image

The solver settings shown in S05–S07 reproduce the revised tutorial benchmark and are not universal tuning recommendations. TVAL3 uses isotropic TV (`TVnorm=2`), a nonnegative image constraint, and the complete fixed option set declared in S06. Its `tol` value is an outer relative-change stopping control, not a measurement-residual tolerance.

For a different image, an iterative solver may reach its maximum iteration limit before satisfying its internal stopping criterion. The reader-facing S06 reports the actual limit or stopping condition. The reconstructed image is still returned and evaluated, but the message indicates that the benchmark settings may need retuning for the new image.

## Included tutorial figures

The repository includes the visually reviewed reader-facing reproductions generated from the frozen tutorial data:

```text
figures/tutorial_reproduction/
├── figure13_reproduced.png
├── figure14_reproduced.png
├── figure15_reproduced.png
└── figure16_reproduced.png
```

Readers can view these immediately or regenerate them with `REPRODUCE_TUTORIAL_RESULTS.m`.

## Repository use

This directory is intended to live at:

```text
matlab/section7_8_simulation/
```

The normal reader entry points are:

```text
REPRODUCE_TUTORIAL_RESULTS.m
INSTALL_EXTERNAL_DEPENDENCIES.m
CHECK_INSTALLATION.m
RUN_SIMULATION.m
```

Files under `functions/` and `support/` are called automatically and do not need to be edited for a normal run. Downloaded L1-Magic and FDRI files are created locally under `external_dependencies/` and are intentionally excluded from version control.

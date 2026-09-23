# Hadamard SPI — Sections 7–8 simulation

This module separates **reproduction of the reference tutorial results** from **new simulations**. Choose the path that matches what you want to do.

## Quick start

| Goal | Commands | External downloads |
|---|---|---|
| A. Reproduce reference tutorial figures | `CHECK_INSTALLATION`, `REPRODUCE_TUTORIAL_RESULTS` | None |
| B. New Direct + TVAL3 simulation | `CHECK_INSTALLATION`, `RUN_SIMULATION` | None |
| C. New five-method simulation | `INSTALL_EXTERNAL_DEPENDENCIES`, `CHECK_INSTALLATION`, `RUN_SIMULATION` | L1-Magic + FDRI |

## A. Reproduce the reference tutorial results

From this directory run:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

`REPRODUCE_TUTORIAL_RESULTS` reads the included reference numerical results. **No reconstruction solver is executed in this mode.** It creates reproductions of Figures 13–16 under:

```text
figures/tutorial_reproduction/
```

This is the fastest way to reproduce the numerical results reported in the tutorial.

A representative expected output is included in the repository:

<img src="../../docs/assets/sections7_8_expected_output.png" alt="Representative Sections 7–8 reconstruction comparison" width="900">

## B. Run a new Direct + TVAL3 simulation

Direct and TVAL3 are available without installing L1-Magic or FDRI. Run:

```matlab
CHECK_INSTALLATION
RUN_SIMULATION
```

If external dependencies are absent, the scripts report them as unavailable and skip the corresponding stages:

- missing FDRI → S04 is skipped;
- missing L1-Magic → S05 and S07 are skipped;
- Direct (S03) and TVAL3 (S06) still run;
- S08 evaluates only reconstruction files created in the current clean run.

New-run numerical files are written under `results/` and summary figures are written under `figures/simulation/`.

## C. Run a new five-method simulation

The five-method simulation uses Direct, FDRI, DCT-l1, TVAL3, and TV-QC. TVAL3 is already supplied under `third_party/`. L1-Magic and FDRI must be downloaded by the reader.

Download the dependency ZIPs from:

- **L1-Magic 1.11:** official site https://candes.su.domains/software/l1magic/; direct official ZIP https://candes.su.domains/software/l1magic/downloads/l1magic-1.11.zip. The GitHub copy https://github.com/scgt/l1magic is an optional mirror.
- **FDRI-single-pixel-imaging:** official project page https://www.igf.fuw.edu.pl/fdri. That page points readers to https://github.com/KMCzajkowski/FDRI-single-pixel-imaging; use **Code → Download ZIP** on the GitHub repository.

Keep the downloaded ZIP files compressed.

Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

For a complete five-method run, `CHECK_INSTALLATION` should report:

```text
TVAL3: available
L1-Magic: installed; TV-QC compatibility patch present
FDRI: installed
Full five-method simulation: READY
```

## Choose the image

At the top of `RUN_SIMULATION.m`:

```matlab
imageMode = "tutorial";
```

uses MATLAB's `cameraman.tif` and the same image-preparation convention used for the tutorial benchmark.

Set:

```matlab
imageMode = "choose";
```

to select another image.

## Choose the sampling percentages

The default is:

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

## Reference-result reproduction vs new simulation

`REPRODUCE_TUTORIAL_RESULTS.m` regenerates the tutorial figures from the included reference numerical results. It does not rerun the reconstruction algorithms.

`RUN_SIMULATION.m` performs a new numerical run. Timing and iterative-solver trajectories can vary with computer, MATLAB version, and selected image. Generated outputs remain separate from the included reference results.

## Iterative solvers with a reader-selected image

The solver settings shown in S05–S07 reproduce the tutorial benchmark and are not universal tuning recommendations. TVAL3 uses isotropic TV (`TVnorm=2`), a nonnegative image constraint, and the fixed option set declared in S06. Its `tol` value is an outer relative-change stopping control, not a measurement-residual tolerance.

For a different image, an iterative solver may reach its maximum iteration limit before satisfying its internal stopping criterion. S06 reports the actual stopping condition.

## Generated tutorial figures

Running `REPRODUCE_TUTORIAL_RESULTS.m` creates:

```text
figures/tutorial_reproduction/
├── figure13_reproduced.png
├── figure14_reproduced.png
├── figure15_reproduced.png
└── figure16_reproduced.png
```

These generated files are intentionally not version-controlled. The repository includes the reference numerical results used to recreate them and a representative expected-output image under `docs/assets/`.

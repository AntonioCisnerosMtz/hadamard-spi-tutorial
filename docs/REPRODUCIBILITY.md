# Reproducibility

This guide summarizes what a reader can reproduce with the software repository and the separate experimental dataset.

## Sections 7–8

### Recreate the tutorial reference figures

From `matlab/section7_8_simulation/`, run:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

This route reads the reference numerical results included with the repository and recreates Figures 13–16. It does not execute the reconstruction solvers.

Expected output directory:

```text
matlab/section7_8_simulation/figures/tutorial_reproduction/
```

### Run a new Direct + TVAL3 simulation

Run:

```matlab
CHECK_INSTALLATION
RUN_SIMULATION
```

Direct and the bundled TVAL3 solver run without L1-Magic or FDRI. If either external package is absent, the stages that require it are skipped.

Reader-generated results are written under `results/`, and generated figures are written under `figures/simulation/`.

### Run all five reconstruction methods

Download the public ZIP archives for L1-Magic and FDRI, keep them compressed, and run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

The complete simulation includes Direct, FDRI, DCT-l1, TVAL3, and TV-QC.

## Section 9

Section 9 requires the separate companion experimental dataset. Install the dataset payload as described in `docs/REPRODUCE_SECTION9.md`.

From `matlab/section9_pipeline/`, run:

```matlab
CHECK_INSTALLATION
RUN_SECTION9_ANALYSIS
```

For the tutorial case, keep:

```matlab
selectedDataset = "paw_print";
generateFigures = true;
```

A complete `paw_print` run should produce:

- 16,384 positive bucket measurements;
- 16,384 complementary bucket measurements;
- the 5:5:100% sampling grid;
- 60 Direct reconstructions;
- 60 TVAL3 reconstructions;
- 120 image-quality evaluations;
- S9_01–S9_05 figure exports.

`USAF` and `logo` are additional experimental signals that use the same processing pipeline.

## What should agree

For a reproduction run, compare:

- array dimensions and measurement counts;
- sampling percentages and retained-measurement counts;
- fixed solver options;
- reconstructed image values within normal floating-point and iterative-solver variation;
- RMSE, NRMSE, PSNR, and SSIM values;
- expected figure content and ordering.

Reference diagnostics are stored under `validation/`.

## What can vary

Wall-clock times depend on hardware and software environment. Iterative solvers can also show small differences in trajectories or stopping behavior across MATLAB releases and computers.

MAT files may include creation metadata and timing information, so regenerated files need not be byte-identical to the supplied reference files. Numerical equivalence is the relevant scientific comparison.

Some low-sampling TVAL3 cases may reach iteration or continuation limits. The scripts record the stopping behavior; such a message is not by itself evidence that the pipeline failed.

## Tested environment

The workflows were tested with MATLAB R2026a on Windows 64-bit. This is a tested environment, not a minimum supported MATLAB release.

See also:

- `docs/INSTALLATION.md`
- `docs/DEPENDENCIES.md`
- `docs/DATA_FORMAT.md`
- `docs/REPRODUCE_SECTION9.md`
- `matlab/section7_8_simulation/README.md`
- `matlab/section9_pipeline/README.md`

# Reproduce Section 9 from a fresh installation

Follow these steps to reproduce the `paw_print` tutorial example using a fresh software copy and the separate experimental dataset.

## 1. Prepare clean software and data copies

Use a fresh copy of the software package and extract the companion experimental dataset separately.

The software package does **not** contain the large raw detector records.

## 2. Install the data payload

Copy everything **inside** the companion dataset's `payload/` directory into:

```text
matlab/section9_pipeline/
```

After copying, verify that these paths exist directly under `section9_pipeline/`:

```text
raw/paw_print/
raw/USAF/
raw/logo/
data/pattern_manifest.csv
reference_results/paw_print/
reference_figures/paw_print/
```

If you see `section9_pipeline/payload/raw/...`, the data are nested one level too deep.

## 3. Check the installation

From `matlab/section9_pipeline/`, run:

```matlab
CHECK_INSTALLATION
```

Resolve any `FAIL` entry before continuing. The final line must report:

```text
Installation ready.
```

## 4. Select the manuscript dataset

In the **User settings** section of `RUN_SECTION9_ANALYSIS.m`, keep:

```matlab
selectedDataset = "paw_print";
generateFigures = true;
```

Valid dataset values are `"paw_print"`, `"USAF"`, and `"logo"`. `paw_print` is the Section 9 manuscript case.

## 5. Run the complete analysis

Run:

```matlab
RUN_SECTION9_ANALYSIS
```

The launcher executes M02→M06 automatically: bucket extraction, measurement-vector formation, Direct reconstruction, TVAL3 reconstruction, quality evaluation, and figure export.

A successful `paw_print` run should structurally report:

- 16,384 positive and 16,384 complementary bucket values;
- the 5:5:100% sampling grid;
- 60 Direct reconstructions;
- 60 TVAL3 reconstructions;
- 120 reconstruction/metric evaluations;
- successful S9_01–S9_05 figure export.

Exact timing values and iterative-solver trajectories are not expected to be identical across computers.

## 6. Expected numerical outputs

```text
results/paw_print/bucket_measurements.mat
results/paw_print/measurement_vectors.mat
results/paw_print/direct_reconstructions.mat
results/paw_print/tval3_reconstructions.mat
results/paw_print/quality_metrics.csv
results/paw_print/quality_evaluation.mat
```

## 7. Expected figure outputs

```text
figures/paw_print/S9_01_detector_and_measurement_vectors.[png|pdf|eps]
figures/paw_print/S9_02_ydiff_direct_vs_tval3_partial.[png|pdf|eps]
figures/paw_print/S9_03_yref_direct_vs_tval3_partial.[png|pdf|eps]
figures/paw_print/S9_04_yavg_direct_vs_tval3_partial.[png|pdf|eps]
figures/paw_print/S9_05_all_paths_quality_nrmse_ssim.[png|pdf|eps]
```

Installed checkpoints remain under `reference_results/paw_print/` and `reference_figures/paw_print/`; the analysis does not overwrite them.

## 8. Additional experimental signals

After `paw_print` succeeds, repeat the analysis by setting:

```matlab
selectedDataset = "USAF";
```

or:

```matlab
selectedDataset = "logo";
```

These are additional examples.

## 9. Figure-only regeneration

If M02–M06 outputs already exist, regenerate figures without rerunning the analysis with, for example:

```matlab
generate_section9_figures("paw_print")
```

See `matlab/section9_pipeline/README.md` for the full reader guide and solver/reference-output notes.

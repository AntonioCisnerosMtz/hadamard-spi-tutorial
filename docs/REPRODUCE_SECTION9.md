# Reproduce the experimental workflow

## 1. Prepare a clean working copy

Use a fresh copy of the software repository and the companion data record. No private project folders are required.

## 2. Install the data payload

Copy everything inside the companion dataset's `payload/` directory into:

`matlab/section9_pipeline/`

The three raw input pairs are then located under:

- `raw/paw_print/`
- `raw/USAF/`
- `raw/logo/`

All three use the published `data/pattern_manifest.csv` in the reader workflow. Immutable reference outputs are supplied only for `paw_print` under `reference_results/paw_print/` and `reference_figures/paw_print/`.

## 3. Check the installation

From `matlab/section9_pipeline/`, run:

```matlab
CHECK_INSTALLATION
```

Resolve any `FAIL` entries before reconstruction.

## 4. Select a dataset in the launcher

Open `RUN_SECTION9_ANALYSIS.m` and edit the single user-setting line:

```matlab
selectedDataset = "paw_print";
```

Valid values are `"paw_print"`, `"USAF"`, and `"logo"`. `paw_print` is the Section 9 manuscript case; `USAF` and `logo` are additional experimental signals.

## 5. Execute M02 → M06

Press **Run** in `RUN_SECTION9_ANALYSIS.m`. The launcher passes `selectedDataset` explicitly to M02–M06, then performs bucket extraction, measurement-vector formation, Direct reconstruction, TVAL3 reconstruction, and quality evaluation.

Outputs are written to `results/<selectedDataset>/`. For example, `paw_print` produces:

- `results/paw_print/bucket_measurements.mat`
- `results/paw_print/measurement_vectors.mat`
- `results/paw_print/direct_reconstructions.mat`
- `results/paw_print/tval3_reconstructions.mat`
- `results/paw_print/quality_metrics.csv`
- `results/paw_print/quality_evaluation.mat`

The immutable dataset checkpoints remain under `reference_results/paw_print/`.

## 6. Generate figures

With the default `generateFigures = true`, `RUN_SECTION9_ANALYSIS.m` generates figures automatically for the selected dataset. To regenerate them manually without rerunning M02–M06, call, for example:

```matlab
generate_section9_figures("logo")
```

There is one public exporter: `generate_section9_figures.m`. `RUN_SECTION9_ANALYSIS.m` passes the same `selectedDataset` to it automatically when `generateFigures = true`. It writes to `figures/<dataset>/`. The `paw_print` output reproduces the manuscript figure family; USAF and logo use the same layouts as reader-facing diagnostic figures. Immutable `reference_figures/paw_print/` are never overwritten.

## 7. Reference-output policy

The tutorial declares `Direct + yDiff + 100%` for `paw_print` as an **internal reference**, not ground truth. Frozen `paw_print` results provide regression checkpoints for the manuscript example.

`USAF` and `logo` are intentionally distributed without frozen manuscript-reference results; their purpose is to let readers run the same pipeline on additional experimental signals.

Regenerated MATLAB files need not be byte-identical because MAT files can store creation metadata and TVAL3 records elapsed runtime. Numerical equivalence is the relevant scientific criterion.

# Hadamard SPI — Section 9 experimental workflow

This is the reader-facing workflow for processing the experimental detector records used in Section 9 of the tutorial.

The normal entry point is `RUN_SECTION9_ANALYSIS.m`. A clean reader run should not require private project folders or manual calls to M02–M06.

## Quick start

1. Download and extract the companion experimental dataset.
2. Copy the **contents of the dataset `payload/` directory** into this directory.
3. Run `CHECK_INSTALLATION` and confirm `Installation ready.`
4. Keep `selectedDataset = "paw_print"` for the manuscript example.
5. Run `RUN_SECTION9_ANALYSIS`.
6. Inspect `results/paw_print/` and `figures/paw_print/`.

`paw_print` is the manuscript reference case. `USAF` and `logo` are additional reader-executable examples that use the same pipeline.

## 1. Install the companion dataset

The experimental records are intentionally distributed separately from the software package.

**Reserved companion dataset DOI:** `10.5281/zenodo.22070080` — dataset publication pending.

After downloading the companion dataset ZIP, extract it to a convenient location. Inside it, locate:

```text
payload/
```

Copy **everything inside `payload/`** into:

```text
matlab/section9_pipeline/
```

Do not copy the outer `payload` directory as an extra nested folder.

Correct layout:

```text
matlab/section9_pipeline/
├── raw/
│   ├── paw_print/
│   ├── USAF/
│   └── logo/
├── data/
│   └── pattern_manifest.csv
├── reference_results/
│   └── paw_print/
└── reference_figures/
    └── paw_print/
```

Incorrect extra nesting:

```text
matlab/section9_pipeline/payload/raw/...
```

If the data are nested that way, move the **contents** of `payload/` up one level.

## 2. Verify the installation before reconstruction

Open MATLAB with this directory as the current folder and run:

```matlab
CHECK_INSTALLATION
```

A ready installation reports PASS for MATLAB/toolbox checks, bundled TVAL3, the published pattern manifest, and all three raw positive/complementary record pairs. The final line should be:

```text
Installation ready.
```

If any line reports `FAIL`, correct that item before running the analysis. The most common data-installation problem is an extra `payload/` directory level.

`CHECK_INSTALLATION` only verifies availability; it does not perform a reconstruction.

## 3. Select the dataset

Near the top of `RUN_SECTION9_ANALYSIS.m`, edit only the **User settings** when making a normal reader run:

```matlab
selectedDataset = "paw_print";  % "paw_print", "USAF", or "logo"
generateFigures = true;
```

Use:

- `"paw_print"` — Section 9 manuscript case and the dataset with frozen reference checkpoints;
- `"USAF"` — additional experimental signal;
- `"logo"` — additional experimental signal.

Run `paw_print` first when checking manuscript reproducibility.

## 4. Run the complete Section 9 analysis

Run:

```matlab
RUN_SECTION9_ANALYSIS
```

The launcher executes the reader analysis in order:

```text
M02  raw detector records -> positive/complementary bucket measurements
M03  bucket measurements -> yDiff, yRef, and yAvg measurement vectors
M04  Direct Hadamard reconstructions
M05  TVAL3 reconstructions
M06  RMSE / NRMSE / PSNR / SSIM evaluation
     optional figure export when generateFigures = true
```

`M01_generate_gcss_dmd_patterns.m` is an optional **pre-acquisition** pattern generator. It is not required to reprocess the supplied experimental detector records.

The workflow corresponds to the processing chain shown below.

<img src="../../docs/assets/section9_workflow.png" alt="Section 9 experimental processing workflow" width="900">

## 5. What a successful `paw_print` run should report

Do not compare wall-clock times exactly; they depend on hardware and MATLAB version. Instead, use the structural milestones below:

```text
yPositive:       16384 x 1
yComplementary:  16384 x 1
N = 16384 measurements at 100% sampling
Sampling grid: 5 10 15 ... 95 100 %
Direct reconstruction grid completed
Images saved: 60
TVAL3 reconstruction grid completed
Images saved: 60
Quality evaluation completed
Evaluated reconstructions: 120
Figure export complete
```

TVAL3 may report iteration-limit messages for individual low-sampling cases. Those messages are solver stopping diagnostics and are not, by themselves, a workflow failure. The software records the actual stopping behavior rather than describing every returned image as tolerance-converged.

## 6. Expected outputs

For `selectedDataset = "paw_print"`, numerical outputs are written under:

```text
results/paw_print/
├── bucket_measurements.mat
├── measurement_vectors.mat
├── direct_reconstructions.mat
├── tval3_reconstructions.mat
├── quality_metrics.csv
└── quality_evaluation.mat
```

With `generateFigures = true`, the figure exporter writes:

```text
figures/paw_print/
├── S9_01_detector_and_measurement_vectors.png/.pdf/.eps
├── S9_02_ydiff_direct_vs_tval3_partial.png/.pdf/.eps
├── S9_03_yref_direct_vs_tval3_partial.png/.pdf/.eps
├── S9_04_yavg_direct_vs_tval3_partial.png/.pdf/.eps
└── S9_05_all_paths_quality_nrmse_ssim.png/.pdf/.eps
```

The same folder pattern is used for `USAF` and `logo` under their own dataset names.

## 7. Reference results are read-only checkpoints

The installed companion dataset keeps manuscript checkpoints under:

```text
reference_results/paw_print/
reference_figures/paw_print/
```

The normal M02–M06 workflow writes only to `results/<dataset>/` and `figures/<dataset>/`; it does not overwrite the installed reference checkpoints.

The tutorial uses the 100% Direct `yDiff` reconstruction as an **internal reference**, not as physical ground truth.

Regenerated MAT files need not be byte-identical because MAT files can store creation metadata and solver timing values. Numerical equivalence is the scientific comparison of interest.

## 8. Generate figures without rerunning M02–M06

If the analysis results already exist, figures can be regenerated manually, for example:

```matlab
generate_section9_figures("paw_print")
```

or:

```matlab
generate_section9_figures("USAF")
generate_section9_figures("logo")
```

## 9. Reproducibility note for TVAL3

The post-peer-review software uses the fixed TVAL3 option set declared directly in `M05_reconstruct_tval3_images.m`, including isotropic TV (`TVnorm=2`) and nonnegativity. Its `tol=1e-6` value is the TVAL3 outer relative-change stopping control, not a measurement-residual tolerance.

Readers normally do not need to edit those solver options to reproduce the tutorial workflow.

## Related documentation

- [Repository start page](../../README.md)
- [Clean-room Section 9 reproduction guide](../../docs/REPRODUCE_SECTION9.md)
- [Data formats](../../docs/DATA_FORMAT.md)
- [Dependencies](../../docs/DEPENDENCIES.md)

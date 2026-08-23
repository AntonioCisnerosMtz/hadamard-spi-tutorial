# Hadamard-based single-pixel imaging tutorial — MATLAB workflow

This repository contains the reader-facing MATLAB workflow supporting **“Hadamard-Based Single-Pixel Imaging: From Detector Signals to Image Reconstruction.”**

## Start here

For reconstruction of the published detector signals, the normal reader entry point is:

`matlab/section9_pipeline/RUN_SECTION9_ANALYSIS.m`

Readers normally change only `selectedDataset` (and, if desired, `generateFigures`) in the **User settings** section, then press **Run**. M02--M06 are called automatically. `M01_generate_gcss_dmd_patterns.m` is a separate optional pre-acquisition utility and is not required to reconstruct the published signals.

The workflow follows the experimental chain described in the tutorial:

1. optional pre-acquisition generation of GCS+S Hadamard DMD masks (`M01`);
2. raw detector signal → one bucket value per displayed mask (`M02`);
3. formation of `yDiff`, `yRef`, and `yAvg` (`M03`);
4. Direct Hadamard reconstruction (`M04`);
5. TVAL3 reconstruction (`M05`);
6. image-quality evaluation using the declared internal reference (`M06`).

## Published experimental signals

The companion dataset contains three positive/complementary detector-record pairs:

- `paw_print` — the worked experimental example used in Section 9 of the tutorial and the dataset with frozen reference results;
- `USAF` — an additional experimental signal for running the same reader workflow;
- `logo` — an additional experimental signal for running the same reader workflow.

`paw_print` is the manuscript case. `USAF` and `logo` are provided so readers can execute the same processing chain on additional experimental signals; they are not manuscript reference cases.

## Requirements

- MATLAB. The workflow has been clean-room tested with **R2026a Update 4** on Windows 64-bit; this is a tested environment, not a minimum-version claim.
- Image Processing Toolbox (`imresize`, `ssim`).
- Signal Processing Toolbox (`findpeaks`).
- TVAL3 beta 2.4 is preserved under `matlab/section9_pipeline/third_party/` because the historical official download is no longer a dependable acquisition route. See `THIRD_PARTY_NOTICES.md`.

## Data installation

Large experimental data are distributed separately as the companion Zenodo dataset:

**Dataset v1.0.0 DOI:** https://doi.org/10.5281/zenodo.22070080

Copy the **contents** of that dataset's `payload/` directory into:

`matlab/section9_pipeline/`

After copying, the pipeline directory should contain:

```text
raw/USAF/
raw/logo/
raw/paw_print/
data/pattern_manifest.csv
reference_results/paw_print/   # immutable regression checkpoints
reference_figures/paw_print/   # immutable manuscript-style exports
```

Generated files are intentionally separate:

```text
results/<dataset>/              # created by M02-M06
figures/<dataset>/              # generated for the selected dataset
generated_patterns/             # created only by optional M01
```

## Quick start

1. Open MATLAB in `matlab/section9_pipeline/`.
2. Run `CHECK_INSTALLATION.m` once after installing the data payload.
3. Open `RUN_SECTION9_ANALYSIS.m` and change **one line** in the `User settings` section:

```matlab
% Available datasets: "paw_print", "USAF", and "logo"
selectedDataset = "paw_print";
```

4. Press **Run**. The launcher passes that dataset explicitly to M02 → M06 and writes to `results/<dataset>/`.
5. Leave `generateFigures = true` in `RUN_SECTION9_ANALYSIS.m` to export figures automatically for the selected dataset. The same single exporter supports `paw_print`, `USAF`, and `logo`. The `paw_print` figure set corresponds to the Section 9 manuscript case.

The dataset selector belongs in `RUN_SECTION9_ANALYSIS.m`; readers do not need to edit `section9_config.m`. The selected value is passed explicitly to every processing module.

A successful run creates six analysis files under `results/<dataset>/` and, when `generateFigures = true`, five figure groups under `figures/<dataset>/` (PNG/PDF/EPS). TVAL3 is iterative and is expected to take substantially longer than the Direct reconstruction.

### M01 is optional and can create many files

`M01_generate_gcss_dmd_patterns.m` is a separate **pre-acquisition** utility and is not required to reconstruct the published detector records. At the default 128×128 logical grid it creates **16,384 positive and 16,384 complementary PNG frames**. All M01 outputs are written under `generated_patterns/`, including the newly generated `pattern_manifest.csv`. M01 intentionally does **not** overwrite the experimental `data/pattern_manifest.csv` installed with the published dataset.

See `docs/INSTALLATION.md`, `docs/REPRODUCE_SECTION9.md`, `docs/REPRODUCIBILITY_TEST.md`, and `docs/DATA_FORMAT.md`.

## Scientific scope

This repository focuses on the real-data Hadamard SPI chain used by the tutorial. Broader simulation/benchmark material involving FDRI and L1-Magic is not bundled in this minimum reader workflow.

## Licensing

Original tutorial code is released under the **BSD 3-Clause License**. Bundled TVAL3 beta 2.4 is third-party software and is **not covered by BSD-3-Clause**; it retains the preserved upstream unversioned GNU GPL notice. See `LICENSE_SCOPE.md`, `THIRD_PARTY_NOTICES.md`, and `LICENSES/` for exact scope and provenance. The companion experimental dataset is released separately under **CC BY 4.0**.

## Citation

Citation metadata for the software are provided in `CITATION.cff`.

Companion dataset v1.0.0: https://doi.org/10.5281/zenodo.22070080

The software DOI and tutorial/article DOI will be added when those identifiers exist.

# Hadamard-based single-pixel imaging tutorial — MATLAB scripts

MATLAB scripts for **Hadamard-Based Single-Pixel Imaging: From Detector Signals to Image Reconstruction**.

**v1.2.1 is a documentation update.** Scientific code, parameters, data, and reference results are unchanged from v1.2.0.

- **Sections 7–8:** reproduce saved results or run new simulations.
- **Section 9:** reconstruct images from experimental detector signals. The dataset is a separate download.

## Sections 7–8: simulations

Open MATLAB with `matlab/section7_8_simulation/` as the current folder.

### Reproduce the saved tutorial results

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

This reads the saved results and recreates Figures 13–16. It does not run reconstruction solvers. Figures are saved in `figures/tutorial_reproduction/`.

<img src="docs/assets/sections7_8_expected_output.png" alt="Sections 7–8 reconstruction comparison" width="900">

### Run Direct + TVAL3

```matlab
CHECK_INSTALLATION
RUN_SIMULATION
```

TVAL3 is included. If L1-Magic or FDRI is missing, the scripts skip the methods that need it. Direct and TVAL3 still run. Installed methods also run.

### Run all five methods

The five methods are Direct, FDRI, DCT-l1, TVAL3, and TV-QC. Download these two repositories using **Code → Download ZIP**:

- [L1-Magic](https://github.com/scgt/l1magic)
- [FDRI](https://github.com/KMCzajkowski/FDRI-single-pixel-imaging)

Keep both ZIP files compressed. Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

The installer asks you to select the ZIP files. Before running the simulation, check for:

```text
TVAL3: available
L1-Magic: available
FDRI: available
Full five-method simulation: READY
```

`NOT YET READY` identifies a missing requirement for that option. Read the lines above it to see what is missing.

### Select another image and find the outputs

At the top of `RUN_SIMULATION.m`, keep `imageMode = "tutorial"` to use the tutorial image. Set `imageMode = "choose"` to select another image.

New results go to `results/`. New figures go to `figures/simulation/`. Saved tutorial results remain in `frozen_results/`.

See the [Sections 7–8 guide](matlab/section7_8_simulation/README.md) for sampling settings and solver details.

## Section 9: experimental data

### Download and copy the dataset

The detector records are distributed separately from the software. The dataset DOI is reserved as `10.5281/zenodo.22070080`; publication is pending.

Once the companion dataset is available, download and extract it. Copy the **contents of `payload/`**, not the folder itself, into:

```text
matlab/section9_pipeline/
```

These paths should then exist directly inside that folder:

```text
raw/paw_print/
raw/USAF/
raw/logo/
data/pattern_manifest.csv
reference_results/paw_print/
reference_figures/paw_print/
```

If you see `section9_pipeline/payload/raw/`, move the contents of `payload/` up one level.

### Check the installation and run the example

Open MATLAB with `matlab/section9_pipeline/` as the current folder. Run:

```matlab
CHECK_INSTALLATION
```

Fix any reported failures. Continue when the final line reads:

```text
Installation ready.
```

In the **User settings** of `RUN_SECTION9_ANALYSIS.m`, keep:

```matlab
selectedDataset = "paw_print";
generateFigures = true;
```

Then run:

```matlab
RUN_SECTION9_ANALYSIS
```

`paw_print` is the main tutorial example. After it succeeds, try `selectedDataset = "USAF"` or `selectedDataset = "logo"` for the additional examples.

The scripts read detector signals, extract positive and complementary buckets, form measurement vectors, reconstruct images with Direct and TVAL3, and calculate image-quality metrics.

<img src="docs/assets/section9_workflow.png" alt="Section 9 data processing and reconstruction steps" width="900">

### Find the results and figures

Under `matlab/section9_pipeline/`, results for the main example are saved in `results/paw_print/`:

```text
bucket_measurements.mat
measurement_vectors.mat
direct_reconstructions.mat
tval3_reconstructions.mat
quality_metrics.csv
quality_evaluation.mat
```

Figures S9_01–S9_05 are saved in `figures/paw_print/` as PNG, PDF, and EPS files. The installed files in `reference_results/` and `reference_figures/` are kept separate.

See the [Section 9 guide](matlab/section9_pipeline/README.md) for output counts, figure names, and troubleshooting.

## Requirements

- Both sections need MATLAB and Image Processing Toolbox (`imresize`, `ssim`). TVAL3 beta 2.4 is included.
- Sections 7–8 need L1-Magic and FDRI only for the complete five-method simulation.
- Section 9 also needs Signal Processing Toolbox (`findpeaks`) and the separate experimental dataset.

The v1.2.0 scripts were tested on a fresh installation with MATLAB R2026a on Windows 64-bit. This is the tested environment, not a minimum version. Run times and iterative solver results can vary with the computer and MATLAB version.

## License and citation

Original code and documentation use the **BSD 3-Clause License**. TVAL3 has its own license. L1-Magic and FDRI are downloaded separately. See [License scope](LICENSE_SCOPE.md) and [Third-party notices](THIRD_PARTY_NOTICES.md).

Software citation details are in [CITATION.cff](CITATION.cff). The earlier software DOIs are `10.5281/zenodo.22133874` (v1.1.0) and `10.5281/zenodo.22070980` (v1.0.0).

The companion dataset is planned for a separate CC BY 4.0 release. No Zenodo record or dataset is changed by this documentation update.

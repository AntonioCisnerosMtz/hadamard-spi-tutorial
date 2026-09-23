# Hadamard-based single-pixel imaging tutorial — MATLAB scripts

MATLAB scripts accompanying **Hadamard-Based Single-Pixel Imaging: From Detector Signals to Image Reconstruction**.

The repository is organized around two reader workflows:

- **Sections 7–8:** reproduce the included reference results or run new Hadamard SPI simulations.
- **Section 9:** process experimental detector signals, reconstruct images, evaluate image quality, and regenerate the tutorial figure family.

For a concise reproducibility checklist, see [docs/REPRODUCIBILITY.md](docs/REPRODUCIBILITY.md).

## Sections 7–8: simulations

Open MATLAB with `matlab/section7_8_simulation/` as the current folder.

### Reproduce the tutorial reference results

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

This reads the included reference numerical results and recreates Figures 13–16. It does not run reconstruction solvers. Figures are saved in `figures/tutorial_reproduction/`.

<img src="docs/assets/sections7_8_expected_output.png" alt="Sections 7–8 reconstruction comparison" width="900">

### Run Direct + TVAL3

```matlab
CHECK_INSTALLATION
RUN_SIMULATION
```

TVAL3 beta 2.4 is included. If L1-Magic or FDRI is not installed, the scripts skip the methods that require those packages. Direct and TVAL3 still run, together with any other installed methods.

### Run all five methods

The five methods are Direct, FDRI, DCT-l1, TVAL3, and TV-QC.

- **L1-Magic 1.11:** download the ZIP from the [official L1-Magic site](https://candes.su.domains/software/l1magic/) ([direct official ZIP](https://candes.su.domains/software/l1magic/downloads/l1magic-1.11.zip)). The [GitHub copy](https://github.com/scgt/l1magic) is an optional mirror.
- **FDRI:** the [official University of Warsaw project page](https://www.igf.fuw.edu.pl/fdri) states that the code was moved to the current [FDRI GitHub repository](https://github.com/KMCzajkowski/FDRI-single-pixel-imaging). Download that repository with **Code → Download ZIP**.

Keep both ZIP files compressed. Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
CHECK_INSTALLATION
RUN_SIMULATION
```

Before the complete five-method simulation, `CHECK_INSTALLATION` should report:

```text
TVAL3: available
L1-Magic: installed; TV-QC compatibility patch present
FDRI: installed
Full five-method simulation: READY
```

### Select another image and find the outputs

At the top of `RUN_SIMULATION.m`, keep `imageMode = "tutorial"` to use the tutorial image. Set `imageMode = "choose"` to select another image.

New numerical outputs go to `results/`. New figures go to `figures/simulation/`. The included reference results remain under `frozen_results/`.

See the [Sections 7–8 guide](matlab/section7_8_simulation/README.md) for sampling settings, solver details, and output locations.

## Section 9: experimental data

The detector records are distributed separately from the software. The companion dataset is currently a Zenodo draft with reserved DOI `10.5281/zenodo.22070080`; it is not public yet.

When the companion dataset is available, extract it and copy the **contents of `payload/`**, not the outer folder itself, into:

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

### Check the installation and run the worked example

Open MATLAB with `matlab/section9_pipeline/` as the current folder and run:

```matlab
CHECK_INSTALLATION
```

Continue when the final line reports:

```text
Installation ready.
```

In the **User settings** section of `RUN_SECTION9_ANALYSIS.m`, keep:

```matlab
selectedDataset = "paw_print";
generateFigures = true;
```

Then run:

```matlab
RUN_SECTION9_ANALYSIS
```

`paw_print` is the Section 9 worked example. After it succeeds, set `selectedDataset = "USAF"` or `selectedDataset = "logo"` to process the additional experimental signals.

The pipeline reads the detector records, extracts positive and complementary bucket measurements, forms measurement vectors, reconstructs images with Direct and TVAL3, evaluates image quality, and optionally exports the Section 9 figure family.

<img src="docs/assets/section9_workflow.png" alt="Section 9 data processing and reconstruction steps" width="900">

### Find the Section 9 outputs

For the worked example, numerical outputs are written to `matlab/section9_pipeline/results/paw_print/`:

```text
bucket_measurements.mat
measurement_vectors.mat
direct_reconstructions.mat
tval3_reconstructions.mat
quality_metrics.csv
quality_evaluation.mat
```

Figures S9_01–S9_05 are written to `figures/paw_print/` as PNG, PDF, and EPS files. Reference files supplied by the companion dataset remain separate under `reference_results/` and `reference_figures/`.

See the [Section 9 guide](matlab/section9_pipeline/README.md) and [fresh-install reproduction guide](docs/REPRODUCE_SECTION9.md) for details.

## Requirements

- MATLAB.
- Image Processing Toolbox for both workflows (`imresize`, `ssim`).
- Signal Processing Toolbox for Section 9 (`findpeaks`).
- TVAL3 beta 2.4 is bundled.
- L1-Magic and FDRI are required only for the complete five-method Sections 7–8 simulation.
- The companion experimental dataset is required for Section 9.

The workflows were tested with MATLAB R2026a on Windows 64-bit. This is a tested environment, not a minimum-version claim. Wall-clock times and iterative-solver trajectories can vary with hardware and MATLAB version.

## License and citation

Original code and documentation are distributed under the **BSD 3-Clause License**. Bundled TVAL3 is third-party software and retains its upstream licensing notice; it is not covered by the BSD 3-Clause license.

Human-readable license scope is described in [LICENSE_SCOPE.md](LICENSE_SCOPE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Per-file machine-readable license scope is declared in [REUSE.toml](REUSE.toml).

Software citation details are provided in [CITATION.cff](CITATION.cff). The companion dataset is intended for a separate CC BY 4.0 release.

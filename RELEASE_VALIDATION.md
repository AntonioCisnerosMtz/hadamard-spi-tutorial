# Release checks — v1.2.1

v1.2.1 changes documentation only. The comparison with v1.2.0 checks every MATLAB file, saved numerical result, solver option record, and figure byte for byte. Moving the numerical check files to `validation/` does not change their contents.

The numerical tests below were recorded for v1.2.0. They were not rerun for this documentation update.

## Sections 7–8

A fresh software installation completed:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

The saved tutorial results reproduced without running reconstruction solvers.

After installing L1-Magic and FDRI from their public ZIP downloads, `RUN_SIMULATION` completed Direct, FDRI, DCT-l1, TVAL3, and TV-QC at 5%, 20%, and 50% sampling. Image-quality evaluation also completed. TVAL3 used isotropic TV and reported its stopping conditions.

## Section 9

After installing the separate dataset into a fresh software copy, these commands completed with `selectedDataset = "paw_print"`:

```matlab
CHECK_INSTALLATION
RUN_SECTION9_ANALYSIS
```

The run produced:

- 16,384 positive and 16,384 complementary bucket values;
- the 5:5:100% sampling grid;
- 60 Direct and 60 TVAL3 reconstructions;
- 120 image-quality evaluations;
- the S9_01–S9_05 figures.

`USAF` and `logo` also completed earlier functional tests. They are additional examples.

## Documentation checks

The main README and section guides describe saved-result reproduction, Direct + TVAL3, all five methods, dependency installation, image selection, and Section 9 dataset installation. They include commands, expected installation messages, and output folders.

See [Numerical checks](validation/README.md) for the saved diagnostic files and [Reproducibility tests](docs/REPRODUCIBILITY_TEST.md) for details of the earlier tests.

The v1.2.0 and v1.1.0 tags and commits remain unchanged. Zenodo records and the experimental dataset are not modified.

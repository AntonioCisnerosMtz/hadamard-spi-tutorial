# Reproducibility tests

These tests were recorded for v1.2.0 using fresh software installations. v1.2.1 changes documentation only; it does not rerun or change the numerical results.

## Sections 7–8

The following commands completed:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

After installing L1-Magic and FDRI from their public ZIP downloads, `RUN_SIMULATION` also completed.

The saved tutorial figures reproduced without running reconstruction solvers. The new simulation completed Direct, FDRI, DCT-l1, TVAL3, and TV-QC, followed by image-quality evaluation.

## Section 9

On 2026-09-03, a fresh installation with the separate dataset completed:

```matlab
CHECK_INSTALLATION
RUN_SECTION9_ANALYSIS
```

The run used `selectedDataset = "paw_print"` and MATLAB R2026a on Windows 64-bit. It produced:

- 16,384 positive buckets;
- 16,384 complementary buckets;
- the 5:5:100% sampling grid;
- 60 Direct reconstructions;
- 60 TVAL3 reconstructions;
- 120 image-quality evaluations;
- the S9_01–S9_05 figures.

TVAL3 reported iteration limits for some low-sampling cases and completed all 20 sampling ratios. The analysis completed without errors.

Earlier Section 9 tests used MATLAB R2026a Update 4 on Windows 64-bit. `USAF` and `logo` also completed functional tests and produced results in their own folders.

## Comparing a new run

Run times depend on the computer. MAT files may include creation dates and solver timings, so newly generated files need not be byte-identical to saved files. Compare numerical values, dimensions, counts, solver settings, and expected outputs.

This differs from checking the v1.2.1 source release: its scientific files must be byte-identical to v1.2.0, since this update changes only documentation.

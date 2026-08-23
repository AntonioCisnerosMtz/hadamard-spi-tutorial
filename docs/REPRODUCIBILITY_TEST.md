# Clean-room reproducibility validation

## Validated manuscript case

The `paw_print` M02→M06 workflow was executed from a clean software/data copy without any additional project folders.

## Tested environment

- Test date: 2026-08-20
- MATLAB: R2026a Update 4
- MATLAB build: 26.1.0.3312084
- Platform: Windows 64-bit (`PCWIN64`)
- Required MathWorks functionality used successfully:
  - Image Processing Toolbox (`imresize`, `ssim`)
  - Signal Processing Toolbox (`findpeaks`)
- TVAL3: preserved beta 2.4 MATLAB source bundled with the repository
- Historical TVAL3 platform-specific MEX binaries: not required

This establishes a tested environment, not the minimum supported MATLAB release.

## Commands

From `matlab/section9_pipeline/`, set `selectedDataset = "paw_print"` and leave `generateFigures = true` in `RUN_SECTION9_ANALYSIS.m`, then run:

```matlab
RUN_SECTION9_ANALYSIS
```

For manual figure-only regeneration after M02--M06 outputs already exist, use `generate_section9_figures("paw_print")`.

## Regression result

Comparison with the frozen files now distributed under `reference_results/paw_print/` showed:

- bucket measurements: numerically/structurally identical;
- measurement vectors: numerically/structurally identical;
- Direct reconstructions: numerically/structurally identical;
- quality evaluation: numerically/structurally identical;
- `quality_metrics.csv`: byte-identical;
- TVAL3 reconstructions and solver data: identical except for expected `elapsedSeconds` runtime fields.

All five Section 9 figure groups were regenerated successfully from the current exporters.

## Additional-signal functional test

The public multi-dataset workflow was also run for `USAF` and `logo`. Both selections completed M02--M06 and produced the five S9-style figure groups in their own dataset folders. This verifies reader-facing dataset routing and execution; it does **not** promote either signal to a manuscript reference case or create article claims from their results.

A subsequent `paw_print` run produced a `quality_metrics.csv` that remained byte-identical to the frozen checkpoint distributed with the data record.

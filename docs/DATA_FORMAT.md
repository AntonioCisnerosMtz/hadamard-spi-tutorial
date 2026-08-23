# Data formats

## Raw detector records

The companion data record provides three dataset folders under `raw/`:

- `raw/paw_print/`
- `raw/USAF/`
- `raw/logo/`

Each folder contains exactly one positive record matching `*_pos_*_F.txt` and one complementary record matching `*_neg_*_F.txt`. The files are numeric detector-voltage samples stored as text. The pipeline preserves the pairing and acquisition order.

Do not infer undocumented acquisition settings solely from the historical filename grammar. For the manuscript `paw_print` case, use `metadata/acquisition_paw_print.json` in the companion dataset as the authoritative published acquisition metadata. `metadata/processing_USAF.json` and `metadata/processing_logo.json` document the released MATLAB processing parameters for those reader datasets without asserting undocumented acquisition hardware details.

## Pattern manifest

`data/pattern_manifest.csv` maps the 16,384 GCS+S acquisition positions to `(u,v)` Hadamard coordinates and the matching positive/complementary pattern identifiers. The released experimental records use this installed manifest.

`M01_generate_gcss_dmd_patterns.m` writes newly generated patterns and their manifest under `generated_patterns/` and intentionally does not replace the installed experimental manifest.

## Generated outputs

`results/<dataset>/bucket_measurements.mat` contains the positive and complementary bucket vectors plus transition/averaging diagnostics. Bucket values retain detector-voltage units.

`results/<dataset>/measurement_vectors.mat` contains the partial-sampling cases for `yDiff`, `yRef`, and `yAvg` on the 5:5:100% grid.

`results/<dataset>/direct_reconstructions.mat` and `tval3_reconstructions.mat` contain results for the three measurement-vector paths and the sampling-ratio grid.

`results/<dataset>/quality_metrics.csv` and `quality_evaluation.mat` use that dataset's 100% Direct `yDiff` reconstruction as the declared internal reference.

## Immutable `paw_print` checkpoints

The companion dataset stores validated manuscript checkpoints separately from reader-generated outputs:

- `reference_results/paw_print/` — frozen bucket values, measurement vectors, reconstructions, and metrics;
- `reference_figures/paw_print/` — frozen PNG/PDF manuscript-style figure exports.

The M02→M06 workflow never writes into these folders.

## Figure exporters

`generate_section9_figures.m` is the single public figure exporter. It accepts `paw_print`, `USAF`, or `logo`, reads `results/<dataset>/`, and writes S9_01–S9_05-style outputs to `figures/<dataset>/`. For `paw_print`, these reproduce the manuscript figure family. For USAF and logo, the same layouts are provided as reader-facing diagnostic figures.

# Clean-room reproducibility validation

## Post-peer-review reader validation

The v1.2.0 workflows were exercised from fresh extracted software copies rather than from the development project tree.

### Sections 7–8

The author clean-room validation completed both reader modes:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

and, after installing the public L1-Magic and FDRI ZIP dependencies:

```matlab
RUN_SIMULATION
```

The frozen tutorial figures reproduced without executing external solvers. The new five-method run completed Direct, FDRI, DCT-l1, TVAL3, and TV-QC, followed by quality evaluation.

### Section 9 manuscript case

On 2026-09-03, the author installed the separate companion dataset payload into a fresh RC3 software copy and ran:

```matlab
CHECK_INSTALLATION
RUN_SECTION9_ANALYSIS
```

with `selectedDataset = "paw_print"` and MATLAB R2026a on Windows 64-bit.

The clean-room run completed the full reader chain with these structural results:

- positive buckets: 16,384;
- complementary buckets: 16,384;
- sampling grid: 5:5:100%;
- Direct reconstructions: 60;
- TVAL3 reconstructions: 60;
- evaluated reconstructions: 120;
- S9_01–S9_05 figure families exported successfully.

The TVAL3 console output included the expected low-sampling iteration-limit diagnostics and completed all 20 sampling ratios. No workflow error occurred.

The final v1.2.0 numerical content is unchanged from the clean-room validated RC3. The RC4 assembly step changed only reader documentation/onboarding and documentation preview assets; numerical code, solver configuration, frozen Sections 7–8 results, and Section 9 analysis code were unchanged.

## Historical Section 9 validation

Earlier clean-room validation of the Section 9 reader workflow used MATLAB R2026a Update 4 on Windows 64-bit. The `USAF` and `logo` selections also completed the same dataset-routing workflow in functional testing. Those additional signals are reader examples, not manuscript reference cases.

## Reproducibility interpretation

Exact wall-clock times are hardware dependent. MAT files can also contain creation metadata and solver timing fields, so byte identity is not required for regenerated MAT files. Numerical equivalence, expected dimensions/counts, declared solver settings, and successful generation of the documented outputs are the relevant reproducibility checks.

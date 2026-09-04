# v1.2.0 release validation record

## Final verdict

**SOFTWARE v1.2.0 RELEASE PAYLOAD: AUTHOR-APPROVED**

The scientific and reader-facing validation gates required for the software release were completed before final package assembly.

## Scientific validation

### Sections 7–8 frozen-result reproduction — PASS

A clean extracted software copy completed:

```matlab
CHECK_INSTALLATION
REPRODUCE_TUTORIAL_RESULTS
```

The frozen tutorial results reproduced without executing external reconstruction solvers.

### Sections 7–8 complete five-method rerun — PASS

After installing the public L1-Magic and FDRI ZIP dependencies, a clean run of:

```matlab
RUN_SIMULATION
```

completed Direct, FDRI, DCT-l1, TVAL3, and TV-QC for the default 5%, 20%, and 50% grid, followed by image-quality evaluation. TVAL3 reported the approved isotropic configuration and actual stopping behavior.

### Section 9 `paw_print` clean-room workflow — PASS

After installing the separate companion dataset payload, a clean software copy completed:

```matlab
CHECK_INSTALLATION
RUN_SECTION9_ANALYSIS
```

with `selectedDataset = "paw_print"`.

The workflow produced 16,384 positive and 16,384 complementary bucket values, the 5:5:100% sampling grid, 60 Direct reconstructions, 60 TVAL3 reconstructions, 120 quality evaluations, and S9_01–S9_05 figure families.

### Reader onboarding — PASS

The root README and module documentation provide separate reader paths for:

- frozen Sections 7–8 reproduction;
- a new Direct + TVAL3 simulation;
- the complete five-method simulation with L1-Magic and FDRI;
- Section 9 experimental-data installation and processing.

L1-Magic and FDRI download links, ZIP-installation instructions, Section 9 payload placement, installation checks, expected outputs, and orientation figures are documented.

## Validation provenance

The scientific reruns were completed on the RC2/RC3 validation chain. RC4 changed documentation/onboarding and documentation preview assets only. The final v1.2.0 transformation from RC4 changes release-state documentation and checksums only; numerical MATLAB code, solver configuration, frozen numerical results, and post-peer-review validation data remain unchanged.

Additional `USAF` and `logo` datasets previously completed the common reader workflow in functional testing. They are additional reader examples rather than manuscript regression cases.

## Historical release protection

Historical `v1.1.0` remains a separate release. The v1.2.0 publication process must create a new commit/tag/release and must not move, recreate, or overwrite the v1.1.0 tag.

## Companion dataset

The companion experimental dataset is versioned and published separately. At software-package assembly its reserved DOI was `10.5281/zenodo.22070080` and publication remained pending. Dataset publication requires its own explicit author approval.

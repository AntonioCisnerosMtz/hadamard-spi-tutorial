# Third-party notices

## TVAL3 beta 2.4

The Section 9 TV reconstruction module uses **TVAL3 beta 2.4**, originally by Chengbo Li and Yin Zhang (Rice University), with Wotao Yin also identified in the preserved solver documentation.

This repository includes only the MATLAB solver files and utility functions required by the tutorial workflow. The bundled scientific solver files are copied from the preserved TVAL3 beta 2.4 distribution used for the tutorial and have not been altered. Historical platform-specific MEX binaries, demos, example images, and unrelated utilities are not included.

TVAL3 is third-party software. It is **not licensed under the BSD 3-Clause License that applies to the original tutorial code**.

The preserved upstream `Solver/readme.txt` states that TVAL3 may be redistributed and/or modified under the **GNU General Public License as published by the Free Software Foundation**. The upstream notice does not state a GPL version number. The notice is preserved verbatim in:

- `LICENSES/TVAL3_UPSTREAM_NOTICE.txt`
- `matlab/section9_pipeline/third_party/TVAL3_beta2.4/Solver/readme.txt`

Because the upstream notice is unversioned, this repository does not assign TVAL3 a version-specific GPL label. `LICENSES/TVAL3_LICENSE_INFO.md` explains the treatment of the notice, and the published GPL version 1, 2, and 3 texts are included in `LICENSES/`.

Provenance of the archived distribution held by the project:

- archive name: `TVAL3_beta2.4.zip`
- SHA-256: `d6ed82335ec1f2265cfca0fe09d84c23cca9894a0490abb871d7a595ad1083c4`
- archived size: `290653` bytes

The historical official download page is no longer relied upon for reproducibility; the preserved copy is included so the exact solver version used by the tutorial remains available.

## Not bundled

- **L1-Magic**: not redistributed in this release because explicit redistribution terms were not established by the release review.
- **FDRI**: not needed by the minimum Section 9 workflow and therefore not bundled in this release.

# Third-party notices

## TVAL3 beta 2.4

The Sections 7–8 simulation workflow and the Section 9 experimental workflow
use **TVAL3 beta 2.4**, originally by Chengbo Li and Yin Zhang (Rice
University), with Wotao Yin also identified in the preserved solver
documentation.

Each MATLAB workflow keeps a module-local copy of the same preserved solver
source so the workflows remain independently runnable:

```text
matlab/section7_8_simulation/third_party/TVAL3_beta2.4/
matlab/section9_pipeline/third_party/TVAL3_beta2.4/
```

TVAL3 is third-party software. It is **not licensed under the BSD 3-Clause
License that applies to the original tutorial code**.

The preserved upstream `Solver/readme.txt` states that TVAL3 may be
redistributed and/or modified under the **GNU General Public License as
published by the Free Software Foundation**. The upstream notice does not
state a GPL version number.

See `LICENSES/TVAL3_UPSTREAM_NOTICE.txt` and
`LICENSES/TVAL3_LICENSE_INFO.md` for the preserved notice and license
treatment.

## L1-Magic

L1-Magic is used by the Sections 7–8 DCT-l1 and TV-QC routes.

It is **not redistributed** in this repository. The reader downloads a public
repository ZIP and supplies it to:

`matlab/section7_8_simulation/INSTALL_EXTERNAL_DEPENDENCIES.m`

The installer copies only the runtime files required by the tutorial and
applies the documented narrow MATLAB compatibility patch for TV-QC.

## FDRI

FDRI is used by the Sections 7–8 simulation workflow.

It is **not bundled** in this repository. The reader downloads the public FDRI
repository ZIP and supplies it to the same dependency installer.

The tutorial creates only a thin local MATLAB wrapper needed to call the
upstream `private/fdri.m` file; the FDRI algorithm itself remains upstream
third-party code.

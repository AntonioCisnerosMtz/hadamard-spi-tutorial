# License scope

This repository contains code under more than one license.

## Original tutorial code

Unless a file is located under a `third_party/` directory or explicitly
states otherwise, the original code and documentation prepared for this
repository are released under the **BSD 3-Clause License**.

The complete BSD 3-Clause text is provided in the root `LICENSE` file and in
`LICENSES/BSD-3-Clause.txt`.

The copyright notice for the author-owned portion is:

> Copyright (c) 2026, José Antonio Cisneros-Martínez and Rubén Ramos-García

## TVAL3 beta 2.4

TVAL3 beta 2.4 is preserved as third-party software for both reader workflows:

```text
matlab/section7_8_simulation/third_party/TVAL3_beta2.4/
matlab/section9_pipeline/third_party/TVAL3_beta2.4/
```

These files are **not covered by the BSD 3-Clause License**.

The preserved upstream TVAL3 notice states that TVAL3 may be redistributed
and/or modified under the **GNU General Public License as published by the Free
Software Foundation**, but it does not state a version number.

To preserve that upstream situation without assigning a version that the
TVAL3 authors did not state, the repository keeps the upstream notice and the
published GPL version 1, version 2, and version 3 texts under `LICENSES/`.

See `LICENSES/TVAL3_LICENSE_INFO.md` and `THIRD_PARTY_NOTICES.md` for
provenance and scope.

## L1-Magic and FDRI

L1-Magic and FDRI are **not redistributed** by this repository.

For the Sections 7–8 workflow, readers download those projects from their
public repositories and install the required runtime files locally through:

`matlab/section7_8_simulation/INSTALL_EXTERNAL_DEPENDENCIES.m`

Downloaded dependency files are excluded from version control.

## Companion data record

The experimental detector-data record is a separate publication object and
is intended for release under **Creative Commons Attribution 4.0 International
(CC BY 4.0)**. Its license notice is contained in that record rather than in
this software repository.

# Third-party software

## TVAL3 beta 2.4

The reader package includes the MATLAB TVAL3 solver files required by S06,
together with the preserved GPL-2.0 notice under:

`third_party/TVAL3_beta2.4/COPYING_GPL-2.0.txt`

TVAL3 is third-party software and is not covered by the license used for the
tutorial's original MATLAB code.

## L1-Magic

L1-Magic is **not redistributed** by this reader package. Readers supply a ZIP
downloaded from the public L1-Magic repository/mirror and install the required
runtime files locally with `INSTALL_EXTERNAL_DEPENDENCIES.m`.

## FDRI

FDRI is **not bundled** in this reader package. Readers supply the
ZIP downloaded from the public FDRI repository. The installer preserves the
upstream `private/fdri.m` locally and creates only the thin tutorial wrapper
needed by MATLAB's `private/` visibility rule.

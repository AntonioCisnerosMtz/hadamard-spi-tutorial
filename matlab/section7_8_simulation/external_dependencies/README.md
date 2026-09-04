# External solver dependencies

This folder intentionally contains no downloaded L1-Magic or FDRI source code in the repository.

The dependencies are needed only for the **full five-method simulation**. They are not required to reproduce the frozen tutorial figures, and Direct + TVAL3 can run without them.

## Download the two repository ZIPs

1. **L1-Magic**
   - https://github.com/scgt/l1magic

2. **FDRI-single-pixel-imaging**
   - https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

On each GitHub page choose **Code → Download ZIP**.

Keep the downloaded files as ZIPs. **Do not extract them manually.**

## Install them into the reader workflow

From `matlab/section7_8_simulation/` run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
```

The installer opens file-selection dialogs. Select the downloaded L1-Magic ZIP and FDRI ZIP. It finds the required files recursively and creates the local dependency folders automatically.

Then run:

```matlab
CHECK_INSTALLATION
```

A complete installation should report:

```text
L1-Magic: available
FDRI: available
Full five-method simulation: READY
```

If one package is still reported as unavailable, rerun `INSTALL_EXTERNAL_DEPENDENCIES` and select the corresponding repository ZIP.

L1-Magic and FDRI remain untracked reader-installed dependencies and are not redistributed by this project.

For recent MATLAB releases, the installer applies the narrow TV-QC compatibility patch described in `../PATCH_TVQC_MATLAB_COMPATIBILITY.md`.

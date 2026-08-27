# External solver dependencies

This folder intentionally contains no downloaded solver code in the repository.

To execute all five reconstruction methods, download the public repository ZIPs for:

1. **L1-Magic**
   - https://github.com/scgt/l1magic

2. **FDRI-single-pixel-imaging**
   - https://github.com/KMCzajkowski/FDRI-single-pixel-imaging

Then run:

```matlab
INSTALL_EXTERNAL_DEPENDENCIES
```

The installer asks for the two downloaded ZIPs, finds the required files
recursively, and creates the local dependency folders automatically.

L1-Magic and FDRI remain untracked reader-installed dependencies.

For recent MATLAB releases, the installer applies the narrow TV-QC
compatibility patch described in `../PATCH_TVQC_MATLAB_COMPATIBILITY.md`.

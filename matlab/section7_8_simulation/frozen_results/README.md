# Frozen tutorial results

These files reproduce the numerical results shown in Sections 7-8 without
rerunning the external reconstruction solvers.

Use:

`REPRODUCE_TUTORIAL_RESULTS.m`

The supplied files contain:

- the reference image and selected frozen reconstructions;
- the tutorial quality-metric table;
- the reconstruction-time ranges used by the reader-facing Figure 14
  reproduction.

Frozen data are intentionally separate from `results/`, which stores outputs
from the reader's own simulation runs.

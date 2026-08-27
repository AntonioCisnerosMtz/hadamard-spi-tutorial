# Validation status

The numerical workflow S01-S08 was validated locally against the frozen
tutorial benchmark before the public-reader module was finalized.

The final reader workflow was also exercised in four usage scenarios:

1. reproduce the tutorial results from frozen data without external solvers;
2. install L1-Magic and FDRI using only public repository ZIPs;
3. rerun the full five-method simulation with `cameraman.tif`;
4. rerun the same workflow with a reader-selected image.

For custom images, the fixed iterative-solver settings are examples based on
the tutorial benchmark. A solver can reach its maximum iteration limit on a
different image; S06 reports that state explicitly rather than displaying
TVAL3's internal `Inf` iteration sentinel.


## Tutorial-figure visual review

The first generated reader-facing figures exposed presentation defects rather
than numerical defects:

- Figure 13 did not visibly identify the reconstruction-method rows.
- Figure 14 used different automatic colors for a timing segment and its
  endpoint markers.
- Figure 15 plotted finite 100% PSNR values for iterative methods even though
  the tutorial convention stops the PSNR panel at 95% because Direct PSNR is
  infinite at 100%.
- Figure 16 did not visibly identify the 5% and 20% rows, omitted a colorbar,
  and used excessive vertical whitespace.

`REPRODUCE_TUTORIAL_RESULTS.m` was revised to correct those reader-facing
presentation issues without changing any frozen numerical result.


## Final visual review of Figures 13-16

The regenerated reader-facing figures were visually inspected after the
presentation corrections.

- Figure 13: PASS — reconstruction methods and sampling percentages are now
  identifiable, with a consistent image display scale.
- Figure 14: PASS — each timing range and its endpoint markers use one
  consistent color and the logarithmic timing structure is clear.
- Figure 15: PASS — all five methods remain distinguishable across RMSE,
  NRMSE, PSNR, and SSIM; the PSNR panel follows the 5-95% tutorial convention.
- Figure 16: PASS — 5% and 20% rows are labeled, all methods are identified,
  and the common 0-160 gray-level error scale is explicit through the shared
  colorbar.

No numerical result was changed during the visual correction.

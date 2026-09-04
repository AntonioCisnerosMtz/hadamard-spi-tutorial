# Simulation checks

These checks were completed before v1.2.1. This documentation update does not rerun the simulations or change the figures.

S01–S08 were tested against the saved tutorial results. The tests covered:

1. Reproducing the tutorial figures from saved data without reconstruction solvers.
2. Installing L1-Magic and FDRI from public repository ZIPs.
3. Running all five methods with `cameraman.tif`.
4. Running the simulation with another selected image.

The fixed solver settings are based on the tutorial example. With a different image, a solver may reach its iteration limit. S06 reports that stopping condition.

## Included figures

- Figure 13 labels methods and sampling percentages and uses a consistent image display scale.
- Figure 14 uses matching colors for each timing range and its endpoints on a logarithmic axis.
- Figure 15 shows all five methods across RMSE, NRMSE, PSNR, and SSIM. The PSNR panel ends at 95% sampling because Direct PSNR is infinite at 100%.
- Figure 16 labels the 5% and 20% rows and all methods. A shared colorbar shows the 0–160 gray-level error scale.

These display corrections did not change the saved numerical results.

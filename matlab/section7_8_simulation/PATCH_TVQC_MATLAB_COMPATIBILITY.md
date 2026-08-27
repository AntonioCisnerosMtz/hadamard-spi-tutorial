# TV-QC MATLAB compatibility patch

Historical `tvqc_newton.m` uses the identifier `H11p` both as:

- a local helper function in large-scale mode; and
- an explicit Hessian matrix variable in small-scale mode.

Recent MATLAB releases can resolve this shared identifier as a variable in the
parent function, causing the large-scale function-handle call to fail.

`INSTALL_EXTERNAL_DEPENDENCIES.m` applies the same narrow compatibility patch
used by the validated tutorial benchmark:

- local helper `H11p(...)` -> `applyH11p(...)`;
- small-scale Hessian variable `H11p` -> `H11pMatrix`.

The objective, derivatives, conjugate-gradient operator, line search, stopping
criteria, and solver parameters are unchanged.

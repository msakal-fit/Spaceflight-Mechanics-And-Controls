# Common MATLAB utilities

This folder is the single public location for reusable MATLAB utilities. Add it
to the MATLAB path together with the homework folder you want to run:

- [`convertOEtoRV.m`](convertOEtoRV.m): converts classical orbital elements to
  ECI position and velocity; originally located in `HW1/` and used by `HW4/`.
- [`RK4.m`](RK4.m): fourth-order Runge-Kutta integrator used by `HW2/` and
  `HW4/`.

`RK4.m` was centralized here from `HW2/` for this public portfolio. The MATLAB
source and call sites are unchanged; run HW2 or HW4 with `common/` on the
MATLAB path.

# Shared MATLAB utilities

This folder makes the two functions reused across the homework collection easy
to find and add to the MATLAB path:

- [`convertOEtoRV.m`](convertOEtoRV.m): converts classical orbital elements to
  ECI position and velocity; originally located in `HW1/` and used by `HW4/`.
- [`RK4.m`](RK4.m): fourth-order Runge-Kutta integrator; originally located in
  `HW2/` and used by `HW4/`.

Each file is a byte-identical convenience copy of its original homework
version. The originals remain in their submitted homework folders; neither the
source nor its call sites were changed for this public repository.


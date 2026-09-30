# Public-release notice

This repository is a public, portfolio-oriented copy of coursework originally
developed in a private class repository. The following items were intentionally
not copied because their public redistribution rights or provenance are not
established here:

- `HW2/get_harmonics_coefficients.m` and `HW2/get_sat_acc_ecef_test.p`
  (course-supplied geopotential helpers).
- `HW4/animate_attitude.p` (a MATLAB P-code animation dependency).
- `HW2/earth_feb.jpg` (the original image was not packaged with attribution).
- The original course-repository README, editor settings, and operating-system
  metadata.

As a result, these preserved scripts need an equivalent local dependency before
they can run unchanged:

- `HW2/passive_satellite.m` and `HW2/test_get_accel_geopotential.m`
- visualization sections in `HW2/hw2_solution.m`, `HW3/hw32_intercept.m`,
  `HW3/hw33_rdv.m`, and `HW3/test_ECI2LVLH.m`
- `HW4/animate_hw4.m` and the animation call in `HW4/hw4.m`

No MATLAB source in this public copy was refactored or altered to replace those
dependencies.


# Spaceflight Mechanics and Controls

Public portfolio copy of MATLAB coursework completed by Morokot Sakal for
**AEE-5805: Spaceflight Mechanics and Controls** at Florida Institute of
Technology (Spring 2025).

The MATLAB source and recorded result figures are preserved from the submitted
coursework. This repository adds only portfolio-oriented documentation and
excludes course-supplied or third-party material that is not appropriate to
redistribute publicly. It is a learning portfolio, not flight-qualified
software.

## Homework collection

| Folder | Focus | Entry point |
| --- | --- | --- |
| [`HW1`](HW1/) | Orbital elements, Kepler solution, two-body propagation, and RK4 integration | [`HW1/README.md`](HW1/README.md) |
| [`HW2`](HW2/) | Perturbed-orbit propagation: drag, geopotential effects, lunar gravity, and Harris-Priester density | [`HW2/README.md`](HW2/README.md) |
| [`HW3`](HW3/) | One-tangent-burn transfer, Lambert targeting, ECI-to-LVLH conversion, and rendezvous control | [`HW3/README.md`](HW3/README.md) |
| [`HW4`](HW4/) | Coupled two-body orbit and rigid-body attitude dynamics using quaternions | [`HW4/README.md`](HW4/README.md) |
| [`common`](common/) | Shared MATLAB utilities used across homework folders | [`common/README.md`](common/README.md) |
| [`Viz`](Viz/) | MATLAB satellite-scenario visualization scripts | [`Viz/README.md`](Viz/README.md) |

## Running the work

The scripts were written in MATLAB during the course and have not been
refactored for this public release. Open MATLAB at the repository root, add the
relevant homework folder and `common/` to the path, then run an entry-point
script from that folder. For example:

```matlab
addpath('HW4', 'common')
hw4
```

Requirements vary by script.

The Earth texture, visualization models, and saved visualization datasets used
by the preserved scripts are included. See
[`ASSET_ACKNOWLEDGMENTS.md`](ASSET_ACKNOWLEDGMENTS.md) for the Earth-texture
credit.

Representative result figures are retained beside the corresponding homework
README files. The numerical values and plots are course-work results, not
current validation of a spacecraft system.

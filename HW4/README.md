# Homework 4 — Satellite Dynamics

This homework combines two-body orbital motion with rigid-body attitude
dynamics. The entry point is [`hw4.m`](hw4.m), which:

1. Initializes an ISS-like orbit from classical orbital elements.
2. Propagates position, velocity, angular rate, and quaternion state with RK4.
3. Uses [`satelliteFullStateDynamics.m`](satelliteFullStateDynamics.m) for
   gravitational acceleration, Euler rigid-body dynamics, and quaternion
   kinematics.
4. Produces orbit, angular-velocity, quaternion, and quaternion-norm plots;
   it also saves simulation data for an attitude animation.

The original MATLAB P-code animation helper is included with the submitted
homework files. The submission code and its animation call are unchanged.

# Visualization Scripts

These MATLAB scripts visualize orbital and relative-motion data using MATLAB
satellite-scenario functionality:

- [`satViz_a_pos_vel.m`](satViz_a_pos_vel.m): position and velocity.
- [`satViz_b_pos_vel_att.m`](satViz_b_pos_vel_att.m): position, velocity, and
  attitude.
- [`satViz_c_rel_dyn.m`](satViz_c_rel_dyn.m): target/chaser relative dynamics.

The scripts, their saved MATLAB data files, and the two custom 3-D model assets
are included together in this folder. From the repository root, run a
visualization unchanged with:

```matlab
cd Viz
satViz_a_pos_vel
```

Use `satViz_b_pos_vel_att` or `satViz_c_rel_dyn` for the other two scenarios.
MATLAB satellite-scenario functionality is required.


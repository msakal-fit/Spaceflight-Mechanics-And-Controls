% HW3.2 Asteriod Intercept


%% Initial Setup
clear; clc; close all;
% define constants
earth.mu = 3.986e5;    % [km^3/s^2]
earth.Re = 6378;       % [km]

% given initial state at t0=0 [s]
r0 = [-3.6244; 5.737; 1.1223]*1e3;  % position [km]
v0 = [-6.4641; -3.9954; -0.4521];   % velocity [km/s]

% define key times [s]
t0 = 0;     % initial time
tprime = 600; % time of first burn
tf = 3000; % final time

% time step for simulation [s]
h = 5;

% propagate the asteroid state from t0 to tprime using RK4
t_range1 = [t0, tprime];
[t1, X1] = RK4(@satelliteODE, [r0; v0], h, t_range1, earth.mu);

% these will be used for lambertsolver and plotting
state_tprime = X1(:, end); % state at tprime
r_tprime = state_tprime(1:3); % position at tprime
v_tprime = state_tprime(4:6); % velocity at tprime


%% Solve Lambert's Problem using Bisection Method
% the intercept point is given by: 
r2_target = [-1271.6350; -11371.0483; 3148.5939];  % [km]

% time-of-flight from tprime to tf
TOF = tf - tprime;

% solve lambert's problem using bisection method
v_required = lambertSolverBisection(r_tprime, r2_target, TOF, earth.mu);

% compute the delta-v required for the burn
delta_v = v_required - v_tprime;
delta_v_mag = norm(delta_v);
fprintf('The required delta-v is %.4f km/s\n', delta_v_mag);


%% CONVERTING THE DELTA-V TO FINITE-TIME THRUST PROFILE
% define burn duration
burn_duration = 350; % [s]
fprintf('The burn duration is %.2f s\n', burn_duration);

% compute the constant acceleration required for the burn
a_required = delta_v_mag / burn_duration;

% set burn start
t_burn_start = tprime;

% define thrust direction
thrust_direction = delta_v / norm(delta_v);

%% RUN SIMULATION with FINITE-TIME THRUST PROFILE
% define the time range for the simulation
t_range2 = [t0, tf];

[t_out, X_out] = RK4(@satelliteODE_thrust, [r0; v0], h, t_range2, ...
                    earth.mu, t_burn_start, burn_duration, a_required, thrust_direction);

% Extract the final state at tf
state_tf = X_out(:, end);
r_tf = state_tf(1:3); % position at tf
v_tf = state_tf(4:6); % velocity at tf

% compute the miss distance at tf relative to the target
miss_distance = norm(r_tf - r2_target);
fprintf('The miss distance at tf is %.4f km\n', miss_distance);


%% PLOTTING
% Load Earth texture for plotting (if needed)
earth_texture = imread('earth_feb.jpg'); % Ensure this file is in your MATLAB directory
earth_texture = flipud(earth_texture);     % Correct orientation 
figure;
hold on; grid on; axis equal;
[x_earth, y_earth, z_earth] = sphere(100);
hEarth = surf(x_earth*earth.Re, y_earth*earth.Re, z_earth*earth.Re, ...
         'EdgeColor', 'none', 'HandleVisibility', 'off');
set(hEarth, 'CData', earth_texture, 'FaceColor', 'texturemap');
view(3); 
view(220, 40); % Azimuth = 220, Elevation = 40

% Plot the trajectory in 3D (ECI coordinates), along with the initial and target positions.
%figure;
plot3(X_out(1,:), X_out(2,:), X_out(3,:), 'r', 'LineWidth', 1.5, 'DisplayName', 'Trajectory');
plot3(r0(1), r0(2), r0(3), 'ro', 'MarkerSize', 8, 'DisplayName', 'Initial Position');
plot3(r_tprime(1), r_tprime(2), r_tprime(3), 'go', 'MarkerSize', 8, 'DisplayName', 'Burn Start Position');
plot3(r2_target(1), r2_target(2), r2_target(3), 'bx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Intercept Point');
xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');
title('Asteroid Intercept Trajectory');
legend; grid on; axis equal;
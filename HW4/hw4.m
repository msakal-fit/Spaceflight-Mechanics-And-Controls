% Homework 4: Satellite Dynamics

clear all; close all; clc;

% define earth constants
earth.mu = 398600.4405;  % [km^3/s^2]
earth.Re = 6378.137;     % [km] Earth's equatorial radius

% Orbital elements for the ISS
ra = earth.Re + 414;     % Perigee [km]
rp = earth.Re + 419;     % Apogee  [km]
a = (ra + rp) / 2;       % Semi-major axis [km]
e = 0.0003764;           % Eccentricity
i_deg = 51.6377;         % Inclination [deg]
Omega_deg = 229.1795;    % RAAN [deg]
omega_deg = 286.0749;    % Argument of perigee [deg]
nu_deg = 0;              % True anomaly [deg]

% convert OE to ECI position and velocity
[r_ECI, v_ECI] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, earth.mu);

% define attitude initial conditions
omega0 = [0.1; 0.01; -0.05];  % Angular velocity [deg/s]
omega0 = deg2rad(omega0); % [rad/s]
q0 = [1; 0; 0; 0];

% initial state vector
X0 = [r_ECI; v_ECI; omega0; q0];

%% simulation parameters
dt = 1;  % time step [s]
T_orbit = 2*pi*sqrt(a^3/earth.mu);  % Orbital period [s]
numOrbits = 3;                      % Number of orbits to simulate
t_final = numOrbits * T_orbit; 
t_range = [0, t_final];

% integrate the dynamics
mass = 20; % [kg]
tau = [0; 0; 0]; % [N*m]
params.gravity.mu = earth.mu;
params.J = diag([0.1, 0.1, 0.1]);  % Inertia matrix [kg*m^2]
params.tau = tau;            % Control torque [N*m]

[t_out, X_out] = RK4(@satelliteFullStateDynamics, X0, dt, t_range, params);

%% Data extraction for plotting
% orbital dynamics
r_history = X_out(1:3, :);
v_history = X_out(4:6, :);
% attitude dynamics
omega_history = X_out(7:9, :);
q_history = X_out(10:13, :);

t_orbits = t_out / T_orbit; % time in orbits

% Organize data for animation
time_array = t_out;     % 1xN vector containing simulation time points
q_array = q_history;    % 4xN array containing quaternion history
pos_array = r_history;  % 3xN array containing position history
% Also save the velocity data obtained directly from the dynamics.
v_array = v_history;     % 3xN array of velocity history [km/s]
save('./HW4/sat_data.mat', 'time_array', 'pos_array', 'v_array', 'q_array');


%% Attitude Animation
% animate the satellite dynamics
% scale_factor = 1/4000; % scale factor for the satellite size
% animate_attitude(time_array, q_array, 'qua', scale_factor * pos_array);

%% plot results

% plot the trajectory
figure;
plot3(r_history(1, :), r_history(2, :), r_history(3, :), 'b-', 'LineWidth', 1.5);
grid on; axis equal;
xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');
title('Satellite Orbit Trajectory');

fig_results = figure;
subplot(3,1,1);
plot(t_orbits, omega_history');
title('Angular Velocity over Time');
xlabel('Time (s)'); ylabel('Angular Velocity (rad/s)');
legend('\omega_x', '\omega_y', '\omega_z');
grid on;

subplot(3,1,2);
plot(t_orbits, q_history');
title('Quaternion over Time');
xlabel('Time (s)'); ylabel('Quaternion');
legend('q_0', 'q_1', 'q_2', 'q_3');
grid on;

subplot(3,1,3);
plot(t_orbits, vecnorm(q_history));
title('Quaternion Norm over Time');
xlabel('Time (s)'); ylabel('Norm');
% adjust limit of y-axis
ylim([0.995 1.005]);
legend('||q||');
grid on;

% Export the complete results figure for the homework README.
output_file = fullfile(fileparts(mfilename('fullpath')), 'output_hw4.png');
exportgraphics(fig_results, output_file, 'Resolution', 200);

% Test the function by integrating two body dynamics
clear; clc;

% gravitational parameter 
mu = 3.986e5; % km^3/s^2 % Earth

% ISS initial position and velocity
% Epoch (UTC): 	07 February 2025 12:54:13
% Eccentricity: 	0.0003764
% inclination: 	51.6377°
% perigee height: 	414 km
% apogee height: 	419 km
% right ascension of ascending node: 	229.1795°
% argument of perigee: 	286.0749°
% revolutions per day: 	15.49894124
% mean anomaly at epoch: 	169.7148°
% orbit number at epoch: 	49505

earthRe = 6378; % km
ra = earthRe + 414; % km
rp = earthRe + 419; % km
a = (ra + rp) / 2; % km
e = 0.0003764;                % Circular orbit
i_deg = 51.6377;    % Inclination [deg]
Omega_deg = 229.1795;   % RAAN [deg] 
omega_deg = 286.0749;   % Argument of perigee [deg]
nu_deg = 0;      % True anomaly at t0 [deg]

% Compute r0 and v0 using the orbital elements
[r0, v0] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, mu);
X_0 = [r0; v0];

% compute orbital period
T = 2*pi*sqrt(a^3/mu); % [s]

% time step
h = 10;
% time initial
t_ini = 0;
% time final
t_end = T; % 90 minutes
t_range = [t_ini, t_end];

% integrate
[tout, X] = integrateRK4(@two_body_dynamics, X_0, h, t_range);

% Extract the position components
r_x = X(1, :);
r_y = X(2, :);
r_z = X(3, :);

disp('Plotting the ISS orbit...');
% Plot the 3D ISS orbit
figure;
plot3(r_x, r_y, r_z, 'b-', 'LineWidth', 1.5);
hold on;
plot3(r0(1), r0(2), r0(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % mark initial position
xlabel('x [km]');
ylabel('y [km]');
zlabel('z [km]');
title('ISS Orbit');
axis equal;
grid on;

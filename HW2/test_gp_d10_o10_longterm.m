clear all; close all; clc;

% load earth texture image for earth plotting
earth_texture = imread('earth_feb.jpg');
earth_texture = flipud(earth_texture); % flip texture so it's right-side up

% constants Earth and Moon Parameters
earth.mu = 398600.4405; % [km^3/s^2] 
earth.Re = 6378.137; % [km] Earth's equatorial radius 
moon.mu = 4902.8005821478; % [km^3/s^2]

% initial conditions for ISS orbit
% Epoch (UTC): 	07 February 2025 12:54:13
ra = earth.Re + 414; % [km] perigee radius
rp = earth.Re + 419; % [km] apogee radius
a = (ra + rp) / 2; % [km] semi-major axis
e = 0.0003764; % eccentricity
i_deg = 51.6377; % [deg] inclination
Omega_deg = 229.1795; % [deg] right ascension of the ascending node
omega_deg = 286.0749; % [deg] argument of perigee
nu_deg = 0; % [deg] true anomaly

% convert orbital elements to ECI position and velocity
[r_ECI, v_ECI] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, earth.mu);
X0 = [r_ECI; v_ECI]; % initial state vector

% define simulation parameters
h = 10; % [s] time step
T_orbit = 2*pi*sqrt(a^3/earth.mu); % [s] orbital period
num_periods = 100; % number of periods to simulate
t_init = 0;
t_end = num_periods * T_orbit;
time_range = [t_init, t_end];

simStartTime = datetime(2025, 2, 7, 12, 54, 13); % simulation start time

%% Scenario a: Point-Mass with Geopotential (skipped)
params_a.gravity.degree =  10;
params_a.gravity.order = 10;
params_a.gravity.mu = earth.mu;
params_a.gravity.Re = earth.Re;
params_a.startTime = simStartTime;
params_a.useGeopotential = true; 
params_a.useMoon = false;
params_a.useDrag = false;

[tout_a, Xout_a] = RK4(@passive_satellite, X0, h, time_range, params_a);

% plot Earth
figure;
hold on; grid on; axis equal;
[x_earth, y_earth, z_earth] = sphere(100);
hEarth = surf(x_earth*earth.Re, y_earth*earth.Re, z_earth*earth.Re, ...
         'EdgeColor', 'none', 'HandleVisibility', 'off');
set(hEarth, 'CData', earth_texture, 'FaceColor', 'texturemap');

xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');
title('ISS Orbit Comparison');
view(3); % set view to 3D
view(220, 40); % Azimuth = 220, Elevation = 40
legend('Location', 'Best');


plot3(Xout_a(1,:), Xout_a(2,:), Xout_a(3,:), ...
                'r', 'LineWidth', 1.5, 'DisplayName', 'Geopot D=10, O=10');

r_a = vecnorm(Xout_a(1:3,:)); % radial distance of scenario a: baseline

time_in_orbits = tout_a / T_orbit; % convert time to number of orbits 

% Plot altitude change vs. time
figure;
hold on; grid on;
plot(time_in_orbits, r_a - earth.Re, 'r', 'LineWidth', 1.5);
xlabel('Time [Orbits]'); ylabel('Altitude [km]');
title('Altitude vs. Time');
legend('GP D=10, O=10', 'Location', 'Best');
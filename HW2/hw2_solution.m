% Homework 2 solution
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
num_periods = 10; % number of periods to simulate
t_init = 0;
t_end = num_periods * T_orbit;
time_range = [t_init, t_end];

%% Scenario 0: check point-mass with hw1 solution
[tout_0, Xout_0] = RK4(@two_body_dynamics, X0, h, time_range);

simStartTime = datetime(2025, 2, 7, 12, 54, 13); % simulation start time

%% Scenario a: Point-Mass with Geopotential (skipped)
params_a.gravity.order =  0;
params_a.gravity.degree = 0;
params_a.gravity.mu = earth.mu;
params_a.gravity.Re = earth.Re;
params_a.startTime = simStartTime;
params_a.useGeopotential = true; 
params_a.useMoon = false;
params_a.useDrag = false;

[tout_a, Xout_a] = RK4(@passive_satellite, X0, h, time_range, params_a);


%% Scenario b: Geopotential degree 10, order 10
params_b.gravity.order =  10;
params_b.gravity.degree = 10;
params_b.gravity.mu = earth.mu;
params_b.gravity.Re = earth.Re;
params_b.startTime = simStartTime;
params_b.useGeopotential = true; 
params_b.useMoon = false;
params_b.useDrag = false;

[tout_b, Xout_b] = RK4(@passive_satellite, X0, h, time_range, params_b);

%% Scenario c: Moon Gravity
params_c = params_b; % copy params from scenario c

params_c.gravity.mu = earth.mu;
params_c.moon.mu = moon.mu;
params_c.startTime = simStartTime;
params_c.startTimeJD = juliandate(simStartTime);
params_c.useGeopotential = true;
params_c.useMoon = true;
params_c.useDrag = false;

[tout_c, Xout_c] = RK4(@passive_satellite, X0, h, time_range, params_c);


%% Scenario d: Moon Gravity and Drag
params_d = params_c; % copy params from scenario c

% % define drag parameters
params_d.drag.mass = 2; % [kg] mass of the satellite
params_d.drag.Cd   = 2; % drag coefficient
params_d.drag.A    = 1; % [m^2] cross-sectional area of the satellite
params_d.omegaEarth = [0; 0; 0.7292e-4]; % [rad/s] Earth's rotation rate
params_d.atmosphere.HP_coeff = get_HP_table(); % get the HP coefficient table
params_d.gravity.Re = earth.Re;
params_d.useGeopotential = true;
params_d.useMoon = true;
params_d.useDrag = true;

[tout_d, Xout_d] = RK4(@passive_satellite, X0, h, time_range, params_d);

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


% plot 3D orbit
% plot3(Xout_0(1,:), Xout_0(2,:), Xout_0(3,:), ...
%         'r', 'LineWidth', 1.5, 'DisplayName', 'Two-body Check');

plot3(Xout_a(1,:), Xout_a(2,:), Xout_a(3,:), ...
                'r', 'LineWidth', 1.5, 'DisplayName', 'PointMass');
plot3(Xout_b(1,:), Xout_b(2,:), Xout_b(3,:), ...
                        'b', 'LineWidth', 1.5, 'DisplayName', 'Geopot D=10, O=10');

plot3(Xout_c(1,:), Xout_c(2,:), Xout_c(3,:), ...
        'b--', 'LineWidth', 1.5, 'DisplayName', 'GP + Moon');
plot3(Xout_d(1,:), Xout_d(2,:), Xout_d(3,:), ...
        'm-.', 'LineWidth', 1.5, 'DisplayName', 'GP + Moon + Drag');

% compute radial distance
%r_0 = vecnorm(Xout_0(1:3,:)); % radial distance of scenario 0: baseline
r_a = vecnorm(Xout_a(1:3,:)); % radial distance of scenario a: Geopot D=0, O=0
r_b = vecnorm(Xout_b(1:3,:)); % radial distance of scenario b: Geopot D=10, O=10
r_c = vecnorm(Xout_c(1:3,:)); % radial distance of scenario c: moon gravity
r_d = vecnorm(Xout_d(1:3,:)); % radial distance of scenario d: moon gravity + drag

time_in_orbits = tout_0 / T_orbit; % convert time to number of orbits 

% Plot altitude change vs. time
figure;
hold on; grid on;
plot(time_in_orbits, r_a - earth.Re, 'r', 'LineWidth', 1.5);
plot(time_in_orbits, r_b - earth.Re, 'b', 'LineWidth', 1.5);
plot(time_in_orbits, r_c - earth.Re, 'g--', 'LineWidth', 1.5);
plot(time_in_orbits, r_d - earth.Re, 'm-.', 'LineWidth', 1.5);
xlabel('Time [orbits]'); ylabel('Altitude [km]');
title('Altitude vs. Time');
legend('PointMass', 'GP D=10, O=10','GP + Moon', 'GP + Moon + Drag', 'Location', 'Best');

% Plot difference in radial distance vs. time 
figure;

subplot(3,1,1);
plot(time_in_orbits, r_b - r_a, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Time [orbits]');
ylabel('\Delta r_{b-a} [km]');
title('GP D=10 O=10 - PointMass');

%r_a = r_0; % debug

% Difference: Geopotential + Moon - Point-Mass Only
subplot(3,1,2);
plot(time_in_orbits, r_c - r_a, 'g--', 'LineWidth', 1.5);
grid on;
xlabel('Time [orbits]');
ylabel('\Delta r_{c-a} [km]');
title('GP + Moon - PointMass');

% Difference: Geopotential + Moon + Drag - Point-Mass Only
subplot(3,1,3);
plot(time_in_orbits, r_d - r_a, 'm-.', 'LineWidth', 1.5);
grid on;
xlabel('Time [orbits]');
ylabel('\Delta r_{d-a} [km]');
title('GP + Moon + Drag - PointMass');

clc; clear; close all;

% define Earth and Moon Parameters
earth.mu = 3.986e5;    % [km^3/s^2]
earth.Re = 6378;       % [km]
moon.mu  = 4.9028e3;   % [km^3/s^2]

% define initial conditions for ISS orbit
% epoch (UTC): 07 February 2025 12:54:13
ra = earth.Re + 414; % km (perigee altitude)
rp = earth.Re + 419; % km (apogee altitude)
a_t = (ra + rp) / 2; % km, semi-major axis
e_t = 0;             % circular orbit
i_t     = 51.6377;   % Inclination [deg]
Omega_t = 229.1795;  % RAAN [deg]
omega_t = 286.0749;  % Argument of perigee [deg]
nu_t    = 0;         % True anomaly [deg]

% convert target orbital elements to ECI state
[rt_ECI, vt_ECI] = convertOEtoRV(a_t, e_t, i_t, Omega_t, omega_t, nu_t, earth.mu);

% define chaser state (follow the lecture example)
a_c = a_t + 200;    % km, semi-major axis of chaser
e_c = 0.002;        % near-circular orbit
i_c = i_t - 3;      % Inclination [deg]
Omega_c = Omega_t;  % RAAN [deg]
omega_c = omega_t;  % Argument of perigee [deg]
nu_c = nu_t + 0.5;  % True anomaly [deg]

% convert chaser orbital elements to ECI state
[rc_ECI, vc_ECI] = convertOEtoRV(a_c, e_c, i_c, Omega_c, omega_c, nu_c, earth.mu);

% test the ECI2LVLH function
[rho, rho_dot, R_ECI2LVLH] = ECI2LVLH(rt_ECI, vt_ECI, rc_ECI, vc_ECI);

% display results
fprintf('=== ECI to LVLH Transformation ===\n');
fprintf('Relative Position (LVLH): [%.4f, %.4f, %.4f] km\n', rho);
fprintf('Relative Velocity (LVLH): [%.4f, %.4f, %.4f] km/s\n', rho_dot);
fprintf('Rotation Matrix (ECI to LVLH):\n');
disp(R_ECI2LVLH);

%% plotting
% plot the relative position of chaser in LVLH frame
figure;
plot3(0, 0, 0, 'bo', 'DisplayName', 'Target');
hold on;
plot3(rho(1), rho(2), rho(3), 'ro', 'DisplayName', 'Chaser');
quiver3(0, 0, 0, rho(1), rho(2), rho(3), 'k', 'DisplayName', 'Relative Position');
xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');
title('Relative Position of Chaser in LVLH Frame');
legend('Location', 'best');
grid on;

% plot the position of target and chaser in ECI frame
% plot the Earth
% load Earth texture image for plotting
earth_texture = imread('earth_feb.jpg');   % Load Earth image
earth_texture = flipud(earth_texture);     % Flip texture vertically to correct orientation 
figure;
hold on; grid on; axis equal;
[x_earth, y_earth, z_earth] = sphere(100);
hEarth = surf(x_earth*earth.Re, y_earth*earth.Re, z_earth*earth.Re, ...
         'EdgeColor', 'none', 'HandleVisibility', 'off');
set(hEarth, 'CData', earth_texture, 'FaceColor', 'texturemap');
view(3); 
view(220, 40); % Azimuth = 220, Elevation = 40

% plot the initial position of the chaser and target in ECI frame (3D Plot)
plot3(rt_ECI(1), rt_ECI(2), rt_ECI(3), 'ro', 'MarkerSize', 10, 'DisplayName', 'Target');
plot3(rc_ECI(1), rc_ECI(2), rc_ECI(3), 'bo', 'MarkerSize', 10, 'DisplayName', 'Chaser');
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');
title('Chaser and Target Trajectory in ECI Frame');
legend('location', 'best');



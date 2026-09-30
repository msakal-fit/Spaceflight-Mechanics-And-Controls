% Test script for Moon Gravity Acceleration
clear all; clc;

% Constants for Earth and Moon
earth.mu = 398600.4405;    % [km^3/s^2]
earth.Re = 6378.137;       % [km]
moon.mu  = 4902.8005821478; % [km^3/s^2]

% Initial conditions for ISS orbit (Epoch: 07 February 2025 12:54:13)
ra = earth.Re + 414; % perigee radius [km]
rp = earth.Re + 419; % apogee radius [km]
a = (ra + rp) / 2;   % semi-major axis [km]
e = 0.0003764;       % eccentricity
i_deg = 51.6377;     % inclination [deg]
Omega_deg = 229.1795;% RAAN [deg]
omega_deg = 286.0749;% argument of perigee [deg]
nu_deg = 0;          % true anomaly [deg]

% Convert orbital elements to ECI state vector
[r_ECI, v_ECI] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, earth.mu);

% Define the epoch time
t = datetime(2025, 2, 7, 12, 54, 13);

% Set up parameters for Moon ephemeris
params.startTime = t;
params.startTimeJD = juliandate(t);
params.moon.mu = moon.mu;

% Compute Moon acceleration using your function
a_moon_eci = get_accel_moon_grav(r_ECI, t, params);

% --- Analytical (Reference) Computation ---
% Get the Moon's position from planetEphemeris (ensure a column vector)
currentJD = juliandate(t);
s_eci = planetEphemeris(currentJD, 'Earth', 'Moon')';
s_eci = s_eci(:);

% Compute acceleration on the satellite due to Moon
a_sat = moon.mu * (s_eci - r_ECI) / norm(s_eci - r_ECI)^3;
% Compute acceleration on the Earth due to Moon
a_earth = moon.mu * s_eci / norm(s_eci)^3;
% Analytical third-body (tidal) acceleration
a_moon_eci_analytical = a_sat - a_earth;

% Display the results
disp('===== Moon Gravity Test =====');
disp('Computed a_moon_eci (km/s^2):');
disp(a_moon_eci);
disp('Analytical a_moon_eci (km/s^2):');
disp(a_moon_eci_analytical);

% Compare the results (allow a small tolerance due to ephemeris differences)
tolerance = 1e-8;
error_norm = norm(a_moon_eci - a_moon_eci_analytical);
disp('Error norm (km/s^2):');
disp(error_norm);
assert(error_norm < tolerance, 'Error: Moon gravity acceleration computation does not match analytical result.');
disp('Test passed!');

% test script to compare and verify the geopotential acceleration computation

clear all; clc;

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

% define an epoch time
t = datetime(2025, 2, 7, 12, 54, 13);

% case 1: point-mass
degree = 0;
order = 0;

% get spherical-harmonics coefficients
[C_nm, S_nm] = get_harmonics_coefficients(degree, order);

% compute the geopotential acceleration in ECI (km/s^2)
a_grav_eci_pm = get_accel_geopotential(degree, order, r_ECI, t, earth.mu, earth.Re, C_nm, S_nm);

% compute the analytical point-mass acceleration in ECI (km/s^2)
% a = -mu * r / r^3
% a_pm = -earth.mu / norm(r_ECI)^3 * r_ECI;
% add test code from Dr. Rios
a_pm = get_sat_acc_ecef_test(C_nm, S_nm, earth.Re, r_ECI, earth.mu, t);

% compare the results
disp('===== Point-Mast Test =====');
disp('Computed a_grav_eci_pm (km/s^2):');
disp(a_grav_eci_pm);
disp('Analytical a_pm (km/s^2):');
disp(a_pm);
assert(norm(a_grav_eci_pm - a_pm) < 1e-6, 'Error: point-mass geopotential acceleration computation');
disp('Error (km/s^2):');
disp(norm(a_grav_eci_pm - a_pm));
disp('Test passed!');


% case 10: deg = 10, order = 0
degree = 10;
order = 10;

% get spherical-harmonics coefficients
[C_nm, S_nm] = get_harmonics_coefficients(degree, order);

% compute the geopotential acceleration in ECI (km/s^2)
a_grav_eci_1010 = get_accel_geopotential(degree, order, r_ECI, t, earth.mu, earth.Re, C_nm, S_nm);

% add test code from Dr. Rios
a_ref_1010 = get_sat_acc_ecef_test(C_nm, S_nm, earth.Re, r_ECI, earth.mu, t);

% compare the results
disp('===== Deg=10, Ord=10 Test =====');
disp('Computed a_grav_eci_20 (km/s^2):');
disp(a_grav_eci_1010);
disp('Ref  a_ref_20 (km/s^2):');
disp(a_ref_1010);
assert(norm(a_grav_eci_1010 - a_ref_1010) < 1e-6, 'Error: J2 perturbation geopotential acceleration computation');
disp('Error (km/s^2):');
disp(norm(a_grav_eci_1010 - a_ref_1010));
disp('Test passed!');
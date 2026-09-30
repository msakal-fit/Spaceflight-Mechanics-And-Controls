% test scrip to check the values of get_accel_drag

clear all; clc;

% constants Earth and Moon Parameters
earth.mu = 398600.4405; % [km^3/s^2] 
earth.Re = 6378.137; % [km] Earth's equatorial radius 
omega_E = [0; 0; 0.7292e-4]; % [rad/s] Earth's rotation rate

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

% define drag parameters
m = 2; % [kg] mass of the satellite
Cd = 2; % drag coefficient
A = 1; % [m^2] cross-sectional area of the satellite

HP_Coeff = get_HP_table(); % get the HP coefficient table

% get atm density at altitude h
h = norm(r_ECI) - earth.Re; % [km] altitude of the satellite

rho_avg = get_density_HP(h, HP_Coeff, 'average'); % [g/km^3] atmospheric density at the satellite altitude
rho_avg = rho_avg * 1e-12; % convert to kg/m^3

% convert to meter
KM2M = 1e3;

a_drag_eci = get_accel_drag(m, Cd, A, r_ECI, v_ECI, HP_Coeff, earth.Re, omega_E);


% Display the results
disp('===== Drag Acceleration Test =====');
disp(['Altitude (km): ', num2str(h)]);
disp(['rho value: ', num2str(rho_avg)]); % order 10^-12 kg/m^3

disp('Computed a_drag_eci (km/s^2):'); % order 10^-6 km/s^2
disp(a_drag_eci);




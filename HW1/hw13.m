% Convert state r and v into orbital elements

clc; clear;

% Given state vectors of the satellite (position and velocity vectors)
r = [-2.6; 5.15; 2.74]*1e3; % km
v = [-3.51; -5.29; 5.06]; % km/s

% gravitational parameter 
mu = 3.986e5; % km^3/s^2 % Earth

% Compute orbital elements
[i_deg, RAAN_deg, a, e, nu_deg, omega_deg] = convertRVtoOE(r, v, mu);


%% Display results
disp(['Inclination (i):              ', num2str(i_deg), ' deg']);
disp(['Right Ascension of AN (RAAN): ', num2str(RAAN_deg), ' deg']);
disp(['Semi-major axis (a):          ', num2str(a), ' km']);
disp(['Eccentricity (e):             ', num2str(e)]);
disp(['True anomaly (nu):            ', num2str(nu_deg), ' deg']);
disp(['Argument of perigee (omega):  ', num2str(omega_deg), ' deg']);



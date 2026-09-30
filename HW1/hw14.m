% Write a functon that takes as inputs 𝑎, 𝑒, 𝑖, Ω, 𝜔, 𝜈 and outputs 𝒓 and v. 
% Test your func7on with the values obtained in problem 3 (hw13)
% You should recover 𝒓 and v from problem 1

clc; clear;

% Given state vectors of the satellite (position and velocity vectors)
r_given = [-2.6; 5.15; 2.74]*1e3; % km
v_given = [-3.51; -5.29; 5.06]; % km/s

% OE values from hw13
a = 6765.8119; % Semi-major axis in km
e = 0.099232; % Eccentricity
i_deg = 51.9771; % Inclination
Omega_deg = 94.9868; % RAAN
omega_deg = 93.4561; % Argument of perigee
nu_deg = 299.5411; % True anomaly

% gravitational parameter 
mu = 3.986e5; % km^3/s^2 % Earth

% Compute r and v
[r_ECI, v_ECI] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, mu);

%
% Display results
%
disp('Computed State Vectors from OE -> RV:');
disp(['r_ECI = [', num2str(r_ECI'), '] km']);
disp(['v_ECI = [', num2str(v_ECI'), '] km/s']);
disp(' ');

disp('Given State Vectors (for comparison):');
disp(['r_given = [', num2str(r_given'), '] km']);
disp(['v_given = [', num2str(v_given'), '] km/s']);
disp(' ');
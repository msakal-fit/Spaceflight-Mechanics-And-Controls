% Given ECI State Vector of the satellite orbiting the earth
% Compute the orbit's angular momentum vector h and the specific energy E
clc; clear;

% state vectors of the satellite (position and velocity vectors)
r = [-2.6; 5.15; 2.74]*1e3; % km
v = [-3.51; -5.29; 5.06]; % km/s

% Constants
mu = 3.986*1e5; % km^3/s^2

% Compute the angular momentum vector h
h = cross(r,v); % km^2/s
% disp(h)

% Compute the specific energy E
E = (norm(v)^2)/2 - mu/norm(r); % km^2/s^2

% display the results
disp(['Angular momentum vector (h):', num2str(h'), ' km^2/s']);

disp(['Specific energy (E):', num2str(E), ' km^2/s^2']);

% Output:
% Angular momentum vector (h):40553.6          3538.6         31830.5 km^2/s
% Specific energy (E):-29.4569 km^2/s^2
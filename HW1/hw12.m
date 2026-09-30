clc; clear;

% Given
a = 10000; % km 
e = 0.3;
M0_deg = 0; % degrees

% Constants
mu = 3.986e5; % km^3/s^2

% initial mean anaomaly
M0_rad = deg2rad(M0_deg);
% compute orbital period and mean motion
T = 2*pi*sqrt(a^3/mu); % [s
n = 2*pi/T; % [rad/s]

% Set time-step, start, and end
h      = 10;           % [s] time step
t_0  = 0;            % [s]
t_end  = T;            % [s] one full period

t_array = t_0:h:t_end; % [s]
% Ensure that the final time is included (if rounding allows).
if t_array(end) < t_end
    t_array = [t_array, t_end];
end

N = length(t_array);
E_array = zeros(1, N); % eccentric anomaly 
p_array = zeros(1, N); % p-coordinate in perifocal plane
q_array = zeros(1, N); % q-coordinate in perifocal plane

tol = 1e-6; % tolerance for convergence
max_iter = 100; % maximum iterations

for k = 1:N
    t_k = t_array(k);
    M_k = M0_rad + n*(t_k - t_0);

    % Solve Kepler's equation for E
    E_k = solveKeplerEquation(M_k, e, tol, max_iter);
    E_array(k) = E_k;

    % Compute perifocal coordinates:
    % p = a (cos E - e)
    % q = a sqrt(1 - e^2) sin E
    p_array(k) = a*(cos(E_k) - e);
    q_array(k) = a*sqrt(1 - e^2)*sin(E_k);
end

% Plot results
% Plot perifocal coordinates versus time
figure;
subplot(2,1,1);
plot(t_array, p_array, 'b-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('p [km]');
title('Perifocal Coordinate p vs. Time');
grid on;

subplot(2,1,2);
plot(t_array, q_array, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('q [km]');
title('Perifocal Coordinate q vs. Time');
grid on;

% Plot the orbit in the perifocal plane (p vs. q)
figure;
plot(p_array, q_array, 'k-', 'LineWidth', 1.5);
xlabel('p [km]');
ylabel('q [km]');
title('Orbit in the Perifocal Plane (p vs. q)');
axis equal;
grid on;
% compare solution from hw15 using RK4 with solution solving kepler equation
clear; clc;

% gravitational parameter 
mu = 3.986e5; % km^3/s^2 % Earth

% ISS initial position and velocity
% Epoch (UTC): 	07 February 2025 12:54:13
% Eccentricity: 	0.0003764
% inclination: 	51.6377°
% perigee height: 	414 km
% apogee height: 	419 km
% right ascension of ascending node: 	229.1795°
% argument of perigee: 	286.0749°
% revolutions per day: 	15.49894124
% mean anomaly at epoch: 	169.7148°
% orbit number at epoch: 	49505

earthRe = 6378; % km
ra = earthRe + 414; % km
rp = earthRe + 419; % km
a = (ra + rp) / 2; % km
e = 0.0003764;                % Circular orbit
i_deg = 51.6377;    % Inclination [deg]
Omega_deg = 229.1795;   % RAAN [deg] 
omega_deg = 286.0749;   % Argument of perigee [deg]
nu_deg = 0;      % True anomaly at t0 [deg]

M0_deg = 0; % degrees

% initial mean anomaly
M0_rad = deg2rad(M0_deg);
% compute orbital period and mean motion
T = 2*pi*sqrt(a^3/mu); % [s
n = 2*pi/T; % [rad/s]

% Set time-step, start, and end
h      = 10;           % [s] time step
t_ini  = 0;            % [s]
t_end  = T;            % [s] one full period
t_array = t_ini:h:t_end;
t_array = t_array(:); % ensure column vector

t_range = [t_ini, t_end];

N = length(t_array);
E_array = zeros(1, N); % eccentric anomaly 
p_array = zeros(1, N); % p-coordinate in perifocal plane
q_array = zeros(1, N); % q-coordinate in perifocal plane

% Preallocate array for ECI positions computed using the Kepler method
r_eci_kepler = zeros(3, N);

tol = 1e-6; % tolerance for convergence
max_iter = 100; % maximum iterations

for k = 1:N
    t_k = t_array(k);
    M_k = M0_rad + n*(t_k - t_ini);

    % Solve Kepler's equation for E
    E_k = solveKeplerEquation(M_k, e, tol, max_iter);
    E_array(k) = E_k;

    % Compute perifocal coordinates:
    % p = a (cos E - e)
    % q = a sqrt(1 - e^2) sin E
    p_array(k) = a*(cos(E_k) - e);
    q_array(k) = a*sqrt(1 - e^2)*sin(E_k);

    r_eci_kepler(:, k) = perifocalToECI(p_array(k), q_array(k), deg2rad(i_deg), deg2rad(Omega_deg), deg2rad(omega_deg));
end

% For comparison, run the RK4 integration (as in problem5)
[r0, v0] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, mu);
X_0 = [r0; v0];
[tout, X] = integrateRK4(@two_body_dynamics, X_0, h, t_range);
r_eci_rk4 = X(1:3, :);

% Compare ECI components: plot each component vs. time
figure;
subplot(3,1,1);
plot(tout, r_eci_rk4(1,:), 'b-', 'LineWidth', 1.5); hold on;
plot(t_array, r_eci_kepler(1,:), 'r--', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('x [km]');
title('ECI x-component Comparison');
legend('RK4', 'Kepler');

subplot(3,1,2);
plot(tout, r_eci_rk4(2,:), 'b-', 'LineWidth', 1.5); hold on;
plot(t_array, r_eci_kepler(2,:), 'r--', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('y [km]');
title('ECI y-component Comparison');
legend('RK4', 'Kepler');

subplot(3,1,3);
plot(tout, r_eci_rk4(3,:), 'b-', 'LineWidth', 1.5); hold on;
plot(t_array, r_eci_kepler(3,:), 'r--', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('z [km]');
title('ECI z-component Comparison');
legend('RK4', 'Kepler');

% Also plot the 3D orbits from both methods for visual comparison
figure;
plot3(r_eci_rk4(1,:), r_eci_rk4(2,:), r_eci_rk4(3,:), 'b-', 'LineWidth', 1.5);
hold on;
plot3(r_eci_kepler(1,:), r_eci_kepler(2,:), r_eci_kepler(3,:), 'r--', 'LineWidth', 1.5);
xlabel('x [km]'); ylabel('y [km]'); zlabel('z [km]');
title('ISS Orbit: RK4 vs. Kepler');
legend('RK4', 'Kepler');
axis equal;
grid on;

figure;
title('Errors')
subplot(3,1,1);
plot(t_array, r_eci_rk4(1,:) - r_eci_kepler(1,:), 'b-', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('x [km]');
title('ECI x-component Error');
grid on;

subplot(3,1,2);
plot(t_array, r_eci_rk4(2,:) - r_eci_kepler(2,:), 'b-', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('y [km]');
title('ECI y-component Error');
grid on;

subplot(3,1,3);
plot(t_array, r_eci_rk4(3,:) - r_eci_kepler(3,:), 'b-', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('z [km]');
title('ECI z-component Error');
grid on;


% print size of tout, t_array
%disp(['Size of tout: ', num2str(size(tout))]);
%disp(['Size of t_array: ', num2str(size(t_array))]);
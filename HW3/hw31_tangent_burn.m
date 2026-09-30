% HW3.1 One Tangent Burn


%% Initial Setup
clear; clc; close all;
% define constants
earth.mu = 3.986e5;    % [km^3/s^2]
earth.Re = 6378;       % [km]

% scenario: start at PERIGEE
% r1 = a_t(1 - e_t)

r1 = earth.Re + 300;   % [km], smaller orbit
r2 = earth.Re + 2000;  % [km], larger orbit
disp('Starting at PERIGEE (r1 < r2).');

% choose final burn location on the transfer ellipse (true anomaly at point b)
nu_tb_deg = 120;   % For perigee start, choose nu_tb between 0 and 180°
nu_tb = deg2rad(nu_tb_deg);

% compute transfer orbit params
R = r2 / r1;

% Compute transfer eccentricity analytically (without using fzero)
e_t = (R - 1) / (1 - R*cos(nu_tb));

% print e_t
fprintf('The transfer eccentricity is %.4f\n', e_t);

% compute transfer semi-major axis
a_t = r1 / (1 - e_t);

% speed at start point a
v_trans_a = sqrt( earth.mu*(2/r1 - 1/a_t) );
v_circ1   = sqrt( earth.mu / r1 );
DV1       = v_trans_a - v_circ1;   % required speed change at point a
DV1_mag   = abs(DV1);

% speed at end point b of transfer orbit
v_trans_b = sqrt( earth.mu*(2/r2 - 1/a_t) );
v_circ2   = sqrt( earth.mu / r2 );
phi_b     = atan( e_t*sin(nu_tb) / (1 + e_t*cos(nu_tb)) );
DV2_mag   = sqrt( v_trans_b^2 + v_circ2^2 - 2*v_trans_b*v_circ2*cos(phi_b) );

fprintf('\n=== ONE-TANGENT-BURN ===\n');
fprintf('r1         = %.1f km\n', r1);
fprintf('r2         = %.1f km\n', r2);
fprintf('nu_tb      = %.1f deg\n', nu_tb_deg);
fprintf('e_t        = %.4f\n', e_t);
fprintf('a_t        = %.1f km\n', a_t);
fprintf('v_trans_a  = %.4f km/s\n', v_trans_a);
fprintf('v_circ1    = %.4f km/s\n', v_circ1);
fprintf('DV1        = %.4f km/s\n', DV1_mag);

fprintf('v_trans_b  = %.4f km/s\n', v_trans_b);
fprintf('v_circ2    = %.4f km/s\n', v_circ2);
fprintf('phi_b      = %.3f deg\n', rad2deg(phi_b));
fprintf('DV2        = %.4f km/s\n', DV2_mag);

% compute eccentric anomaly at point b
% Using: cos E_b = (e_t + cos(nu_tb))/(1+ e_t*cos(nu_tb))
cosE_b = (e_t + cos(nu_tb)) / (1 + e_t*cos(nu_tb));
E_b = acos(cosE_b);
if nu_tb_deg > 180
    E_b = 2*pi - E_b;
end

E_a = 0;  % perigee: eccentric anomaly E=0

% compute time of flight
ToF_ab = sqrt(a_t^3/earth.mu) * ( (E_b - e_t*sin(E_b)) - (E_a - e_t*sin(E_a)) );
fprintf('\nTime of flight (a -> b) = %.1f s\n', ToF_ab);

%% Setup Simulation
% define finite burn durations
dt1 = 100;  % [s]
dt2 = 100;  % [s]

% period of r1 orbit
T1 = 2*pi*sqrt(r1^3/earth.mu);

% period of r2 orbit
T2 = 2*pi*sqrt(r2^3/earth.mu);

% define key time points
t0 = 0;
t_b1_start = T1;
t_b2_start = t_b1_start + ToF_ab;
T_coast = 0.5*T2;
t_final = t_b2_start + T_coast;

% total simulation time
t_range = [t0, t_final]; % [s]
h       = 10;            % time step [s]

% satellite initial conditions
r0 = [r1; 0; 0];         % km
v0 = [0; v_circ1; 0];     % km/s
X0 = [r0; v0];

% calculate thrust at a and b
% thrust at a
a1 = (v_trans_a - v_circ1) / dt1;  % scalar acceleration; Burn is applied tangentially
% print the first thrust
disp('a_thrust_a1 [km/s^2] = ');
disp(a1); % [km/s^2]

% thrust at b
% used transfer orbit velocity at point b using energy method
% v_trans_b

% compute the unit vector from the perifocal formulation
% (Unnormalized direction based on eccentric anomaly E_b)
p_vec = -sin(E_b)*[1;0;0] + sqrt(1-e_t^2)*cos(E_b)*[0;1;0];
p_unit = p_vec / norm(p_vec);

% the transfer orbit velocity vector
v_trans_b_vec = v_trans_b * p_unit;

% compute the desired circular orbit velocity vector at r2
v_circ2_vec = sqrt(earth.mu / r2) * ( -sin(nu_tb)*[1;0;0] + cos(nu_tb)*[0;1;0] );

% compute the delta-v vector at b2
deltaV2_vec = v_circ2_vec - v_trans_b_vec;

a_thrust_b2 = deltaV2_vec / dt2;

% print a_thrust vector
disp('a_thrust_b2 = ');
disp(a_thrust_b2);


% define simulation parameters
params.mu = earth.mu;
params.b1_start = t_b1_start;
params.b1_duration = dt1;
params.a1 = a1;
params.b2_start = t_b2_start;
params.b2_duration = dt2;
params.a2 = a_thrust_b2;

% integrate the equations of motion
[t_out, X_out] = RK4(@satelliteODETwoBurns, X0, h, t_range, params);

% Extract position data from the solution.
r_sol = X_out(1:3,:);
x_pos = X_out(1,:);
y_pos = X_out(2,:);
z_pos = X_out(3,:);

% Plot the initial circular orbit (red dashed)
theta = linspace(0, 2*pi, 200);
x_circ1 = r1 * cos(theta);
y_circ1 = r1 * sin(theta);
z_circ1 = zeros(size(theta));

% Plot the final circular orbit (green dashed)
x_circ2 = r2 * cos(theta);
y_circ2 = r2 * sin(theta);
z_circ2 = zeros(size(theta));

% 2D Perifocal (Orbital Plane) Trajectory
figure;
plot(x_pos, y_pos, 'b', 'LineWidth', 2); hold on;
plot(x_circ1, y_circ1, 'r--', 'LineWidth', 1.5);
plot(x_circ2, y_circ2, 'g--', 'LineWidth', 1.5);
% add burn start and end points
% t_b1_start and t_b2_start


xlabel('Perifocal x (km)');
ylabel('Perifocal y (km)');
title('Satellite Trajectory in Perifocal Coordinates');
axis equal; grid on;
legend('Trajectory', 'Initial Orbit', 'Final Orbit');

% HW3.3 Relative Motion


%% Initial Setup
clear; clc; close all;
% define constants
earth.mu = 3.986e5;    % [km^3/s^2]
earth.Re = 6378;       % [km]

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

T_orb_t = 2*pi*sqrt(a_t^3/earth.mu); % orbital period of target [s]

% convert target orbital elements to ECI state
[rt_ECI, vt_ECI] = convertOEtoRV(a_t, e_t, i_t, Omega_t, omega_t, nu_t, earth.mu);
Xt0 = [rt_ECI; vt_ECI];  % initial state vector of target

% define chaser state (follow the lecture example)
a_c = a_t + 200;    % km, semi-major axis of chaser
e_c = 0.002;        % near-circular orbit
i_c = i_t - 3;      % Inclination [deg]
Omega_c = Omega_t;  % RAAN [deg]
omega_c = omega_t;  % Argument of perigee [deg]
nu_c = nu_t + 0.5;  % True anomaly [deg]

T_orb_c = 2*pi*sqrt(a_c^3/earth.mu); % orbital period of chaser [s]

m = 20; % kg, mass of the chaser

% convert chaser orbital elements to ECI state
% convert chaser orbital elements to ECI state
[rc_ECI, vc_ECI] = convertOEtoRV(a_c, e_c, i_c, Omega_c, omega_c, nu_c, earth.mu);
Xc0 = [rc_ECI; vc_ECI];  % initial state vector of target

% state vector of the two satellites
X0 = [Xt0; Xc0];

%% Relative Orbit Controller Design
% mean motion of target orbit
n_t = sqrt(earth.mu / a_t^3); % [rad/s]

% matrics from CW equations
A_CW = [0, 0, 0, 1, 0, 0;
        0, 0, 0, 0, 1, 0;
        0, 0, 0, 0, 0, 1;
        3*n_t^2, 0, 0, 0, 2*n_t, 0;
        0, 0, 0, -2*n_t, 0, 0;
        0, 0, -n_t^2, 0, 0, 0];

B_CW = [zeros(3); eye(3)];

% follow example in the lecture
alpha = 0.00035; % user-define
A_alpha = -alpha * eye(6) - A_CW;
check_stability_matrix = eig(A_alpha);

% print the eigenvalues of A_alpha
% disp('Eigenvalues of A_alpha:');
% disp(check_stability_matrix);

W = lyap(A_alpha, B_CW*B_CW');
P = inv(W);
K = 1/2 * B_CW' * P; % control gain (constant)

% print size of K
% disp('Size of K:');
% disp(size(K));

enable_ctrl = true;

%% Simulation Setup
% simulation time
t0      = 0;            % initial time [s]
tf      = 10.5*T_orb_t;   % final time [s]
h       = 10;           % time step [s]
t_range = [t0 tf];      % time range [s]

% set parameters
params.mu = earth.mu;
params.K = K;
params.enable_ctrl = enable_ctrl;

% run simulation loop
[t_out, X_out] = RK4(@two_satellites, X0, h, t_range, params);

N = length(t_out); % number of time steps

% preallocate arrays to store the results
rho_LVLH_hist = zeros(3, N); % relative position in LVLH frame
u_ECI_hist    = zeros(3, N); % control input in ECI frame
rt_hist       = zeros(3, N); % target position in ECI frame
rc_hist       = zeros(3, N); % chaser position in ECI frame

% loop through the time steps and store the results
for i = 1 : N
    % extract state at time t_out(i)
    rt = X_out(1:3, i);
    vt = X_out(4:6, i);
    rc = X_out(7:9, i);
    vc = X_out(10:12, i);

    % save the ECI positions for plotting
    rt_hist(:, i) = rt;
    rc_hist(:, i) = rc;

    % compute the relative position in LVLH frame
    [rho, rho_dot, R_ECI2LVLH] = ECI2LVLH(rt, vt, rc, vc);
    rho_LVLH_hist(:, i) = rho;

    % compute control input in LVLH using the PD law
    % compute the control input
    u_LVLH = -K * [rho; rho_dot];

    % convert the control input from LVLH to ECI
    u_ECI = R_ECI2LVLH'*u_LVLH;

    u_ECI_hist(:, i) = u_ECI * 1000 * m; % convert to N

end

% check the norm of the control input
disp('Max Control Input Norm [N]:');
disp(max(vecnorm(u_ECI_hist)));

%% Plotting
% plot the relative position in LVLH frame

% convert t_out to number of orbits
t_orb = t_out / T_orb_t;

figure;
subplot(3, 1, 1);
plot(t_orb, rho_LVLH_hist(1, :), 'r', 'LineWidth', 1.5);
xlabel('Time [Orbits]'); ylabel('\rho_x [km]');
title('Rel Pos \rho_x in LVLH Frame');
grid on;

subplot(3, 1, 2);
plot(t_orb, rho_LVLH_hist(2, :), 'g', 'LineWidth', 1.5);
xlabel('Time [Orbits]'); ylabel('\rho_y [km]');
title('Rel Pos \rho_y in LVLH Frame');
grid on;

subplot(3, 1, 3);
plot(t_orb, rho_LVLH_hist(3, :), 'b', 'LineWidth', 1.5);
xlabel('Time [Orbits]'); ylabel('\rho_z [km]');
title('Rel Pos \rho_z in LVLH Frame');
grid on;
sgtitle('Relative Position in LVLH Frame');
if enable_ctrl
    saveas(gcf,'./HW3/plot_hw33a_LVLH_ON.png');
else
    saveas(gcf,'./HW3/plot_hw33a_LVLH_OFF.png');
end


% plot chaser trajectory in LVLH 
figure;
plot3(rho_LVLH_hist(1, :), rho_LVLH_hist(2, :), rho_LVLH_hist(3, :), 'b-', 'LineWidth', 1.5);
hold on;
% mark initial and final positions
plot3(rho_LVLH_hist(1, 1), rho_LVLH_hist(2, 1), rho_LVLH_hist(3, 1), 'ro', 'MarkerSize', 10, 'DisplayName', 'Start');
plot3(rho_LVLH_hist(1, end), rho_LVLH_hist(2, end), rho_LVLH_hist(3, end), 'gx', 'MarkerSize', 10, 'DisplayName', 'End');
xlabel('\rho_x [km]');
ylabel('\rho_y [km]');
zlabel('\rho_z [km]');
title('Chaser Trajectory in LVLH Frame');
legend('Trajectory', 'Start', 'End');
grid on;
axis equal;
hold off;
if enable_ctrl
    saveas(gcf,'./HW3/plot_hw33b_LVLH_3D_ON.png');
else
    saveas(gcf,'./HW3/plot_hw33b_LVLH_3D_OFF.png');
end

% plot chaser trajectory in LVLH (2D: \rho_x vs. \rho_y)
figure;
plot(rho_LVLH_hist(1, :), rho_LVLH_hist(2, :), 'b-', 'LineWidth', 1.5);
hold on;
plot(rho_LVLH_hist(1, 1), rho_LVLH_hist(2, 1), 'ro', 'MarkerSize', 10, 'DisplayName', 'Start');
plot(rho_LVLH_hist(1, end), rho_LVLH_hist(2, end), 'gx', 'MarkerSize', 10, 'DisplayName', 'End');
xlabel('\rho_x [km]');
ylabel('\rho_y [km]');
title('Chaser Trajectory in LVLH Frame');
legend('Trajectory', 'Start', 'End');
grid on;
axis equal;
hold off;
if enable_ctrl
    saveas(gcf,'./HW3/plot_hw33b_LVLH_2D_ON.png');
else
    saveas(gcf,'./HW3/plot_hw33b_LVLH_2D_OFF.png');
end

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

% % mark initial and final positions
plot3(rt_hist(1, 1), rt_hist(2, 1), rt_hist(3, 1), 'ko', 'MarkerSize', 10, 'DisplayName', 'Target Start');
hold on;
plot3(rc_hist(1, 1), rc_hist(2, 1), rc_hist(3, 1), 'bo', 'MarkerSize', 10, 'DisplayName', 'Chaser Start');
plot3(rt_hist(1, end), rt_hist(2, end), rt_hist(3, end), 'k*', 'MarkerSize', 10, 'DisplayName', 'Target End');
plot3(rc_hist(1, end), rc_hist(2, end), rc_hist(3, end), 'b*', 'MarkerSize', 10, 'DisplayName', 'Chaser End');

% plot the trajectory of the chaser and target in ECI frame (3D Plot)
plot3(rt_hist(1, :), rt_hist(2, :), rt_hist(3, :), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Target');
%hold on;
plot3(rc_hist(1, :), rc_hist(2, :), rc_hist(3, :), 'b-', 'LineWidth', 1.5, 'DisplayName', 'Chaser');

xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');
title('Chaser and Target Trajectory in ECI Frame');
legend('location', 'best');
grid on;
axis equal;
hold off;
if enable_ctrl
    saveas(gcf,'./HW3/plot_hw33c_tracjectory_ON.png');
else
    saveas(gcf,'./HW3/plot_hw33c_tracjectory_OFF.png');
end

% % plot Control Input Over Time (ECI Components)
if enable_ctrl

    figure;
    subplot(3,1,1);
    plot(t_orb, u_ECI_hist(1,:), 'LineWidth', 1.5);
    xlabel('Time [Orbits]'); ylabel('u_x [N]');
    title('Control Input u_x (ECI)');
    grid on;

    subplot(3,1,2);
    plot(t_orb, u_ECI_hist(2,:), 'LineWidth', 1.5);
    xlabel('Time [Orbits]'); ylabel('u_y [N]');
    title('Control Input u_y (ECI)');
    grid on;

    subplot(3,1,3);
    plot(t_orb, u_ECI_hist(3,:), 'LineWidth', 1.5);
    xlabel('Time [Orbits]'); ylabel('u_z [N]');
    title('Control Input u_z (ECI)');
    grid on;
    sgtitle('Control Input in ECI Frame');
    saveas(gcf,'./HW3/plot_hw33d_control_ECI.png');
end
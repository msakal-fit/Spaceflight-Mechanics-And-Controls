clear; clc; close all;

%% Initial Setup

% define constants
earth.mu = 3.986e5;    % [km^3/s^2]
earth.Re = 6378;       % [km]

% given initial state at t0=0 [s]
r0 = [-3.6244; 5.737; 1.1223]*1e3;  % position [km]
v0 = [-6.4641; -3.9954; -0.4521];   % velocity [km/s]

% define key times [s]
t0 = 0;     % initial time
tprime = 600; % time of first burn
tf = 3000; % final time

% time step for simulation [s]
h = 5;

% propagate the asteroid state from t0 to tprime using RK4
t_range1 = [t0, tprime];
[t1, X1] = RK4(@satelliteODE, [r0; v0], h, t_range1, earth.mu);

% these will be used for lambertsolver and plotting
state_tprime = X1(:, end); % state at tprime
r_tprime = state_tprime(1:3); % position at tprime
v_tprime = state_tprime(4:6); % velocity at tprime


%% Solve Lambert's Problem using Bisection Method

% the intercept point is given by: 
r2_target = [-1271.6350; -11371.0483; 3148.5939];  % [km]

% time-of-flight from tprime to tf
TOF = tf - tprime;

% compute geometrics parameters
r1mag = norm(r_tprime);
r2mag = norm(r2_target);
c = norm(r2_target - r_tprime); % chord length
s = (r1mag + r2mag + c) / 2; % semi-perimeter
a_min = (r1mag + r2mag + c) / 4; % lower bound for a_t

fprintf('Geometric params: r1mag = %.4f, r2mag = %.4f, c = %.4f, s = %.4f, a_min = %.4f\n',...
    r1mag, r2mag, c, s, a_min);

% minimum flight time 
t_min = 1/3 * sqrt(2) * sqrt(s^3 / earth.mu) * (1 - ((s-c)/s)^(3/2));
fprintf('Minimum flight time (parabolic transfer) t_min = %.4f s\n', t_min);

% compute transfer angles alpha and beta (using short-way)
alpha_m = 2 * asin( sqrt(s / (2 * a_min)) );
beta_m  = 2 * asin( sqrt((s - c) / (2 * a_min)) );

t_max = sqrt(a_min^3 / earth.mu) * (alpha_m - beta_m - (sin(alpha_m) - sin(beta_m)));
fprintf('Maximum transfer time t_max = %.4f s\n', t_max);

% To ensure proper sign for beta (for short-way transfer) if needed:
if TOF <= t_max
    % Already consistent with short-way
    fprintf('Short-way transfer checked\n');
end

% solve Lambert problem
fprintf('Starting LambertSolverBisection\n');
v_required = lambertSolverBisection(r_tprime, r2_target, TOF, earth.mu);

% compute the impulsive delta_v (the difference between the required and current velocity)
delta_v = v_required - v_tprime;
delta_v_mag = norm(delta_v);
fprintf('The required delta-v is %.4f km/s\n', delta_v_mag);


function Xdot = satelliteFullStateDynamics(t, X, params)

    %% orbital dynamics
    r = X(1:3); % position vector
    v = X(4:6); % velocity vector

    % extract parameters
    mu = params.gravity.mu; % gravitational parameter
    J = params.J; % inertia matrix
    tau = params.tau; % control torque

    % compute gravitational acceleration
    r_norm = norm(r);
    a_grav = - mu * r / r_norm^3;

    %% Attitude dynamics
    omega = X(7:9); % angular velocity [rad/s]
    q     = X(10:13); % quaternion q = [q0, q1, q2, q3]

    % normalize the quaternion
    q = q / norm(q);

    % euler's equation
    omega_dot = J \ (tau - cross(omega, J*omega));

    % quaternion kinematics
    % define quaternions
    q0 = q(1);
    qv = q(2:4);

    % define skew-symmetric matrix of q_v
    qv_skew = [0, -qv(3), qv(2);
                qv(3), 0, -qv(1);
                -qv(2), qv(1), 0];

    % compute derivative
    qv_dot = 0.5 * (qv_skew + q0 * eye(3)) * omega;
    q0_dot = -0.5 * qv' * omega;

    % assemble quaternion derivative
    q_dot = [q0_dot; qv_dot];

    %% assemble state derivative
    Xdot = [v; a_grav; omega_dot; q_dot];
end
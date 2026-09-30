function Xdot = two_satellites(t, X, params)

    % Extract target and chaser states
    rt = X(1:3);
    vt = X(4:6);
    rc = X(7:9);
    vc = X(10:12);

    % Extract parameters
    mu = params.mu;
    K = params.K;

    enable_ctrl = params.enable_ctrl;

    %% relative state dynamics
    % Use the ECI2LVLH function to compute the rel states
    [rho, rho_dot, R_ECI2LVLH] = ECI2LVLH(rt, vt, rc, vc);

    % compute the control input
    u_LVLH = - K * [rho; rho_dot]; % 

    % convert the control input from LVLH to ECI
    u_ECI = R_ECI2LVLH' * u_LVLH;

    %% target satellit EoMs
    % compute the grav accel for the target
    a_target = -mu * rt / norm(rt)^3;

    %% chaser satellite EoMs
    % compute the grav accel for the chaser
    a_chaser_grav = -mu * rc / norm(rc)^3;

    % apply the control accel to the chaser
    if enable_ctrl
        a_chaser = a_chaser_grav + u_ECI;
    else
        a_chaser = a_chaser_grav;
    end

    % assemble the derivative of the state vector
    Xdot = [vt; a_target; vc; a_chaser];

end
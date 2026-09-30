function X_dot = satelliteODETwoBurns(t, X, params)

    r = X(1:3); % position

    v = X(4:6); % velocity

    % Extract parameters
    mu = params.mu;
    b1_start = params.b1_start;
    b1_duration = params.b1_duration;
    a1 = params.a1;
    b2_start = params.b2_start;
    b2_duration = params.b2_duration;
    a2 = params.a2;

    r_mag = norm(r);
    a_grav = - mu * r / r_mag^3; % gravitational acceleration

    % initialize thrust accel as zero
    a1_thrust = [0; 0; 0];
    a2_thrust = [0; 0; 0];

    % apply thrust only during the burn window
    if (abs(t - b1_start) < b1_duration/2)
        u_t = v / norm(v);

        a1_thrust = a1 * u_t;
    end

    if (abs(t - b2_start) < b2_duration/2)
        a2_thrust = a2;
    end

    a_total = a_grav + a1_thrust + a2_thrust;
    X_dot = [v; a_total];

end
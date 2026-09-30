function X_dot = satelliteODE_thrust(t, X, mu, burn_start, burn_duration, a_req, thrust_dir)

    r = X(1:3);
    v = X(4:6);
    r_mag = norm(r);
    a_grav = - mu * r / r_mag^3; % gravitational acceleration

    % initialize thrust accel as zero
    a_thrust = [0; 0; 0];

    % apply thrust only during the burn window
    if (abs(t - burn_start) < burn_duration/2)
        a_thrust = a_req * thrust_dir;
    end

    a_total = a_grav + a_thrust;
    X_dot = [v; a_total];

end
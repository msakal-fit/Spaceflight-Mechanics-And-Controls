function X_dot = two_body_dynamics(t, X)
    % Earth's gravitational parameter
    mu = 3.986*1e5; % km^3/s^2

    r = X(1:3);
    v = X(4:6);

    r_mag = norm(r);
    a = - mu * r / r_mag^3; % gravitational acceleration

    X_dot = [v; a];

end

function X_dot = satelliteODE(t, X, mu)

    r = X(1:3);
    v = X(4:6);

    r_mag = norm(r);
    a = - mu * r / r_mag^3; % gravitational acceleration

    X_dot = [v; a];

end
function [i_deg, RAAN_deg, a, e, nu_deg, omega_deg] = convertRVtoOE(r, v, mu)
% convertRVtoOE converts position and velocity vectors to orbital elements

    % 1. compute magnitude of r and v
    r_mag = norm(r);
    v_mag = norm(v);

    % 2. compute specific angular momentum and its magnitude
    h = cross(r, v);
    h_mag = norm(h);

    h_hat = h / h_mag; % unit vector of h

    % 3. compute inclination i
    % i = atan2(sqrt(hx^2 + hy^2), hz) % radians
    i_rad = atan2(sqrt(h(1)^2 + h(2)^2), h(3)); 
    i_deg = rad2deg(i_rad);

    % 4. compute right ascension of the ascending node RAAN
    % RAAN = atan2(hx, -hy)
    RAAN_rad = atan2(h(1), -h(2));
    RAAN_deg = rad2deg(RAAN_rad);

    % 5. compute semi-latus rectum p
    p = h_mag^2 / mu; % km

    % 6. compute semi-major axis a
    a = 1 / (2 / r_mag - v_mag^2 / mu); % km

    % 7. compute eccentricity e
    e = sqrt(1 - p / a); % eccentricity

    % 8. compute mean motion n
    n = sqrt(mu / a^3); % radians/s

    % 9. compute Eccentric Anomaly E
    % E = atan2( (r · v)/(a^2 * n), 1 - (r_mag / a) )
    E_rad = atan2(dot(r, v) / (a^2 * n), 1 - (r_mag / a));

    % Normalize E to [0, 2π]
    if E_rad < 0
        E_rad = E_rad + 2*pi;
    end
    E_deg = rad2deg(E_rad);

    % 10. Compute Mean Anomaly M (in radians)
    % M = E - e*sin(E)
    M_rad = E_rad - e*sin(E_rad);
    
    % Normalize M to [0, 2π]
    if M_rad < 0
        M_rad = M_rad + 2*pi;
    end
    M_deg = rad2deg(M_rad);

    % 11. Compute argument of latitude u = ω + ν
    % u = atan2(rz, -rx*h_hat_y + ry*h_hat_x)
    u_rad = atan2(r(3), -r(1)*h_hat(2) + r(2)*h_hat(1));
    u_deg = rad2deg(u_rad);

    % 12. Compute true anomaly nu (in radians)
    % nu = atan2( sqrt(1 - e^2) * sin(E), cos(E) - e )
    nu_rad = atan2(sqrt(1 - e^2)*sin(E_rad), cos(E_rad) - e);

    % Normalize nu to [0, 2π]
    if nu_rad < 0
        nu_rad = nu_rad + 2*pi;
    end
    nu_deg = rad2deg(nu_rad);

    % 13. Compute argument of perigee omega = u - ν
    omega_rad = u_rad - nu_rad;
    if omega_rad < 0
        omega_rad = omega_rad + 2*pi;
    end
    omega_deg = rad2deg(omega_rad);

    %% For debug
    % disp(['Eccentric Anomaly (E):        ', num2str(E_deg), ' deg']);
    % disp(['Mean Anomaly (M):             ', num2str(M_deg), ' deg']);
    % disp(['Argument of latitude (u):     ', num2str(u_deg), ' deg']);

end


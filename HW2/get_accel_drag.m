% HW2/get_accel_drag.m

function a_drag_eci = get_accel_drag(m, Cd, A, r_eci, v_eci, HP_Coeff, R_E, omega_E)


    % get atm density at altitude h
    h = norm(r_eci) - R_E; % [km] altitude of the satellite

    rho_g_km3 = get_density_HP(h, HP_Coeff, 'average'); % [g/km^3] atmospheric density at the satellite altitude
    rho = rho_g_km3 * 1e-12; % convert to kg/m^3

    % convert to meter
    KM2M = 1e3;

    r_eci_m = r_eci * KM2M; % [m] position vector in ECI
    v_eci_m = v_eci * KM2M; % [m/s] velocity vector in ECI

    % get relative velocity
    v_rel = v_eci_m - cross(omega_E, r_eci_m); % [m/s] relative velocity
    v_rel_mag = norm(v_rel); % [m/s] magnitude of relative velocity

    % compute drag acceleration
    a_drag_m = -0.5 * Cd * A * rho * v_rel_mag .* v_rel ./ m; % [m/s^2] drag acceleration

    % convert to km
    a_drag_eci = a_drag_m / KM2M; % [km/s^2] drag acceleration in ECI

end


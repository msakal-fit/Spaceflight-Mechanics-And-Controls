function [r_ECI, v_ECI] = convertOEtoRV(a, e, i_deg, Omega_deg, omega_deg, nu_deg, mu)

    % 1. convert angles from degrees to radians
    i_rad     = deg2rad(i_deg);
    Omega_rad = deg2rad(Omega_deg);
    omega_rad = deg2rad(omega_deg);
    nu_rad    = deg2rad(nu_deg);

    %2. Compute Eccentric Anomaly, E, from true anomaly, nu
    %    E = atan2( sqrt(1 - e^2)*sin(nu), cos(nu) + e )
    E_rad = atan2(sqrt(1 - e^2) * sin(nu_rad), cos(nu_rad) + e);

    %3. Compute position in the perifocal frame
    r_pf = [ a*(cos(E_rad) - e);
             a*sqrt(1 - e^2)*sin(E_rad);
             0 ];

    %4. Find magnitude of r_pf for velocity calculation
    r_pf_mag = norm(r_pf);

    %5. Compute velocity in the perifocal frame
    %    v_pf = (sqrt(mu*a)/|r_pf|)*[-sin(E); sqrt(1 - e^2)*cos(E); 0]
    v_pf = ( sqrt(mu*a) / r_pf_mag ) * [ -sin(E_rad);
                                          sqrt(1 - e^2)*cos(E_rad);
                                          0 ];

    %6. Construct rotation matrices to transform from perifocal to ECI
    %    Order: Rz(-Omega) * Rx(-i) * Rz(-omega)
    R_z_Omega = [ cos(-Omega_rad),  sin(-Omega_rad), 0
                 -sin(-Omega_rad),  cos(-Omega_rad), 0
                  0,                0,               1 ];

    R_x_i = [ 1,     0,           0
              0, cos(-i_rad), sin(-i_rad)
              0, -sin(-i_rad), cos(-i_rad) ];

    R_z_omega = [ cos(-omega_rad),  sin(-omega_rad), 0
                 -sin(-omega_rad),  cos(-omega_rad), 0
                  0,                0,               1 ];

    % Combined rotation
    R = R_z_Omega * R_x_i * R_z_omega;

    % 7. Transform position and velocity to ECI
    r_ECI = R * r_pf;  % km
    v_ECI = R * v_pf;  % km/s
end
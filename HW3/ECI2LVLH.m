function [rho, rho_dot, R_ECI2LVLH] = ECI2LVLH(rt, vt, rc, vc)
    % Earth's gravitational parameter (km^3/s^2)
    GMe = 398600;
    
    % Define the LVLH axes:
    % Radial unit vector along the target position vector.
    e_r = rt / norm(rt);
    
    % Compute the target's angular momentum vector.
    h = cross(rt, vt);
    
    % Out-of-plane unit vector (same as k_unit in first function).
    e_z = h / norm(h);
    
    % Along-track unit vector to complete the right-handed system.
    e_t = cross(e_z, e_r);
    
    % Assemble the rotation matrix (columns are the LVLH unit vectors in ECI).
    R_LVLH2ECI = [e_r, e_t, e_z];
    R_ECI2LVLH = R_LVLH2ECI';  % Inverse transformation (transpose).
    
    % Relative position in ECI frame.
    rho_ECI = rc - rt;
    
    % Compute the target's mean motion.
    nt = sqrt(GMe / norm(rt)^3);
    
    % Compute the relative velocity in ECI, including the correction for LVLH rotation.
    v_ECI = vc - vt - cross(nt * e_z, (rc - rt));
    
    % Transform the relative position and velocity to the LVLH frame.
    rho = R_ECI2LVLH * rho_ECI;
    rho_dot = R_ECI2LVLH * v_ECI;
end

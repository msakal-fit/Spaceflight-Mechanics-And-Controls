% HW2/get_accel_moon_grav.m

function a_moon_eci = get_accel_moon_grav(r_eci, t, params)

    % (1) get moon position s(t) in ECI using planetEphemeris

    % Determine the simulation time in seconds relative to sim start time
    if isnumeric(t)
        simTimeSec = t;
    elseif isdatetime(t)
        simTimeSec = seconds(t - params.startTime);
    else
        error('Invalid time input');
    end

    % Covert simulation time to Julian date
    currentJD = params.startTimeJD + (simTimeSec / 86400);

    s_eci = planetEphemeris(currentJD, 'Earth', 'Moon');
    s_eci = s_eci(:); % ensure it is a column vector

    % form the unit vector
    s_norm = norm(s_eci);
    r_norm = norm(r_eci);

    s_hat = s_eci / s_norm;
    r_hat = r_eci / r_norm;

    % compute acceleration
    factor = (params.moon.mu/s_norm^3 * r_norm ); 
    
    a_moon_eci = factor * (-r_hat + 3*s_hat*(dot(s_hat, r_hat)));
end
% HW2/passive_satellite.m

function Xdot = passive_satellite(t, X, params)

    % Extract state components
    r = X(1:3);
    v = X(4:6);

    % Ensure it is a column vector
    r = r(:);
    v = v(:);

    % convert scalar time t to a datetime
    % need as input for get_accel_geopotential
    if ~isdatetime(t)
        if isfield(params, 'startTime')
            t_datetime = params.startTime + second(t);
        else
            error('startTime field must be provided')
        end
    else
        t_datetime = t;
    end

    % compute Earth's gravitational acceleration in ECI
    if params.useGeopotential
        % get spherical harmonics coefficients
        [C, S] = get_harmonics_coefficients(params.gravity.degree, params.gravity.order);

        % compute gravitational acceleration
        a_grav = get_accel_geopotential(params.gravity.degree, ...
                                       params.gravity.order, ...
                                       r, t_datetime, ...
                                       params.gravity.mu, ...
                                       params.gravity.Re, ... 
                                       C, S);
    else
        r_norm = norm(r);
        a_grav = -params.gravity.mu / r_norm^3 * r;
    end
    
    % Add moon gravity
    if params.useMoon
        a_moon = get_accel_moon_grav(r, t, params);
    else
        a_moon = zeros(3,1);
    end

    if params.useDrag
        a_drag = get_accel_drag(params.drag.mass, ...
                                params.drag.Cd, ...
                                params.drag.A, ...
                                r, v, ...
                                params.atmosphere.HP_coeff, ...
                                params.gravity.Re, params.omegaEarth);
    else
        a_drag = zeros(3,1);
    end

    %  total acceleration
    a_total = a_grav + a_moon + a_drag;

    % compute state derivative
    Xdot = [v; a_total];
end
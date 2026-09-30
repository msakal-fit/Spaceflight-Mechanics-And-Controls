% Lambert solver using bisection method
function v1 = lamberSolverBisection(r1, r2, dt, mu)
    % this function compute the required departure v1
    % such that it depart from r1 to r2 in time dt

    % compute geometrics parameters
    r1mag = norm(r1);
    r2mag = norm(r2);
    c = norm(r2 - r1); % chord length
    s = (r1mag + r2mag + c) / 2; % semi-perimeter
    a_min = (r1mag + r2mag + c) / 4; % lower bound for a_t


    % use bisection method to find a_t
    a_t = search_a_t(dt, mu, s, c, a_min);

    % compute transfer angles alpha and beta (using short-way)
    alpha = 2 * asin( sqrt(s / (2 * a_t)) );
    beta  = 2 * asin( sqrt((s - c) / (2 * a_t)) );

    % compute the scalar coefficient A and B
    A = sqrt(mu / (4 * a_t)) * cot(alpha / 2);
    B = sqrt(mu / (4 * a_t)) * cot(beta / 2);

    % compute unit vector along the chord from r1 to r2
    u_c = (r2 - r1) / c;

    % compute unit vector along the velocity at r1
    u1 = r1/norm(r1); 
    
    % Compute the required departure velocity v1
    v1 = (B + A) * u_c + (B - A) * u1;

end

% Bisection search to find a_t such that the computed transfer time matches dt.
function a_t = search_a_t(dt, mu, s, c, a_min)
    a_max = 5 * a_min;      % initial upper bound (can be adjusted)
    min_a_diff = 1e-6;      % convergence tolerance on a_t
    iter = 0;
    while (a_max - a_min) > min_a_diff
        iter = iter + 1;
        a_mid = (a_min + a_max) / 2;
        dt_mid = lamberts(a_mid, mu, s, c);
        %fprintf('Iter %2d: a_min = %.6f, a_max = %.6f, a_mid = %.6f, dt_mid = %.2f s\n',...
        %           iter, a_min, a_max, a_mid, dt_mid);
        if dt_mid > dt
            a_min = a_mid;  % dt_mid is too high → decrease a_t to shorten dt
        else
            a_max = a_mid;  % dt_mid is too low → increase a_t to lengthen dt
        end
    end
    a_t = a_mid;
    %fprintf('Converged after %2d iterations: a_t = %.6f km\n', iter, a_t);
end

% Computes the transfer time for a given semi-major axis a using Lambert’s equation.
function dt_calc = lamberts(a, mu, s, c)
    % Compute transfer angles alpha and beta
    alpha = 2 * asin( sqrt(s / (2*a)) );
    beta  = 2 * asin( sqrt((s - c) / (2*a)) );
    % Compute the time of flight based on Lambert's equation:
    dt_calc = sqrt(a^3 / mu) * ( (alpha - beta) - (sin(alpha) - sin(beta)) );
end

% cot(x) helper function
function y = cot(x)
    y = cos(x) ./ sin(x);
end

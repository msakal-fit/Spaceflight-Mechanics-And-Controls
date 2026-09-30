function E = solveKeplerEquation(M, e, tol, maxIter)

    % initial guess for E
    if e < 0.8
        E = M; % initial guess
    else
        E = pi; % initial guess for highly eccentric orbits
    end

    for k = 1:maxIter
        f    = E - e*sin(E) - M;          % f(E) = E - e sin(E) - M
        fdot = 1 - e*cos(E);              % df/dE
        E_new = E - f / fdot;             % Newton step
        if abs(E_new - E) < tol
            E = E_new;
            return;
        end
        E = E_new;
    end
    warning('Fixed-point iteration did not converge within %d iterations.', maxIter);
end





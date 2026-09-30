function a_grav_eci = get_accel_geopotential(maxDegree, maxOrder, ...
    r_eci, t, mu, Re, C, S)


    % define the coordinate system
    csys = 'IAU-2000/2006';

    % compute the transformation matrix from ECI to ECEF
    dcm = dcmeci2ecef(csys, t);

    % convert position vector from ECI to ECEF
    r_ecef = dcm * r_eci;

    % compute the geopotential acceleration in ECEF
    % using the recursion method
    a_ecef = gravity_accel_ecef_recursion(r_ecef, ...
                                    maxDegree, maxOrder,...
                                    mu, Re, C, S);   
                                    
    a_grav_eci = dcm' * a_ecef;
end

function a_ecef = gravity_accel_ecef_recursion(r_ecef, ...
    maxDegree, maxOrder, mu, Re, C_nm, S_nm)

    % extract ECEF coordinates
    x_e = r_ecef(1);
    y_e = r_ecef(2);
    z_e = r_ecef(3);
    r = norm(r_ecef);

    % build array of V_{n, m} and W_{n, m} terms
    % Matlab use 1-based indexing, so we need to add 1 to the degree and order
    % to get the correct index in the array.
    V = zeros(maxDegree+2, maxOrder+2); % V_{n+1, m+1} is at V(n+2, m+2)
    W = zeros(maxDegree+2, maxOrder+2); % W_{n+1, m+1} is at W(n+2, m+2)

    % initialize terms
    %V_{0,0} = Re/r, W_{0,0} = 0
    V(1, 1) = Re / r; % V_{0,0} is at V(1, 1)
    W(1, 1) = 0;

    % build the recursion arrays

    for n = 1:(maxDegree+1)
        for m = 0: n
            i = n + 1; % row index of degrees
            j = m + 1; % column index of orders

            if m == n
                % Sectorial terms (n = m)
                alpha = (2*n - 1) * (Re / (r^2));
                V(i,j) = alpha * ( x_e * V(i-1, j-1) - y_e * W(i-1, j-1) );
                W(i,j) = alpha * ( x_e * W(i-1, j-1) + y_e * V(i-1, j-1) );
            else
                % Tesseral/zonal terms (n > m)
                alpha = (2*n - 1) / (n - m) * ( z_e * Re / (r^2) );
                beta  = (n + m - 1) / (n - m) * ( Re^2 / (r^2) );
                
                V(i,j) = alpha * V(i-1, j);
                W(i,j) = alpha * W(i-1, j);
                
                % this recursion, beta term involved two previous rows (i-2)
                % thus only valid when n-2 >= m
                % when n-2 < m, we try to access the entry 
                % above the Sectorial terms (n = m), thus invalid

                if (n - 2) >= m
                    V(i,j) = V(i,j) - beta * V(i-2, j);
                    W(i,j) = W(i,j) - beta * W(i-2, j);
                end
            end
        end
    end

    a_ecef = zeros(3,1);  % initialize acceleration vector.
    prefac = mu / (Re^2);
    
    % loop over spherical harmonic degrees and orders.
    for n = 0:maxDegree
        for m = 0: n
            % retrieve the spherical harmonic coefficients.
            Cnm = C_nm(n+1, m+1);
            Snm = S_nm(n+1, m+1);
            
            if m == 0
                % sectorial (m = 0) terms.
                ax_nm = - Cnm * V(n+2, 2); % V_{n+1,1} is at V(n+2, 1+1)
                ay_nm = - Cnm * W(n+2, 2); % W_{n+1,1} is at W(n+2, 1+1)
                az_nm = (n - m + 1) * ( - Cnm * V(n+2, 1) ...
                                    - Snm * W(n+2, 1) );
            else
                % tesseral (m > 0) terms.
                fr = factorial(n - m + 2) / factorial(n - m);
                ax_nm = 0.5 * ( ...
                    - Cnm * V(n+2, m+2) ...
                    - Snm * W(n+2, m+2) ...
                    + fr * ( Cnm * V(n+2, m) ...
                            + Snm * W(n+2, m) ) ...
                );
                ay_nm = 0.5 * ( ...
                    - Cnm * W(n+2, m+2) ...
                    + Snm * V(n+2, m+2) ...
                    + fr * ( - Cnm * W(n+2, m) ...
                            + Snm * V(n+2, m) )...
                );
                az_nm = (n - m + 1) * ( ...
                    - Cnm * V(n+2, m+1) ...
                    - Snm * W(n+2, m+1) ...
                );
            end
            
            % accumulate the contributions.
            a_ecef(1) = a_ecef(1) + ax_nm;
            a_ecef(2) = a_ecef(2) + ay_nm;
            a_ecef(3) = a_ecef(3) + az_nm;
        end
    end
    
    % multiply the sum by the prefactor.
    a_ecef = prefac * a_ecef;
end


% HW2/RK4.m
% Runge-Kutta 4th order integrator with parameters

function [t_out, X] = RK4(func, X_0, h, t_range, varargin)

    % preallocate output array
    N = floor((t_range(2) - t_range(1)) / h) + 1;
    t_out = zeros(N, 1);
    X = zeros(length(X_0), N);    % each column is a state vector

    % initialize
    t_out(1) = t_range(1);
    X(:, 1) = X_0;
    idx = 1;
    t = t_range(1);
    X_i = X_0;

    % loop until we reach the final index
    while idx < N
        k1 = func(t, X_i, varargin{:});
        k2 = func(t + h/2, X_i + h/2 * k1, varargin{:});
        k3 = func(t + h/2, X_i + h/2 * k2, varargin{:});
        k4 = func(t + h, X_i + h * k3, varargin{:});

        phi = 1/6 * (k1 + 2*k2 + 2*k3 + k4);
        X_i_plus_h = X_i + phi * h;

        X_i = X_i_plus_h;

        % update state using preallocated array
        idx = idx + 1;  
        t = t + h;
        t_out(idx) = t;
        X(:, idx) = X_i_plus_h;
    end
end
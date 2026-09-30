load('HW4/simulation_data.mat'); % Load the satellite data

time_array = t_out;     % 1xN vector containing simulation time points
q_array = q_history;    % 4xN array containing quaternion history
pos_array = r_history;  % 3xN array containing position history

% animate the satellite dynamics
scale_factor = 1/4000; % scale factor for the satellite size
animate_attitude(time_array, q_array, 'qua', scale_factor * pos_array);
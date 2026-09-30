%% Visualize Satellite Orbit with Custom 3-D Model and Attitude
clc; clear all; close all;

%% Load Full Simulation Data
% The file 'sat_data.mat' is assumed to contain:
%   time_array: 1xN numeric vector (seconds from simulation start)
%   q_array: 4xN array of quaternions (scalar-first) for attitude
%   pos_array: 3xN array of positions (in kilometers)
%   v_array: 3xN array of velocities (in km/s)
load('sat_data.mat', ...
    'time_array', ...
    'pos_array', 'v_array', 'q_array');


%% Define Simulation Time and Convert Units
% Set simulation start time (this should match the simulation epoch)
simStartTime = datetime(2025,2,7,12,54,13);
% Create a datetime vector for each simulation time by adding seconds to the start time
simTime = simStartTime + seconds(time_array);

% Convert position data from kilometers to meters (required for visualization)
positions = pos_array * 1000;   % positions in meters
% Convert velocity data from km/s to m/s
velocities = v_array * 1000;      % velocities in m/s

% Transpose q_array to get an N×4 matrix where each row is a quaternion.
attData = q_array';


% Create Timeseries Objects
% Create a timeseries object for positions (each row corresponds to a sample)
posTS = timeseries(positions', time_array);   % size: N×3
% Create a timeseries object for velocities (each row corresponds to a sample)
velTS = timeseries(velocities', time_array);    % size: N×3

% Create a timeseries for normalized attitude data.
attTS = timeseries(attData, time_array);        % size: N×4


%% Create the Satellite Scenario and Add the Satellite
% Create the satellite scenario using the simulation start time and the last simulation time.
scenario = satelliteScenario(simStartTime, simTime(end), 10);

% Add the satellite using the position and velocity timeseries.
sat = satellite(...
    scenario, ...
    posTS, velTS, ...
    'CoordinateFrame', 'inertial', ...
    'Name', 'SVR-CubeSat');

% Override the default attitude (nadir) by applying your custom attitude timeseries.
% This call interprets your attitude data as scalar-first quaternions that rotate 
% from the inertial frame to the body frame.
pointAt(sat, attTS, ...
    'CoordinateFrame','inertial', ...
    'Format','quaternion' ...
);

% Customize the Satellite Visualization
% Set a custom 3-D model (e.g., "CubeSat.glb") and display coordinate axes.
sat.Visual3DModel = "CubeSat-2U.glb";
sat.Visual3DModelScale = 1; % Adjust the scale of the model
coordinateAxes(sat, 'Scale', 3);

% set how orbit trail is displayed
sat.orbit.TrailTime = 10*60; % Set the trail time to 10 mins
sat.orbit.LeadTime = 30*60; % Set the lead time to 30 mins

% Create the Scenario Viewer and Play the Simulation
v = satelliteScenarioViewer(scenario);
% Create viewer and play
play(scenario, "Viewer", v, ...
    "PlaybackSpeedMultiplier", 200); % Adjust playback speed as needed

% Set the camera target to the satellite
camtarget(v, sat);
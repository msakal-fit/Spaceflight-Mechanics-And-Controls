%% Visualize Satellite Orbit with Custom 3-D Model

clc; clear all; close all;

% Load simulation data 
% The file 'sat_data.mat' is assumed to contain:
%   time_array: 1xN numeric vector (seconds from simulation start)
%   q_array: 4xN array of quaternions (scalar-first) for attitude
%   pos_array: 3xN array of positions (in kilometers)
%   v_array: 3xN array of velocities (in km/s)
load('sat_data.mat', ...
    'time_array', ...
    'pos_array', 'v_array', 'q_array');

% Define simulation start time (matching your simulation)
simStartTime = datetime(2025,2,7,12,54,13);

% Create a datetime vector for each simulation time
simTime = simStartTime + seconds(time_array);
% Convert simTime to a numeric vector representing seconds since simStartTime
timeVec = seconds(simTime - simStartTime);

% Convert positions (first 3 rows) and velocities (last 3 rows)
% from kilometers (km) and km/s to meters (m) and m/s
positions = pos_array * 1e3;   % positions in meters
velocities = v_array * 1e3;    % velocities in m/s

% Create timeseries objects for position and velocity data
posTS = timeseries(positions', timeVec);
velTS = timeseries(velocities', timeVec);

% Create a satellite scenario object with specified start, stop times and a sample time (seconds)
scenario = satelliteScenario(simStartTime, simTime(end), 10);

% Add a satellite to the scenario.
% Specify the CoordinateFrame as 'inertial' (i.e., GCRF) since our data is in that frame.
% Also, set the Visual3DModel
sat = satellite(...
    scenario, ...
    posTS, velTS, ...
    'CoordinateFrame', 'inertial', ...
    'Name', 'SVR-Sat');

% Add a custom 3-D model to the satellite visualization
sat.Visual3DModel = "ICESat.glb";
coordinateAxes(sat, Scale=2);

% set how orbit trail is displayed
sat.orbit.TrailTime = 10*60; % Set the trail time to 10 mins
sat.orbit.LeadTime = 30*60; % Set the lead time to 30 mins

% Create a satellite scenario viewer
v = satelliteScenarioViewer(scenario);

% Create viewer and play
play(scenario, "Viewer", v, ...
    "PlaybackSpeedMultiplier", 200); % Adjust playback speed as needed


% Set the camera target to the satellite
camtarget(v, sat);

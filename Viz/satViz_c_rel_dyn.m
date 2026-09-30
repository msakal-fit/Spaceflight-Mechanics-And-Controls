%% Visualize Both Target and Chaser with Custom 3-D Models and Attitude
clc; clear all; close all;

% Load simulation data (with attitude)
load('sat_rel_dyn_data.mat', ...
     'time_array', ...
     'pos_t_array','v_t_array','q_t_array', ...
     'pos_c_array','v_c_array','q_c_array');

% Define simulation start time
simStartTime = datetime(2025,2,7,12,54,13);

% Build the datetime vector
simTime = simStartTime + seconds(time_array);
timeVec = seconds(simTime - simStartTime);  % seconds since start

% Convert positions (km→m) and velocities (km/s→m/s)
pos_t_m = pos_t_array * 1e3;    vel_t_m = v_t_array * 1e3;
pos_c_m = pos_c_array * 1e3;    vel_c_m = v_c_array * 1e3;

% Create timeseries for position & velocity
posTS_t = timeseries(pos_t_m.', timeVec);
velTS_t = timeseries(vel_t_m.', timeVec);
posTS_c = timeseries(pos_c_m.', timeVec);
velTS_c = timeseries(vel_c_m.', timeVec);

% Create timeseries for attitude (quaternions scalar-first)
attTS_t = timeseries(q_t_array.', timeVec);
attTS_c = timeseries(q_c_array.', timeVec);

% Create satellite scenario (sample time = 10 seconds)
scenario = satelliteScenario(simStartTime, simTime(end), 10); 

% Add Target satellite
sat_t = satellite(...
    scenario, ...
    posTS_t, velTS_t, ...
    'CoordinateFrame','inertial', ...
    'Name','Target' ...
);
sat_t.Visual3DModel = "ICESat.glb";
sat_t.Visual3DModelScale = 1;
coordinateAxes(sat_t, Scale=2);

% Apply custom attitude to Target
%    rotates from inertial→body using scalar-first quaternions
pointAt(sat_t, attTS_t, ...
    'CoordinateFrame','inertial', ...
    'Format','quaternion' ...
);

% Add Chaser satellite
sat_c = satellite(...
    scenario, ...
    posTS_c, velTS_c, ...
    'CoordinateFrame','inertial', ...
    'Name','Chaser' ...
);
sat_c.Visual3DModel = "CubeSat-2U.glb";
sat_c.Visual3DModelScale = 1;
coordinateAxes(sat_c, Scale=2);

% Apply custom attitude to Chaser
pointAt(sat_c, attTS_c, ...
    'CoordinateFrame','inertial', ...
    'Format','quaternion' ...
);

% Create viewer and play
v = satelliteScenarioViewer(scenario);
play(scenario, "Viewer", v, ...
    "PlaybackSpeedMultiplier", 200); % Adjust playback speed as needed

% Optionally hide orbit trails
hide(sat_t.orbit)
hide(sat_c.orbit)

% Set camera to follow the Chaser (or switch to the Target)
% camtarget(v, sat_c);
camtarget(v, sat_t);

clc;clear ;close all
% Create a tracking scenario to manage the movement of the platforms.
scene = trackingScenario;

% Set the duration of the scenario to 10 seconds.
scene.StopTime = 10; % s

% Platform 1: Airborne and northbound at 500 km/h
spd = 500*1e3/3600; % m/s
wp1 = [0 0 -6000];
wp2 = [spd*scene.StopTime 0 -6000];
toa = [0; scene.StopTime];
platform(scene, 'Trajectory', waypointTrajectory('Waypoints', [wp1; wp2], 'TimeOfArrival', toa));

% Platform 2: Airborne and southbound at 600 km/h
spd = 600*1e3/3600; % m/s
wp1 = [30e3+spd*scene.StopTime 0 -6000];
wp2 = [30e3 0 -6000];
toa = [0; scene.StopTime];
platform(scene, 'Trajectory', waypointTrajectory('Waypoints', [wp1; wp2], 'TimeOfArrival', toa));

% Platform 3: Airborne and eastbound at 700 km/h
spd = 700*1e3/3600; % m/s
wp1 = [10e3 1e3 -6000];
wp2 = [10e3 1e3+spd*scene.StopTime -6000];
toa = [0; scene.StopTime];
platform(scene, 'Trajectory', waypointTrajectory('Waypoints', [wp1; wp2], 'TimeOfArrival', toa));
% Use theaterPlot to create a display showing the platforms in the scenario and their trajectories.

ax = axes;
theaterDisplay = theaterPlot('Parent',ax,'AxesUnit',["km" "km" "km"], 'XLim',[-10000 40000] , 'YLim', [-20000 20000], 'ZLim',[-1e7 1e7]);
view([90 -90]) % swap X and Y axis
patch('XData',[-10000 -10000 40000 40000],'YData',[-20000 20000 20000 -20000],'EdgeColor','none', 'FaceColor',[0.8 0.8 0.8],'DisplayName','Ground');

platPlotter = platformPlotter(theaterDisplay,'DisplayName','Platforms','MarkerFaceColor','k');
plotPlatform(platPlotter,vertcat(scene.platformPoses.Position));

trajPlotter = trajectoryPlotter(theaterDisplay,'DisplayName','Trajectories','LineStyle','-');
allTrajectories = cellfun(@(x) x.Trajectory.lookupPose(linspace(0,scene.StopTime,10)), scene.Platforms, 'UniformOutput', false);
plotTrajectory(trajPlotter,allTrajectories);

% Create the interference emitter.
rfEmitter = radarEmitter(1, 'No scanning', ...
    'FieldOfView', [20 5], ...       % [az el] deg
    'EIRP', 200, ...                 % dBi
    'CenterFrequency', 300e6, ...    % Hz
    'Bandwidth', 30e6, ...           % Hz
    'WaveformType', 0);               % Use 0 for noise-like emissions
% Attach the emitter to the first platform.
platEmit = scene.Platforms{1};
platEmit.Emitters = rfEmitter;

% Create a monostatic radar.
radar = monostaticRadarSensor(2, 'Sector', ...
    'UpdateRate', 12.5, ...          % Hz
    'FieldOfView', [2 10]);          % [az el] deg

% Mount the radar so that it scans the sector in front of the second
% platform which includes the interfering signal and the third platform.
radar.MountingAngles = [0 0 0];      % [Z Y X] deg

% Enable the radar's INS input so that it can use the pose estimated by
% the platform's pose estimator to generate detections.
radar.HasINS = true;

% Enable the radar's interference input so that the interference signal
% created by the emitter above can be passed to the radar.
radar.HasInterference = true;

% Set coordinate system for detections to scenario
radar.DetectionCoordinates = 'scenario';

% Attach the radar to the second platform.
platRadar = scene.Platforms{2};
platRadar.Sensors = radar;

% Update the display to show the platforms, the radar, and the emitter in the scenario.

emitterColor =  [0.9290 0.6940 0.1250];
radarColor = [0 0.4470 0.7410];
platEmitPlotter = platformPlotter(theaterDisplay,'DisplayName', 'RF emitter','Marker','d','MarkerFaceColor',emitterColor);
platRadarPlotter = platformPlotter(theaterDisplay,'DisplayName','Monostatic radar','Marker','d','MarkerFaceColor',radarColor);
platPlotter.DisplayName = 'Targets';
clearData(platPlotter);
covPlotter = coveragePlotter(theaterDisplay,'Alpha',[0.2 0]);
detPlotter = detectionPlotter(theaterDisplay,'DisplayName','Radar detections','MarkerFaceColor',radarColor);
title('Radar detection with an interfering emitter');

plotPlatform(platRadarPlotter, platRadar.pose.Position);
plotPlatform(platEmitPlotter, platEmit.pose.Position);
plotPlatform(platPlotter, scene.Platforms{3}.pose.Position);
plotCoverage(covPlotter, coverageConfig(scene), [-1 2], {emitterColor, radarColor});

scene.UpdateRate = 0;


% Set the random seed for repeatable results.
rng('default');

plotDets = {};
while advance(scene)
    
    % Emit the RF signal.
    txEmiss = emit(scene);
    
    % Reflect the emitted signal off of the platforms in the scenario.
    reflEmiss = propagate(scene, txEmiss);
    
    % Generate detections from the monostatic radar sensor.
    [dets, config] = detect(scene, reflEmiss);
    
    % Reset detections every time the radar completes a sector scan.
    if config.IsScanDone
        % Reset
        plotDets = dets;
    else
        % Buffer
        plotDets = [plotDets;dets]; %#ok<AGROW> 
    end
    
    % Update display with current platform positions, beam positions and detections.
    plotPlatform(platRadarPlotter, platRadar.pose.Position);
    plotPlatform(platEmitPlotter, platEmit.pose.Position);
    plotPlatform(platPlotter, scene.Platforms{3}.pose.Position);
    plotCoverage(covPlotter, coverageConfig(scene), [-1 2], {emitterColor, radarColor});
    if ~isempty(plotDets)
        allDets = [plotDets{:}];
        % extract column vector of measurement positions
        meas = [allDets.Measurement]';
        plotDetection(detPlotter,meas);
    end
end



restart(scene);
esm = radarSensor(1, 'No scanning', ...
    'DetectionMode', 'ESM', ...
    'UpdateRate', 12.5, ...          % Hz
    'MountingAngles', [0 0 0], ...   % [Z Y X] deg
    'FieldOfView', [30 10], ...      % [az el] deg
    'CenterFrequency', 300e6, ...    % Hz
    'Bandwidth', 30e6, ...           % Hz
    'WaveformTypes', 0, ...          % Detect the interference waveform type
    'HasINS', true);



platESM = scene.Platforms{2};
platESM.Sensors = esm;
% Update the visualization accordingly

platRadarPlotter.DisplayName = "ESM sensor";
esmColor = [0.4940 0.1840 0.5560];
platRadarPlotter.MarkerFaceColor = esmColor;
% use a helper to add an angle only detection plotter
delete(detPlotter);
esmDetPlotter = helperAngleOnlyDetectionPlotter(theaterDisplay,'DisplayName','ESM detections','Color',esmColor,'LineStyle','-');
clearData(covPlotter);

plotCoverage(covPlotter, coverageConfig(scene), [-1 1], {emitterColor, esmColor});
title('Passive detection of RF emissions');



% Set the random seed for repeatable results.
rng(2018);

plotDets = {};
snap = [];
while advance(scene)
    
    % Emit the RF signal.
    txEmiss = emit(scene);
    
    % Reflect the emitted signal off of the platforms in the scenario.
    reflEmiss = propagate(scene, txEmiss);
    
    % Generate detections from the monostatic radar sensor.
    [dets, config] = detect(scene, reflEmiss);
    
    % Reset detections every time the radar completes a sector scan.
    if config.IsScanDone
        % Reset
        plotDets = dets;
    else
        % Buffer
        plotDets = [plotDets;dets]; %#ok<AGROW> 
    end
    
    % Update display with current platform positions, beam positions and detections.
    plotPlatform(platRadarPlotter, platRadar.pose.Position);
    plotPlatform(platEmitPlotter, platEmit.pose.Position);
    plotPlatform(platPlotter, scene.Platforms{3}.pose.Position);
    plotCoverage(covPlotter, coverageConfig(scene), [-1 1], {emitterColor, esmColor});
    plotDetection(esmDetPlotter,plotDets);
        
    % Record the reflected detection at t = 2 sec
    snap = getSnap(ax, scene.SimulationTime, 2, snap);
    drawnow
end
title('RF emitter detected by an ESM sensor');


dets{1}.ObjectAttributes{1};

figure; imshow(snap.cdata);
title('Emitter and target detected by an ESM sensor');


restart(scene);

% Create the emitter for the monostatic radar.
radarTx = radarEmitter(2, 'Sector', ...
    'UpdateRate', 12.5, ...          % Hz
    'MountingAngles', [0 0 0], ...   % [Z Y X] deg
    'FieldOfView', [2 10], ...       % [az el] deg
    'CenterFrequency', 300e6, ...    % Hz
    'Bandwidth', 3e6, ...            % Hz
    'ProcessingGain', 50, ...        % dB
    'WaveformType', 1)       ;        % Use 1 to indicate this radar's waveform


radarRx = radarSensor(2, ...
    'DetectionMode', 'Monostatic', ...
    'EmitterIndex', radarTx.EmitterIndex, ...
    'HasINS', true,...
    'DetectionCoordinates','Scenario')

% Attach to the radar emitter and sensor to the second platform.
platRadar = scene.Platforms{2};
platRadar.Emitters = radarTx;
platRadar.Sensors = radarRx;
% Add the radar's waveform to the list of known waveform types for the ESM sensor.
esm.WaveformTypes = [0 1];

% Attach the ESM sensor to the first platform.
platESM = scene.Platforms{1};
platESM.Emitters = {}; % Remove the emitter.
platESM.Sensors = esm;


detPlotter = detectionPlotter(theaterDisplay,'DisplayName','Radar detections','MarkerFaceColor',radarColor);
platRadarPlotter.DisplayName = 'Monostatic radar';
platRadarPlotter.MarkerFaceColor = radarColor;
platEmitPlotter.DisplayName = 'ESM sensor';
platEmitPlotter.MarkerFaceColor = esmColor;
clearData(esmDetPlotter);
clearData(covPlotter);
covcon = coverageConfig(scene);
plotCoverage(covPlotter, covcon([1 3]) , [1 -2], {esmColor, radarColor});
title(ax,'Passive detection of a monostatic radar');



% Set the random seed for repeatable results.
rng(2018);

platforms = scene.Platforms;
numPlat = numel(platforms);


plotDets = {};
snap = [];
while advance(scene)
    
    % Emit the RF signal.
    [txEmiss, txConfigs] = emit(scene);
    
    % Reflect the emitted signal off of the platforms in the scenario.
    reflEmiss = propagate(scene, txEmiss);
    
    % Generate detections from the monostatic radar sensor.
    [dets, config] = detect(scene, reflEmiss, txConfigs);
    
    % Reset detections every time the radar completes a sector scan.
    if txConfigs(end).IsScanDone
        % Reset
        plotDets = dets;
    else
        % Buffer
        plotDets = [plotDets;dets];%#ok<AGROW>
    end
    
    % Update display with current platform positions, beam positions and detections.
    plotPlatform(platRadarPlotter, platRadar.pose.Position);
    plotPlatform(platEmitPlotter, platEmit.pose.Position);
    plotPlatform(platPlotter, scene.Platforms{3}.pose.Position);
    covcon = coverageConfig(scene);
    plotCoverage(covPlotter, covcon([1 3]) , [1 -2], {esmColor, radarColor});
    plotDetection(esmDetPlotter,plotDets);
    plotMonostaticDetection(detPlotter,plotDets);
    
    % Record the reflected detection at t = 5.6 sec
    snap = getSnap(ax, scene.SimulationTime, 5.6, snap);
    drawnow
end

figure; imshow(snap.cdata);
title('Radar and target detected by an ESM sensor');
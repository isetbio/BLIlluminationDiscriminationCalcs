% coneCurrentVisualizations
%
% This tutorial applies the code found in the ISETBIO tutorial
% t_osHyperSpectralSceneEyeScan to the BLIlluminationDiscrimination
% project.  The EM generation code in this project will be used to create
% saccadic movements and the full image of the stimuli will be used.
%
% xd    2/29/2016  wrote it

ieInit;

%% Load the data needed for visualizations
imageName = 'TestImage0';

% Load the scene and optical image
scene = loadSceneData('Neutral_FullImage/Standard', imageName);
oi = loadOpticalImageData('Neutral_FullImage/Standard', imageName);

% Create a sensor of the size used in the 2nd order model
sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, 0.07, [], oiCreate('human'));
em = emCreate;
em = emSet(em, 'sample time', 0.001);
sensor = sensorSet(sensor, 'eye move', em);
sensor = sensorSet(sensor, 'time interval', 0.001);
sensor = sensorSet(sensor, 'integration time', 2);
sensor = sensorSet(sensor, 'positions', zeros(2000, 2));

%% Generate an eye movement sequence
s.n = 5;
s.mu = 200;
s.sigma = 50;

% Find bounds from image
d = size(oi.data.photons);
b = [-round(d(1)/2) round(d(1)/2) -round(d(2)/2) round(d(2)/2)];

thePath = getEMPaths(sensor, 1, 'saccades', s, 'bound', b);
sensor = sensorSet(sensor, 'positions', thePath);

%% Calculate absorptions
sensor = coneAbsorptions(sensor, oi);

%% Calculate OS signals and visualize
osB = osBioPhys();
osB = osSet(osB, 'noiseFlag', 1);
osB = osCompute(osB, sensor);

osBwindow = osWindow(1, 'biophys-based outer segment', 'horizontalLayout', osB, sensor, oi, scene);

osL = osLinear();
osL = osSet(osL, 'noiseFlag', 1);
osL = osCompute(osL, sensor);

osLwindow = osWindow(2, 'linear outer segment', 'horizontalLayout', osL, sensor, oi, scene);
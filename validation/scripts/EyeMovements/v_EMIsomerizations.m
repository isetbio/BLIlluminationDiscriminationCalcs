function varargout = v_EMIsomerizations(varargin)
%
% Validate that the photoisomerizations for a static sensor is the same as a sensor with EM when the integration time is equivalent.
%
% 12/30/15  dhb  Tune this up a bit.

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

%% Close figures and fix random number generator
close all;
rng(1);

%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Set tolerance


%% Generate a default sensor
sensor = getDefaultBLIllumDiscrSensor;

%% Load optical image data
data = load('TestImage0OpticalImage');
oi = data.opticalimage;

%% Create eye movement object.
% We will sample nFrames of eye movement using the default settings in ISETBIO.
nFrames = 20;
em = emCreate;
em = emSet(em, 'sample time', sensorGet(sensor, 'exp time') / nFrames);

% Put eye movement object into sensor
sensorEM = sensorSet(sensor,'eyemove',em);
sensorEM = sensorSet(sensorEM,'positions',zeros(nFrames,2));
sensorEM = sensorSet(sensorEM, 'exp time', sensorGet(sensor, 'exp time') / 20);

% Generate sensor positions, and then force them to be all zero movement.
sensorEM = emGenSequence(sensorEM);
positions = sensorGet(sensorEM,'sensor positions');
positions = zeros(size(positions));
sensorEM0 = sensorSet(sensorEM,'sensor positions',positions);

%% Calculate the absorptions
sensor = coneAbsorptions(sensor, oi);
sensorEM0 = coneAbsorptions(sensorEM0, oi);
sensorEM = coneAbsorptions(sensorEM, oi);

%% Compare the total cone absorptions 
% They should be very very close when we don't move the eyes, and pretty close
% for fixational eye movements.
tolerance = 1;
photons = sensorGet(sensor, 'photons');
photonsEM0 = sensorGet(sensorEM0, 'photons');
photonsEM0 = sum(photonsEM0, 3);
photonsEM = sensorGet(sensorEM, 'photons');
photonsEM = sum(photonsEM, 3);

% Plot, left should lie along diagnonal, right should be close
if (runTimeParams.generatePlots)
    figure; clf;
    subplot(1,2,1); hold on
    plot(photons(:),photonsEM0(:),'ro','MarkerFaceColor','r','MarkerSize',6);
    plot([0 3500],[0 3500],'k');
    xlabel('Photons w/o Eye Movements');
    ylabel('Photons with Stationary Eye Movements');
    subplot(1,2,2); hold on
    plot(photons(:),photonsEM(:),'go','MarkerFaceColor','g','MarkerSize',6);
    plot([0 3500],[0 3500],'k');
    xlabel('Photons w/o Eye Movements');
    ylabel('Photons with Fixational Eye Movements');
    drawnow;
end

% Assertions of closeness
UnitTest.assertIsZero(norm(photons(:) - photonsEM0(:)) / numel(photons), 'Distance from static to EM0', 0.001);
UnitTest.assertIsZero(norm(photons(:) - photonsEM(:)) / numel(photons), 'Distance from static to EM', tolerance);

%% Tuck away validation data
UnitTest.validationData('static',photons);
UnitTest.validationData('EM0',photonsEM0);
UnitTest.validationData('EM',photonsEM);
end
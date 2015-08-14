function varargout = v_EMIsomerizations(varargin)
%
% Validate that the photoisomerizations for a static sensor is the same as a sensor with EM when the integration time is equivalent.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
close all;
rng(1);

%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation scipt
tolerance = 1;

% Generate a default sensor that will be used in many of the validation
% scripts.
sensor = getDefaultBLIllumDiscrSensor;

% Load optical image data
data = load('TestImage0OpticalImage');
oi = data.opticalimage;

% Create eye movement object.  We will sample 20 frames of eye movement
% using the default settings in ISETBIO.
em = emCreate;
em = emSet(em, 'sample time', sensorGet(sensor, 'exp time') / 20);

sensorEM = sensorSet(sensor,'eyemove',em);
sensorEM = sensorSet(sensorEM,'positions',zeros(20, 2));
sensorEM = sensorSet(sensorEM, 'exp time', sensorGet(sensor, 'exp time') / 20);
sensorEM = emGenSequence(sensorEM);

% Calculate the absorptions in both the the static sensor and the eye
% movement sensor.
sensor = coneAbsorptions(sensor, oi);
sensorEM = coneAbsorptions(sensorEM, oi);

% We want to compare the total cone absorptions to make sure that they are
% roughly the same.  In this case, we specify it to be within an average
% distance of 1 (tolerance) absorption per cone.
photons = sensorGet(sensor, 'photons');
photonsEM = sensorGet(sensorEM, 'photons');
photonsEM = sum(photonsEM, 3);

UnitTest.assertIsZero(norm(photons(:) - photonsEM(:)) / numel(photons), 'Distance from static to EM', tolerance);
UnitTest.validationData('static',photonsEM);
UnitTest.validationData('EM',photons);
end
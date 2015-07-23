function varargout = v_EMIsomerizations(varargin)
%
% Validate that the photoisomerizations for a static sensor is the same as a sensor with EM when the integration time is equivalent.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation scipt
rng(1);

tolerance = 1;

sensor = getDefaultBLIllumDiscrSensor;

oi = loadOpticalImageData('Neutral/Standard', 'TestImage0');

% Create eye movement object
em = emCreate;
em = emSet(em, 'sample time', sensorGet(sensor, 'exp time') / 20);

sensorEM = sensorSet(sensor,'eyemove',em);
sensorEM = sensorSet(sensorEM,'positions',zeros(20, 2));
sensorEM = sensorSet(sensorEM, 'exp time', sensorGet(sensor, 'exp time') / 20);
sensorEM = emGenSequence(sensorEM);

sensor = coneAbsorptions(sensor, oi);
sensorEM = coneAbsorptions(sensorEM, oi);

photons = sensorGet(sensor, 'photons');
photonsEM = sensorGet(sensorEM, 'photons');
photonsEM = sum(photonsEM, 3);

UnitTest.assertIsZero(norm(photons(:) - photonsEM(:)) / numel(photons), 'Distance from static to EM', tolerance);
UnitTest.validationData('static',photonsEM);
UnitTest.validationData('EM',photons);
end
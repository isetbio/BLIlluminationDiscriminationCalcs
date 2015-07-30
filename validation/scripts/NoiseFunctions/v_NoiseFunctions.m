function varargout = v_NoiseFunctions(varargin)
%
%  Validate that the poisson noise generated by noiseShot, matlab poissrnd, and the normal approximation is roughly equal.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
close all;

%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation
rng(1);

tolerance = 200;
sensor = getDefaultBLIllumDiscrSensor;

oi = loadOpticalImageData('Neutral/Standard', 'TestImage0');
sensor = coneAbsorptions(sensor, oi);

photons = sensorGet(sensor, 'photons');

[~, noiseShotRes] = noiseShot(sensor);
noiseShotRes = photons + noiseShotRes;
poissrndRes = poissrnd(photons);
approx = normrnd(photons, sqrt(photons));

UnitTest.validationRecord('SIMPLE_MESSAGE', '***** Noise Functions *****');   

A = norm(noiseShotRes(:) - poissrndRes(:));
B = norm(noiseShotRes(:) - approx(:));
C = norm(poissrndRes(:) - approx(:));

UnitTest.assertIsZero(A - B, 'DIFFERENCE from noiseShot to poissrnd', tolerance);
UnitTest.assertIsZero(B - C, 'DIFFERENCE from noiseShot to approx', tolerance);
UnitTest.assertIsZero(C - A, 'DIFFERENCE from poissrnd to approx', tolerance);

end
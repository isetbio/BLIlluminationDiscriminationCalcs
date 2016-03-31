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
pathDir = fullfile(myDir,'Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation
rng(1);
tolerance = 200;

% Generate a default sensor that will be used in many of the validation
% scripts.
sensor = getDefaultBLIllumDiscrSensor;

% Load optical image data
data = load('TestImage0OpticalImage');
oi = data.opticalimage;

% Calculate the cone absorptions to get the mean photons absorbed
sensor = coneAbsorptions(sensor, oi);
photons = sensorGet(sensor, 'photons');

% Apply the three different noise functions.
%   noiseShot is found in ISETBIO and uses iePoisson, the Poisson generator found in ISETBIO.
%   poissrnd is the Poisson generator that comes in MATLAB's Statistics Toolbox. 
%   approx is a Gaussian approximation to the Poisson.
[~, noiseShotRes] = noiseShot(sensor);
noiseShotRes = photons + noiseShotRes;
poissrndRes = poissrnd(photons);
approx = normrnd(photons, sqrt(photons));

UnitTest.validationRecord('SIMPLE_MESSAGE', '***** Noise Functions *****');   

% Calculate the Euclidian distance between the results of the different
% types of noise.  We want to validate that this values are within a
% certain range, specified by the tolerance, of each other.
A = norm(noiseShotRes(:) - poissrndRes(:));
B = norm(noiseShotRes(:) - approx(:));
C = norm(poissrndRes(:) - approx(:));

UnitTest.validationData('noiseShot', noiseShotRes);
UnitTest.validationData('poissrnd', poissrndRes);
UnitTest.validationData('approx', approx);

UnitTest.assertIsZero(A - B, 'DIFFERENCE from noiseShot to poissrnd', tolerance);
UnitTest.assertIsZero(B - C, 'DIFFERENCE from noiseShot to approx', tolerance);
UnitTest.assertIsZero(C - A, 'DIFFERENCE from poissrnd to approx', tolerance);

end
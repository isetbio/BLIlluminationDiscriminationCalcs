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
rng('default');
tolerance = 200;

% Generate a default sensor that will be used in many of the validation
% scripts.
mosaic = load(fullfile(fileparts('fullpath'),'coneMosaic1.1degs.mat'));
mosaic = mosaic.coneMosaic;
mosaic.noiseFlag = 'none';

% Load optical image data
data = load(fullfile(fileparts('fullpath'),'ValidationOI'));
oi = data.oi;

dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
if ~exist(fullfile(dataDir,'ValidationData','ValidationOptics.mat'),'file')
    error('ValidationOptics.mat not found! This file is needed for this validation to run!');
end
optics = load(fullfile(dataDir,'ValidationData','ValidationOptics.mat'));
oi.optics = optics.optics;

% Calculate the cone isomerizations to get the mean photons absorbed
isomerizations = mosaic.compute(oi,'currentFlag',false);


% Apply the three different noise functions.
%   iePoisson is found in ISETBIO.
%   poissrnd is the Poisson generator that comes in MATLAB's Statistics Toolbox. 
%   approx is a Gaussian approximation to the Poisson.
iePoissonRes = iePoisson(isomerizations);
poissrndRes = poissrnd(isomerizations);
approx = normrnd(isomerizations, sqrt(isomerizations));

UnitTest.validationRecord('SIMPLE_MESSAGE', '***** Noise Functions *****');   

% Calculate the Euclidian distance between the results of the different
% types of noise.  We want to validate that this values are within a
% certain range, specified by the tolerance, of each other.
A = norm(iePoissonRes(:) - poissrndRes(:));
B = norm(iePoissonRes(:) - approx(:));
C = norm(poissrndRes(:) - approx(:));

UnitTest.validationData('iePoisson', iePoissonRes, ...
    'UsingTheFollowingVariableTolerancePairs', ...
     'iePoisson',5e-7);
UnitTest.validationData('poissrnd', poissrndRes, ...
    'UsingTheFollowingVariableTolerancePairs', ...
     'poissrnd',5e-7);
UnitTest.validationData('approx', approx, ...
    'UsingTheFollowingVariableTolerancePairs', ...
     'approx',5e-7);

UnitTest.assertIsZero(abs(A - B), 'DIFFERENCE from iePoisson to poissrnd', tolerance);
UnitTest.assertIsZero(abs(B - C), 'DIFFERENCE from isPoisson to approx', tolerance);
UnitTest.assertIsZero(abs(C - A), 'DIFFERENCE from poissrnd to approx', tolerance);

end
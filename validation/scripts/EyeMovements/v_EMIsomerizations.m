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

%% Generate a default sensor
mosaic = load(fullfile(fileparts('fullpath'),'coneMosaic1.1degs.mat'));
mosaic = mosaic.coneMosaic;
mosaic.noiseFlag = 'none';

%% Load optical image data
data = load(fullfile(fileparts('fullpath'),'ValidationOI'));
oi = data.oi;

dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
if ~exist(fullfile(dataDir,'ValidationData','ValidationOptics.mat'),'file')
    error('ValidationOptics.mat not found! This file is needed for this validation to run!');
end
optics = load(fullfile(dataDir,'ValidationData','ValidationOptics.mat'));
oi.optics = optics.optics;

%% Create eye movement object.
% We will sample nFrames of eye movement using the default settings in ISETBIO.
nFrames = 20;

mosaicEM  = mosaic.copy;
mosaicEM0 = mosaic.copy;

mosaicEM.integrationTime  = mosaic.integrationTime / nFrames;
mosaicEM0.integrationTime = mosaic.integrationTime / nFrames;

mosaicEM.emGenSequence(nFrames);

% Generate sensor positions, and then force them to be all zero movement.
% sensorEM = emGenSequence(sensorEM);
positions = mosaicEM.emPositions;
positions = zeros(size(positions));
mosaicEM0.emPositions = positions;

%% Calculate the absorptions
% sensor = coneAbsorptions(sensor, oi);
% sensorEM0 = coneAbsorptions(sensorEM0, oi);
% sensorEM = coneAbsorptions(sensorEM, oi);

photons = mosaic.compute(oi,'currentFlag',false);
photonsEM0 = mosaicEM0.compute(oi,'currentFlag',false);
photonsEM = mosaicEM.compute(oi,'currentFlag',false);

%% Compare the total cone absorptions 
% They should be very very close when we don't move the eyes, and pretty close
% for fixational eye movements.
tolerance = 1e-2;
photonsEM0 = sum(squeeze(photonsEM0), 3);
photonsEM = sum(squeeze(photonsEM), 3);

% Plot, left should lie along diagnonal, right should be close
if (runTimeParams.generatePlots)
    figure; clf;
    subplot(1,2,1); hold on
    plot(photons(:),photonsEM0(:),'ro','MarkerFaceColor','r','MarkerSize',6);
    plot([0 1000],[0 1000],'k');
    xlabel('Photons w/o Eye Movements');
    ylabel('Photons with Stationary Eye Movements');
    subplot(1,2,2); hold on
    plot(photons(:),photonsEM(:),'go','MarkerFaceColor','g','MarkerSize',6);
    plot([0 1000],[0 1000],'k');
    xlabel('Photons w/o Eye Movements');
    ylabel('Photons with Fixational Eye Movements');
    drawnow;
end

% Assertions of closeness
UnitTest.assertIsZero(norm(photons(:) - photonsEM0(:)) / numel(photons), 'Distance from static to EM0', 1e-8);
UnitTest.assertIsZero(norm(photons(:) - photonsEM(:)) / numel(photons), 'Distance from static to EM', tolerance);

%% Tuck away validation data
UnitTest.validationData('static',photons, ....
    'UsingTheFollowingVariableTolerancePairs', ...
     'static',5e-10);
UnitTest.validationData('EM0',photonsEM0, ....
    'UsingTheFollowingVariableTolerancePairs', ...
     'EM0',5e-10);
UnitTest.validationData('EM',photonsEM, ....
    'UsingTheFollowingVariableTolerancePairs', ...
    'EM',5e-10);
end
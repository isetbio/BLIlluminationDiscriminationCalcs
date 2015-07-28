function createCalcParams
% createCalcParams
%
% This function creates a calcParam file and saves it to the CalcParamQueue
% folder on ColorShare.  From there, the queue can be processed by the
% function runAllCalcFromQueue.  For consistancy across all functions
% associated with this project, please update the functions
% updateCacheFolderList and updateCropRect whenever a new calcIDStr is used.
%
% 6/4/15  xd  wrote it

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Create a calcParam object

% Define the steps of the calculation that should be carried out.
calcParams.CACHE_SCENES = false;
calcParams.forceSceneCompute = true; % Will overwrite any existing data.

calcParams.CACHE_OIS = false; 
calcParams.forceOICompute = true;    % Will overwrite any existing data.

calcParams.RUN_MODEL = false;
calcParams.MODEL_ORDER = 1;          % Which model to run
calcParams.chooserColorChoice = 0;   % Which color direction to use (0 means all)
calcParams.overWriteFlag = 1;        % Whether or not to overwrite existing data.

calcParams.CALC_THRESH = false; 
calcParams.displayIndividualThreshold = true;

% Set the name of this calculation set
calcParams.calcIDStr = 'StaticPhoton';

% Folder list to run over for conversions into isetbio format
calcParams = updateCacheFolderList(calcParams);

% Specify how to crop the image.  We don't want it all.
% Code further on makes the most sense if the image is square (because we
% define a square patch of cone mosaic when we build the sensor), so the
% cropped region should always be square.
calcParams = updateCropRect(calcParams);              % [450 350 624 574] is the entire non-black region of our initial images with small border
calcParams.S = [380 8 51];                            % [489 393 535 480] will get image without any black border

% Parameters for creating the sensor
calcParams.coneIntegrationTime = 0.050;
calcParams.sensorFOV = 0.83;             % Visual angle defining the size of the sensor

% Specify the number of trials for each combination of Kp Kg as well as
% the highest illumination step (max 50) to go up to.
calcParams.numTrials = 100;
calcParams.maxIllumTarget = 50;

% Kp represents the scale factor for the Poisson noise.  This is the
% realistic noise representation of the photons arriving at the retina.
% Therefore, startKp should always be kept at 1.
calcParams.numKpSamples = 10;
calcParams.KpInterval = 1;
calcParams.startKp = 1;

% Kg is the scale factor for an optional Gaussian noise.  The standard
% deviation of the Gaussian distribution is equal to the square root of
% the mean photoisomerizations across the available target image
% samples.
calcParams.numKgSamples = 1;
calcParams.startKg = 0;
calcParams.KgInterval = 1;

% Specify the number of standard image samples available as well as the
% number of test image samples available.  The chooser will randomly
% choose two images out of the target set and one image out of the
% comparison set.  This is in order to reduce the effect of pixel noise
% cause by the image renderer.

calcParams.targetImageSetSize = 7;
calcParams.comparisonImageSetSize = 1;

% Specify eye movement parameters
calcParams.enableEM = false;

% EMPositions represents the number of positions of eye movement to sample
calcParams.numEMPositions = 5;
calcParams.EMPositions = zeros(calcParams.numEMPositions, 2);
calcParams.EMSampleTime = 0.001;                    % Setting sample time to 1 ms
calcParams.enableTremor = true;
calcParams.enableDrift = true;
calcParams.enableMSaccades = true;

% Whether or not to recreate a new eye movement path for the target and two comparisons 
calcParams.useSameEMPath = false;

% Define some eye movement parameters related to large saccades
calcParams.numSaccades = 5;
calcParams.saccadeInterval = 0.200;

% Specify cone adaptation parameters
% The Isetbio code for cone adaptation is currently under reconstruction
calcParams.osType = 1;  % 1 for linear, 2 for biophysical

% Define parameters for outer segment noise
calcParams.numKosSamples = 10;
calcParams.startKos = 1;
calcParams.KosInterval = 1;

%% Save the parameter in the queue directory
savePath = fullfile(BaseDir, ['calcParams' calcParams.calcIDStr]);
save(savePath, 'calcParams');
end


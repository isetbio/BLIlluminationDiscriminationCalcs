function createCalcParams
% createCalcParams
%
% This function creates a calcParam file and saves it to the CalcParamQueue
% folder on ColorShare.  From there, the queue can be processed by the
% function runAllCalcFromQueue.  For consistancy across all functions
% associated with this project, please update the function
% updateCacheFolderList whenever a new calcIDStr is used.
%
% 6/4/15  xd  wrote it

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Create a calcParam object

% Set the name of this calculation set
calcParams.calcIDStr = 'StaticPhoton_AfterMerge';

% Folder list to run over for conversions into isetbio format
calcParams = updateCacheFolderList(calcParams);

% Specify how to crop the image.  We don't want it all.
% Code further on makes the most sense if the image is square (because we
% define a square patch of cone mosaic when we build the sensor), so the
% cropped region should always be square.
calcParams.cropRect = [550 450 40 40];              % [450 350 624 574] is the entire non-black region of our initial images

% Specify the parameters for the chooser calculation
calcParams.coneIntegrationTime = 0.050;
calcParams.S = [380 8 51];
calcParams.sensorFOV = 0.83; 

calcParams.numTrials = 100;
calcParams.maxIllumTarget = 50;
calcParams.numKValueSamples = 10;
calcParams.kInterval = 1;
calcParams.startK = 1;

% Specify eye movement parameters
% EMPositions represents the number of positions of eye movement to sample,
% in this case it is 100
calcParams.enableEM = false;
calcParams.numEMPositions = 5;
calcParams.EMPositions = zeros(calcParams.numEMPositions, 2);
calcParams.EMSampleTime = 0.010;                    % Setting sample time to 1 ms
calcParams.tremorAmpFactor = 0;                     % This factor determines amplitude of tremors

% Specify cone adaptation parameters
% The Isetbio code for cone adaptation is currently under reconstruction
calcParams.coneAdaptEnable = false;
calcParams.coneAdaptType = 4;

%% Save the parameter in the queue directory
savePath = fullfile(BaseDir, ['calcParams' calcParams.calcIDStr]);
save(savePath, 'calcParams');
end


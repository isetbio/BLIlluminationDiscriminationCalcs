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

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Create a calcParam object

% Set the name of this calculation set
calcParams.calcIDStr = 'StaticPhoton_KxMean5';

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
    calcParams.numTrials = 500;
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
    % EMPositions represents the number of positions of eye movement to sample,
    % in this case it is 100
    calcParams.enableEM = false;
    calcParams.numEMPositions = 5;
    calcParams.EMPositions = zeros(calcParams.numEMPositions, 2);
    calcParams.EMSampleTime = 0.001;                    % Setting sample time to 1 ms
    calcParams.tremorAmpFactor = 1;                     % This factor determines amplitude of tremors
    
    % Specify cone adaptation parameters
    % The Isetbio code for cone adaptation is currently under reconstruction
    calcParams.coneAdaptEnable = false;
    calcParams.coneAdaptType = 4;

%% Save the parameter in the queue directory
savePath = fullfile(BaseDir, ['calcParams' calcParams.calcIDStr]);
save(savePath, 'calcParams');
end


function runAllCalculations
% runAllCalculations
%
% Run the full set of calculations in the BLIlluminationDiscrimination
% project, for one set of parameters.
%
% Typically, we will only execute pieces of this at any given time, because
% certain parts are cached and need not be redone each time through.  But,
% this documents for us the flow of the whole calculation, and also lets us
% gather all of the parameters together in one place.
%
% 4/29/15  dhb, xd           Wrote it.
% 5/31/15  dhb               Tuning for multiple calculations

%% Clear and initialize
close all; ieInit;

%% Control of what gets done in this function
CACHE_SCENES = false; forceSceneCompute = true;
CACHE_OIS = false; forceOICompute = true;
RUN_CHOOSER = false; chooserColorChoice = 0; overWriteFlag = 1;
CALC_THRESH = true; displayIndividualThreshold = false;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

% Set identifiers to run
calcIDStrs = {'StaticPhoton' 'StaticPhoton_2' 'StaticPhoton_3' 'StaticPhoton_4'};

%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database.  We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.
%
% This part loops through the calculations for all caldIDStrs specified
for k1 = 1:length(calcIDStrs)
    calcParams.calcIDStr = calcIDStrs{k1};
    
    % Folder list to run over for conversions into isetbio format
    calcParams = updateCacheFolderList(calcParams);
    
    % Specify how to crop the image.  We don't want it all.
    % Code further on makes the most sense if the image is square (because we
    % define a square patch of cone mosaic when we build the sensor), so the
    % cropped region should always be square.
    calcParams = updateCropRect(calcParams);              % [450 350 624 574] is the entire non-black region of our initial images
    calcParams.S = [380 8 51];
        
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
    calcParams.tremorAmpFactor = 0;                     % This factor determines amplitude of tremors
    
    % Specify cone adaptation parameters
    % The Isetbio code for cone adaptation is currently under reconstruction
    calcParams.coneAdaptEnable = false;
    calcParams.coneAdaptType = 4;
    
    %% Convert the images to cached scenes for more analysis
    if (CACHE_SCENES)
        convertRBGImagesToSceneFiles(calcParams,forceSceneCompute);
    end
    
    %% Convert cached scenes to optical images
    if (CACHE_OIS)
        convertScenesToOpticalimages(calcParams, forceOICompute);
    end
    
    %% Create data sets using the simple chooser model
    if (RUN_CHOOSER)
        sensorImageSimpleChooserModel(calcParams, chooserColorChoice, overWriteFlag);
    end
    
    %% Calculate threshholds using chooser model data
    if (CALC_THRESH)
        thresholdCalculation(calcParams.calcIDStr, displayIndividualThreshold);
    end
end

end
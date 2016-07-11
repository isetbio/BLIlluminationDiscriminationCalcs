function runAllSecondOrderCalcs
% runAllSecondOrderCalcs
%
% Run the full set of calculations for the second order model in the
% BLIlluminationDiscrimination project, for one set of parameters.
%
% 7/27/15  xd  copied base code from runAllFirstOrderCalcs
% 7/29/15  xd  renamed

%% Clear and initialize
close all; ieInit;

%% Set identifiers to run
calcIDStrs = {'OS3StepConeAbsorb'};

%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database.  We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.

% This part loops through the calculations for all caldIDStrs specified
for k1 = 1:length(calcIDStrs)
    
    % Define the steps of the calculation that should be carried out.
    calcParams.CACHE_SCENES = false;
    calcParams.forceSceneCompute = false; % Will overwrite any existing data.
    
    calcParams.CACHE_OIS = false;
    calcParams.forceOICompute = false;    % Will overwrite any existing data.
    
    calcParams.RUN_MODEL = true;
    calcParams.MODEL_ORDER = 2;          % Which model to run
    calcParams.chooserColorChoice = 0;   % Which color direction to use (0 means all)
    calcParams.overWriteFlag = true;    % Whether or not to overwrite existing data. An overwrite is required to run the same calculation name again.
    
    calcParams.CALC_THRESH = false;
    calcParams.displayIndividualThreshold = false;
    
    % Set the name of this calculation set
    calcParams.calcIDStr = calcIDStrs{k1};
    
    % Folder list to run over for conversions into isetbio format
    calcParams = updateCacheFolderList(calcParams);
    
    % Specify how to crop the image.  We don't want it all.
    % Code further on makes the most sense if the image is square (because we
    % define a square patch of cone mosaic when we build the sensor), so the
    % cropped region should always be square.
    calcParams = updateCropRect(calcParams);              % [450 350 624 574] is the entire non-black region of our initial images with small border
    calcParams.S = [380 8 51];                            % [489 393 535 480] will get image without any black border
    
    % Parameters for creating the sensor
    calcParams.coneIntegrationTime = 0.001;
    calcParams.sensorFOV = 0.07;             % Visual angle defining the size of the sensor
    calcParams.OIvSensorScale = 0;
    
    % Specify the number of trials for each combination of Kp Kg as well as
    % the highest illumination step (max 50) to go up to.
    calcParams.trainingSetSize = 200;
    calcParams.testingSetSize = 200;
    calcParams.illumLevels = 1:50;

    calcParams.standardizeData = false;
    calcParams.cFunction = 4;
    
    % Keep this as 4 since that is the only function that supports eye
    % movements and the outer segment.
    calcParams.dFunction = 4;
    
    % Kp represents the scale factor for the Poisson noise.  This is the
    % realistic noise representation of the photons arriving at the retina.
    % Therefore, startKp should always be kept at 1.
    calcParams.KpLevels = 1;
    
    % Kg is the scale factor for an optional Gaussian noise.  The standard
    % deviation of the Gaussian distribution is equal to the square root of
    % the mean photoisomerizations across the available target image
    % samples.
    calcParams.KgLevels = 1:10;
    
    % Define some eye movement parameters related to large saccades
    calcParams.numSaccades = 3;             % Set this to 1 for only fixational eye movements
    calcParams.saccadeInterval = 0.150;
    
    % EMPositions represents the number of positions of eye movement to sample.  
    calcParams.numEMPositions = 20;
    
    % Enable or disable certain aspects of fixational eye movement
    calcParams.enableTremor = true;
    calcParams.enableDrift = true;
    calcParams.enableMSaccades = true;
    
    % Whether or not to recreate a new eye movement path for the target and
    % two comparisons. We can also give the location to a matlab data file
    % that contains pre-generated paths for the model to use. If no path
    % file is desired, set the value to [].  A set of locations can also be
    % specified, in which the saccades will be randomly chosen from the
    % provided list.  If this is left empty, the saccades will be randomly
    % chosen from across the entire optical image.
    calcParams.useSameEMPath = true;
    calcParams.EMLoc = [];
    
    % Whether to use OS code
    calcParams.enableOS = true;
    calcParams.OSType = 'linear'; % Types of OS, options are 'linear' 'biophys' 'identity'
    calcParams.noiseFlag = false;
    
    %% Convert the images to cached scenes for more analysis
    if (calcParams.CACHE_SCENES)
        convertRBGImagesToSceneFiles(calcParams,calcParams.forceSceneCompute);
    end
    
    %% Convert cached scenes to optical images
    if (calcParams.CACHE_OIS)
        convertScenesToOpticalimages(calcParams,calcParams.forceOICompute);
    end
    
    %% Create data sets using the simple chooser model
    if (calcParams.RUN_MODEL)
        RunModel(calcParams,calcParams.overWriteFlag);
    end
    
    %% Calculate threshholds using chooser model data
    if (calcParams.CALC_THRESH)
        plotAllThresholds(calcParams.calcIDStr);
    end
end

end
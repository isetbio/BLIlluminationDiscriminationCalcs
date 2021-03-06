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
calcIDStrs = {'SVM_YesEM_LinearOS_TestTheory_500ms'};

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
    calcParams.MODEL_ORDER = 2;           % Which model to run
    calcParams.overWriteFlag = true;      % Whether or not to overwrite existing data. An overwrite is required to run the same calculation name again.
    
    calcParams.CALC_THRESH = false;
    
    % Set the name of this calculation set
    calcParams.calcIDStr = calcIDStrs{k1};
    
    % Folder list to run over for conversions into isetbio format
%     calcParams = updateCacheFolderList(calcParams);
    calcParams.cacheFolderList = {'Neutral' 'SVM_Static_Interp_End_60'};
    
    % Specify how to crop the image.  We don't want it all.
    % Code further on makes the most sense if the image is square (because we
    % define a square patch of cone mosaic when we build the sensor), so the
    % cropped region should always be square.
%     calcParams = updateCropRect(calcParams);   
    calcParams.cropRect = [];
    calcParams.S = [380 8 51];                            
    calcParams.spatialDensity = [0 0.62 0.31 0.07];
    
    % Parameters for creating the sensor
    calcParams.coneIntegrationTime = 0.010;  % Integration time in ms. Also determines eye movement and os sampling interval
    calcParams.sensorFOV = 0.83;             % Visual angle defining the size of the sensor
    calcParams.OIvSensorScale = 0;
    
    % Specify the number of trials for each combination of Kp Kg as well as
    % the highest illumination step (max 50) to go up to. 
    calcParams.trainingSetSize = 1000;
    calcParams.testingSetSize = 1000;
    calcParams.illumLevels = 1:2:50;

    calcParams.standardizeData = true;
    calcParams.usePCA = true;
    calcParams.numPCA = 100;
    calcParams.cFunction = 3;
    
    % Keep this as 4 since that is the only function that supports eye
    % movements and the outer segment.
    calcParams.dFunction = 4;
    
    % Kp represents the scale factor for the Poisson noise.  This is the
    % realistic noise representation of the photons arriving at the retina.
    % Therefore, startKp should always be kept at 1. If os is enabled this
    % does nothing (but keep it a scalar).
    calcParams.KpLevels = 1;
    
    % Kg is the scale factor for an optional Gaussian noise.  The standard
    % deviation of the Gaussian distribution is equal to the square root of
    % the mean photoisomerizations across the available target image
    % samples. If os is enabled, this multiplies the outer segment noise
    % instead.
    calcParams.KgLevels = 1;
    
    % EMPositions represents the number of positions of eye movement to sample.  
    calcParams.numEMPositions = 50;
    
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
    
    % Whether to use OS code
    calcParams.enableOS = true;
    calcParams.OSType = 'linear'; % Types of OS, options are 'linear' 'biophys' 'identity'
    
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
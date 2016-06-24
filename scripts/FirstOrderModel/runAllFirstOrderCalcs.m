function runAllFirstOrderCalcs
% runAllFirstOrderCalcs
%
% Run the full set of calculations for the first order model in the
% BLIlluminationDiscrimination project, for one set of parameters.  The
% calcParam fields detailed in this function are only the ones relevant to
% the first order model.  To see all the fields, refer to the
% createCalcParams function in the toolbox.
%
% Typically, we will only execute pieces of this at any given time, because
% certain parts are cached and need not be redone each time through.  But,
% this documents for us the flow of the whole calculation, and also lets us
% gather all of the parameters together in one place.
%
% 4/29/15  dhb, xd           Wrote it.
% 5/31/15  dhb               Tuning for multiple calculations
% 7/29/15  xd                Renamed.

%% Clear and initialize
close all; ieInit;

%% Set identifiers to run
calcIDStrs  = {'StaticPhoton'};
    
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
    calcParams.MODEL_ORDER = 1; 
    calcParams.overWriteFlag = true;        % Whether or not to overwrite existing data.
    
    calcParams.CALC_THRESH = true;
    calcParams.displayIndividualThreshold = false;
    
    % Set the calcID
    calcParams.calcIDStr = calcIDStrs{k1};
    
    % Folder list to run over for conversions into isetbio format
    calcParams = updateCacheFolderList(calcParams);
    
    % Need to specify the calibration file to use
    calcParams = assignCalibrationFile(calcParams);
    
    % Specify how to crop the image.  We don't want it all.
    % Code further on makes the most sense if the image is square (because we
    % define a square patch of cone mosaic when we build the sensor), so the
    % cropped region should always be square.
    calcParams = updateCropRect(calcParams);              
    calcParams.S = [380 8 51];
        
    % Parameters for creating the sensor. OIvSensorScale is a parameter
    % that, if set to a value > 0, will subsample the optical image to the
    % size sensorFOV*OIvSensorScale.
    calcParams.coneIntegrationTime = 0.050;
    calcParams.sensorFOV = 0.83;             
    calcParams.OIvSensorScale = 0;
    
    % Specify the number of trials for each combination of Kp Kg as well as
    % the range of illuminants to use (max 50).
    calcParams.trainingSetSize = 200;
    calcParams.testingSetSize = 200;
    calcParams.illumLevels = 1:50;
    
    % Here we specify which data function and classification function to
    % use. 
    calcParams.standardizeData = false;
    calcParams.cFunction = 4;
    calcParams.dFunction = 3;
    
    % Kp represents the scale factor for the Poisson noise.  This is the
    % realistic noise representation of the photons arriving at the retina.
    % Therefore, there should always be at least 1x Kp.
    calcParams.KpLevels = 1:10;
    
    % Kg is the scale factor for Gaussian noise.  The standard deviation of 
    % the Gaussian noise is equal to the square root of the mean 
    % photoisomerizations across the available target image samples.
    calcParams.KgLevels = 1;
    
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
%         thresholdCalculation(calcParams.calcIDStr,calcParams.displayIndividualThreshold);
        plotAllThresholds(calcParams.calcIDStr,'NoiseIndex',[0 1]);
    end
end

end
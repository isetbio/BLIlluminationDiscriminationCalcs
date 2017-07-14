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
% 4/29/15  dhb, xd           Wrote it
% 5/31/15  dhb               Tuning for multiple calculations
% 7/29/15  xd                Renamed
% 7/6/17   xd                Reorganized for clarity

%% Clear and initialize
close all; ieInit;

%% Set identifiers to run
calcIDStrs = {'NM1_FullImage' 'NM2_FullImage'};

%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database. We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.

% This part loops through the calculations for all caldIDStrs specified
for k1 = 1:length(calcIDStrs)
    
    % Define the steps of the calculation that should be carried out
    calcParams.CACHE_SCENES = true;
    calcParams.forceSceneCompute = true;  % Will overwrite any existing data
    
    calcParams.CACHE_OIS = false;
    calcParams.forceOICompute = false;     % Will overwrite any existing data
    
    calcParams.RUN_MODEL = false;
    calcParams.MODEL_ORDER = 1;            % Corresponds to model function number
    calcParams.overWriteFlag = false;      % Whether or not to overwrite existing data
    
    calcParams.CALC_THRESH = false;        % Immediately calculate thresholds after finishing
    
    % Set the calcIDStr so functions that fill in some of the struct fields
    % know what to do. This will be changed when the files are actually
    % saved.
    calcParams.calcIDStr = calcIDStrs{k1};
    
    % Folder list to run over for conversions into ISETBIO format.
    % Alternatively, manually set this value by uncommenting the second
    % line.
    calcParams = updateCacheFolderList(calcParams);
%     calcParams.cacheFolderList = {'Neutral', 'Neutral'};
    
    % Need to specify the display calibration file to use.
    calcParams = assignCalibrationFile(calcParams);
    
    % Specify how to crop the image.  This is used to convert the RGB image
    % to an ISETBIO scene. We don't want it all as there may be some black
    % space. 
    calcParams = updateCropRect(calcParams);  
    
    % Parameters for creating the sensor. OIvSensorScale is a parameter
    % that, if set to a value > 0, will subsample the optical image to the
    % size sensorFOV*OIvSensorScale.
    calcParams.OIvSensorScale = 0;
    
    % Kp represents the scale factor for the Poisson noise.  This is the
    % realistic noise representation of the photons arriving at the retina.
    % Therefore, there should always be at least 1x Kp.
    calcParams.KpLevels = 1;
    
    % Kg is the scale factor for Gaussian noise.  The standard deviation of 
    % the Gaussian noise is equal to the square root of the mean 
    % photoisomerizations across the available target image samples. 
    calcParams.KgLevels = 0:5:50;
    
    calcParams.S = [380 8 51];                              % S vector representation of the wavelength to use for the calculation
    calcParams.spatialDensity = [0 0.62 0.31 0.07];         % Distribution of cones [null L M S]
    calcParams.coneIntegrationTime = 0.050;                 % Amount of time to simulate in seconds
    calcParams.sensorFOV = 1;                               % Size of cone mosaic in degrees
    calcParams.trainingSetSize = 1000;                      % Number of response vectors in training set
    calcParams.testingSetSize = 1000;                       % Number of response vectors in test set
    calcParams.illumLevels = 1:50;                          % Illumination step sizes to cover in calculation
    calcParams.standardizeData = true;                      % Whether to standardize data before classification
    calcParams.cFunction = 3;                               % Calculation function number
    calcParams.dFunction = 1;                               % Dataset generation function number
    calcParams.usePCA = true;                               % Whether to perform PCA before classification
    calcParams.numPCA = 400;                                % Number of PCA components to project vectors onto
    
    % Update to calcIDStr to a uniformly formatted name
    calcParams.calcIDStr = params2Name_FirstOrderModel(calcParams);
    
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
        plotAllThresholds(calcParams.calcIDStr,'NoiseIndex',[0 1]);
    end
end

end
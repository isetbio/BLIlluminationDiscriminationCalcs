% function runAllFirstOrderCalcsHexMosaic(numCores,oiFolder,sceneFolder,spatialDensity)
%%
% clear global
% tbUseProject('BLIlluminationDiscriminationCalcs','runLocalHooks',false);
numCores = 8;
oiFolder = 'Constant_CorrectSize';
sceneFolder = 'Constant_CorrectSize';
spatialDensity = [0 0.62 0.31 0.07];

%% Clear and initialize
% ieInit;
% parpool(numCores);

%% Load mosaic
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
mosaic = load(fullfile(dataDir,'MosaicData','coneMosaic1.1degs.mat'));
mosaic = mosaic.coneMosaic;
mosaic.noiseFlag = 'none';

%% Calculate how many patches there are
%
% We will just load in a whole scene and divide into patches as it would
% have been when the OI are created. This is because no information
% structure about how many patches are created exists in an easily
% accessible manner. The cacheFolderList is used slightly differently here
% than normal because the optical image folder names may differ from the
% scene folder names due to how they are generated.
calcIDStr       = sceneFolder;
cacheFolderList = {oiFolder,sceneFolder};
sensorFOV       = mosaic.fov(1);

fileNames         = getFilenamesInDirectory(fullfile(dataDir,'SceneData',cacheFolderList{2},'Standard'));
tempScene         = loadSceneData([cacheFolderList{2} '/Standard'],fileNames{1}(1:end-9));
tempOI            = loadOpticalImageData([cacheFolderList{1} '/Standard'],fileNames{1}(1:end-9));
[smallScenes,p]   = splitSceneIntoMultipleSmallerScenes(tempScene,sensorFOV);
numberofOI        = numel(smallScenes);
clear smallScenes;

% Get sizes of scene and OI
scenehFov = sceneGet(tempScene,'hfov');
scenevFov = sceneGet(tempScene,'vfov');
oihFov = oiGet(tempOI,'hfov');
oivFov = oiGet(tempOI,'vfov');
oiPadding = [oihFov - scenehFov, oivFov - scenevFov] / 2;
oiSize = oiGet(tempOI,'cols') / oihFov;

% This is so that you can skip certain OI if not needed or to speed up
% calculations for testing an idea/thought.
theIndex = 1;%18;
tic
%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database. We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.
for k1 = 1:length(theIndex)
    
    theIdx = theIndex(k1);
    
    calcParams.RUN_MODEL = true;
    calcParams.MODEL_ORDER = 3;           % Corresponds to model function number
    calcParams.overWriteFlag = false;     % Whether or not to overwrite existing data.
    
    % Calculate proper EM position
    calcParams.oiCR = convertPatchToOICropRect(theIdx,p,oiPadding,oiSize,sensorFOV);
    
    % Temp placeholder
    calcParams.calcIDStr = calcIDStr;
    
    % Edit the cache folder list to point to an actual OI
    calcParams.cacheFolderList = {sceneFolder oiFolder};
    
    % Check OI exists
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    oiPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2});
    
    if exist(oiPath,'dir')
        % Need to specify the display calibration file to use.
        calcParams = assignCalibrationFile(calcParams);
        
        % Specify how to crop the image. Not needed since scenes will not
        % be generated in this script.
        calcParams.cropRect = [];
        
        % Parameters for creating the sensor. OIvSensorScale is a parameter
        % that, if set to a value > 0, will subsample the optical image to
        % the size sensorFOV*OIvSensorScale.
        calcParams.OIvSensorScale = 0;
        
        % Kp represents the scale factor for the Poisson noise.  This is
        % the realistic noise representation of the photons arriving at the
        % retina. Therefore, there should always be at least 1x Kp.
        calcParams.KpLevels = 1;
        
        % Kg is the scale factor for Gaussian noise.  The standard
        % deviation of the Gaussian noise is equal to the square root of
        % the mean photoisomerizations across the available target image
        % samples.
        calcParams.KgLevels = 0:5:30;
        
        calcParams.S = [380 8 51];                              % S vector representation of the wavelength to use for the calculation
        calcParams.spatialDensity = spatialDensity;             % Distribution of cones [null L M S]
        calcParams.coneIntegrationTime = 0.050;                 % Amount of time to simulate in seconds
        calcParams.sensorFOV = sensorFOV;                               % Size of cone mosaic in degrees
        calcParams.trainingSetSize = 1000;                      % Number of response vectors in training set
        calcParams.testingSetSize = 1000;                       % Number of response vectors in test set
        calcParams.illumLevels = 1:50;                          % Illumination step sizes to cover in calculation
        calcParams.standardizeData = true;                      % Whether to standardize data before classification
        calcParams.cFunction = 3;                               % Calculation function number
        calcParams.dFunction = 1;                               % Dataset generation function number
        calcParams.usePCA = true;                               % Whether to perform PCA before classification
        calcParams.numPCA = 400;                                % Number of PCA components to project vectors onto
        calcParams.hexMosaic = mosaic;
        
        % Update to calcIDStr to a uniformly formatted name
        calcParams.cacheFolderList{2} = [calcParams.cacheFolderList{2} '_' num2str(theIdx) '_test2'];
        calcParams.calcIDStr = params2Name_FirstOrderModel(calcParams);
        disp(calcParams.calcIDStr);
        calcParams.cacheFolderList = {sceneFolder oiFolder};
        
        %% Create data sets using the simple chooser model
        if (calcParams.RUN_MODEL)
            RunModel(calcParams,calcParams.overWriteFlag);
        end
    end
end
fprintf('%0.2f min \n',toc/60);
% end
clear globalPref;

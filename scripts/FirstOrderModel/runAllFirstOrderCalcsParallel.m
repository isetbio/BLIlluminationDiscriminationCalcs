% function rv';%unAllFirstOrderCalcsParallel(numCores,oiFolder,sceneFolder,spatialDensity)
tbUseProject('BLIlluminationDiscriminationCalcs','runLocalHooks',false);
numCores = 5;
oiFolder = 'Constant';
sceneFolder = 'Constant_FullImage';
spatialDensity = [0 0.62 0.31 0.07];
% runAllFirstOrderCalcsParallel(numCores,oiFolder,sceneFolder,spatialDensity)
%
% This function is a modified version of runAllFirstOrderCalcs made for the
% purpose of utilizing Matlab parpool workers to speed up the calculations.
% Specifically, this function is built for the purpose of running the
% calculation over many small pataches corresponding areas within a large
% stimulus. See AllPaperCalculations for an example of usage of this
% function.
%
% As such, this function assumes that the scenes and appropriate optical
% images have already been created. This function assumes that the optical
% image folder names will be numbered (name1, name2, name3, etc.). 
% 
% Note that this function will only perform the model calculation and will
% not generate scenes/optical images nor extract/plot threhsolds. Like the
% runAllFirstOrderCalcs function, calculation parameters can be edited in
% this file directly.
%
% Inputs:
%    numCores        -  number of parallel workers to start up
%    oiFolder        -  common shared name of the folders that contain the
%                       optical images
%    sceneFolder     -  where the whole stimulus scene file is cached
%    spatialDensity  -  the distribution of the cone photoreceptors in a
%                       vector form [null L M S]
%
% 7/6/17    xd    Reorganized for clarity


%% Clear and initialize
%close all; ieInit; 
parpool(numCores);

%% Calculate how many patches there are
%
% We will just load in a whole scene and divide into patches as it would
% have been when the OI are created. This is because no information
% structure about how many patches are created exists in an easily
% accessible manner. The cacheFolderList is used slightly differently here
% than normal because the optical image folder names may differ from the
% scene folder names due to how they are generated.
c.calcIDStr       = sceneFolder;
c.cacheFolderList = {oiFolder,sceneFolder};
c.sensorFOV       = 1;
dataDir           = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
fileNames         = getFilenamesInDirectory(fullfile(dataDir,'SceneData',c.cacheFolderList{2},'Standard'));
tempScene         = loadSceneData([c.cacheFolderList{2} '/Standard'],fileNames{1}(1:end-9));
%numberofOI        = numel(splitSceneIntoMultipleSmallerScenes(tempScene,c.sensorFOV));

% This is so that you can skip certain OI if not needed or to speed up
% calculations for testing an idea/thought.
theIndex = 1:270;

%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database. We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.
parfor k1 = 1:length(theIndex)
    
    calcParams.RUN_MODEL = true;
    calcParams.MODEL_ORDER = 1;           % Corresponds to model function number
    calcParams.overWriteFlag = false;     % Whether or not to overwrite existing data.
    
    % Temp placeholder
    calcParams.calcIDStr = c.calcIDStr;
    
    % Edit the cache folder list to point to an actual OI
    calcParams.cacheFolderList = {c.cacheFolderList{1} [c.cacheFolderList{1} '_' num2str(theIndex(k1))]};
    
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
        calcParams.sensorFOV = 1;                               % Size of cone mosaic in degrees
        calcParams.trainingSetSize = 2000;                      % Number of response vectors in training set
        calcParams.testingSetSize = 2000;                       % Number of response vectors in test set
        calcParams.illumLevels = 1:50;                          % Illumination step sizes to cover in calculation
        calcParams.standardizeData = false;                      % Whether to standardize data before classification
        calcParams.cFunction = 4;                               % Calculation function number
        calcParams.dFunction = 3;                               % Dataset generation function number
        calcParams.usePCA = false;                              % Whether to perform PCA before classification
        calcParams.numPCA = 400;                                % Number of PCA components to project vectors onto
        
        % Update to calcIDStr to a uniformly formatted name
        calcParams.calcIDStr = params2Name_FirstOrderModel(calcParams);
        disp(calcParams.calcIDStr);
        
        %% Create data sets using the simple chooser model
        if (calcParams.RUN_MODEL)
            RunModel(calcParams,calcParams.overWriteFlag);
        end
    end
end

% end

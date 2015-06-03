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
%
% NOTE: Need to save calcParams

%% Clear and initialize
close all; ieInit;

%% Control of what gets done in this function
CACHE_SCENES = false; forceSceneCompute = false;
CACHE_OIS = false; forceOICompute = false;
RUN_CHOOSER = false; chooserColorChoice = 1;
CALC_THRESH = true; displayIndividualThreshold = false;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

% Set identifiers to run
calcIDStrs = {'StaticPhoton'};

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
    switch (calcParams.calcIDStr)
        case {'StaticPhoton', 'ThreeFrameEM','ConeIntegrationTime_Tests', ...
                'StaticPhoton_MatlabRNG'}
            calcParams.cacheFolderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
                'RedIllumination', 'YellowIllumination'};
        case {'StaticPhoton_NM1','StaticPhoton_NM1_MatlabRNG'}
            calcParams.cacheFolderList = {'Standard_NM1', 'BlueIllumination_NM1', 'GreenIllumination_NM1', ...
                'RedIllumination_NM1', 'YellowIllumination_NM1'};
        case {'StaticPhoton_NM2','StaticPhoton_NM2_MatlabRNG'}
            calcParams.cacheFolderList = {'Standard_NM2', 'BlueIllumination_NM2', 'GreenIllumination_NM2', ...
                'RedIllumination_NM2', 'YellowIllumination_NM2'};
        otherwise
            error('Unknown calcIDStr set');
    end
    
    % Specify how to crop the image.  We don't want it all.
    % Code further on makes the most sense if the image is square (because we
    % define a square patch of cone mosaic when we build the sensor), so the
    % cropped region should always be square.
    calcParams.cropRect = [550 450 40 40];              % [450 350 624 574] is the entire non-black region of our initial images
    
    % Specify the parameters for the chooser calculation
    calcParams.coneIntegrationTime = 0.005;
    calcParams.S = [380 8 51];
    
    calcParams.numTrials = 100;
    calcParams.maxIllumTarget = 50;
    calcParams.numKValueSamples = 10;
    calcParams.kInterval = 1;
    calcParams.startK = 8;
    
    % Specify eye movement parameters
    % EMPositions represents the number of positions of eye movement to sample,
    % in this case it is 100
    calcParams.enableEM = false;
    calcParams.numEMPositions = 1;
    calcParams.EMPositions = zeros(calcParams.numEMPositions, 2);
    calcParams.EMSampleTime = 0.001;                    % Setting sample time to 1 ms
    calcParams.tremorAmpFactor = 1;                    % This factor determines amplitude of tremors
    
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
        sensorImageSimpleChooserModel(calcParams, chooserColorChoice);
    end
    
    %% Calculate threshholds using chooser model data
    if (CALC_THRESH)
        thresholdCalculation(calcParams.calcIDStr, displayIndividualThreshold);
    end
end

end
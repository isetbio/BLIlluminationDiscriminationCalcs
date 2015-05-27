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
% 4/29/15  dhb, xd  Wrote it.

%% Clear and initialize
close all; ieInit;

%% Control of what gets done in this function
CACHE_SCENES = true; forceSceneCompute = false;
CACHE_OIS = true; forceOICompute = false;
RUN_CHOOSER = true; chooserColorChoice = 0;
displayIndividualThreshold = true;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Parameters of the calculation
%
% We'll define this as a structure, with the fields providing the name of
% what is specified.  These fields could later be viewed as key-value pairs
% either for override by key-value calling arguments or for saving out in
% some sensible manner in a database.  We could also run some sort of check
% on the structure at runtime to make sure our caches are consistent with
% the current parameters being used.

% Folder list to run over for conversions into isetbio format
calcParams.cacheFolderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
    'RedIllumination', 'YellowIllumination'};
    
% Specify how to crop the image.  We don't want it all.
% Code further on makes the most sense if the image is square (because we
% define a square patch of cone mosaic when we build the sensor), so the
% cropped region should always be square.
calcParams.cropRect = [550 450 40 40];              % [450 350 624 574] is the entire non-black region of our initial images

% Specify the parameters for the chooser calculation
calcParams.coneIntegrationTime = 0.050;
calcParams.S = [380 8 51];

calcParams.numTrials = 100;
calcParams.maxIllumTarget = 50;
calcParams.numKValueSamples = 10;
calcParams.kInterval = 1;

% Specify eye movement parameters
% EMPositions represents the number of positions of eye movement to sample,
% in this case it is 100
calcParams.enableEM = false;
calcParams.numEMPositions = 100;
calcParams.EMPositions = zeros(calcParams.numEMPositions, 2);
calcParams.EMSampleTime = 0.001;                    % Setting sample time to 1 ms

% Specify cone adaptation parameters
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
%
% Note that the data set generated below is using the volt data from the
% sensor images.  The photon data set is still being generated.
thresholdCalculation(displayIndividualThreshold);
end
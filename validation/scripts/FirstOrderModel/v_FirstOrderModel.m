function varargout = v_FirstOrderModel(varargin)
%
% Script to run through all the calculations once for the first order model.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
close all;

%% Set a seed to make things run nicely
rng(1);

%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
pathDir = fullfile(myDir,'..','toolbox','');
AddToMatlabPathDynamically(pathDir);
setPrefsForBLIlluminationDiscriminationCalcs;

%% Validation
ieSessionSet('wait bar','off');

%% Load desired params
calcParams = load(fullfile(myDir, 'scripts/FirstOrderModel/validationCalcParams'));
calcParams = calcParams.calcParams;

%% Check if necessary data exists
if ~exist(fullfile(getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir'), 'ImageData', 'Neutral'), 'dir')
    error('Please set up the data file directories approriately.  Consult the project wiki on GitHub for instructions.');
end

fprintf('Please note that the first order model validation script will take 6-7 minutes to run\n');

%% Convert the images to cached scenes for more analysis
if (calcParams.CACHE_SCENES)
    convertRBGImagesToSceneFiles(calcParams,calcParams.forceSceneCompute);
end

%% Convert cached scenes to optical images
if (calcParams.CACHE_OIS)
    convertScenesToOpticalimages(calcParams, calcParams.forceOICompute);
end

%% Create data sets using the simple chooser model
if (calcParams.RUN_MODEL)
    results = firstOrderModel(calcParams, calcParams.chooserColorChoice, calcParams.overWriteFlag);
end

%% Calculate threshholds using chooser model data
if (calcParams.CALC_THRESH)
    thresholdCalculation(calcParams.calcIDStr, calcParams.displayIndividualThreshold);
end
    
UnitTest.validationData('FirstOrderModelResults', results);
end
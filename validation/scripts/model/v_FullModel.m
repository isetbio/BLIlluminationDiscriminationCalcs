function varargout = v_FullModel(varargin)
%
% Script to run through all the calculations once.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
    
ieSessionSet('wait bar','off');

%% Load desired params
calcParams = load('scripts/model/validationCalcParams');
calcParams = calcParams.calcParams;

%% Add path and set pref
rootDir = fileparts(pwd);
AddToMatlabPathDynamically(fullfile(rootDir, 'ToolBox'));
setPrefsForBLIlluminationDiscriminationCalcs;

%% Convert the images to cached scenes for more analysis
if (calcParams.CACHE_SCENES)
    convertRBGImagesToSceneFiles(calcParams,calcParams.forceSceneCompute);
end

%% Convert cached scenes to optical images
if (calcParams.CACHE_OIS)
    convertScenesToOpticalimages(calcParams, calcParams.forceOICompute);
end

%% Create data sets using the simple chooser model
if (calcParams.RUN_CHOOSER)
    sensorImageSimpleChooserModel(calcParams, calcParams.chooserColorChoice, calcParams.overWriteFlag);
end

%% Calculate threshholds using chooser model data
if (calcParams.CALC_THRESH)
    thresholdCalculation(calcParams.calcIDStr, calcParams.displayIndividualThreshold);
end
    
end
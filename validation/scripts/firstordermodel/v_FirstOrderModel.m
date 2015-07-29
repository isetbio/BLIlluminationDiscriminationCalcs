function varargout = v_FirstOrderModel(varargin)
%
% Script to run through all the calculations once for the first order model.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);
setPrefsForBLIlluminationDiscriminationCalcs;

%% Validation
ieSessionSet('wait bar','off');

%% Load desired params
calcParams = load('scripts/firstordermodel/validationCalcParams');
calcParams = calcParams.calcParams;

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
    firstOrderModel(calcParams, calcParams.chooserColorChoice, calcParams.overWriteFlag);
end

%% Calculate threshholds using chooser model data
if (calcParams.CALC_THRESH)
    thresholdCalculation(calcParams.calcIDStr, calcParams.displayIndividualThreshold);
end
    
end
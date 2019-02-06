function varargout = v_FirstOrderModel(varargin)
%
% Script to run through all the calculations once for the first order model.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

%% Close any figures
close all;

%% Add ToolBox to Matlab path
myDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
pathDir = fullfile(myDir,'..','toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation
ieSessionSet('wait bar','off');

%% Load desired params
calcParams = load(fullfile(myDir, 'scripts/FirstOrderModel/validationCalcParams'));
calcParams = calcParams.calcParams;

%% Set a seed to make things run repeatably
rng(1);
calcParams.frozen = true;
% Run below again, new validation file works without frozen noise
fprintf('Please note that the first order model validation script will take 6-7 minutes to run\n');

%% Create data sets using the simple chooser model
if (calcParams.RUN_MODEL)
	results = RunModel(calcParams,calcParams.overWriteFlag,calcParams.frozen,true);
end

UnitTest.validationData('FirstOrderModelResults', results);
end
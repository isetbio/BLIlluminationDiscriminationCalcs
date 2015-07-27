%% MasterCalcParamList
%
% This script will generate all the calcParams used in the current set of
% calculations for the BLIlluminationDiscrimination project.  The
% calcParams in this file will be grouped together if they contribute to
% the same 'mean' calculation.
%
% Running this script will generate the desired sets of calcParams on
% ColorShare1 for use in 'runAllCalcFromQueue.m'.  Set the boolean flags
% at the top of this function to disable groups of calcs.
%
% 7/21/15  xd  wrote it

%% Clear and close
clear; close all;

%% Set preferences
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Boolean options for which sets of calcParams to generate
CREATE_StaticPhoton_Neutral = true;

%% StaticPhoton in the Neutral case
calcIDStrList = {'StaticPhoton' 'StaticPhoton_2' 'StaticPhoton_3' 'StaticPhoton_4' ...
    'StaticPhoton_5' 'StaticPhoton_6' 'StaticPhoton_7' 'StaticPhoton_8' ...
    'StaticPhoton_9' 'StaticPhoton_10' 'StaticPhoton_11' 'StaticPhoton_12' ...
    'StaticPhoton_13' 'StaticPhoton_14' 'StaticPhoton_15'};

for ii = 1:length(calcIDStrList)
    
    % Define the steps of the calculation that should be carried out.
    calcParams.CACHE_SCENES = false;
    calcParams.forceSceneCompute = true; % Will overwrite any existing data.
    
    calcParams.CACHE_OIS = false;
    calcParams.forceOICompute = true;    % Will overwrite any existing data.
    
    calcParams.RUN_MODEL = true;
    calcParams.MODEL_ORDER = 1;          % Which model to run
    calcParams.chooserColorChoice = 0;   % Which color direction to use (0 means all)
    calcParams.overWriteFlag = 1;        % Whether or not to overwrite existing data.
    
    calcParams.CALC_THRESH = false;
    calcParams.displayIndividualThreshold = false;
    
    % Create each calcParam.  Full detail on the fields can be found in runAllCalculations.m
    calcParams.calcIDStr = calcIDStrList{ii};
    calcParams = updateCacheFolderList(calcParams);
    calcParams = updateCropRect(calcParams);
    
    calcParams.S = [380 8 51];
    calcParams.coneIntegrationTime = 0.050;
    calcParams.sensorFOV = 0.83;
    
    calcParams.numTrials = 500;
    calcParams.maxIllumTarget = 50;
    
    calcParams.numKpSamples = 10;
    calcParams.KpInterval = 1;
    calcParams.startKp = 1;
    
    calcParams.numKgSamples = 1;
    calcParams.startKg = 0;
    calcParams.KgInterval = 1;
    
    calcParams.targetImageSetSize = 7;
    calcParams.comparisonImageSetSize = 1;
        
    % Save the calcParam in the queue folder
    savePath = fullfile(BaseDir, ['calcParams' calcParams.calcIDStr]);
    save(savePath, 'calcParams');
end



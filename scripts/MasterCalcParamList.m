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

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Set preferences
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Boolean options for which sets of calcParams to generate
CREATE_StaticPhoton_Neutral = false;
CREATE_StaticPhoton_NM1 = false;
CREATE_StaticPhoton_NM2 = false;
CREATE_StaticPhoton_S2_Neutral = true;

%% StaticPhoton in the Neutral case
if (CREATE_StaticPhoton_Neutral)
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
end
%% StaticPhoton in the NM1 case
if (CREATE_StaticPhoton_NM1)
    calcIDStrList = {'StaticPhoton_NM1' 'StaticPhoton_NM1_2' 'StaticPhoton_NM1_3' 'StaticPhoton_NM1_4' ...
        'StaticPhoton_NM1_5' 'StaticPhoton_NM1_6' 'StaticPhoton_NM1_7' 'StaticPhoton_NM1_8' ...
        'StaticPhoton_NM1_9' 'StaticPhoton_NM1_10' 'StaticPhoton_NM1_11' 'StaticPhoton_NM1_12' ...
        'StaticPhoton_NM1_13' 'StaticPhoton_NM1_14' 'StaticPhoton_NM1_15'};
    
    for ii = 1:length(calcIDStrList)
        
        % Define the steps of the calculation that should be carried out.
        calcParams.CACHE_SCENES = true;
        calcParams.forceSceneCompute = false; % Will overwrite any existing data.
        
        calcParams.CACHE_OIS = true;
        calcParams.forceOICompute = false;    % Will overwrite any existing data.
        
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
end
%% StaticPhoton in the NM2 case
if (CREATE_StaticPhoton_NM2)
    calcIDStrList = {'StaticPhoton_NM2' 'StaticPhoton_NM2_2' 'StaticPhoton_NM2_3' 'StaticPhoton_NM2_4' ...
        'StaticPhoton_NM2_5' 'StaticPhoton_NM2_6' 'StaticPhoton_NM2_7' 'StaticPhoton_NM2_8' ...
        'StaticPhoton_NM2_9' 'StaticPhoton_NM2_10' 'StaticPhoton_NM2_11' 'StaticPhoton_NM2_12' ...
        'StaticPhoton_NM2_13' 'StaticPhoton_NM2_14' 'StaticPhoton_NM2_15'};
    
    for ii = 1:length(calcIDStrList)
        
        % Define the steps of the calculation that should be carried out.
        calcParams.CACHE_SCENES = true;
        calcParams.forceSceneCompute = false; % Will overwrite any existing data.
        
        calcParams.CACHE_OIS = true;
        calcParams.forceOICompute = false;    % Will overwrite any existing data.
        
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
end

%% StaticPhoton in the Neutral case 2nd image set
if (CREATE_StaticPhoton_S2_Neutral)
    calcIDStrList = {'StaticPhoton_S2_1' 'StaticPhoton_S2_2' 'StaticPhoton_S2_3' 'StaticPhoton_S2_4' ...
        'StaticPhoton_S2_5' 'StaticPhoton_S2_6' 'StaticPhoton_S2_7' 'StaticPhoton_S2_8' ...
        'StaticPhoton_S2_9' 'StaticPhoton_S2_10' 'StaticPhoton_S2_11' 'StaticPhoton_S2_12' ...
        'StaticPhoton_S2_13' 'StaticPhoton_S2_14' 'StaticPhoton_S2_15'};
    
    for ii = 1:length(calcIDStrList)
        
        % Define the steps of the calculation that should be carried out.
        calcParams.CACHE_SCENES = true;
        calcParams.forceSceneCompute = true; % Will overwrite any existing data.
        
        calcParams.CACHE_OIS = true;
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
end
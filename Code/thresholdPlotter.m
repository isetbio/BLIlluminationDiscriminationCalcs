function thresholdPlotter
%THRESHOLDPLOTTER Summary of this function goes here
%   Detailed explanation goes here

%% Clear
clear; close all;

%% Load global parameters
figParams = getFigureParameters;
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');


%% While loop that takes in commands for certain plots parameters
fprintf('*********Threshold Plotter*********\n');
while true
    outerLoopCommand = input('Enter command: ', 's');
    switch outerLoopCommand
        case {'Load' 'load' 'l'}
            targetDataFolder = input('Enter directory name: ','s');
            psychoData = load(fullfile(dataBaseDir, 'SimpleChooserData',targetDataFolder, ['psychofitSummary' targetDataFolder]));
            calcParams = psychoData.calcParams;
            calcParams = updateCalcParamFields(calcParams);
        case {'List Kg', 'li kg'}
            if ~exist('calcParams', 'var')
                cprintf('Errors', 'No files loaded! Please load a data file first\n');
            else
                startKg = calcParams.startKg;
                KgInterval = calcParams.KgInterval;
                numKgSamples = calcParams.numKgSamples;
                KgVals = startKg:KgInterval:(numKgSamples - 1) * KgInterval;
                fprintf('%s\n',sprintf('%d', KgVals));
            end
        case {'List Kp', 'li kp'}
            if ~exist('calcParams', 'var')
                cprintf('Errors', 'No files loaded! Please load a data file first\n');
            else
                startKp = calcParams.startKp;
                KpInterval = calcParams.KpInterval;
                numKpSamples = calcParams.numKpSamples;
                KgVals = startKp:KpInterval:(numKpSamples - 1) * KpInterval;
                fprintf('% s\n',sprintf('%d', KgVals));
            end
        case {'exit'}
            break;
    end
    
end
end

% Plot along Kg or Kp
% Plot singular combination of Kp Kg
% Load data set

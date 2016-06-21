function thresholdPlotter
% thresholdPlotter
% 
% This function is a plot data through command window instructions.  This
% is to facilitate easy plotting for desired plots now that the simulation
% data is potentially a 3D matrix.  
%
% NOTE: This function lacks thorough input guarding, so some invalid inputs
% may cause the program to crash.
%
% 6/30/15  xd  wrote it

%% Clear
clear;

%% Load global parameters
figParams = getFigureParameters;
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% While loop that takes in commands for certain plots parameters
fprintf('*********Threshold Plotter*********\n');
while true
    cprintf('keywords','Enter command: ');
    outerLoopCommand = input('', 's');
    outerLoopCommand = strtrim(outerLoopCommand);
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
                fprintf('%s\n',sprintf('% d', KgVals));
            end
        case {'List Kp', 'li kp'}
            if ~exist('calcParams', 'var')
                cprintf('Errors', 'No files loaded! Please load a data file first\n');
            else
                startKp = calcParams.startKp;
                KpInterval = calcParams.KpInterval;
                numKpSamples = calcParams.numKpSamples;
                KgVals = startKp:KpInterval:(numKpSamples - 1) * KpInterval;
                fprintf('%s\n',sprintf('% d', KgVals));
            end
        case {'plot' 'p'}
            type = input('kType (Kg/Kp): ', 's');
            number = input('kValue: ', 's');
            plotAllThresholds(calcParams, psychoData.psycho, figParams, type, str2double(number));
        case {'close all' 'ca'}
            close all;
        case {'plot single' 'ps'}
            target = input('Enter 2 numbers followed by a color for target (Kp Kg color): ', 's');
            [f, s] = strtok(target, ' ');
            [s, c] = strtok(s, ' ');
            Kp = str2double(f);
            Kg = str2double(strtrim(s));
            Color = strtrim(c);
            data = loadChooserData(calcParams.calcIDStr, [Color 'IllumComparison' calcParams.calcIDStr]);
            switch Color
                case 'green'
                    plotSingleData(calcParams, data, psychoData.psycho.greenPsychoFitParamsTotal,psychoData.psycho.uGreenTotal, 'g', Kg, Kp);
                case 'blue'
                    plotSingleData(calcParams, data, psychoData.psycho.bluePsychoFitParamsTotal,psychoData.psycho.uBlueTotal, 'b', Kg, Kp);
                case 'red'
                    plotSingleData(calcParams, data, psychoData.psycho.redPsychoFitParamsTotal,psychoData.psycho.uRedTotal, 'r', Kg, Kp);
                case 'yellow'
                    plotSingleData(calcParams, data, psychoData.psycho.yellowPsychoFitParamsTotal,psychoData.psycho.uYellowTotal, 'y', Kg, Kp);
            end
        case {'plot all' 'pa'}
        case {'l p kg'}
            targetDataFolder = input('Enter directory name: ','s');
            psychoData = load(fullfile(dataBaseDir, 'SimpleChooserData',targetDataFolder, ['psychofitSummary' targetDataFolder]));
            calcParams = psychoData.calcParams;
            calcParams = updateCalcParamFields(calcParams);
            plotAllThresholds(calcParams, psychoData.psycho, figParams, 'Kg', 0);
        case {'l p kp'}
            targetDataFolder = input('Enter directory name: ','s');
            psychoData = load(fullfile(dataBaseDir, 'SimpleChooserData',targetDataFolder, ['psychofitSummary' targetDataFolder]));
            calcParams = psychoData.calcParams;
            calcParams = updateCalcParamFields(calcParams);
            plotAllThresholds(calcParams, psychoData.psycho, figParams, 'Kp', 1);
        case {'plot many' 'pm'}
            calcIDList = input('Enter desired calcIDs delineated by spaces: ', 's');
            calcIDList = textscan(calcIDList, '%s');
            calcIDList = calcIDList{1};
            for ii = 1:length(calcIDList)
                theData = load(fullfile(dataBaseDir, 'SimpleChooserData',calcIDList{ii}, ['psychofitSummary' calcIDList{ii}]));
                plotAllThresholds(theData.calcParams, theData.psycho, figParams, 'Kg', 0);
            end
        case {'exit'}
            break;
    end
end
end

function plotSingleData (calcParams, data, fittedParams, usableDataTotal, color, Kg, Kp)
% plotSingleData (calcParams, data, fittedParams, usableDataTotal, color, Kg, Kp)
%
% This function plots data for a single Kp-Kg combination

%% Set common parameters
sizeOfData = size(data);
criterion = .709;
stimLevels = 1:1:sizeOfData(1);

%% Define functions 
PF = @PAL_Weibull;
PFI = @PAL_inverseWeibull;

%% Some optimization settings for the fit
options = optimset('fminsearch');
options.TolFun = 1e-09;
options.MaxFunEvals = 10000 * 100;
options.MaxIter = 500*100;

%% Convert Kg and Kp to indices
startKp = calcParams.startKp;
KpIndex = (Kp - startKp) / calcParams.KpInterval + 1;

startKg = calcParams.startKg;
KgIndex = (Kg - startKg) / calcParams.KgInterval + 1;

usableData = usableDataTotal(KgIndex);
usableData = usableData - 1;
KpFit = KpIndex - usableData;

%% Plotting
if KpFit < 1
    warning('No fit available for this data set');
else
    figure;
    data = data(:,KpIndex,KgIndex);

    % Fit the data to a curve
    paramsValues = fittedParams{KgIndex}(KpFit,:);
    
    % Get threshold value for current level of noise
    threshold = PFI(paramsValues, criterion);
    
    PropCorrectData = data / 100; % Convert from percentage to decimal
    StimLevelsFine  = min(stimLevels):(max(stimLevels)-...
        min(stimLevels))/1000:max(stimLevels);
    Fit = PF(paramsValues, StimLevelsFine);
    plot(stimLevels, PropCorrectData, 'k.', 'markersize', 40);
    set(gca, 'fontsize', 12);
    hold on;
    plot(StimLevelsFine, Fit, color, 'linewidth', 4);
    plot([threshold threshold], [0, criterion], color, 'linewidth', 3);
    
    title(['Kg: ' num2str(Kg) ' Kp: ' num2str(Kp)]);
    xlabel('Stimulus Difference (nominal)');
    ylabel('Percent Correct');
    ylim([0 1.0]);
    xlim([0 50]);
end
end


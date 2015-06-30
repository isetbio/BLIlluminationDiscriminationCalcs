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
            target = input('Enter 2 numbers for target Kp Kg: ', 's');
            [f, s] = strtok(target, ' ');
            Kp = str2double(f);
            Kg = str2double(strtrim(s));
            green = loadChooserData(calcParams.calcIDStr, ['greenIllumComparison' calcParams.calcIDStr]);
            fitToData(calcParams, green, psychoData.psycho.greenPsychoFitParamsTotal,psychoData.psycho.uGreenTotal, 'g', Kg, Kp);
        case {'exit'}
            break;
    end
end
end

function fitToData (calcParams, data, fittedParams, usableDataTotal, color, Kg, Kp)
% [threshold, paramsValues] = fitToData (data, paramsEstimate, color, toPlot)
%
% This function will fit input data to a Weibull curve.  The choice of
% psychometric function can be changed manually here.  Set "toPlot" to
% false to disable plotting of the fitted curves.  This function will
% automatically calculate where to start fitting the data.  This is done by
% looking at the first 5 entries in each column and setting the column
% where the average of these 5 values are less than 70 the first time as
% the usableData field.
%
% Inputs:
%   calcParams     - A struct containing parameters used for the chooser calculation
%   data           - The data with which to fit a Weibull curve.
%   paramsEstimate - The initial estimates for the fitting function.
%   toPlot         - Boolean flag to decide whether or not to plot all the
%                    individual fitted curves

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


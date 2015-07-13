function thresholdCalculation(calcIDStr,displayIndividualThreshold)
% thresholdCalculation(calcIDStr,displayIndividualThreshold)
%
% This function passes the pre-calculated simple chooser model data to
% fitToData to generate a fitted Weibull curve.  These curves are then
% plotted together on one figure.
%
% Inputs:
%   calcIDStr                  - Identifier for this calculation set.  This
%                                is the name of the folder in which the data is
%                                stored.
%   displayIndividualThreshold - Set to true if individual fitted curves
%                                are to be displayed.  Only the final threshold
%                                graph will be shown if set to false.
%
% 4/20/2015   xd  wrote it
% 4/22/2015   xd  finished running chooser model on all 4 illum colors
% 4/24/2015   xd  cleaned up the function for readability
% 5/28/2015   xd  usableData range decision is now automated
% 6/4/15      xd  now decides usable end range as well
% 6/29/15     xd  implemented fitting to Kg values

%% clear
clear global; %close all;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Load the data for each illumination matrix
blueMatrix  = loadChooserData(calcIDStr,['blueIllumComparison' calcIDStr]);
greenMatrix = loadChooserData(calcIDStr,['greenIllumComparison' calcIDStr]);
redMatrix = loadChooserData(calcIDStr,['redIllumComparison' calcIDStr]);
yellowMatrix = loadChooserData(calcIDStr,['yellowIllumComparison' calcIDStr]);

%% Load the calcParams used for this set of data
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
dataFilePath = fullfile(dataBaseDir, 'SimpleChooserData', calcIDStr, ['calcParams' calcIDStr]);
p = load(dataFilePath);
calcParams = p.calcParams;
calcParams = updateCalcParamFields(calcParams);

%% Load default figure parameters
figParams = getFigureParameters;

%% Set estimation parameter for calculations

% Use same estimated parameters for all data sets
paramsValueEst = [10 1 0.5 0];

%% Calculate Thresholds

% Preload cells the size of Kg samples to store thresholds fitted along Kp
tBlue = cell(calcParams.numKgSamples, 1);
tGreen = cell(calcParams.numKgSamples, 1);
tRed = cell(calcParams.numKgSamples, 1);
tYellow = cell(calcParams.numKgSamples, 1);

pBlue = cell(calcParams.numKgSamples, 1);
pGreen = cell(calcParams.numKgSamples, 1);
pRed = cell(calcParams.numKgSamples, 1);
pYellow = cell(calcParams.numKgSamples, 1);

uBlue = ones(calcParams.numKgSamples, 1);
uGreen = ones(calcParams.numKgSamples, 1);
uRed = ones(calcParams.numKgSamples, 1);
uYellow = ones(calcParams.numKgSamples, 1);

% For each illumination color, we find a vector of thresholds at which the success rate is 0.709
for ii = 1:calcParams.numKgSamples
    [tBlue{ii}, pBlue{ii}, uBlue(ii)] = fitToData(calcParams, blueMatrix(:,:,ii), paramsValueEst, 'b', displayIndividualThreshold);
    [tRed{ii}, pRed{ii}, uRed(ii)] = fitToData(calcParams, redMatrix(:,:,ii), paramsValueEst, 'r', displayIndividualThreshold);
    [tGreen{ii}, pGreen{ii}, uGreen(ii)] = fitToData(calcParams, greenMatrix(:,:,ii), paramsValueEst, 'g', displayIndividualThreshold);
    [tYellow{ii}, pYellow{ii}, uYellow(ii)] = fitToData(calcParams, yellowMatrix(:,:,ii), paramsValueEst, 'y', displayIndividualThreshold);
end

psycho.thresholdBlueTotal = tBlue; psycho.bluePsychoFitParamsTotal = pBlue; psycho.uBlueTotal = uBlue;
psycho.thresholdRedTotal = tRed; psycho.redPsychoFitParamsTotal = pRed; psycho.uRedTotal = uRed;
psycho.thresholdGreenTotal = tGreen; psycho.greenPsychoFitParamsTotal = pGreen; psycho.uGreenTotal = uGreen;
psycho.thresholdYellowTotal = tYellow; psycho.yellowPsychoFitParamsTotal = pYellow; psycho.uYellowTotal = uYellow;

% Save some data in previous format to code further on does not break
psycho.thresholdBlue = tBlue{1}; psycho.bluePsychoFitParams = pBlue{1}; psycho.uBlue = uBlue(1);
psycho.thresholdRed = tRed{1}; psycho.redPsychoFitParams = pRed{1}; psycho.uRed = uRed(1);
psycho.thresholdGreen = tGreen{1}; psycho.greenPsychoFitParams = pGreen{1}; psycho.uGreen = uGreen(1);
psycho.thresholdYellow = tYellow{1}; psycho.yellowPsychoFitParams = pYellow{1}; psycho.uYellow = uYellow(1);

%% Plot Thresholds

% Plot each threshold vector against its representative k-value of
% noise.  Also fit a line to it.
plotAllThresholds(calcParams, psycho, figParams);

% Save the threshold data for later plotting
outputFile = fullfile(dataBaseDir, 'SimpleChooserData', calcIDStr, ['psychofitSummary' calcIDStr]);
save(outputFile,'calcParams','psycho');
end

function [threshold, paramsValues, usableDataStart] = fitToData (calcParams, data, paramsEstimate, color, toPlot)
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
%
% Outputs:
%   threshold    - A vector of thresholds coresponding to the k-values of
%                  the data input
%   paramsValues - The updated params of the curve returned by the fitting function
%   usableData   - The first column at which the data set is appropriate
%                  for fitting

%% Find usable data range based on Kp

sizeOfData = size(data);

% To find the start of the usable data, take average of 1st 5 values
% and if it is less than 80, declare that column to be the first
% possible start
for ii = 1:sizeOfData(2)
    sum = data(1,ii) + data(2,ii) + data(3,ii) + data(4,ii) + data(5,ii);
    avg = sum / 5;
    
    if (avg < 80)
        usableDataStart = ii;
        break;
    end
end

if ~exist('usableDataStart','var')
    warning('No Usable Data'); 
    threshold = 0;
    paramsValues = [];
    usableDataStart = sizeOfData(2) + 1;
    return;
end

% If the average of the last 5 values is less than 70, this is the first
% non usable column of data
usableDataEnd = sizeOfData(2) + 1;
for ii = 1:sizeOfData(2)
    sum = data(46,ii) + data(47,ii) + data(48,ii) + data(49,ii) + data(50,ii);
    avg = sum / 5;
    
    if (avg < 70)
        usableDataEnd = ii;
        break;
    end
end

%% Set common parameters
numTrials = calcParams.numTrials;
paramsFree  = [1, 1, 0, 0];
criterion = .709;
stimLevels = 1:1:sizeOfData(1);
outOfNum   = repmat(numTrials, 1, sizeOfData(1));
numKValue = usableDataEnd - usableDataStart;

%% Convert data from percentage to trial sample numbers
data = data * numTrials / 100;

%% Pre-allocate room for return values
threshold = zeros(numKValue,1);
paramsValues = zeros(numKValue, 4);

%% Define functions to fit to
PF = @PAL_Weibull;
PFI = @PAL_inverseWeibull;

%% Some optimization settings for the fit
options = optimset('fminsearch');
options.TolFun = 1e-09;
options.MaxFunEvals = 10000 * 100;
options.MaxIter = 500*100;

%% Settings for plotting fits
    function createFigure
        figure;
        set(gcf,'Position',[0 0 1000 1000]);
        set(gca,'FontName','Helvetica','FontSize',12);
        suptitle(['Threshold fits for ' abbToWord(color) ' illumination']);
    end

%% Define a function that converts from color abbreviation to full word
    function colorFull = abbToWord(colorAbbr)
        switch colorAbbr
            case {'r'}
                colorFull = 'red';
            case {'g'}
                colorFull = 'green';
            case {'b'}
                colorFull = 'blue';
            case {'y'}
                colorFull = 'yellow';
        end
    end
%% Set max subplots per figure
maxSubplot = 6;

%% Calculate thresholds and fits
for i = 1:numKValue
    % Load the current column of data, each column is a different k-value
    NumPos = data(:, i + usableDataStart - 1)';
    
    % Fit the data to a curve
    [paramsValues(i,:)] = PAL_PFML_Fit(stimLevels, NumPos, outOfNum, ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options);
    
    % Get threshold value for current level of noise
    threshold(i) = PFI(paramsValues(i,:), criterion);
    
    % Plot fitted curves
    if (toPlot)
        x = rem(i - 1, maxSubplot) + 1;
        if x == 1
            createFigure;
        end
        subplot(maxSubplot/2,2,x);
        PropCorrectData = NumPos./outOfNum;
        StimLevelsFine  = min(stimLevels):(max(stimLevels)-...
            min(stimLevels))/1000:max(stimLevels);
        Fit = PF(paramsValues(i,:), StimLevelsFine);
        plot(stimLevels, PropCorrectData, 'k.', 'markersize', 40);
        set(gca, 'fontsize', 12);
        hold on;
        plot(StimLevelsFine, Fit, color, 'linewidth', 4);
        plot([threshold(i) threshold(i)], [0, criterion], color, 'linewidth', 3);
        
        currentK = calcParams.startK + calcParams.kInterval * (i + usableDataStart - 1 - 1);
        title(strcat('K-Value : ',int2str(currentK)));
        xlabel('Stimulus Difference (nominal)');
        ylabel('Percent Correct');
        ylim([0 1.0]);
        xlim([0 50]);
    end
end
end

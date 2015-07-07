function getMeanThresholdFromMultiSample(calcIDStrList)
% meanThreshold = getMeanThresholdFromMultiSample(calcIDStrList)
% 
% NOTE: THIS FUNCTION IS WORK IN PROGRESS
% NEEDS PARAMETER TO DECIDE BETWEEN MEAN KP OR KG
%
% 7/3/15  xd  wrote it

%% Get directory path
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% Load thresholds for each calcIDStr
psychoData = cell(length(calcIDStrList),1);
for ii = 1:length(calcIDStrList)
    theCalcIDStr = calcIDStrList{ii};
    psychoSummary = load(fullfile(dataBaseDir, 'SimpleChooserData', theCalcIDStr, ['psychofitSummary' theCalcIDStr]));
    psychoData{ii} = psychoSummary.psycho;
end

%% Resize and format data to take average
thisIsAnnoying = cellfun(@(X) resizeAllThresholds(X), psychoData);
for ii = 1:length(psychoData)
    psychoData{ii} = thisIsAnnoying(ii);
end

% Need to pad end?

maxUBlue = max(cellfun(@(X) max(X.uBlue), psychoData));
maxUGreen = max(cellfun(@(X) max(X.uGreen), psychoData));
maxURed = max(cellfun(@(X) max(X.uRed), psychoData));
maxUYellow = max(cellfun(@(X) max(X.uYellow), psychoData));

fprintf('');
minEndBlue = min(cellfun(@(X) cellfun(@(Y) length(Y), X.thresholdBlueTotal), psychoData));
minEndGreen = min(cellfun(@(X) length(X.thresholdGreenTotal{1}), psychoData));
minEndRed = min(cellfun(@(X) length(X.thresholdRedTotal{1}), psychoData));
minEndYellow = min(cellfun(@(X) length(X.thresholdYellowTotal{1}), psychoData));

%% Calculate mean thresholds
tBlue = cellfun(@(X) X.thresholdBlueTotal{1}(maxUBlue:minEndBlue), psychoData,'UniformOutput', false);
meanTBlue = mean(cell2mat(tBlue'), 2);

tGreen = cellfun(@(X) X.thresholdGreenTotal{1}(maxUGreen:minEndGreen), psychoData,'UniformOutput', false);
meanTGreen = mean(cell2mat(tGreen'), 2);

tRed = cellfun(@(X) X.thresholdRedTotal{1}(maxURed:minEndRed), psychoData,'UniformOutput', false);
meanTRed = mean(cell2mat(tRed'), 2);

tYellow = cellfun(@(X) X.thresholdYellowTotal{1}(maxUYellow:minEndYellow), psychoData,'UniformOutput', false);
meanTYellow = mean(cell2mat(tYellow'), 2);

%% Get standard error
errorBlue = std(cell2mat(tBlue'), [], 2) / sqrt(length(calcIDStrList));
errorRed = std(cell2mat(tRed'), [], 2) / sqrt(length(calcIDStrList));
errorGreen = std(cell2mat(tGreen'), [], 2) / sqrt(length(calcIDStrList));
errorYellow = std(cell2mat(tYellow'), [], 2) / sqrt(length(calcIDStrList));

%% Here calc mean and std err using available data -> not necessarily having all 15 points
tBlue = cellfun(@(X) X.thresholdBlueTotal{1}, psychoData,'UniformOutput', false);
tGreen = cellfun(@(X) X.thresholdGreenTotal{1}, psychoData,'UniformOutput', false);
tRed = cellfun(@(X) X.thresholdRedTotal{1}, psychoData,'UniformOutput', false);
tYellow = cellfun(@(X) X.thresholdYellowTotal{1}, psychoData,'UniformOutput', false);

    function l = maxLength(thresholds)
        l = max(cellfun(@(X) length(X), thresholds));
    end

    function t = padEnd(threshold, maxL)
        L = length(threshold);
        if L < maxL
            t = [threshold; zeros(maxL - L, 1) - 1];
        else
            t = threshold;
        end
    end

tBlue = cellfun(@(X) padEnd(X, maxLength(tBlue)), tBlue,'UniformOutput', false);
tGreen = cellfun(@(X) padEnd(X, maxLength(tGreen)), tGreen,'UniformOutput', false);
tRed = cellfun(@(X) padEnd(X, maxLength(tRed)), tRed,'UniformOutput', false);
tYellow = cellfun(@(X) padEnd(X, maxLength(tYellow)), tYellow,'UniformOutput', false);

tBlueMatrix = cell2mat(tBlue')'; 
tGreenMatrix = cell2mat(tGreen')';
tRedMatrix = cell2mat(tRed')';
tYellowMatrix = cell2mat(tYellow')'; % Each row is an entry, each column is a Kp value, -1 are filler values

    function [theMean, stderr, usable] = calcMean(dataMatrix)
        dataSize = size(dataMatrix);
        usable = 1;
        theMean = zeros(1, dataSize(2));
        stderr = zeros(1, dataSize(2));
        for jj = 1:dataSize(2)
            theColumn = dataMatrix(:, jj);
            theColumn = theColumn(theColumn ~= -1);        
            if isempty(theColumn)
                usable = usable + 1;
            else
                theMean(jj) = mean(theColumn);
                stderr(jj) = std(theColumn)/sqrt(length(theColumn));
            end
        end
        theMean = theMean(theMean ~= 0);
        stderr = stderr(theMean ~= 0);
    end

[tBlueMean, tBlueStdErr, tBlueUsable] = calcMean(tBlueMatrix);
[tGreenMean, tGreenStdErr, tGreenUsable] = calcMean(tGreenMatrix);
[tRedMean, tRedStdErr, tRedUsable] = calcMean(tRedMatrix);
[tYellowMean, tYellowStdErr, tYellowUsable] = calcMean(tYellowMatrix);

figParams = getFigureParameters;
KInterval = 1;
KValsFine = 1:10;

figure;
box off;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);

hold on;
fitAndPlotToThreshold(tBlueUsable, tBlueMean', 'b', KInterval, KValsFine, figParams, tBlueStdErr);
fitAndPlotToThreshold(tGreenUsable, tGreenMean', 'g', KInterval, KValsFine, figParams, tGreenStdErr);
fitAndPlotToThreshold(tRedUsable, tRedMean', 'r', KInterval, KValsFine, figParams, tRedStdErr);
fitAndPlotToThreshold(tYellowUsable, tYellowMean', 'y', KInterval, KValsFine, figParams, tYellowStdErr);


%% Plot thresholds
figParams = getFigureParameters;

KInterval = min([maxUBlue maxURed maxUGreen maxUYellow]):max([minEndBlue minEndGreen minEndRed minEndYellow]);
KValsFine = min(KInterval):1/1000:max(KInterval);

figure;
box off;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);

hold on;
fitAndPlotToThreshold(maxUBlue, meanTBlue, 'b', KInterval, KValsFine, figParams, errorBlue);
fitAndPlotToThreshold(maxURed, meanTRed, 'r', KInterval, KValsFine, figParams, errorRed);
fitAndPlotToThreshold(maxUGreen, meanTGreen, 'g', KInterval, KValsFine, figParams, errorGreen);
fitAndPlotToThreshold(maxUYellow, meanTYellow, 'y', KInterval, KValsFine, figParams, errorYellow);
end

function resizeData = resizeAllThresholds(psychoData)

resizeData = psychoData;

resizeData.thresholdBlueTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdBlueTotal, num2cell(psychoData.uBlueTotal), 'Uniform', false);
resizeData.thresholdRedTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdRedTotal, num2cell(psychoData.uRedTotal), 'Uniform', false);
resizeData.thresholdGreenTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdGreenTotal, num2cell(psychoData.uGreenTotal), 'Uniform', false);
resizeData.thresholdYellowTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdYellowTotal, num2cell(psychoData.uYellowTotal), 'Uniform', false);
end

function fitAndPlotToThreshold (usableData, threshold, color, KpInterval, KpValsFine, figParams, error)
% fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams)
%
% This function plots the thresholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
%
% Inputs:
%   usableData  - The start index at which the data is usable for fitting
%   threshold   - The threshold data to plot
%   color       - The color to plot the data
%   KpInterval  - The interval between k-Poisson samples
%   KpValsFine  - The total range to plot the fit over.  This should be
%                 subdivided into many small intervals (finely) to create
%                 a line
%   figParams   - Parameters to format the plot

%% Define x-axis value range
numOfData = size(threshold);
dataStart = min(KpValsFine(:)) + (usableData - 1) * KpInterval;
dataEnd = dataStart + (numOfData(1) - 1) * KpInterval;
kVals = dataStart:KpInterval:dataEnd;

%% Plot threshold points
% plot(kVals, threshold, strcat(color,'.'), 'markersize', figParams.markerSize);
errorbar(kVals, threshold, error, strcat(color, '.'), 'markersize', figParams.markerSize);

%% Fit to line and get set of y values

% This will start the fit as a linear line.  Then increase the target fit
% and try again if the mean error is greater than the tolerance.
errorTolerance = .5;
delta = 1;
polynomialToFit = 1;
s = warning('error','MATLAB:polyval:ZeroDOF');
while mean(delta) > errorTolerance && polynomialToFit < 4
    try
        [p, S] = polyfit(kVals, threshold', polynomialToFit);
        [y, delta] = polyval(p, KpValsFine,S);
        polynomialToFit = polynomialToFit + 1;
    catch
        [p, S] = polyfit(kVals, threshold', polynomialToFit - 1);
        y = polyval(p, KpValsFine,S);
        break;
    end
end
warning(s);

hold on;
plot (KpValsFine, y, color, 'linewidth', figParams.lineWidth);
end
function getMeanThresholdFromMultiSample(calcIDStrList)
% meanThreshold = getMeanThresholdFromMultiSample(calcIDStrList)
% 
% NOTE: THIS FUNCTION IS WORK IN PROGRESS
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

minEndBlue = min(cellfun(@(X) length(X.thresholdBlueTotal{1}), psychoData));
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

resizeData.thresholdBlueTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdBlueTotal, num2cell(psychoData.uBlueTotal), 'Uniform', false);
resizeData.thresholdRedTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdRedTotal, num2cell(psychoData.uRedTotal), 'Uniform', false);
resizeData.thresholdGreenTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdGreenTotal, num2cell(psychoData.uGreenTotal), 'Uniform', false);
resizeData.thresholdYellowTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdYellowTotal, num2cell(psychoData.uYellowTotal), 'Uniform', false);
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
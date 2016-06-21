function [psycho, calcParams] = getMeanThresholdFromMultiSample(calcIDStrList)
% meanThreshold = getMeanThresholdFromMultiSample(calcIDStrList)
% 
% This function will take the input list of calcID's and calculate the mean
% thresholds for the list.  Only data points present in all sames will be
% used, so that the data will not be skewed.
%
% Inputs:
%    calcIDStrList - List of calcID's from which to calculate the mean
%
% NOTE: This function will only plot the means when Kp is varying
%
% 7/3/15  xd  wrote it

%% Get directory path
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');

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

psycho.thresholdBlue = meanTBlue;
psycho.thresholdGreen = meanTGreen;
psycho.thresholdRed = meanTRed;
psycho.thresholdYellow = meanTYellow;

psycho.uBlue = maxUBlue;
psycho.uGreen = maxUGreen;
psycho.uRed = maxURed;
psycho.uYellow = maxUYellow;

calcParams = {'test' 'placeholder'};  % This really isn't needed for this function but some functions might make a call to it

%% Get standard error
errorBlue = std(cell2mat(tBlue'), [], 2) / sqrt(length(calcIDStrList));
errorRed = std(cell2mat(tRed'), [], 2) / sqrt(length(calcIDStrList));
errorGreen = std(cell2mat(tGreen'), [], 2) / sqrt(length(calcIDStrList));
errorYellow = std(cell2mat(tYellow'), [], 2) / sqrt(length(calcIDStrList));

psycho.errorBlue = errorBlue;
psycho.errorRed = errorRed;
psycho.errorGreen = errorGreen;
psycho.errorYellow = errorYellow;

save('Mean_Data', 'psycho', 'calcParams');


%% Plot thresholds
figParams = getFigureParameters;

% KInterval = min([maxUBlue maxURed maxUGreen maxUYellow]):max([minEndBlue minEndGreen minEndRed minEndYellow]);
KValsFine = 1:1/1000:10;

figure;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);

hold on;
% fitAndPlotToThreshold(maxUBlue, meanTBlue, 'b', KInterval, KValsFine, figParams,errorBlue);
% fitAndPlotToThreshold(maxURed, meanTRed, 'r', KInterval, KValsFine, figParams,errorRed);
% fitAndPlotToThreshold(maxUGreen, meanTGreen, 'g', KInterval, KValsFine, figParams,errorGreen);
% fitAndPlotToThreshold(maxUYellow, meanTYellow, 'y', KInterval, KValsFine, figParams,errorYellow);
fitAndPlotToThreshold(maxUBlue, meanTBlue, 'b', 1, KValsFine, figParams);
fitAndPlotToThreshold(maxURed, meanTRed, 'r', 1, KValsFine, figParams);
fitAndPlotToThreshold(maxUGreen, meanTGreen, 'g', 1, KValsFine, figParams);
fitAndPlotToThreshold(maxUYellow, meanTYellow, 'y', 1, KValsFine, figParams);
title('Only all samples available');
ylim([0 50]);
end

function resizeData = resizeAllThresholds(psychoData)

resizeData = psychoData;

resizeData.thresholdBlueTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdBlueTotal, num2cell(psychoData.uBlueTotal), 'Uniform', false);
resizeData.thresholdRedTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdRedTotal, num2cell(psychoData.uRedTotal), 'Uniform', false);
resizeData.thresholdGreenTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdGreenTotal, num2cell(psychoData.uGreenTotal), 'Uniform', false);
resizeData.thresholdYellowTotal = cellfun(@(X,U) [zeros(U-1,1) - 1; X],psychoData.thresholdYellowTotal, num2cell(psychoData.uYellowTotal), 'Uniform', false);
end
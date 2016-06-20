% PlotSVMPerformance
%
% This function will plot the data generated through the
% svmPerformanceAsymptote script. The data contains performance asymptotes
% for the Neutral, NM1, NM2 conditions for blue illumination. This data is
% to be used to determine what size of training data should be used for SVM
% classification.
%
% xd  6/20/16  wrote it

clear; close all;
%% Load the data
load('SVMPerformance.mat');

%% Process the data into points and error bars
%% UPDATE THIS PART ONCE FULL DATA AVAILABLE
SVMpercentCorrect = reshape(SVMpercentCorrect,3,1,7,25); % Temporary

%% Plot
% The first index of the data matrix will be image condition. The second
% index is illumination color. We only ran blue, so it should be 1 in this
% case. The third index represents the training set sizes which is stored
% in the dimensions variable.

figParams = BLIllumDiscrFigParams;
figure('Position',figParams.sqPosition); hold on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
set(gca,'XScale','log');
set(gca,'OuterPosition',figParams.OuterPosition);

xl = xlabel('Training Set Size','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);
yl.Position = [0.3 0.665];

for ii = 1:1 % length(dimensions.folders)
    % Process the data here
    CurrentData = SVMpercentCorrect(ii,:,:,:);
    DataToPlot = squeeze(mean(CurrentData,4));
    StdErr = std(squeeze(CurrentData),[],2) / 25; % dimensions.numCrossVal ; % CHANGE TO THIS WHEN FULL DATA AVAILABLE

    % Actual plotting here
    errorbar(dimensions.trainingSetSizes,DataToPlot,StdErr);
end
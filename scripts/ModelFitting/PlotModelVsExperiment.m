%% PlotModelVsExperiment
%
% This script takes the model and predicted data and plots them against
% each other to get a sense of what the data looks like. A distribution of
% points along the identity line would indicate that the model is doing
% well for fits while a distribution skewed away from the identity line
% indicates model deviations.
%
% 11/10/16  xd  wrote it

clear; close all;
%% Load data
%
% We use the data saved from the fitting routines. These files can be
% obtained by setting the save data flags at the top of the respective
% scripts to true. Then, put the appropriate file name here.
load('FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat');

%% Plot 
numSubjects = length(perSubjectExperimentalThresholds);
figParams = BLIllumDiscrFigParams;
figure; hold on;

% Re-organize colors because the data order is incoherent. This is done
% here instead of inside the figParams function since it's only one line.
c = figParams.colors;
c = c([1 4 2 3]);

% Plot identity line
plot([0 1000],[0 1000],'k','linewidth',2);

% Plot data
for ii = 1:numSubjects
    x = perSubjectExperimentalThresholds{ii};
    y = perSubjectFittedThresholds{ii};
    
    for jj = 1:length(x)
        plot(x(jj),y(jj),'.','Color',c{jj},'MarkerSize',50);
    end
end

% Set limits
lmax = max([cell2mat(perSubjectExperimentalThresholds') cell2mat(perSubjectFittedThresholds')]);
ylim([0 lmax + 3]);
xlim([0 lmax + 3]);

% Formatting 
axis square

set(gca,'FontSize',figParams.axisFontSize,'FontName',figParams.fontName,'LineWidth',figParams.axisLineWidth);
set(gca,'XTick',get(gca,'YTick'));

xlabel('Experimental Thresholds','FontSize',figParams.labelFontSize,'FontName',figParams.fontName);
ylabel('Fitted Thresholds','FontSize',figParams.labelFontSize,'FontName',figParams.fontName);
title('Experimental v Model Thresholds','FontSize',figParams.titleFontSize,'FontName',figParams.fontName);

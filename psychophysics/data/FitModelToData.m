% FitModelToData
%
% This script will plot the data from the psychophysical experiment as well
% as the mean data generated from the first order model.
%
% 7/23/15  xd  adapted from IllumDiscrimPlots

%% Clear and close
clear;
close all;

%% Load the data.
ALL_BACKGROUNDS = true;
if (ALL_BACKGROUNDS)
    % This is the VSS 14 data, for all backgrounds.  The neutral background
    % data here is for a subset of subjects plotted above.  It's a little
    % unusual in that these particular subjects didn't show an obvious "blue
    % bias", but in fact does not differ by statistical test from other closely
    % matched conditions -- there is just a lot of subject variability.
    load('FitThresholdsAveragesExp5.mat');
else
    % The combined data is for the neutral condition across both VSS and depth control
    % data.  Not sure if the depth control is for both depths or only one.
    load('FitThresholdsAveragesExp5Exp6Combined.mat');
end

%% Load the mean data
compObserverSummaryNeutral = load('FirstOrderModelMeanData');
compObserverSummaryNM1 = load('FirstOrderModelNM1');

%% Figure parameters
curDir = pwd;
figParams = PsychophysicsFigParams;
cd(curDir);
if (exist('../SecondaryFigParams','file'))
    cd ..
    figParams = SecondaryFigParams(figParams);
    cd(curDir);
end
figParams.figType = {'pdf'};

%% Special plotting colors
figParams.plotRed = [178,34,34]/255;
figParams.plotGreen = [46 139 87]/255;
figParams.plotBlue = [0 191 255]/255;
figParams.plotYellow = [255 215 0]/255;
yAxisLimit = 25;
saveFigure = 0;

%% Plots thresholds from all subjects averaged, matched condition only.
figParams.figName = 'AverageOverSubjectsNeutralSet';
figParams.xLimLow = 0;
figParams.xLimHigh = 5;
figParams.xTicks = [0 1 2 3 4 5];
figParams.xTickLabels = {'', 'Blue', 'Yellow', 'Green', 'Red'};
figParams.yLimLow = 0;
figParams.yLimHigh = 25;
figParams.yTicks = [0 5 10 15 20 25];
figParams.yTickLabels = {' 0 ' ' 0 ' ' 10 ' ' 15 ' ' 20 ' ' 25 '};
theFig = figure; clf; hold on
set(gcf,'Position',[100 100 figParams.size figParams.sqSize]);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

errorbar(1,allSubjects.meanMatchedBlue, allSubjects.SEMMatchedBlue, 'o', 'MarkerFaceColor',figParams.plotBlue, 'color', figParams.plotBlue,'MarkerSize', figParams.markerSize);
errorbar(2,allSubjects.meanMatchedYellow, allSubjects.SEMMatchedYellow,'o', 'MarkerFaceColor',figParams.plotYellow, 'color', figParams.plotYellow,'MarkerSize', figParams.markerSize);
errorbar(3,allSubjects.meanMatchedGreen, allSubjects.SEMMatchedGreen,'o', 'MarkerFaceColor',figParams.plotGreen, 'color', figParams.plotGreen,'MarkerSize', figParams.markerSize);
errorbar(4,allSubjects.meanMatchedRed, allSubjects.SEMMatchedRed, 'o', 'MarkerFaceColor',figParams.plotRed,'color', figParams.plotRed,'MarkerSize', figParams.markerSize);

xlim([figParams.xLimLow figParams.xLimHigh]);
set(gca,'XTick',figParams.xTicks);
set(gca,'XTickLabel',figParams.xTickLabels);
xlabel({'Illumination Direction'},'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylim([figParams.yLimLow figParams.yLimHigh]);
ylabel('Threshold (\DeltaE*)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
set(gca,'YTick',figParams.yTicks);
set(gca,'YTickLabel',figParams.yTickLabels);
title('Average Over Subjects','FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
%legend({' L cones ' ' M cones ' ' S cones '},'Location','NorthEast','FontSize',figParams.legendFontSize);
%axis('square');
%set(gca,'XMinorTick','on');
%FigureSave(fullfile(figParams.figName),theFig,figParams.figType);

%% Add theory to this plot
figParams.figName = 'AverageOverSubjectsWithTheory';
useK = 3.2;
useK1 = floor(useK);
useK2 = ceil(useK);
lambda = abs(useK2-useK);
dataTheoryBlue = lambda*compObserverSummaryNeutral.psycho.thresholdBlue(useK1-compObserverSummaryNeutral.psycho.uBlue+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdBlue(useK2-compObserverSummaryNeutral.psycho.uBlue+1);
dataTheoryYellow = lambda*compObserverSummaryNeutral.psycho.thresholdYellow(useK1-compObserverSummaryNeutral.psycho.uYellow+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdYellow(useK2-compObserverSummaryNeutral.psycho.uYellow+1);
dataTheoryGreen = lambda*compObserverSummaryNeutral.psycho.thresholdGreen(useK1-compObserverSummaryNeutral.psycho.uGreen+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdGreen(useK2-compObserverSummaryNeutral.psycho.uGreen+1);
dataTheoryRed = lambda*compObserverSummaryNeutral.psycho.thresholdRed(useK1-compObserverSummaryNeutral.psycho.uRed+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdRed(useK2-compObserverSummaryNeutral.psycho.uRed+1);
plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
title({'Average Over Subjects Neutral' ; ['Fit Kp Factor ',num2str(useK)]},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
%FigureSave(fullfile(figParams.figName),theFig,figParams.figType);

%% Plot NM1 data
theFig = figure; clf; hold on
set(gcf,'Position',[100 100 figParams.size figParams.sqSize]);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

errorbar(1,allSubjects.meanNonMatched1Blue, allSubjects.SEMNonMatched1Blue, 's', 'MarkerFaceColor',figParams.plotBlue, 'color', figParams.plotBlue,'MarkerSize', figParams.markerSize);
errorbar(2,allSubjects.meanNonMatched1Yellow, allSubjects.SEMNonMatched1Yellow,'s', 'MarkerFaceColor',figParams.plotYellow, 'color', figParams.plotYellow,'MarkerSize', figParams.markerSize);
errorbar(3,allSubjects.meanNonMatched1Green, allSubjects.SEMNonMatched1Green,'s', 'MarkerFaceColor',figParams.plotGreen, 'color', figParams.plotGreen,'MarkerSize', figParams.markerSize);
errorbar(4,allSubjects.meanNonMatched1Red, allSubjects.SEMNonMatched1Red, 's', 'MarkerFaceColor',figParams.plotRed,'color', figParams.plotRed,'MarkerSize', figParams.markerSize);

xlim([figParams.xLimLow figParams.xLimHigh]);
set(gca,'XTick',figParams.xTicks);
set(gca,'XTickLabel',figParams.xTickLabels);
xlabel({'Illumination Direction'},'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylim([figParams.yLimLow figParams.yLimHigh]);
ylabel('Threshold (\DeltaE*)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
set(gca,'YTick',figParams.yTicks);
set(gca,'YTickLabel',figParams.yTickLabels);
title('Average Over Subjects','FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
%legend({' L cones ' ' M cones ' ' S cones '},'Location','NorthEast','FontSize',figParams.legendFontSize);
%axis('square');
%set(gca,'XMinorTick','on');
%FigureSave(fullfile(figParams.figName),theFig,figParams.figType);

%% Add theory to this plot
figParams.figName = 'AverageOverSubjectsWithTheory';
useK = 3.2;
useK1 = floor(useK);
useK2 = ceil(useK);
lambda = abs(useK2-useK);
dataTheoryBlue = lambda*compObserverSummaryNM1.psycho.thresholdBlue(useK1-compObserverSummaryNM1.psycho.uBlue+1) + ...
    (1-lambda)*compObserverSummaryNM1.psycho.thresholdBlue(useK2-compObserverSummaryNM1.psycho.uBlue+1);
dataTheoryYellow = lambda*compObserverSummaryNM1.psycho.thresholdYellow(useK1-compObserverSummaryNM1.psycho.uYellow+1) + ...
    (1-lambda)*compObserverSummaryNM1.psycho.thresholdYellow(useK2-compObserverSummaryNM1.psycho.uYellow+1);
dataTheoryGreen = lambda*compObserverSummaryNM1.psycho.thresholdGreen(useK1-compObserverSummaryNM1.psycho.uGreen+1) + ...
    (1-lambda)*compObserverSummaryNM1.psycho.thresholdGreen(useK2-compObserverSummaryNM1.psycho.uGreen+1);
dataTheoryRed = lambda*compObserverSummaryNM1.psycho.thresholdRed(useK1-compObserverSummaryNM1.psycho.uRed+1) + ...
    (1-lambda)*compObserverSummaryNM1.psycho.thresholdRed(useK2-compObserverSummaryNM1.psycho.uRed+1);
plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
title({'Average Over Subjects NM1' ; ['Fit Kp Factor ',num2str(useK)]},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
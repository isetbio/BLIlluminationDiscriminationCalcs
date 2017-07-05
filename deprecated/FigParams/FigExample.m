% FigExample
%
% Skeleton figure example
%
% 6/26/15  dhb  Stripped it out

%% Clear and close
clear; close all;

%% Load the calcParams used for this set of data
calcIDStr = 'StaticPhoton';
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
dataFilePath = fullfile(dataBaseDir, 'SimpleChooserData', calcIDStr, ['psychofitSummary' calcIDStr]);
compObserverSummaryNeutral = load(dataFilePath);
dataFilePath = fullfile(dataBaseDir, 'SimpleChooserData', calcIDStr, ['blueIllumComparison' calcIDStr]);
blueIlluminantPsychoNeutral = load(dataFilePath);

%% Figure parameters
curDir = pwd;
masterFigParamsDir = getpref('BrainardFigs','masterFigParamsDir');
cd(masterFigParamsDir);
figParams = MasterFigParams;
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

%% Plot thresholds for one subject. Which one? Set s to any number from 1 to 10.
%
% Note the trick of putting a space as a superscript space at the start and a
% subcript space at the end of the x axis tick labels, which has the effect of creating
% some vertical space. Similarly for the leading space on the y axis
% labels.
s = 5;
figParams.figName = 'IllumDiscrimOneSubjectNeutralSet';
figParams.xLimLow = 0;
figParams.xLimHigh = 5;
figParams.xTicks = [0 1 2 3 4 5];
figParams.xTickLabels = {'', '^{ }Blue_{ }', '^{ }Yellow_{ }', '^{ }Green_{ }', '^{ }Red_{ }'};
figParams.yLimLow = 0;
figParams.yLimHigh = 25;
figParams.yTicks = [0 5 10 15 20 25];
figParams.yTickLabels = {' 0 ' ' 0 ' ' 10 ' ' 15 ' ' 20 ' ' 25 '};

theFig = figure; clf; hold on
set(gcf,'Position',[100 100 figParams.size figParams.sqSize]);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

errorbar(1,subject{s}.meanMatched.BlueMean, subject{s}.meanMatched.BlueSEM, 'o', 'MarkerFaceColor',figParams.plotBlue, 'color', figParams.plotBlue,'MarkerSize', figParams.markerSize);
errorbar(2,subject{s}.meanMatched.YellowMean, subject{s}.meanMatched.YellowSEM,'o', 'MarkerFaceColor',figParams.plotYellow, 'color', figParams.plotYellow,'MarkerSize', figParams.markerSize);
errorbar(3,subject{s}.meanMatched.GreenMean, subject{s}.meanMatched.GreenSEM,'o', 'MarkerFaceColor',figParams.plotGreen, 'color', figParams.plotGreen,'MarkerSize', figParams.markerSize);
errorbar(4,subject{s}.meanMatched.RedMean, subject{s}.meanMatched.RedSEM, 'o', 'MarkerFaceColor',figParams.plotRed,'color', figParams.plotRed,'MarkerSize', figParams.markerSize);

xlim([figParams.xLimLow figParams.xLimHigh]);
set(gca,'XTick',figParams.xTicks);
set(gca,'XTickLabel',figParams.xTickLabels);
xlabel('Illumination Direction','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylim([figParams.yLimLow figParams.yLimHigh]);
ylabel('Threshold (Delta E*)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
set(gca,'YTick',figParams.yTicks);
set(gca,'YTickLabel',figParams.yTickLabels);
title('Single Subject Data','FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
%legend({' L cones ' ' M cones ' ' S cones '},'Location','NorthEast','FontSize',figParams.legendFontSize);
%axis('square');
%set(gca,'XMinorTick','on');
FigureSave(fullfile(figParams.figName),theFig,figParams.figType);


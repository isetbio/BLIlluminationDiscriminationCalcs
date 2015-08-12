% FitModelToData
%
% This script will plot the data from the psychophysical experiment as well
% as the mean data generated from the first order model.
%
% 7/23/15  xd  Adapted from IllumDiscrimPlots
% 8/11/15  dhb Variable useKp set just once at top.
%          dhb Save figures with Kp identifier in name.
%          dhb Plots for NM1 and NM2 conditional upon having loaded that
%              data.

%% Clear and close
clear;
close all;

%% Make plots directory
curDir = pwd;
plotDir = fullfile(curDir,'plots',[]);
if (~exist(plotDir,'dir'))
    mkdir(plotDir);
end

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

% Set Kp for plots
useKp = 3.6;

%% Load the mean data
compObserverSummaryNeutral = load('FirstOrderModelNeutral');
compObserverSummaryNeutral_2 = load('FirstOrderModelNeutral_2');
compObserverSummaryNM1 = load('FirstOrderModelNM1');
compObserverSummaryNM1_2 = load('FirstOrderModelNM1_2');
compObserverSummaryNM2 = load('FirstOrderModelNM2');
compObserverSummaryNM2_2 = load('FirstOrderModelNM2_2');

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
figParams.figName = 'AverageOverSubjectsNeutral';
figParams.xLimLow = 0;
figParams.xLimHigh = 5;
figParams.xTicks = [0 1 2 3 4 5];
figParams.xTickLabels = {'', 'Blue', 'Yellow', 'Green', 'Red'};
figParams.yLimLow = 0;
figParams.yLimHigh = 25;
figParams.yTicks = [0 5 10 15 20 25];
figParams.yTickLabels = {' 0 ' ' 5 ' ' 10 ' ' 15 ' ' 20 ' ' 25 '};
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
cd(plotDir); FigureSave(fullfile(figParams.figName),theFig,figParams.figType); cd (curDir);

% Add theory to the plot
figParams.figName = ['AverageOverSubjectsNeutral_' num2str(10*useKp)];
useK1 = floor(useKp);
useK2 = ceil(useKp);
lambda = abs(useK2-useKp);
dataTheoryBlue = lambda*compObserverSummaryNeutral.psycho.thresholdBlue(useK1-compObserverSummaryNeutral.psycho.uBlue+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdBlue(useK2-compObserverSummaryNeutral.psycho.uBlue+1);
dataTheoryYellow = lambda*compObserverSummaryNeutral.psycho.thresholdYellow(useK1-compObserverSummaryNeutral.psycho.uYellow+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdYellow(useK2-compObserverSummaryNeutral.psycho.uYellow+1);
dataTheoryGreen = lambda*compObserverSummaryNeutral.psycho.thresholdGreen(useK1-compObserverSummaryNeutral.psycho.uGreen+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdGreen(useK2-compObserverSummaryNeutral.psycho.uGreen+1);
dataTheoryRed = lambda*compObserverSummaryNeutral.psycho.thresholdRed(useK1-compObserverSummaryNeutral.psycho.uRed+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.thresholdRed(useK2-compObserverSummaryNeutral.psycho.uRed+1);
errorTheoryBlue = lambda*compObserverSummaryNeutral.psycho.errorBlue(useK1-compObserverSummaryNeutral.psycho.uBlue+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.errorBlue(useK2-compObserverSummaryNeutral.psycho.uBlue+1);
errorTheoryYellow = lambda*compObserverSummaryNeutral.psycho.errorYellow(useK1-compObserverSummaryNeutral.psycho.uYellow+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.errorYellow(useK2-compObserverSummaryNeutral.psycho.uYellow+1);
errorTheoryRed = lambda*compObserverSummaryNeutral.psycho.errorBlue(useK1-compObserverSummaryNeutral.psycho.uBlue+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.errorRed(useK2-compObserverSummaryNeutral.psycho.uRed+1);
errorTheoryGreen = lambda*compObserverSummaryNeutral.psycho.errorGreen(useK1-compObserverSummaryNeutral.psycho.uGreen+1) + ...
    (1-lambda)*compObserverSummaryNeutral.psycho.errorGreen(useK2-compObserverSummaryNeutral.psycho.uGreen+1);

% plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
h = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
set(get(h,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
title({'Average Over Subjects Neutral' ; ['Fit Kp Factor ',num2str(useKp)]},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
%FigureSave(fullfile(figParams.figName),theFig,figParams.figType);

% %% Add theory to this plot for set 2
% useK1 = floor(useKp);
% useK2 = ceil(useKp);
% lambda = abs(useK2-useKp);
% dataTheoryBlue = lambda*compObserverSummaryNeutral_2.psycho.thresholdBlue(useK1-compObserverSummaryNeutral_2.psycho.uBlue+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.thresholdBlue(useK2-compObserverSummaryNeutral_2.psycho.uBlue+1);
% dataTheoryYellow = lambda*compObserverSummaryNeutral_2.psycho.thresholdYellow(useK1-compObserverSummaryNeutral_2.psycho.uYellow+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.thresholdYellow(useK2-compObserverSummaryNeutral_2.psycho.uYellow+1);
% dataTheoryGreen = lambda*compObserverSummaryNeutral_2.psycho.thresholdGreen(useK1-compObserverSummaryNeutral_2.psycho.uGreen+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.thresholdGreen(useK2-compObserverSummaryNeutral_2.psycho.uGreen+1);
% dataTheoryRed = lambda*compObserverSummaryNeutral_2.psycho.thresholdRed(useK1-compObserverSummaryNeutral_2.psycho.uRed+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.thresholdRed(useK2-compObserverSummaryNeutral_2.psycho.uRed+1);
% errorTheoryBlue = lambda*compObserverSummaryNeutral_2.psycho.errorBlue(useK1-compObserverSummaryNeutral_2.psycho.uBlue+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.errorBlue(useK2-compObserverSummaryNeutral_2.psycho.uBlue+1);
% errorTheoryYellow = lambda*compObserverSummaryNeutral_2.psycho.errorYellow(useK1-compObserverSummaryNeutral_2.psycho.uYellow+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.errorYellow(useK2-compObserverSummaryNeutral_2.psycho.uYellow+1);
% errorTheoryRed = lambda*compObserverSummaryNeutral_2.psycho.errorBlue(useK1-compObserverSummaryNeutral_2.psycho.uBlue+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.errorRed(useK2-compObserverSummaryNeutral_2.psycho.uRed+1);
% errorTheoryGreen = lambda*compObserverSummaryNeutral_2.psycho.errorGreen(useK1-compObserverSummaryNeutral_2.psycho.uGreen+1) + ...
%     (1-lambda)*compObserverSummaryNeutral_2.psycho.errorGreen(useK2-compObserverSummaryNeutral_2.psycho.uGreen+1);
% 
% % plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
% h2 = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'm', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
% set(get(h2,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
% 
% legend([h h2], 'Old Set', 'New Set');

if (ALL_BACKGROUNDS)
    
    %% Plot NM1 data
    figParams.figName = 'AverageOverSubjectsNM1';
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
    cd(plotDir); FigureSave(fullfile(figParams.figName),theFig,figParams.figType); cd (curDir);
    
    % Add theory to this plot
    figParams.figName = ['AverageOverSubjectsNM1_' num2str(10*useKp)];
    useK1 = floor(useKp);
    useK2 = ceil(useKp);
    lambda = abs(useK2-useKp);
    dataTheoryBlue = lambda*compObserverSummaryNM1.psycho.thresholdBlue(useK1-compObserverSummaryNM1.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.thresholdBlue(useK2-compObserverSummaryNM1.psycho.uBlue+1);
    dataTheoryYellow = lambda*compObserverSummaryNM1.psycho.thresholdYellow(useK1-compObserverSummaryNM1.psycho.uYellow+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.thresholdYellow(useK2-compObserverSummaryNM1.psycho.uYellow+1);
    dataTheoryGreen = lambda*compObserverSummaryNM1.psycho.thresholdGreen(useK1-compObserverSummaryNM1.psycho.uGreen+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.thresholdGreen(useK2-compObserverSummaryNM1.psycho.uGreen+1);
    dataTheoryRed = lambda*compObserverSummaryNM1.psycho.thresholdRed(useK1-compObserverSummaryNM1.psycho.uRed+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.thresholdRed(useK2-compObserverSummaryNM1.psycho.uRed+1);
    errorTheoryBlue = lambda*compObserverSummaryNM1.psycho.errorBlue(useK1-compObserverSummaryNM1.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.errorBlue(useK2-compObserverSummaryNM1.psycho.uBlue+1);
    errorTheoryYellow = lambda*compObserverSummaryNM1.psycho.errorYellow(useK1-compObserverSummaryNM1.psycho.uYellow+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.errorYellow(useK2-compObserverSummaryNM1.psycho.uYellow+1);
    errorTheoryRed = lambda*compObserverSummaryNM1.psycho.errorBlue(useK1-compObserverSummaryNM1.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.errorRed(useK2-compObserverSummaryNM1.psycho.uRed+1);
    errorTheoryGreen = lambda*compObserverSummaryNM1.psycho.errorGreen(useK1-compObserverSummaryNM1.psycho.uGreen+1) + ...
        (1-lambda)*compObserverSummaryNM1.psycho.errorGreen(useK2-compObserverSummaryNM1.psycho.uGreen+1);
    
    h = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
    set(get(h,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
    title({'Average Over Subjects NM1' ; ['Fit Kp Factor ',num2str(useKp)]},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
    cd(plotDir); FigureSave(fullfile(figParams.figName),theFig,figParams.figType); cd (curDir);
    
%     %% Add theory to this plot for set 2
%     useK1 = floor(useKp);
%     useK2 = ceil(useKp);
%     lambda = abs(useK2-useKp);
%     dataTheoryBlue = lambda*compObserverSummaryNM1_2.psycho.thresholdBlue(useK1-compObserverSummaryNM1_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.thresholdBlue(useK2-compObserverSummaryNM1_2.psycho.uBlue+1);
%     dataTheoryYellow = lambda*compObserverSummaryNM1_2.psycho.thresholdYellow(useK1-compObserverSummaryNM1_2.psycho.uYellow+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.thresholdYellow(useK2-compObserverSummaryNM1_2.psycho.uYellow+1);
%     dataTheoryGreen = lambda*compObserverSummaryNM1_2.psycho.thresholdGreen(useK1-compObserverSummaryNM1_2.psycho.uGreen+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.thresholdGreen(useK2-compObserverSummaryNM1_2.psycho.uGreen+1);
%     dataTheoryRed = lambda*compObserverSummaryNM1_2.psycho.thresholdRed(useK1-compObserverSummaryNM1_2.psycho.uRed+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.thresholdRed(useK2-compObserverSummaryNM1_2.psycho.uRed+1);
%     errorTheoryBlue = lambda*compObserverSummaryNM1_2.psycho.errorBlue(useK1-compObserverSummaryNM1_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.errorBlue(useK2-compObserverSummaryNM1_2.psycho.uBlue+1);
%     errorTheoryYellow = lambda*compObserverSummaryNM1_2.psycho.errorYellow(useK1-compObserverSummaryNM1_2.psycho.uYellow+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.errorYellow(useK2-compObserverSummaryNM1_2.psycho.uYellow+1);
%     errorTheoryRed = lambda*compObserverSummaryNM1_2.psycho.errorBlue(useK1-compObserverSummaryNM1_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.errorRed(useK2-compObserverSummaryNM1_2.psycho.uRed+1);
%     errorTheoryGreen = lambda*compObserverSummaryNM1_2.psycho.errorGreen(useK1-compObserverSummaryNM1_2.psycho.uGreen+1) + ...
%         (1-lambda)*compObserverSummaryNM1_2.psycho.errorGreen(useK2-compObserverSummaryNM1_2.psycho.uGreen+1);
%     
%     % plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
%     h2 = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'm', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
%     set(get(h2,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
%     
%     legend([h h2], 'Old Set', 'New Set');
    
    %% Plot NM2 data
    figParams.figName = 'AverageOverSubjectsNM2';
    theFig = figure; clf; hold on
    set(gcf,'Position',[100 100 figParams.size figParams.sqSize]);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    errorbar(1,allSubjects.meanNonMatched2Blue, allSubjects.SEMNonMatched2Blue, 's', 'MarkerFaceColor',figParams.plotBlue, 'color', figParams.plotBlue,'MarkerSize', figParams.markerSize);
    errorbar(2,allSubjects.meanNonMatched2Yellow, allSubjects.SEMNonMatched2Yellow,'s', 'MarkerFaceColor',figParams.plotYellow, 'color', figParams.plotYellow,'MarkerSize', figParams.markerSize);
    errorbar(3,allSubjects.meanNonMatched2Green, allSubjects.SEMNonMatched2Green,'s', 'MarkerFaceColor',figParams.plotGreen, 'color', figParams.plotGreen,'MarkerSize', figParams.markerSize);
    errorbar(4,allSubjects.meanNonMatched2Red, allSubjects.SEMNonMatched2Red, 's', 'MarkerFaceColor',figParams.plotRed,'color', figParams.plotRed,'MarkerSize', figParams.markerSize);
    
    xlim([figParams.xLimLow figParams.xLimHigh]);
    set(gca,'XTick',figParams.xTicks);
    set(gca,'XTickLabel',figParams.xTickLabels);
    xlabel({'Illumination Direction'},'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylim([figParams.yLimLow figParams.yLimHigh]);
    ylabel('Threshold (\DeltaE*)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    set(gca,'YTick',figParams.yTicks);
    set(gca,'YTickLabel',figParams.yTickLabels);
    title('Average Over Subjects','FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
    cd(plotDir); FigureSave(fullfile(figParams.figName),theFig,figParams.figType); cd (curDir);
    
    % Add theory to the plot
    figParams.figName = ['AverageOverSubjectsNM2_' num2str(10*useKp)];
    useK1 = floor(useKp);
    useK2 = ceil(useKp);
    lambda = abs(useK2-useKp);
    dataTheoryBlue = lambda*compObserverSummaryNM2.psycho.thresholdBlue(useK1-compObserverSummaryNM2.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.thresholdBlue(useK2-compObserverSummaryNM2.psycho.uBlue+1);
    dataTheoryYellow = lambda*compObserverSummaryNM2.psycho.thresholdYellow(useK1-compObserverSummaryNM2.psycho.uYellow+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.thresholdYellow(useK2-compObserverSummaryNM2.psycho.uYellow+1);
    if useKp < 4 && useKp >= 3
        dataTheoryGreen = lambda*compObserverSummaryNM2.psycho.tGreen3 + ...
            (1-lambda)*compObserverSummaryNM2.psycho.thresholdGreen(useK2-compObserverSummaryNM2.psycho.uGreen+1);
    else
        dataTheoryGreen = lambda*compObserverSummaryNM2.psycho.thresholdGreen(useK1-compObserverSummaryNM2.psycho.uGreen+1) + ...
            (1-lambda)*compObserverSummaryNM2.psycho.thresholdGreen(useK2-compObserverSummaryNM2.psycho.uGreen+1);
    end
    dataTheoryRed = lambda*compObserverSummaryNM2.psycho.thresholdRed(useK1-compObserverSummaryNM2.psycho.uRed+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.thresholdRed(useK2-compObserverSummaryNM2.psycho.uRed+1);
    errorTheoryBlue = lambda*compObserverSummaryNM2.psycho.errorBlue(useK1-compObserverSummaryNM2.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.errorBlue(useK2-compObserverSummaryNM2.psycho.uBlue+1);
    errorTheoryYellow = lambda*compObserverSummaryNM2.psycho.errorYellow(useK1-compObserverSummaryNM2.psycho.uYellow+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.errorYellow(useK2-compObserverSummaryNM2.psycho.uYellow+1);
    errorTheoryRed = lambda*compObserverSummaryNM2.psycho.errorBlue(useK1-compObserverSummaryNM2.psycho.uBlue+1) + ...
        (1-lambda)*compObserverSummaryNM2.psycho.errorRed(useK2-compObserverSummaryNM2.psycho.uRed+1);
    if useKp < 4 && useKp >= 3
        dataTheoryGreen = lambda*compObserverSummaryNM2.psycho.eGreen3 + ...
            (1-lambda)*compObserverSummaryNM2.psycho.thresholdGreen(useK2-compObserverSummaryNM2.psycho.uGreen+1);
    else
        errorTheoryGreen = lambda*compObserverSummaryNM2.psycho.errorGreen(useK1-compObserverSummaryNM2.psycho.uGreen+1) + ...
            (1-lambda)*compObserverSummaryNM2.psycho.errorGreen(useK2-compObserverSummaryNM2.psycho.uGreen+1);
    end
    
    h = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
    set(get(h,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
    title({'Average Over Subjects NM2' ; ['Fit Kp Factor ',num2str(useKp)]},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
    cd(plotDir); FigureSave(fullfile(figParams.figName),theFig,figParams.figType); cd (curDir);
    
%     %% Add theory to this plot for set 2
%     figParams.figName = 'AverageOverSubjectsWithTheory';
%     useK1 = floor(useKp);
%     useK2 = ceil(useKp);
%     lambda = abs(useK2-useKp);
%     dataTheoryBlue = lambda*compObserverSummaryNM2_2.psycho.thresholdBlue(useK1-compObserverSummaryNM2_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdBlue(useK2-compObserverSummaryNM2_2.psycho.uBlue+1);
%     dataTheoryYellow = lambda*compObserverSummaryNM2_2.psycho.thresholdYellow(useK1-compObserverSummaryNM2_2.psycho.uYellow+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdYellow(useK2-compObserverSummaryNM2_2.psycho.uYellow+1);
%     if useKp < 4 && useKp >= 3
%         dataTheoryGreen = lambda*compObserverSummaryNM2_2.psycho.tGreen3 + ...
%             (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdGreen(useK2-compObserverSummaryNM2_2.psycho.uGreen+1);
%     else
%         dataTheoryGreen = lambda*compObserverSummaryNM2_2.psycho.thresholdGreen(useK1-compObserverSummaryNM2_2.psycho.uGreen+1) + ...
%             (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdGreen(useK2-compObserverSummaryNM2_2.psycho.uGreen+1);
%     end
%     dataTheoryRed = lambda*compObserverSummaryNM2_2.psycho.thresholdRed(useK1-compObserverSummaryNM2_2.psycho.uRed+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdRed(useK2-compObserverSummaryNM2_2.psycho.uRed+1);
%     errorTheoryBlue = lambda*compObserverSummaryNM2_2.psycho.errorBlue(useK1-compObserverSummaryNM2_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.errorBlue(useK2-compObserverSummaryNM2_2.psycho.uBlue+1);
%     errorTheoryYellow = lambda*compObserverSummaryNM2_2.psycho.errorYellow(useK1-compObserverSummaryNM2_2.psycho.uYellow+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.errorYellow(useK2-compObserverSummaryNM2_2.psycho.uYellow+1);
%     errorTheoryRed = lambda*compObserverSummaryNM2_2.psycho.errorBlue(useK1-compObserverSummaryNM2_2.psycho.uBlue+1) + ...
%         (1-lambda)*compObserverSummaryNM2_2.psycho.errorRed(useK2-compObserverSummaryNM2_2.psycho.uRed+1);
%     if useKp < 4 && useKp >= 3
%         dataTheoryGreen = lambda*compObserverSummaryNM2_2.psycho.eGreen3 + ...
%             (1-lambda)*compObserverSummaryNM2_2.psycho.thresholdGreen(useK2-compObserverSummaryNM2_2.psycho.uGreen+1);
%     else
%         errorTheoryGreen = lambda*compObserverSummaryNM2_2.psycho.errorGreen(useK1-compObserverSummaryNM2_2.psycho.uGreen+1) + ...
%             (1-lambda)*compObserverSummaryNM2_2.psycho.errorGreen(useK2-compObserverSummaryNM2_2.psycho.uGreen+1);
%     end
%     
%     % plot([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed],'k', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
%     h2 = errorbar([1 2 3 4],[dataTheoryBlue dataTheoryYellow dataTheoryGreen dataTheoryRed], [errorTheoryBlue errorTheoryYellow errorTheoryGreen errorTheoryRed], 'm', 'LineWidth',figParams.lineWidth,'MarkerSize',50);
%     set(get(h2,'Children'),{'LineWidth'},{figParams.lineWidth; 3})
%     legend([h h2], 'Old Set', 'New Set');
    
end
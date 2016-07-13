% PlotSVMwithPCA
%
% Look at SVM performance when trained on full data and only pca data.
%
% xd  6/24/16

clear; 
saveFig = false;
%% Load and pull out some data
fileName = 'SVMv100PCAv250SVD.mat';
load(fileName);

resultsWithFullData = squeeze(SVMpercentCorrect(1,:,:));
resultsWithPCA = squeeze(SVMpercentCorrect(2,:,:));
resultsWithSVD = squeeze(SVMpercentCorrect(3,:,:));
runtimeWithFullData = squeeze(SVMrunTime(1,:,:));
runtimeWithPCA = squeeze(SVMrunTime(2,:,:));
runtimeWithSVD = squeeze(SVMrunTime(3,:,:));
%% Calculate the mean and std err for things we want to plot
meanFullDataResults = mean(resultsWithFullData,2);
stderrWithFullData = std(resultsWithFullData,[],2)/sqrt(dimensions.numCrossVal);
meanPCAResults = mean(resultsWithPCA,2);
stderrWithPCA = std(resultsWithPCA,[],2)/sqrt(dimensions.numCrossVal);
meanSVDResults = mean(resultsWithSVD,2);
stderrWithSVD = std(resultsWithSVD,[],2)/sqrt(dimensions.numCrossVal);

meanRuntimeWithFullData = mean(runtimeWithFullData(:));
stderrRuntimeWithFullData = std(runtimeWithFullData(:))/sqrt(dimensions.numCrossVal*length(dimensions.illumSteps));
meanRuntimeWithPCA = mean(runtimeWithPCA(:));
stderrRuntimeWithPCA = std(runtimeWithPCA(:))/sqrt(dimensions.numCrossVal*length(dimensions.illumSteps));
meanRuntimeWithSVD = mean(runtimeWithSVD(:));
stderrRuntimeWithSVD = std(runtimeWithSVD(:))/sqrt(dimensions.numCrossVal*length(dimensions.illumSteps));

%% Plot
figParams = BLIllumDiscrFigParams([],'SVMvPCA');
f = figure('Position',figParams.sqPosition); hold on;
errorbar(dimensions.illumSteps,meanFullDataResults*100,stderrWithFullData*100,'LineWidth',figParams.lineWidth,...
    'Color',figParams.colors{1});
errorbar(dimensions.illumSteps,meanPCAResults*100,stderrWithPCA*100,'LineWidth',figParams.lineWidth,...
    'Color',figParams.colors{2});
errorbar(dimensions.illumSteps,meanSVDResults*100,stderrWithSVD*100,'LineWidth',figParams.lineWidth,...
    'Color',figParams.colors{3});

legend({'Full Data','PCA Components','Fast SVD'},'Location','Northwest','FontSize',figParams.legendFontSize);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square;
grid on;

xlim(figParams.xlimit);
ylim(figParams.ylimit);

t = title('SVM Full Data v PCA','FontSize',figParams.titleFontSize);
xl = xlabel('Stimulus Level (\DeltaE)','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);

yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;

% Make an inset for the runtime
inset = axes('Position', figParams.insetPosition); hold on;
bar(1,meanRuntimeWithFullData,'FaceColor',figParams.colors{1});
bar(2, meanRuntimeWithPCA,'FaceColor',figParams.colors{2});
bar(3, meanRuntimeWithSVD,'FaceColor',figParams.colors{3});
errorbar(1:3,[meanRuntimeWithFullData meanRuntimeWithPCA meanRuntimeWithSVD],...
    [stderrRuntimeWithFullData stderrRuntimeWithPCA stderrRuntimeWithSVD],'k.',...
    'LineWidth',figParams.lineWidth);
xlim([0 4]);
axis(inset,'square');
oldYTicks = get(inset,'YTick');
set(inset,'YTick',oldYTicks(1:2:length(oldYTicks)));
set(inset,'XTick',[]);
set(inset,'FontName',figParams.fontName,'FontSize',figParams.insetAxisFontSize,'LineWidth',figParams.insetAxisLineWidth);
title('Runtime (s)','FontSize',figParams.insetTitleFontSize);

if saveFig, FigureSave(fileName,f,figParams.figType); end;
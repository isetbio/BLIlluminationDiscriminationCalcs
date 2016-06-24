% PlotSVMwithPCA
%
% Look at SVM performance when trained on full data and only pca data.
%
% xd  6/24/16

clear;
%% Load and pull out some data
load('SVMvPCA.mat');

resultsWithFullData = squeeze(SVMpercentCorrect(1,:,:));
resultsWithPCA = squeeze(SVMpercentCorrect(2,:,:));
runtimeWithFullData = squeeze(SVMrunTime(1,:,:));
runtimeWithPCA = squeeze(SVMrunTime(2,:,:));

%% Calculate the mean and std err for things we want to plot
meanFullDataResults = mean(resultsWithFullData,1);
stderrWithFullData = std(resultsWithFullData,[],1)/sqrt(dimensions.numCrossVal);
meanPCAResults = mean(resultsWithPCA,1);
stderrWithPCA = std(resultsWithPCA,[],1)/sqrt(dimensions.numCrossVal);

meanRuntimeWithFullData = mean(runtimeWithFullData(:));
stderrRuntimeWithFullData = std(runtimeWithFullData(:))/sqrt(dimensions.numCrossVal*length(dimensions.illumSteps));
meanRuntimeWithPCA = mean(runtimeWithPCA(:));
stderrRuntimeWithPCA = std(runtimeWithPCA(:))/sqrt(dimensions.numCrossVal*length(dimensions.illumSteps));

%% Plot
figParams = BLIllumDiscrFigParams([],'SVMvPCA');
f = figure('Position',figParams.sqPosition); hold on;
errorbar(dimensions.illumSteps,meanFullDataResults*100,stderrWithFullData*100,'LineWidth',figParams.lineWidth,...
    'Color',figParams.colors{1});
errorbar(dimensions.illumSteps,meanPCAResults*100,stderrWithPCA*100,'LineWidth',figParams.lineWidth,...
    'Color',figParams.colors{2});

legend({'Full Data','2 PCA Components'},'Location','Northwest','FontSize',figParams.legendFontSize);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square;
grid on;

xlim(figParams.xlimit);
ylim(figParams.ylimit);

t = title('SVM Full Data v 2 PC','FontSize',figParams.titleFontSize);
xl = xlabel('Stimulus Level (\DeltaE)','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);

yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;

% Make an inset for the runtime
inset = axes('Position', figParams.insetPosition); hold on;
bar(1,meanRuntimeWithFullData,'FaceColor',figParams.colors{1});
bar(2, meanRuntimeWithPCA,'FaceColor',figParams.colors{2});
errorbar(1:2,[meanRuntimeWithFullData meanRuntimeWithPCA],[stderrRuntimeWithFullData stderrRuntimeWithPCA],'k.',...
    'LineWidth',figParams.lineWidth);
xlim([0 3]);
axis(inset,'square');
set(inset,'YTick',[0 10 20]);
set(inset,'XTick',[]);
set(inset,'FontName',figParams.fontName,'FontSize',figParams.insetAxisFontSize,'LineWidth',figParams.insetAxisLineWidth);

title('Runtime (s)','FontSize',figParams.insetTitleFontSize);

FigureSave('SVMFullDataVPCA',f,figParams.figType);
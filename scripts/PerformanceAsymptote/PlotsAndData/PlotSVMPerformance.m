% PlotSVMPerformance
%
% This function will plot the data generated through the
% svmPerformanceAsymptote script. The data contains performance asymptotes
% for the Neutral, NM1, NM2 conditions for blue illumination. This data is
% to be used to determine what size of training data should be used for SVM
% classification.
%
% xd  6/20/16  wrote it

clear; 

%% Flag to save figure
saveFig = false;

%% Load the data
dataFile = 'SVMPerformance_Illum1_0.1deg_100PCA_parfor.mat';
load(dataFile);

%% Plot
% The first index of the data matrix will be image condition. The second
% index is illumination color. We only ran blue, so it should be 1 in this
% case. The third index represents the training set sizes which is stored
% in the dimensions variable.
figParams = BLIllumDiscrFigParams([],'Asymptote');
f = figure('Position',figParams.sqPosition); hold on;

for ii = 1:length(dimensions.folders)
    % Process the data by calculating the mean and std err for each cross validated point.
    CurrentData = SVMpercentCorrect(ii,:,:,:);
    DataToPlot = squeeze(mean(CurrentData,4));
    StdErr = std(squeeze(CurrentData),[],2) / sqrt(dimensions.numCrossVal); 

    % Actual plotting here
    errorbar(dimensions.trainingSetSizes,DataToPlot*100,StdErr*100,'Color',figParams.colors{ii},'LineWidth',figParams.lineWidth,'LineStyle',figParams.lineStyles{ii});
end
ylim([45 100]);
xlim([10^1 10^6]);

legend(cellfun(@(X)strtok(X,'_'),dimensions.folders,'UniformOutput',false),'Location','Northwest','FontSize',figParams.legendFontSize);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
set(gca,'XTick',logspace(0,5,6))
set(gca,'XScale','log');
axis square;
grid on;

t = title(dataFile(1:end-4),'FontSize',figParams.titleFontSize,'Interpreter','none');
xl = xlabel('Training Set Size','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);

yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;

if saveFig, FigureSave(strrep(dataFile(1:end-4),'_',' '),f,figParams.figType); end;
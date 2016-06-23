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
%% Load the data
load('SVMPerformance_0.1deg.mat');

%% Plot
% The first index of the data matrix will be image condition. The second
% index is illumination color. We only ran blue, so it should be 1 in this
% case. The third index represents the training set sizes which is stored
% in the dimensions variable.

figParams = BLIllumDiscrFigParams([],'Asymptote');
figure('Position',figParams.sqPosition); hold on;

for ii = 1:length(dimensions.folders)
    % Process the data by calculating the mean and std err for each cross validated point.
    CurrentData = SVMpercentCorrect(ii,:,:,:);
    DataToPlot = squeeze(mean(CurrentData,4));
    StdErr = std(squeeze(CurrentData),[],2) / dimensions.numCrossVal ; 

    % Actual plotting here
    errorbar(dimensions.trainingSetSizes,DataToPlot*100,StdErr*100,'Color',figParams.colors{ii},'LineWidth',figParams.lineWidth,'LineStyle',figParams.lineStyles{ii});
end

legend(cellfun(@(X)strtok(X,'_'),dimensions.folders,'UniformOutput',false),'Location','Northwest','FontSize',figParams.legendFontSize);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
set(gca,'XTick',logspace(0,5,6))
set(gca,'XScale','log');
axis square;
grid on;

t = title('SVM Performance','FontSize',figParams.titleFontSize);
xl = xlabel('Training Set Size','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);

yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;
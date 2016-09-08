%% PlotSVMPerformance
%
% This function will plot the data generated through the
% svmPerformanceAsymptote script. The data contains performance asymptotes
% for the Neutral, NM1, NM2 conditions for blue illumination. This data is
% to be used to determine what size of training data should be used for SVM
% classification.
%
% xd  6/20/16  wrote it

clear; close all;
%% Flag to save figure
saveFig = false;

%% Load the data
dataFile = 'SVMPerformance_Illum1_0.3deg_400PCA.mat';
load(dataFile);

%% Plot
%
% The first index of the data matrix will be image condition. The second
% index is illumination color. We only ran blue, so it should be 1 in this
% case. The third index represents the training set sizes which is stored
% in the dimensions variable.
figParams = BLIllumDiscrFigParams([],'Asymptote');
f = figure('Position',figParams.sqPosition); hold on;

for ii = 1:length(MetaData.dimensions.Folders)
    % Process the data by calculating the mean and std err for each cross validated point.
    
    DataToPlot = squeeze(SVMpercentCorrect(ii,1,:,3));
    StdErr = squeeze(SVMpercentCorrect(ii,1,:,2));

    % Actual plotting here
    errorbar(MetaData.dimensions.TrainingSetSizes,DataToPlot*100,StdErr*100,'Color',figParams.colors{ii},'LineWidth',figParams.lineWidth,'LineStyle',figParams.lineStyles{ii});
end


ylim([45 100]);
xlim([10^0 10^6]);

% Legend, titles, and axes labels
legend(cellfun(@(X)strtok(X,'_'),MetaData.dimensions.Folders,'UniformOutput',false),'Location','Northwest','FontSize',figParams.legendFontSize);
t = title(dataFile(1:end-4),'FontSize',figParams.titleFontSize,'Interpreter','none');
xl = xlabel('Training Set Size','FontSize',figParams.labelFontSize);
yl = ylabel('% Correct','FontSize',figParams.labelFontSize);

% Set some formatting and style things
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
set(gca,'XTick',logspace(0,5,6));
set(gca,'XScale','log');
axis square;
grid on;

% yl.Position = yl.Position + figParams.deltaYlabelPosition;
% xl.Position = xl.Position + figParams.deltaXlabelPosition;

%% Save the figure
if saveFig, FigureSave(strrep(dataFile(1:end-4),'_',' '),f,figParams.figType); end;
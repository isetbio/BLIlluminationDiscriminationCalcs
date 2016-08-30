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
%% Flag to save figure
saveFig = false;

%% Plot choice
sensorSize = 1;
illumLevels = [1 5 10 15];

%% Plot
figParams = BLIllumDiscrFigParams([],'Asymptote');
figParams.sqPosition = [0 0 1400 1400];
f = figure('Position',figParams.sqPosition);
for il = 1:length(illumLevels)
    %% Load the data
    dataFile = sprintf('SVMPerformance_Illum%d_%03.1fdeg_400PCA.mat',illumLevels(il),sensorSize);
    load(dataFile);
    
    %% Plot
    % The first index of the data matrix will be image condition. The second
    % index is illumination color. We only ran blue, so it should be 1 in this
    % case. The third index represents the training set sizes which is stored
    % in the dimensions variable.
    subplot(2,2,il); hold on;
    
    for ii = 1:length(MetaData.dimensions.Folders)
        % Process the data by calculating the mean and std err for each cross validated point.
        CurrentData = SVMpercentCorrect(ii,1,:,:);
        DataToPlot = squeeze(SVMpercentCorrect(ii,2,:,1));
        StdErr = squeeze(SVMpercentCorrect(ii,1,:,2));
        
        % Actual plotting here
        errorbar(MetaData.dimensions.TrainingSetSizes,DataToPlot*100,StdErr*100,'Color',figParams.colors{ii},'LineWidth',figParams.lineWidth,'LineStyle',figParams.lineStyles{ii});
    end
    ylim([45 100]);
    xlim([10^2 10^5]);
    
    legend(cellfun(@(X)strtok(X,'_'),MetaData.dimensions.Folders,'UniformOutput',false),'Location','Northeast','FontSize',figParams.legendFontSize);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    set(gca,'XTick',logspace(0,5,6))
    set(gca,'XScale','log');
    axis square;
    grid on;
    
    t = title(dataFile(1:end-11),'FontSize',figParams.titleFontSize,'Interpreter','none');
    xl = xlabel('Training Set Size','FontSize',figParams.labelFontSize);
    yl = ylabel('% Correct','FontSize',figParams.labelFontSize);
    
    yl.Position = yl.Position + figParams.deltaYlabelPosition;
    xl.Position = xl.Position + figParams.deltaXlabelPosition;
    
end
if saveFig, FigureSave(sprintf('SummaryFigures_%3.1fdeg',sensorSize),f,figParams.figType); end;

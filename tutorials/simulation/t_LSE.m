%% t_LSE
%
% Plots the LSE for each of the different mosaic conditions. Uses
% data saved from fits done in another script.
%
% 3/31/17  xd  wrote it

clear; 
%% List all the data file names
% Data mat file names
dataFiles = {'StandardMosaicFitDataWeighted',...
             'LMMosaicFitDataWeighted',...
             'LSMosaicFitDataWeighted',...
             'MSMosaicFitDataWeighted',...
             'StandardMosaicFitDataUniform',...
             'LMMosaicFitDataUniform',...
             'LSMosaicFitDataUniform',...
             'MSMosaicFitDataUniform'};
         
% Corresponding labels for x axis
xAxisLabels = {'Standard_w', 'LM_w', 'LS_w', 'MS_w',...
               'Standard_u', 'LM_u', 'LS_u', 'MS_u'};

%% Load LSE data for each mosaic
% Vectors to save mean and std error
meanLSE = zeros(length(dataFiles),1);
stderrLSE = zeros(size(meanLSE));

% Loop over data files and calculate mean and std error
for i = 1:length(dataFiles)
    load(dataFiles{i});
    meanLSE(i) = mean(LSE);
    stderrLSE(i) = std(LSE)/sqrt(length(LSE));
end

%% Plot the data
figParams = BLIllumDiscrFigParams;

figure('Position',[1000 900 960 420]); 
hold on;
bar(1:length(dataFiles), meanLSE);
errorbar(1:length(dataFiles),meanLSE,stderrLSE,'.','LineWidth',figParams.lineWidth);

set(gca, 'XTick', 1:length(dataFiles), 'XTickLabels', xAxisLabels);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

title('Model LSEs','FontSize',figParams.titleFontSize);
xlabel('Mosaic type','FontSize',figParams.labelFontSize);
ylabel('LSE','FontSize',figParams.labelFontSize);

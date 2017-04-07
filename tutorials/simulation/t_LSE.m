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
             'MSMosaicFitDataWeighted'};
         
% Corresponding labels for x axis
xAxisLabels = {'Standard', 'LM', 'LS', 'MS'};

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

figure; hold on;
bar(1:length(dataFiles), meanLSE);
errorbar(1:length(dataFiles),meanLSE,stderrLSE,'.','LineWidth',figParams.lineWidth);

set(gca, 'XTick', 1:length(dataFiles), 'XTickLabels', xAxisLabels);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

title('Model LSEs','FontSize',figParams.titleFontSize);
xlabel('Mosaic type','FontSize',figParams.labelFontSize);
ylabel('LSE','FontSize',figParams.labelFontSize);

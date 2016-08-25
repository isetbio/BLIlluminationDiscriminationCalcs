function plotFitForSingleThreshold(plotInfo,data,threshold,fitParams)
% plotFitForSingleThreshold(plotInfo,data,fitParams,threshold)
% 
% This function will generate a plot for the fitted Weibull function as
% well as the data used to fit. threshold and fitParams are the direct
% outputs of the singleThresholdExtraction function. data is the data
% points used to generated the fit. plotInfo is a struct that contains
% information for that will be used to add details such as the axis labels
% and title.
%
% xd  6/21/16  wrote it

%% Generate a default set of figure parameters used in this project
figParams = BLIllumDiscrFigParams([],'sThreshold');

% We'll also extract some parameters based on what is specified in the
% plotInfo struct here.
if isempty(plotInfo.stimLevels), plotInfo.stimLevels = 1:length(data); end;
if ~isempty(plotInfo.fitColor), figParams.defaultFitLineColor = plotInfo.fitColor; end;

% Create a finely spaced data vector to generate data points along a curve for plotting.
stimLevelsFine = min(plotInfo.stimLevels):(max(plotInfo.stimLevels)-min(plotInfo.stimLevels))/1000:max(plotInfo.stimLevels);
curveFit = PAL_Weibull(fitParams,stimLevelsFine) * 100;

%% Create the plot
figure('Position',figParams.sqPosition); hold on;

plot(plotInfo.stimLevels,data,figParams.dataMarker,'MarkerSize',figParams.dataMarkerSize); 
plot(stimLevelsFine,curveFit,'Color',figParams.defaultFitLineColor, 'LineWidth',figParams.fitLineWidth);
plot([threshold threshold], [0 plotInfo.criterion],'Color',figParams.defaultCriterionColor,'LineWidth',figParams.criterionLineWidth);
plot([min(stimLevelsFine) threshold], [plotInfo.criterion plotInfo.criterion],'Color',figParams.defaultCriterionColor,...
    'LineStyle',figParams.criterionLineStyle,'LineWidth',figParams.criterionLineWidth);

% Do some plot manipulations to make it look nice
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square;
ylim(figParams.ylimit);

xl = xlabel(plotInfo.xlabel,'FontSize',figParams.labelFontSize);
yl = ylabel(plotInfo.ylabel,'FontSize',figParams.labelFontSize);
t = title(plotInfo.title,'FontSize',figParams.titleFontSize);
yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;

end


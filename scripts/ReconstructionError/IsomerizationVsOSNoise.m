%% IsomerizationsVsOSNoise
%
% Using the linear OS results in a huge drop in performance for SVM
% classification (>=10x). This implies that there is some dramatic change
% in signal/noise when going from isomerizations to cone current. Here, we
% take a look at the mean signals as well as noisy signals for a single
% cone.
%
% 7/18/16  xd  wrote it

ieInit; clear;
%% Set parameters
fov = 0.10; rng(1);

% Multipliers for the noise we add. Isomerizations always have at least 1x
% Poisson noise built in.
osNoiseFactor = 1;
isomNoiseFactor = 0;

% Determines how long the sample time for eye movements is and how many eye
% movements to have.
integrationTimeInSeconds = 0.001;
numberOfEMPositions = 500;

% Number of noise draws
numberOfSamples = 100;

comparisonStimLevel = 50;

osType = 'biophys';

% Type of cone to plot, 2 = L, 3 = M, 4 = S
coneTypeToMatch = 2;

%% Load optical images and create mosaic
% Create a cone mosaic that will be used to calculate things throughout the
% entire script. We also create a large mosaic which will be used to
% generate the LMS for quickly calculating EM samples.
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
mosaic.sampleTime      = integrationTimeInSeconds;
mosaic.noiseFlag       = false;
mosaic.os              = osCreate(osType);
largeMosaic            = mosaic.copy;

% Load all optical images we will used
analysisDir    = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath     = fullfile(analysisDir,'OpticalImageData','Neutral_FullImage','Standard');
standardOIList = getFilenamesInDirectory(folderPath);

standardOIPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;

OI = loadOpticalImageData('Neutral_FullImage/Standard',strrep(standardOIList{1},'OpticalImage.mat',''));
OI2 = loadOpticalImageData('Neutral_FullImage/BlueIllumination',['blue' num2str(comparisonStimLevel) 'L-RGB']);

% Resize the large OI so that the difference in size is even.
largeMosaic.fov = oiGet(OI,'fov');
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;
if mod(colPadding,1), largeMosaic.cols = largeMosaic.cols + 1; end
if mod(rowPadding,1), largeMosaic.rows = largeMosaic.rows + 1; end
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;

LMS = largeMosaic.computeSingleFrame(OI,'FullLMS',true);
gaussianStd = sqrt(mean2(largeMosaic.applyEMPath(LMS,'padRows',0,'padCols',0)));

%% Calculate mean isomerizations and cone current data for first OI
mosaic.emGenSequence(numberOfEMPositions);
isomerizationData = mosaic.applyEMPath(LMS,'padRows',rowPadding,'padCols',colPadding);
coneCurrentData   = mosaic.os.compute(isomerizationData/integrationTimeInSeconds,mosaic.pattern);

%% Calculate mean isomerizations and cone current data for second OI
LMS2 = largeMosaic.computeSingleFrame(OI2,'FullLMS',true);
gaussianStd2 = sqrt(mean2(largeMosaic.applyEMPath(LMS2,'padRows',0,'padCols',0)));
isomerizationData2 = mosaic.applyEMPath(LMS2,'padRows',rowPadding,'padCols',colPadding);
coneCurrentData2   = mosaic.os.compute(isomerizationData2/integrationTimeInSeconds,mosaic.pattern);

%% Get those figure parameters yay
figParams = BLIllumDiscrFigParams;

%% Plot

% Find the cone that has the largest difference in isomerizations between
% the two optical images.
conesMatch = mosaic.pattern == coneTypeToMatch;
[coneRow, coneCol] = find(conesMatch);
maxVal = 0;
idx = 0;
for zz = 1:length(coneRow)
    tVal = norm(squeeze(isomerizationData(coneRow(zz),coneCol(zz),:)-isomerizationData2(coneRow(zz),coneCol(zz),:)));
    if  tVal > maxVal
        maxVal = tVal;
        idx = zz;
    end
end
coneRow = coneRow(idx);
coneCol = coneCol(idx);

% Generate the entire time series which is going to be the xaxis values
xaxis = integrationTimeInSeconds:integrationTimeInSeconds:numberOfEMPositions*integrationTimeInSeconds;

% Plot both mean isomerizations series as well as a desired number of noise
% draws for each
figure('Position',[100 100 1600 1000]);
subplot(2,1,1); hold on;
theIsomerizationToPlot = squeeze(isomerizationData(coneRow,coneCol,:))';
theIsomerizationToPlotWithNoise = coneMosaic.photonNoise(repmat(theIsomerizationToPlot,numberOfSamples,1));
theIsomerizationToPlotWithNoise = theIsomerizationToPlotWithNoise + ...
    isomNoiseFactor * gaussianStd * randn(size(theIsomerizationToPlotWithNoise));
for ii = 1:numberOfSamples
    
    h = plot(xaxis,theIsomerizationToPlotWithNoise(ii,:),'m');
    h.Color(4) = 0.5;
end

theIsomerizationToPlot2 = squeeze(isomerizationData2(coneRow,coneCol,:))';
theIsomerizationToPlotWithNoise2 = coneMosaic.photonNoise(repmat(theIsomerizationToPlot2,numberOfSamples,1));
theIsomerizationToPlotWithNoise2 = theIsomerizationToPlotWithNoise2 + ...
    isomNoiseFactor * gaussianStd2 * randn(size(theIsomerizationToPlotWithNoise2));
for ii = 1:numberOfSamples
    h = plot(xaxis,theIsomerizationToPlotWithNoise2(ii,:),'c');
    h.Color(4) = 0.5;
end
h1 = plot(xaxis,theIsomerizationToPlot,'r','LineWidth',5);
h2 = plot(xaxis,theIsomerizationToPlot2,'b','LineWidth',5);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

legend([h1,h2],{'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Northeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Isomerizations (quanta)','FontSize',figParams.labelFontSize);
theTitle = sprintf('Standard v Blue 1, Isomerizations, 1x Poisson %dx Gaussian Noise',isomNoiseFactor);
title(theTitle,'FontSize',figParams.titleFontSize);

% Similar plot for cone current
subplot(2,1,2); hold on;
theCurrentToPlot = squeeze(coneCurrentData(coneRow,coneCol,:))';
theCurrentToPlotMat = repmat(theCurrentToPlot,numberOfSamples,1);
osNoise = zeros(size(theCurrentToPlotMat));
osNoise = osAddNoise(osNoise,struct('sampTime',integrationTimeInSeconds));
theCurrentToPlotWithNoise = theCurrentToPlotMat + osNoiseFactor*squeeze(osNoise);

for ii = 1:numberOfSamples
    h = plot(xaxis,theCurrentToPlotWithNoise(ii,:),'m');
    h.Color(4) = 0.5;
end

theCurrentToPlot2 = squeeze(coneCurrentData2(coneRow,coneCol,:))';
theCurrentToPlot2Mat = repmat(theCurrentToPlot2,numberOfSamples,1);
osNoise = zeros(size(theCurrentToPlot2Mat));
osNoise = osAddNoise(osNoise,struct('sampTime',integrationTimeInSeconds));
theCurrentToPlotWithNoise2 = theCurrentToPlot2Mat + osNoiseFactor*squeeze(osNoise);
for ii = 1:numberOfSamples
    h = plot(xaxis,theCurrentToPlotWithNoise2(ii,:),'c');
    h.Color(4) = 0.5;
end

h1 = plot(xaxis,theCurrentToPlot,'r','LineWidth',5);
h2 = plot(xaxis,theCurrentToPlot2,'b','LineWidth',5);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

legend([h1,h2],{'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Northeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Current (pA)','FontSize',figParams.labelFontSize);
theTitle = sprintf('Standard v Blue 1, Cone Current, %dx OS Noise',osNoiseFactor);
title(theTitle,'FontSize',figParams.titleFontSize);

h = findobj(gcf,'type','axes');
set(h,'XLim',[min(xaxis) max(xaxis)]);

%% Double mass THINGY
figure('Position',figParams.sqPosition); hold on;
for ii = 1:numberOfSamples
    plot(cumsum(theIsomerizationToPlotWithNoise(ii,:)),cumsum(theIsomerizationToPlotWithNoise2(ii,:)),'k');
end
h = findobj(gcf,'type','axes');
xlimit = get(h,'XLim');
ylimit = get(h,'YLim');
set(h,'XTickLabel',get(h,'XTick')/1000,'YTickLabel',get(h,'YTick')/1000);

h1 = plot([-1e10 1e10],[-1e10 1e10], '--r','linewidth',4);
h2 = plot(cumsum(theIsomerizationToPlot),cumsum(theIsomerizationToPlot2), '--c','linewidth',4);
xlim(xlimit);
ylim(ylimit);

axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

legend([h1 h2],{'Identity Line','CumSum of Mean'},'FontSize',figParams.legendFontSize,...
    'Location','Northwest');
xlabel('CumSum of Standard Isomerizations (1000)','FontSize',figParams.labelFontSize);
ylabel('CumSum of Blue 1 Isomerizations (1000)','FontSize',figParams.labelFontSize);
title('Isomerizations','FontSize',figParams.titleFontSize);

%% DOUBLE MASS CURRENT
figure('Position',figParams.sqPosition); hold on;
for ii = 1:numberOfSamples
    plot(-1*cumsum(theCurrentToPlotWithNoise(ii,:)),-1*cumsum(theCurrentToPlotWithNoise2(ii,:)),'k');
end
h = findobj(gcf,'type','axes');
xlimit = get(h,'XLim');
ylimit = get(h,'YLim');
h1 = plot([-1e10 1e10],[-1e10 1e10], '--r','linewidth',4);
h2 = plot(-1*cumsum(theCurrentToPlot),-1*cumsum(theCurrentToPlot2), '--c','linewidth',4);
xlim(xlimit);
ylim(ylimit);

axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
set(h,'XTickLabel',get(h,'XTick')/1000,'YTickLabel',get(h,'YTick')/1000);

legend([h1 h2],{'Identity Line','CumSum of Mean'},'FontSize',figParams.legendFontSize,...
    'Location','Northwest');
xlabel('CumSum of Standard Cone Current (1000)','FontSize',figParams.labelFontSize);
ylabel('CumSum of Blue 1 Cone Current (1000)','FontSize',figParams.labelFontSize);
title('Negative Cone Current','FontSize',figParams.titleFontSize);

%% FOR PLOTTING
cones = {'B' 'L' 'M' 'S'};

%% THING
conesMatch = mosaic.pattern == coneTypeToMatch;
[coneRow, coneCol] = find(conesMatch);
figure('Position',figParams.sqPosition); hold on;
for ii = 1:length(coneRow)
    theIsomerizationToPlot = squeeze(isomerizationData(coneRow(ii),coneCol(ii),:));
    h1 = plot(xaxis,theIsomerizationToPlot,'r','LineWidth',3);
    h1.Color(4) = 0.5;
    
    theIsomerizationToPlot = squeeze(isomerizationData2(coneRow(ii),coneCol(ii),:));
    h2 = plot(xaxis,theIsomerizationToPlot,'b','LineWidth',3);
    h2.Color(4) = 0.5;
end
xlim([min(xaxis) max(xaxis)]);

axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

legend({'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Southeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Isomerizations (quanta)','FontSize',figParams.labelFontSize);
title(sprintf('Mean isomerizations for all %s cones',cones{coneTypeToMatch}),'FontSize',figParams.titleFontSize);

%% THING2
conesMatch = mosaic.pattern == coneTypeToMatch;
[coneRow, coneCol] = find(conesMatch);
figure('Position',figParams.sqPosition); hold on;
for ii = 1:length(coneRow)
    theCurrentToPlot = squeeze(coneCurrentData(coneRow(ii),coneCol(ii),:))';
    h1 = plot(xaxis,theCurrentToPlot,'r','LineWidth',3);
    h1.Color(4) = 0.5;
    
    theCurrentToPlot = squeeze(coneCurrentData2(coneRow(ii),coneCol(ii),:))';
    h2 = plot(xaxis,theCurrentToPlot,'b','LineWidth',3);
    h2.Color(4) = 0.5;
end
xlim([min(xaxis) max(xaxis)]);

axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

legend({'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Southeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Cone Current (pA)','FontSize',figParams.labelFontSize);
title(sprintf('Mean cone current for all %s cones',cones{coneTypeToMatch}),'FontSize',figParams.titleFontSize);
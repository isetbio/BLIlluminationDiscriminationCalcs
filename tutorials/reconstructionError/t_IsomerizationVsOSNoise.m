%% t_IsomerizationsVsOSNoise
%
% Using the linear OS results in a huge drop in performance for SVM
% classification (>= 10x Noise factor). This implies that there is some
% dramatic change in signal/noise when going from isomerizations to cone
% current. Here, we take a look at the mean signals as well as noisy
% signals for a single cone.
%
% 7/18/16  xd  wrote it

clear; ieInit; 
%% Set parameters

% These parameters control what calculations get done in this script. We'll
% keep the rng frozen so that results can be duplicated.
rng(1);

% Use a relatively small sensor. 0.10 degrees corresponds to about a 12-13
% cone wide square patch. Because the purpose of this function is to look
% at the noise, it is not necessary to use a large sensor and thereby
% increase computational time.
fov = 0.10;
 
% Multipliers for the noise we add. Isomerizations always have at least 1x
% Poisson noise. The osNoise is the only type of noise added to the cone
% currents and therefore should be kept at a minimum value of 1. The
% isomNoise is Gaussian white noise with a variance equal the mean
% isomerization number.
osNoiseFactor = 1;
isomNoiseFactor = 10;

% Determines how long the sample time for eye movements is and how many eye
% movements to have.
integrationTimeInSeconds = 0.001;
numberOfEMPositions = 1000;

% Number of noise draws
numberOfSamples = 10;

% Which stimulus level to use. For this script, it will always load the
% blue stimulus.
comparisonStimLevel = 50;

% Type of os. Options are 'linear' 'biophys' 'identity'.
osType = 'linear';

% Type of cone to plot, 2 = L, 3 = M, 4 = S
coneTypeToMatch = 3;

%% Load optical images and create mosaic
%
% Create a cone mosaic that will be used to calculate things throughout the
% entire script. We also create a large mosaic which will be used to
% generate the LMS for quickly calculating EM samples.
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
mosaic.noiseFlag       = 'none';
mosaic.os              = osCreate(osType);
largeMosaic            = mosaic.copy;

% Load optical images we will use. One standard OI and one comparison OI
% will be loaded for this script.
analysisDir    = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath     = fullfile(analysisDir,'OpticalImageData','Neutral','Standard');
standardOIList = getFilenamesInDirectory(folderPath);
standardOIPool = cell(1, length(standardOIList));

OI = loadOpticalImageData('Neutral/Standard',strrep(standardOIList{1},'OpticalImage.mat',''));
OI2 = loadOpticalImageData('Neutral/BlueIllumination',['blue' num2str(comparisonStimLevel) 'L-RGB']);

% Resize the large OI so that the difference in size is even.
largeMosaic.fov = oiGet(OI,'fov');
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;
if mod(colPadding,1), largeMosaic.cols = largeMosaic.cols + 1; end
if mod(rowPadding,1), largeMosaic.rows = largeMosaic.rows + 1; end
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;

% Get the LMS absorptions for both OI. Also calculate what the standard
% deviation for the Gaussian noise should be based on the absorptions in
% the standard OI.
LMS = largeMosaic.computeSingleFrame(OI,'FullLMS',true);
LMS2 = largeMosaic.computeSingleFrame(OI2,'FullLMS',true);
gaussianStd = sqrt(mean2(largeMosaic.applyEMPath(LMS,'padRows',0,'padCols',0)));

%% Calculate mean isomerizations and cone current data for OI
%
% Generate an eye movement path. This will be used to calculate absorptions
% for both OI. We calculate noise free versions of both the isomerizations
% as well as the cone current.
mosaic.emGenSequence(numberOfEMPositions);
isomerizationData = mosaic.applyEMPath(LMS,'padRows',rowPadding,'padCols',colPadding);
coneCurrentData   = mosaic.os.compute(isomerizationData/integrationTimeInSeconds,mosaic.pattern);

% Calculate mean isomerizations and cone current data for second OI
isomerizationData2 = mosaic.applyEMPath(LMS2,'padRows',rowPadding,'padCols',colPadding);
coneCurrentData2   = mosaic.os.compute(isomerizationData2/integrationTimeInSeconds,mosaic.pattern);

%% Load figParams 
figParams = BLIllumDiscrFigParams;

%% Plot
%
% Here we plot the mean signals with their respective noises added. This
% visualization should give us an idea of how strong the noise is relative
% to the actual signal.

% Find the cone that has the largest difference in isomerizations between
% the two optical images. This is just so that the plot is a bit easier to
% understand. Any arbitrary cone could be picked, but that could result in
% two identical signals, which wouldn't be as interesting.
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
% draws for each. We generate the noise by replicating the signal and
% copying into a matrix with as many rows as the number of desired noise
% draws. Then we add photon noise to each draw in addition to Gaussian
% white noise.
figure('Position',[100 100 1600 1000]);
subplot(2,1,1); hold on;
theIsomerizationToPlot = squeeze(isomerizationData(coneRow,coneCol,:))';
theIsomerizationToPlotWithNoise = coneMosaic.photonNoise(repmat(theIsomerizationToPlot,numberOfSamples,1));
theIsomerizationToPlotWithNoise = theIsomerizationToPlotWithNoise + ...
    isomNoiseFactor * gaussianStd * randn(size(theIsomerizationToPlotWithNoise));
theIsomerizationToPlotWithNoise(theIsomerizationToPlotWithNoise<0) = 0;
for ii = 1:numberOfSamples
    h = plot(xaxis,theIsomerizationToPlotWithNoise(ii,:),'m');
    h.Color(4) = 0.5;
end

% Noise generation for second OI
theIsomerizationToPlot2 = squeeze(isomerizationData2(coneRow,coneCol,:))';
theIsomerizationToPlotWithNoise2 = coneMosaic.photonNoise(repmat(theIsomerizationToPlot2,numberOfSamples,1));
theIsomerizationToPlotWithNoise2 = theIsomerizationToPlotWithNoise2 + ...
    isomNoiseFactor * gaussianStd * randn(size(theIsomerizationToPlotWithNoise2));
theIsomerizationToPlotWithNoise2(theIsomerizationToPlotWithNoise2<0) = 0;
for ii = 1:numberOfSamples
    h = plot(xaxis,theIsomerizationToPlotWithNoise2(ii,:),'c');
    h.Color(4) = 0.5;
end

% Formatting
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

% Formatting
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

%% Double mass 
%
% By plotting the cumulative sum, we can see if the signals differ at any
% given time point as there will be a nonlinearity in the cumulative sum
% curve. Additionally, the relative difference between the mean of the
% noisy draws and the identity line should give us an idea of how well a
% classifier may perform on the dataset. This is because if the two signals
% are different, then the line should veer away from the identity. In this
% case, a simple classifier might just add up all the values and ask which
% one greater. If the mean of the noise distribution is relatively close to
% the identity with respect to the variance of the noise, then it becomes
% difficult to make accurate classifications.
figure('Position',figParams.sqPosition); hold on;
for ii = 1:numberOfSamples
    plot(cumsum(theIsomerizationToPlotWithNoise(ii,:)),cumsum(theIsomerizationToPlotWithNoise2(ii,:)),'k');
end

% Formatting
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

%% Same plot for current
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

%% Plot every noise free cone of a given type
%
% We can plot the noise free signal of a give type of cone (L,M,S) for each
% cone of that type in the mosaic. This will give us a sense of how much
% overlap/difference in signal there is between the standard and comparison
% stimuli.
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

% Formatting
xlim([min(xaxis) max(xaxis)]);
axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
legend({'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Southeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Isomerizations (quanta)','FontSize',figParams.labelFontSize);
title(sprintf('Mean isomerizations for all %s cones',cones{coneTypeToMatch}),'FontSize',figParams.titleFontSize);

%% Same plot for current
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

% Formatting
xlim([min(xaxis) max(xaxis)]);
axis square; grid on;
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
legend({'Standard',['Blue ' num2str(comparisonStimLevel)]},'Location','Southeast','FontSize',figParams.legendFontSize);
xlabel('Time (seconds)','FontSize',figParams.labelFontSize);
ylabel('Cone Current (pA)','FontSize',figParams.labelFontSize);
title(sprintf('Mean cone current for all %s cones',cones{coneTypeToMatch}),'FontSize',figParams.titleFontSize);
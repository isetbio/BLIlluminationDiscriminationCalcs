%% OSNoiseVsIntensity
%
% The osAddNoise routine adds noise independent of signal intensity. This
% demonstrates this by using the same scene, but reducing the intensity of
% one by 10. The main source of osNoise is channel noise which is
% independent of the signal. Thus we would expect there to be no difference
% amongst the std deviations of the noise between the two signals.
%
% 7/20/16  xd  wrote it

ieInit; clear; close all;
%% Params
%
% A few parameters that determine which os to use as well as the sampling
% interval and number of draws.
osType = 'linear';
numOfNoiseDraws = 100;

timeStepInSeconds = 0.001;
numberOfEMPositions = 1000;

%% Load scenes and compute OI
%
% We load the scene file because we need to reduce the intensity of image.
% We do this by dividing the original number of photons by 10 and then
% calculating the OI using human optics.
originalScene = loadSceneData('Neutral_FullImage/Standard','TestImage0');
reducedIntensityScene = originalScene;
reducedIntensityScene = sceneSet(reducedIntensityScene,'photons',sceneGet(originalScene,'photons')/10);

humanOI = oiCreate('human');
originalOI = oiCompute(humanOI,originalScene);
reducedIntensityOI = oiCompute(humanOI,reducedIntensityScene);

%% Create a cone mosaic
%
% Create a cone mosaic based on the parameters set. We also set its size to
% only 1 cone since we are only going to be doing noise draws from 1 cone
% anyways. The noise flags are turned off so we can generate the noise
% later.
mosaic = coneMosaic;
mosaic.integrationTime = timeStepInSeconds;
mosaic.sampleTime = timeStepInSeconds;
mosaic.rows = 5;
mosaic.cols = 5;
mosaic.os = osCreate(osType);
mosaic.os.noiseFlag = false;
mosaic.noiseFlag = false;
mosaic.emGenSequence(numberOfEMPositions);

%% Calculate mean signals
[~,originalConeCurrent] = mosaic.compute(originalOI);
[~,reducedIntensityConeCurrent] = mosaic.compute(reducedIntensityOI);

%% Do many noisy draws
%
% We calculate the noisy signal many times. Because we are only interested
% in the noise, we will subtract the mean signal and save the noise in a
% separate matrix.
originalNoisyData = zeros(numOfNoiseDraws,numberOfEMPositions);
reducedIntensityNoisyData = zeros(numOfNoiseDraws,numberOfEMPositions);

for ii = 1:numOfNoiseDraws
    originalDataVec = osAddNoise(originalConeCurrent,struct('sampTime',timeStepInSeconds));
    originalNoisyData(ii,:) = squeeze(originalDataVec - originalConeCurrent)';
    
    reducedIntensityDataVec = osAddNoise(reducedIntensityConeCurrent,struct('sampTime',timeStepInSeconds));
    reducedIntensityNoisyData(ii,:) = squeeze(reducedIntensityDataVec - reducedIntensityConeCurrent)';
end

%% Calculate Standard Deviation
originalStd = std(originalNoisyData,[],1);
reducedIntensityStd = std(reducedIntensityNoisyData,[],1);

%% Plot Stuff
% 
% Plot the standard deviation of the noise of the two different scenes. The
% plot should appear roughly spherical since the noise draws are
% independent of the signal.

figParams = BLIllumDiscrFigParams;
figure('Position',figParams.sqPosition);
plot(originalStd,reducedIntensityStd,'ro','MarkerSize',20,'LineWidth',2);

% Format
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square; grid on; box off;
xlabel('Original','FontSize',figParams.labelFontSize);
ylabel('Reduced Intensity','FontSize',figParams.labelFontSize);
title('Std deviation in osNoise for 100 time steps');

%% Plot the mean signal
%
% This is to confirm that there is indeed a difference between the mean signals.
figure('Position',figParams.sqPosition); hold on;
timeValues = timeStepInSeconds:timeStepInSeconds:numberOfEMPositions*timeStepInSeconds;
plot(timeValues,squeeze(originalConeCurrent),'LineWidth',2);
plot(timeValues,squeeze(reducedIntensityConeCurrent),'LineWidth',2);

% Format
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square; grid on; box off;
legend({'Original','Reduced Intensity'},'FontSize',figParams.legendFontSize,...
    'Location','Northwest');
xlabel('Time (seconds','FontSize',figParams.labelFontSize);
ylabel('Cone Current (pA)','FontSize',figParams.labelFontSize);
title('Mean Cone Currents','FontSize',figParams.titleFontSize);
%% OSNoiseVIntensity
%
% The osAddNoise routine adds noise independent of signal intensity. This
% demonstrates this by using the same scene, but reducing the intensity of
% one by 10.
%
% 7/20/16  xd  wrote it

ieInit; clear; 
%% Params
osType = 'linear';
numOfNoiseDraws = 100;

timeStepInSeconds = 0.001;
numberOfEMPositions = 1000;

%% Load scenes and compute OI
originalScene = loadSceneData('Neutral_FullImage/Standard','TestImage0');
reducedIntensityScene = originalScene;
reducedIntensityScene = sceneSet(reducedIntensityScene,'photons',sceneGet(originalScene,'photons')/10);

humanOI = oiCreate('human');
originalOI = oiCompute(humanOI,originalScene);
reducedIntensityOI = oiCompute(humanOI,reducedIntensityScene);

%% Create a cone mosaic
mosaic = coneMosaic;
mosaic.integrationTime = timeStepInSeconds;
mosaic.sampleTime = timeStepInSeconds;
mosaic.rows = 1;
mosaic.cols = 1;
mosaic.os = osCreate(osType);
mosaic.os.noiseFlag = false;
mosaic.noiseFlag = false;
mosaic.emGenSequence(numberOfEMPositions);

%% Calculate mean signals
[~,originalConeCurrent] = mosaic.compute(originalOI);
[~,reducedIntensityConeCurrent] = mosaic.compute(reducedIntensityOI);

%% Do many noisy draws
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
figParams = BLIllumDiscrFigParams;

figure('Position',figParams.sqPosition);
plot(originalStd,reducedIntensityStd,'ro','MarkerSize',20,'LineWidth',2);

set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square; grid on; box off;

xlabel('Original','FontSize',figParams.labelFontSize);
ylabel('Reduced Intensity','FontSize',figParams.labelFontSize);
title('Std deviation in osNoise for 100 time steps');

%%
figure('Position',figParams.sqPosition); hold on;
timeValues = timeStepInSeconds:timeStepInSeconds:numberOfEMPositions*timeStepInSeconds;

plot(timeValues,squeeze(originalConeCurrent),'LineWidth',2);
plot(timeValues,squeeze(reducedIntensityConeCurrent),'LineWidth',2);

set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square; grid on; box off;

legend({'Original','Reduced Intensity'},'FontSize',figParams.legendFontSize,...
    'Location','Northwest');
xlabel('Time (seconds','FontSize',figParams.labelFontSize);
ylabel('Cone Current (pA)','FontSize',figParams.labelFontSize);
title('Mean Cone Currents','FontSize',figParams.titleFontSize);
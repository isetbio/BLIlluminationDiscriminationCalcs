%% t_UseExistingNoiseFits
%
% Fits data using existing noise levels.
%
% 12/8/16  xd  wrote it

clear; close all;
%% Load data
% load(fullfile(mfilename('fullpath'),'../../tutorialData/uniformIndividualFitThresholds'));
load('NeutralUniformFit');

modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
modelDataIDStr = 'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Neutral';

singlePlots = false;

aggregateThresholds = plotThresholdForMeanPerformance(modelDataIDStr,false);
aggregateThresholds = aggregateThresholds(:,[1 4 2 3]);

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
[~, calcParams] = loadModelData(allDirs{1});
noiseVector = calcParams.noiseLevels;

% Create some label information for plotting.
stimLevels = 1:50;
pI = createPlotInfoStruct;
pI.stimLevels = stimLevels;
pI.xlabel = 'Gaussian Noise Levels';
pI.ylabel = 'Stimulus Levels (\DeltaE)';
pI.title  = 'Thresholds v Noise';

%%
if ~singlePlots
    figure('Position',[150 238 2265 1061]);
end
orderOfSubjects = {'azm','bmj','vle','vvu','idh','hul','ijj','eom','dtm','ktv'}';
load('Exp5AllData');
for ii = 1:length(perSubjectFittedNoiseLevel)
    d1 = subject{ii}.Matched{1};
    d2 = subject{ii}.Matched{2};
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
    
    expThreshold = [b y g r];
    perSubjectExperimentalThresholds{ii} = expThreshold;
%     expThreshold = perSubjectExperimentalThresholds{ii};
    
    noise = 1 + perSubjectFittedNoiseLevel{ii}/(noiseVector(2) - noiseVector(1));
    
    fitThreshold = interpolateThreshold(noise,aggregateThresholds);
    
    if ~singlePlots
        subplot(2,5,ii);
    end
    perSubjectFittedThresholds{ii} = plotAndFitThresholdsToRealData(pI,fitThreshold,expThreshold,...
        'NoiseVector',calcParams.noiseLevels,'NewFigure',singlePlots);
    
    title([orderOfSubjects{ii} ', ' num2str(perSubjectFittedNoiseLevel{ii}) ' Noise']);
end

%%
fitMean = mean(cell2mat(perSubjectFittedThresholds));
fitSEM  = std(cell2mat(perSubjectFittedThresholds))/sqrt(10);
expMean = mean(cell2mat(perSubjectExperimentalThresholds));
expSEM  = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(10);

plotAndFitThresholdsToRealData(pI,fitMean,expMean,'ThresholdError',fitSEM,'DataError',expSEM,...
    'NoiseVector',calcParams.noiseLevels,'NewFigure',true);

ylim([0 20]);
title('Uniform Aggregate Fit');
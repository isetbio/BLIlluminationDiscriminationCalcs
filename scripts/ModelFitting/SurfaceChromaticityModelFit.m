%% SurfaceChromaticityModelFit
%
% Uses the uniform mean over the model data to fit performance to subjects.
% This script performs fits to the data from the surface chromaticity
% varying experiment.
%
% 8/4/16    xd  wrote it
% 10/27/16  xd  added some file saving and plotting options
% 6/20/17   xd  change file naming conventions

clear; close all;
%% Some parameters

% If set to true, each subject fit gets it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = false;

% This is the calcIDStr for the SVM dataset we want to use to fit to the
% experimental results.
modelDataIDStrs = {'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Neutral',...
                   'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_NM1',...
                   'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_NM2'};

% Set to true to save the data after the script has finished running. Will
% be saved into local directory where this script is called from.
saveData = true;
saveFilename = 'ChromaticityModelFits';

%% Load experimental data
load('Exp5AllData.mat');

% Need to change order of data for plotting purposes. We do the same for
% the model data later on.
Neutral = Neutral(:,[1 4 2 3]);
NM1 = NM1(:,[1 4 2 3]);
NM2 = NM2(:,[1 4 2 3]);

%% Preallocate some space for data
%
% We save the aggregate thresholds, the fitted thresholds, and the
% experimental thresholds. This should be enough for any auxiliary plot we
% want to create.
perSubjectFittedThresholds       = cell(size(Neutral,1),1);
perSubjectExperimentalThresholds = cell(size(Neutral,1),1);
perSubjectFittedNoiseLevel       = cell(size(Neutral,1),1);

%% Calculation and plotting loop
if ~singlePlots
    figure('Position',[150 238 2265 1061]);
end

% Data is ordered blue, green, red, yellow so we need to reorganize it to
% become blue, yellow, green, red.
aggregateThresholds = [];
for ii = 1:length(modelDataIDStrs)
    thresholds = plotThresholdForMeanPerformance(modelDataIDStrs{ii},false);
    aggregateThresholds = [aggregateThresholds thresholds(:,[1 4 2 3])]; %#ok<*AGROW>
end

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
allDirs     = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStrs{1});
[~,calcParams] = loadModelData(allDirs{1});

%% Fit
for subjectNumber = 1:size(Neutral,1)

    % Create some label information for plotting.
    stimLevels = 1:50;
    pI = createPlotInfoStruct;
    pI.stimLevels = stimLevels;
    pI.xlabel = 'Gaussian Noise Levels';
    pI.ylabel = 'Stimulus Levels (\DeltaE)';
    pI.title  = 'Thresholds v Noise';
    
    %% Get subject data
    dataToFit = [Neutral(subjectNumber,:) NM1(subjectNumber,:) NM2(subjectNumber,:)];
    
    % Plot a the thresholds along with the model predictions.
    if ~singlePlots
        subplot(2,5,subjectNumber);
    end
    [perSubjectFittedThresholds{subjectNumber},perSubjectFittedNoiseLevel{subjectNumber}]...
        = plotAndFitThresholdsToRealData(pI,aggregateThresholds,dataToFit,...
                                         'NoiseVector',calcParams.noiseLevels,...
                                         'NewFigure',singlePlots);
 
end

if ~singlePlots
    st = suptitle('Constant');
    set(st,'FontSize',30);
end

%% Fit the aggregate
%
% Calculate the mean and std of thresholds for both the experimental
% condition as well as the model performance. Use these to make plots.
mFit = mean(cell2mat(perSubjectFittedThresholds));
sFit = std(cell2mat(perSubjectFittedThresholds))/sqrt(10);
mExp = mean([Neutral NM1 NM2]);
sExp = std([Neutral NM1 NM2])/sqrt(10);

figure('Position', [188 514 2281 758]);
for ii = 1:length(modelDataIDStrs)
    s = (ii-1) * 4 + 1;
    subplot(2,3,ii+3);
    
    plotAndFitThresholdsToRealData(pI,mFit(s:s+3),mExp(s:s+3),...
        'ThresholdError',sFit(s:s+3),'DataError',sExp(s:s+3),...
        'NoiseVector',calcParams.noiseLevels,'NewFigure',false);
    
    ylim([0 20]);
    title(['Uniform Aggregate Fit, ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
end

disp(['Uniform Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);

%%
if saveData
    save([saveFilename '.mat'],'perSubjectFittedNoiseLevel','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds');
end
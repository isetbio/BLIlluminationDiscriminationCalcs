%% UniformMeanModelFit
%
% Uses the uniform mean over the model data to fit performance to subjects.
%
% 8/4/16    xd  wrote it
% 10/27/16  xd  added some file saving and plotting options
% 6/20/17   xd  change file naming conventions

clear; close all;
%% Set parameters

% This is the calcIDStr for the SVM dataset we want to use to fit to the
% % experimental results.
modelDataIDStrs = {'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'...
    'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'...
    'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'...
    'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'...
    'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'...
    'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize'};
titleStrs = {'LS' 'LM' 'MS' 'L' 'M' 'S'};
RMSE = zeros(length(modelDataIDStrs),1);


% If set to true, each subject fit get's it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = false;

% Whether to just generate to data or to show the plots
showPlots = true;

% Whether to save the averaged model fit figure
saveAvgFigure = true;

% Whether to save data
saveData = true;

% Path to data
pathToExperimentData = 'G:\Dropbox (Aguirre-Brainard Lab)\xColorShare\Xiaomao\Exp8ImageProcessingCodeTempLocation\ThresholdData\FitThresholdsAllSubjectsExp8.mat';

%% Preallocate some space for data
load('FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.09_PCA400_ABBA_SVM_Constant_CorrectSize_UniformModelFits.mat');
RMSE = zeros(length(modelDataIDStrs),1);

%% Calculation and plotting loop
figure;
for ii = 1:length(modelDataIDStrs)
    
    modelDataIDStr = modelDataIDStrs{ii};
    
    % Data is ordered blue, green, red, yellow so we need to reorganize it to
    % become blue, yellow, green, red.
    aggregateThresholds = plotThresholdForMeanPerformance(modelDataIDStr,false,70.71);
    aggregateThresholds = aggregateThresholds(:,[1 4 2 3]);
    
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
    [~, calcParams] = loadModelData(allDirs{1});
    
    % Create some label information for plotting.
    stimLevels = 1:50;
    pI = createPlotInfoStruct;
    pI.stimLevels = stimLevels;
    pI.xlabel = 'Gaussian Noise Levels';
    pI.ylabel = 'Stimulus Levels (\DeltaE)';
    pI.title  = 'Thresholds v Noise';
    
    %% Fit the aggregate
    % Calculate the mean and std of thresholds for both the experimental
    % condition as well as the model performance. Use these to make plots.
    meanExpThreshold   = mean(cell2mat(perSubjectExperimentalThresholds));
    semExpThreshold    = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(length(perSubjectExperimentalThresholds));
    meanModelThreshold = mean(cell2mat(perSubjectFittedThresholds));
    semModelThreshold  = std(cell2mat(perSubjectFittedThresholds))/sqrt(length(perSubjectFittedThresholds));
    
    meanNoiseLevel = mean(cell2mat(perSubjectFittedNoiseLevel));
    dNoise = calcParams.noiseLevels(2) - calcParams.noiseLevels(1);
    meanNoiseLevel = meanNoiseLevel / dNoise + 1;
    
    subplot(2,3,ii);
    currentThresh = plotAndFitThresholdsToRealData(pI,aggregateThresholds,meanModelThreshold,...
        'DataError',semModelThreshold,...
        'NoiseLevel',meanNoiseLevel,...
        'NoiseVector',calcParams.noiseLevels,'NewFigure',false,'CreatePlot',showPlots);
    
    if showPlots
        ylim([0 20]);
        title(titleStrs{ii});
        disp(['Uniform Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
        
        if saveAvgFigure
            savefig(['AlternateMosaicsAtUniformNoise.fig']);
        end
    end
    
    RMSE(ii) = sqrt(sum((currentThresh(:) - meanModelThreshold(:)).^2) / length(currentThresh));
    
end

%% Calculate LSE
RMSE = zeros(length(perSubjectFittedThresholds),1);
for i = 1:length(perSubjectFittedThresholds)
    RMSE(i) = sqrt(sum((perSubjectFittedThresholds{i} - perSubjectExperimentalThresholds{i}).^2) / 4);
end

%%
if saveData
    save(['RMSE.mat'],'perSubjectFittedNoiseLevel','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds','RMSE');
end
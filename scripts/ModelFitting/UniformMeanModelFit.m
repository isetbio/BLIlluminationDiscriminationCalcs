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
modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_noABBA_distanceBased_Constant';

% If set to true, each subject fit get's it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = false;

% Whether to just generate to data or to show the plots
showPlots = true;

% Set to true to save the data after the script has finished running. Will
% be saved into local directory where this script is called from.
saveData = false;
saveFilename = [modelDataIDStr '_UniformModelFits'];

% Whether to save the averaged model fit figure
saveAvgFigure = true;

% Path to data
pathToExperimentData = '/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat';

%% Subject ID's
% DON'T CHANGE
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';

%% Preallocate some space for data
%
% We save the aggregate thresholds, the fitted thresholds, and the
% experimental thresholds. This should be enough for any auxiliary plot we
% want to create.
perSubjectFittedThresholds = cell(length(orderOfSubjects),1);
perSubjectExperimentalThresholds = cell(length(orderOfSubjects),1);
perSubjectFittedNoiseLevel = cell(length(orderOfSubjects),1);

%% Calculation and plotting loop
if ~singlePlots && showPlots
    figure('Position',[150 238 2265 1061]);
end

% Data is ordered blue, green, red, yellow so we need to reorganize it to
% become blue, yellow, green, red.
aggregateThresholds = plotThresholdForMeanPerformance(modelDataIDStr,false);
aggregateThresholds = aggregateThresholds(:,[1 4 2 3]);

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
[~, calcParams] = loadModelData(allDirs{1});

thresholdMatrix = zeros(length(orderOfSubjects),8);

for subjectNumber = 1:length(orderOfSubjects)
    subjectId = orderOfSubjects{subjectNumber};
    load(pathToExperimentData)
    
    % Create some label information for plotting.
    stimLevels = 1:50;
    pI = createPlotInfoStruct;
    pI.stimLevels = stimLevels;
    pI.xlabel = 'Gaussian Noise Levels';
    pI.ylabel = 'Stimulus Levels (\DeltaE)';
    pI.title  = 'Thresholds v Noise';
    
    %% Get subject data
    %
    % Load the subject performances. We need to calculate the mean
    % thresholds for the constant runs as well as the standard deviations.
    d1 = subject{subjectNumber}.Constant{1};
    d2 = subject{subjectNumber}.Constant{2};
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
    
    thresholdMatrix(subjectNumber,:) = [ d1.Bluer.threshold,d2.Bluer.threshold , ...
                                         d1.Greener.threshold,d2.Greener.threshold , ...
                                         d1.Redder.threshold,d2.Redder.threshold, ...
                                         d1.Yellower.threshold,d2.Yellower.threshold ];

    % Plot a the thresholds along with the model predictions.
    if ~singlePlots && showPlots
        subplot(2,5,subjectNumber);
    end
    [perSubjectFittedThresholds{subjectNumber},perSubjectFittedNoiseLevel{subjectNumber}]...
        = plotAndFitThresholdsToRealData(pI,aggregateThresholds,[b y g r],...
        'NoiseVector',calcParams.noiseLevels,'NewFigure',singlePlots,'CreatePlot',showPlots);
    perSubjectExperimentalThresholds{subjectNumber} = [b y g r];
    
    if showPlots
        theTitle = get(gca,'title'); %#ok<*UNRCH>
        theTitle = theTitle.String;
        title(strrep(theTitle,'Data fitted at',[subjectId ',']));
    end
end

if ~singlePlots && showPlots
    st = suptitle('Constant');
    set(st,'FontSize',30);
end

%% Fit the aggregate

% Calculate the mean and std of thresholds for both the experimental
% condition as well as the model performance. Use these to make plots.
meanExpThreshold   = mean(cell2mat(perSubjectExperimentalThresholds));
semExpThreshold    = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(length(perSubjectExperimentalThresholds));
meanModelThreshold = mean(cell2mat(perSubjectFittedThresholds));
semModelThreshold  = std(cell2mat(perSubjectFittedThresholds))/sqrt(length(perSubjectFittedThresholds));

plotAndFitThresholdsToRealData(pI,meanModelThreshold,meanExpThreshold,...
    'ThresholdError',semModelThreshold,...
    'DataError',semExpThreshold,...
    'NoiseVector',calcParams.noiseLevels,'NewFigure',true,'CreatePlot',showPlots);

if showPlots
    ylim([0 20]);
    title(['Uniform Aggregate Fit, ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
    disp(['Uniform Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
    
    if saveAvgFigure
        savefig([saveFilename '.fig']);
    end
end

%% Calculate LSE
RMSE = zeros(length(perSubjectFittedThresholds),1);
for i = 1:length(perSubjectFittedThresholds)
    RMSE(i) = sqrt(sum((perSubjectFittedThresholds{i} - perSubjectExperimentalThresholds{i}).^2) / 4);
end

%%
if saveData
    save([saveFilename '.mat'],'perSubjectFittedNoiseLevel','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds','RMSE');
end
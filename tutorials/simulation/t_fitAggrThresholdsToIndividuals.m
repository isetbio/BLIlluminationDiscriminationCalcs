%% t_fitAggrThresholdsToIndividuals
%
% Uses the uniform mean over the model data to fit performance to subjects.
%
% 8/04/16  xd  wrote it
% 10/27/16  xd  added some file saving and plotting options

clear;% close all; ieInit;
%% Some parameters
%
% If set to true, each subject fit get's it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = false;

% This is the calcIDStr for the SVM dataset we want to use to fit to the
% % experimental results.
modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_RSNeutral';

% Set to true to save the data after the script has finished running. Will
% be saved into local directory where this script is called from.
saveData = true;
saveFilename = 'LMosaicFitDataUniform';

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
if ~singlePlots
    figure('Position',[150 238 2265 1061]);
end

% Data is ordered blue, green, red, yellow so we need to reorganize it to
% become blue, yellow, green, red.
aggregateThresholds = plotThresholdForMeanPerformance(modelDataIDStr,false);
aggregateThresholds = aggregateThresholds(:,[1 4 2 3]);

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
[~, calcParams] = loadModelData(allDirs{1});

for subjectNumber = 1:length(orderOfSubjects)
    subjectId = orderOfSubjects{subjectNumber};
    load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')
    
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
    subjectIdx = find(not(cellfun('isempty', strfind(orderOfSubjects,subjectId))));
    d1 = subject{subjectIdx}.Constant{1};
    d2 = subject{subjectIdx}.Constant{2};
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
        
    % Plot a the thresholds along with the model predictions.
    if ~singlePlots
        subplot(2,5,subjectNumber);
    end
    [perSubjectFittedThresholds{subjectNumber},perSubjectFittedNoiseLevel{subjectNumber}]...
        = plotAndFitThresholdsToRealData(pI,aggregateThresholds,[b y g r],...
        'NoiseVector',calcParams.noiseLevels,'NewFigure',singlePlots);
    perSubjectExperimentalThresholds{subjectNumber} = [b y g r];
    
    theTitle = get(gca,'title');
    theTitle = theTitle.String;
    title(strrep(theTitle,'Data fitted at',[subjectId ',']));
end

if ~singlePlots
    st = suptitle('Constant');
    set(st,'FontSize',30);
end
% close all;

%% Fit the aggregate
%
% Calculate the mean and std of thresholds for both the experimental
% condition as well as the model performance. Use these to make plots.
Z   = mean(cell2mat(perSubjectFittedThresholds));
Zs  = std(cell2mat(perSubjectFittedThresholds))/sqrt(10);
Zr  = mean(cell2mat(perSubjectExperimentalThresholds));
Zrs = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(10);

plotAndFitThresholdsToRealData(pI,Z,Zr,'ThresholdError',Zs,'DataError',Zrs,...
    'NoiseVector',calcParams.noiseLevels,'NewFigure',true);

ylim([0 20]);

title(['Uniform Aggregate Fit, ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
disp(['Uniform Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);

%% Calculate LSE
LSE = zeros(length(perSubjectFittedThresholds),1);
for i = 1:length(perSubjectFittedThresholds)
    LSE(i) = sqrt(sum((perSubjectFittedThresholds{i} - perSubjectExperimentalThresholds{i}).^2));
end

%%
if saveData
    save(saveFilename,'perSubjectFittedNoiseLevel','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds','LSE');
end
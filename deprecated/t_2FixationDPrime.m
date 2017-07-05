%% t_2FixationDPrime
%
% In many of the trials, subjects fixated at two locations in the stimuli.
% Using the performances of the two patches in which the fixation is binned
% into, we can calculate what a theoretical performance percentage for
% using both fixations would be. This script implements this type of
% analysis using a d-prime mapping for 2AFC tasks.
%
% 12/6/16  xd  wrote it

clear; %close all;
%% Some parameters and settings

modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';

singlePlots = false;

saveData = false;

%% Load some things
% Z = load(fullfile(mfilename('fullpath'),'../../tutorialData/IndividualFitThresholds'));
% perSubjectFittedNoiseLevel = Z.perSubjectFittedNoiseLevel;

load(fullfile(mfilename('fullpath'),'../../tutorialData/IndividualFitThresholds_dPrime'));

%% Fixed variables
%
% Don't change these
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';
pathToFixationData = '/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Exp8ProcessedData/';

%% Preallocate some space for data
%
% We save the aggregate thresholds, the fitted thresholds, and the
% experimental thresholds. This should be enough for any auxiliary plot we
% want to create.

perSubjectAggregateThresholds = cell(length(orderOfSubjects),1);
perSubjectFittedThresholds = cell(length(orderOfSubjects),1);
perSubjectExperimentalThresholds = cell(length(orderOfSubjects),1);

%% Load d-prime lookup table
%
% Multiply percentages by 100 since the lookup table is in decimals and the
% saved data is in percentages.
dpl = load('dPrimeLookup');
percentTable = dpl.probCorrectAreaROC * 100;
dprimeTable  = dpl.dPrimesTAFC;
clear dpl;

%% Something
fittedNoiseLevel = zeros(length(orderOfSubjects),1);

%% Calculation loop
if ~singlePlots
    figure('Position',[150 238 2265 1061]);
end

for subjectNumber = 1:length(orderOfSubjects)
    subjectId = orderOfSubjects{subjectNumber};
    
    %% Load the data
    %
    % We need to load the fixations from the experiment. These paths are
    % stored locally and may need to be changed depending on your setup.
    r1 = load([pathToFixationData 'Exp8EMByScenePatches_1deg/' subjectId '-Constant-' num2str(1) '-EMInPatches.mat']);
    r2 = load([pathToFixationData 'Exp8EMByScenePatches_1deg/' subjectId '-Constant-' num2str(2) '-EMInPatches.mat']);
    r1 = r1.resultData;
    r2 = r2.resultData;
    
    load(fullfile(fileparts(mfilename('fullpath')),'plotInfoMatConstant_1deg.mat'))
    load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')
    
    %% Load dummy data to preallocate results matrix
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
    [dummyData, calcParams] = loadModelData(allDirs{1});
    results = zeros(size(dummyData));
    noiseVector = calcParams.noiseLevels;
    
    %% Generate performance matrix
    %
    % We first pool all the fixation data available. Then, for each trial,
    % we take the fixation and calculated the adjusted performance based
    % on the d-prime calulcation as follows. d'_final = sqrt(sum((d'_i)^2))
    % where i is an individual fixation during the trial.
    
    % Pool together all fixations in one cell array.
    allFixations = [r1(:,2); r2(:,2)];
    
%     tic
%     % Loop over fixations to calculate performance
%     for ff = 1:length(allFixations)
%         theCurrentFixations = allFixations{ff};
%         dPrimeTemp = zeros(size(results));
%         
%         % Load model results for these fixations
%         for ii = 1:length(theCurrentFixations)
%             thePatch = theCurrentFixations(ii);
%             currentPatchData = loadModelData(allDirs{thePatch});
%             
%             % Find the percentTable idx for the performances in
%             % currentPatchData. These are used to look up the d-prime
%             % values.
%             [~,pIdx] = min(abs(bsxfun(@minus,percentTable,currentPatchData(:)')));
%             
%             % Add d-prime squared
%             dPrimeTemp = dPrimeTemp + reshape(dprimeTable(pIdx).^2,size(dPrimeTemp));
%         end
%         
%         % Take square root of sums of d-primed squares
%         dPrimeTemp = sqrt(dPrimeTemp);
%         
%         % Look up performance based on calculated d-prime and add to
%         % running total.
%         [~,pIdx] = min(abs(bsxfun(@minus,dprimeTable,dPrimeTemp(:)')));
%         results = results + reshape(percentTable(pIdx),size(results));
%         if mod(ff,100) == 0
%             toc
%         end
%     end
%     results = results / length(allFixations);
    
    %% Extract the thresholds for each color direction.
%     for ii = 1:4
%         t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
%     end
    
    % Turn from cell into matrix. This allows for easier plotting later. We
    % also reorganize the matrix so that the color order is b, y, g, r.
%     t = cell2mat(t);
%     t = t(:,[1 4 2 3]);
%     perSubjectAggregateThresholds{subjectNumber} = t;
    t = perSubjectAggregateThresholds{subjectNumber};
    
    noise = 1 + perSubjectFittedNoiseLevel{subjectNumber}/(noiseVector(2) - noiseVector(1));
    t = interpolateThreshold(noise,t);
    
    % Create some label information for plotting.
    stimLevels = calcParams.stimLevels;
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
    [perSubjectFittedThresholds{subjectNumber},fittedNoiseLevel(subjectNumber)]...
        = plotAndFitThresholdsToRealData(pI,t,...
        [b y g r],'NoiseVector',calcParams.noiseLevels,'NewFigure',singlePlots);
    perSubjectExperimentalThresholds{subjectNumber} = [b y g r];
    theTitle = get(gca,'title');
    theTitle = theTitle.String;
    title(strrep(theTitle,'Data fitted at',[subjectId ',']));
    
    %     % Save the weighted thresholds along with the proper noise level at
    %     % which to interpolate the results.
    %     if savePerf
    %         save([subjectId '-weightedPerf'],'results','itpN');
    %     end
    
    clearvars t;
    
end

%% Plot mean
meanExpThreshold = mean(cell2mat(perSubjectExperimentalThresholds));
semExpThreshold  = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(length(perSubjectExperimentalThresholds));
meanModelThreshold = mean(cell2mat(perSubjectFittedThresholds));
semModelThreshold  = std(cell2mat(perSubjectFittedThresholds))/sqrt(length(perSubjectFittedThresholds));

plotAndFitThresholdsToRealData(pI,meanModelThreshold,meanExpThreshold,...
    'ThresholdError',semModelThreshold,...
    'DataError',semExpThreshold,...
    'NoiseVector',calcParams.noiseLevels,'NewFigure',true);

% Format plot
ylim([0 20]);
if exist('perSubjectFittedNoiseLevel','var')
    fittedNoiseLevel = cell2mat(perSubjectFittedNoiseLevel);
end
title(['Weighted Aggregate Fit, d-prime, ' num2str(mean(fittedNoiseLevel))]);

%% Save the data
if saveData
    save('IndividualFitThresholds_dPrime','perSubjectAggregateThresholds','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds','perSubjectFittedNoiseLevel');
end
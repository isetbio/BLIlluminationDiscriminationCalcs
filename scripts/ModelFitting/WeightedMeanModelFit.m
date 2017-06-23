%% t_UseRealEMDistribution
%
% Uses a real EM Distrbution data file from the psychophysical experiments
% in order to come to a prediction of performance. The data is also saved
% at then end of the script so that we can have easy access for plotting!
% Note that this script requires you to have experimental data from our
% experiment available.
%
% Please send an email to David Brainard (brainard@psych.upenn.edu) for
% data requests.
%
% 8/4/16    xd  wrote it 
% 10/27/16  xd  added some file saving and plotting options
% 6/20/17   xd  change file naming conventions

clear; close all;
%% Some parameters

% This is the calcIDStr for the SVM dataset we want to use to fit to the
% experimental results.
modelDataIDStr = 'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant'; 
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';
% modelDataIDStr = 'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant';

% If set to true, each subject fit get's it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = false;

% Whether to just generate to data or to show the plots
showPlots = false;

% Set to true to save the data after the script has finished running. Will
% be saved into local directory where this script is called from.
saveData = false;
saveFilename = [modelDataIDStr '_WeightedModelFits'];

% Set to true to save the weighted performance matrices.
savePerf = true;

% Whether to dynamically scale axes
scaleAxes = false;

%% Some constant values
% Subject ID's
% DON'T CHANGE
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
perSubjectFittedNoiseLevel = cell(length(orderOfSubjects),1);

%% Calculation and plotting loop
if ~singlePlots && showPlots
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
    
    load('plotInfoMatConstant_1deg.mat')
    load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')
    
    %% Load dummy data to preallocate results matrix
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    allDirs = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),modelDataIDStr);
    [dummyData, calcParams] = loadModelData(allDirs{1});
    results = zeros(size(dummyData));
    
    %% Put all the experimental data into one matrix
    %
    % This let's us calculate the weighted patch values based on a desired
    % set of fixations.
    dataset      = [r1{:,2} r1{:,3} r2{:,2} r2{:,3}];
    uniqueValues = unique(dataset);
    totalNumber  = numel(dataset);
    
    % Count the number of times each patch appears so that we can have a
    % set of weights by which to multiply the SVM performance values.
    weightedPatchImage = zeros(p.vNum,p.hNum);
    for ii = 1:length(uniqueValues)
        weight = sum(dataset == uniqueValues(ii)) / totalNumber;
        weightedPatchImage(uniqueValues(ii)) = weight;
    end

    %% Calculate performance
    %
    % We calculate the performance by mutliplying the patch weights with
    % their percent correct. Then, we extract thresholds for these
    % performance values.
    weightedPatchImage = weightedPatchImage(:);
    nonZeroProbIdx     = find(weightedPatchImage);
    weightedPatchImage = weightedPatchImage / sum(weightedPatchImage);
    for ii = 1:length(nonZeroProbIdx)
        thePatch = nonZeroProbIdx(ii);
        currentPatchData = loadModelData(allDirs{thePatch});
        results = results + (weightedPatchImage(thePatch) * currentPatchData);
    end
    
    % Extract the thresholds for each color direction.
    for ii = 1:4
        t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.71,...
                                            calcParams.illumLevels,calcParams.testingSetSize,...
                                            true,calcParams.colors{ii}); %#ok<SAGROW>
    end
    
    % Turn from cell into matrix. This allows for easier plotting later. We
    % also reorganize the matrix so that the color order is b, y, g, r.
    t = cell2mat(t);
    t = t(:,[1 4 2 3]);    
    perSubjectAggregateThresholds{subjectNumber} = t;
    
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
    d1 = subject{subjectNumber}.Constant{1};
    d2 = subject{subjectNumber}.Constant{2};
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
    
    % Plot a the thresholds along with the model predictions.
    if ~singlePlots && showPlots
        subplot(2,5,subjectNumber);
    end
    [perSubjectFittedThresholds{subjectNumber},perSubjectFittedNoiseLevel{subjectNumber}]...
        = plotAndFitThresholdsToRealData(pI,t,...
        [b y g r],'NoiseVector',calcParams.noiseLevels,'NewFigure',singlePlots,'CreatePlot',showPlots);
    perSubjectExperimentalThresholds{subjectNumber} = [b y g r];
    
    if showPlots
        theTitle = get(gca,'title');
        theTitle = theTitle.String;
        title(strrep(theTitle,'Data fitted at',[subjectId ',']));
        
        % Change the y-axis limit to be scaled to the range of the thresholds
        % to get a sense of the relative differences.
        if scaleAxes
            upperLimit = max([b y g r perSubjectFittedThresholds{subjectNumber}]) * 1.5; %#ok<*UNRCH>
            upperLimit = 10 * ceil(upperLimit / 10);
            ylim([0 upperLimit]);
        end
    end
    
    % Save the weighted thresholds along with the proper noise level at
    % which to interpolate the results.
    if savePerf
        itpN = perSubjectFittedNoiseLevel{subjectNumber};
        save([subjectId '-weightedPerf.mat'],'results','itpN');
    end
    
    clearvars t;
end

if ~singlePlots && showPlots
    st = suptitle('Constant');
    set(st,'FontSize',30);
end

%% Plot mean
meanExpThreshold   = mean(cell2mat(perSubjectExperimentalThresholds));
semExpThreshold    = std(cell2mat(perSubjectExperimentalThresholds))/sqrt(length(perSubjectExperimentalThresholds));
meanModelThreshold = mean(cell2mat(perSubjectFittedThresholds));
semModelThreshold  = std(cell2mat(perSubjectFittedThresholds))/sqrt(length(perSubjectFittedThresholds));

plotAndFitThresholdsToRealData(pI,meanModelThreshold,meanExpThreshold,...
    'ThresholdError',semModelThreshold,...
    'DataError',semExpThreshold,...
    'NoiseVector',calcParams.noiseLevels,'NewFigure',true,'CreatePlot',showPlots);

% Format plot
if showPlots
    ylim([0 20]);
    title(['Weighted Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
    disp(['Weighted Aggregate Fit ' num2str(mean(cell2mat(perSubjectFittedNoiseLevel)))]);
end

%% Calculate LSE
RMSE = zeros(length(perSubjectFittedThresholds),1);
for i = 1:length(perSubjectFittedThresholds)
    RMSE(i) = sqrt(sum((perSubjectFittedThresholds{i} - perSubjectExperimentalThresholds{i}).^2) / 4);
end

%% Save the data
if saveData
    save([saveFilename '.mat'],'perSubjectAggregateThresholds','perSubjectExperimentalThresholds',...
        'perSubjectFittedThresholds','perSubjectFittedNoiseLevel','RMSE');
end
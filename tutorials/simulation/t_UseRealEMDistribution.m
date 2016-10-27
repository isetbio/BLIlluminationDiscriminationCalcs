%% t_UseRealEMDistribution
%
% Uses a real EM Distrbution data file from the psychophysical experiments
% in order to come to a prediction of performance. The data is also saved
% at then end of the script so that we can have easy access for plotting!
% Note that this script requires you to have experimental data from our
% experiment available. 

% Please send an email to David Brainard (brainard@psych.upenn.edu).
%
% 8/04/16  xd  wrote it

clear; %close all; ieInit;
%% Some parameters
%
% If set to true, each subject fit get's it's own individual figure window.
% Otherwise, everything is plotted as a subplot on 1 figure.
singlePlots = true;

%% Subject ID's
% DON'T CHANGE
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';

%% Preallocate some space for data
%
% We save the aggregate thresholds, the fitted thresholds, and the
% experimental thresholds. This should be enough for any auxiliary plot we
% want to create.
perSubjectAggregateThresholds = cell(length(orderOfSubjects),1);
perSubjectFittedThresholds = cell(length(orderOfSubjects),1);
perSubjectExperimentalThresholds = cell(length(orderOfSubjects),1);

%% Calculation and plotting loop
if ~singlePlots
    figure('Position',[150 238 2265 1061]);
end

for subjectNumber = 1:length(orderOfSubjects)
    subjectId = orderOfSubjects{subjectNumber};
    
    %% Load the data
    %
    % We need to load the fixations from the experiment. These paths are
    % stored locally and may need to be changed depending on your setup.
    r1 = load(['/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Exp8ProcessedData/Exp8EMByScenePatches/' subjectId '-Constant-' num2str(1) '-EMInPatches.mat']);
    r2 = load(['/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Exp8ProcessedData/Exp8EMByScenePatches/' subjectId '-Constant-' num2str(2) '-EMInPatches.mat']);
    r1 = r1.resultData;
    r2 = r2.resultData;
    
    load(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'plotInfoMatConstant.mat'))
    load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')
    
    %% Load dummy data to preallocate results
    dummyData = loadModelData('SVM_Static_Isomerizations_Constant_1');
    result1 = zeros(size(dummyData));
    result2 = zeros(size(dummyData));
    results = zeros(size(dummyData));
    
    %% Put all the data into one matrix
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
        [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(thePatch)]);
        results = results + (weightedPatchImage(thePatch) * currentPatchData);
    end
    
    % Extract the thresholds for each color direction.
    for ii = 1:4
        t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
    end
    
    % Turn from cell into matrix. This allows for easier plotting later. We
    % also reorganize the matrix so that the color order is b, y, g, r.
    t = cell2mat(t);
    t = t(:,[1 4 2 3]);    
    perSubjectAggregateThresholds{subjectNumber} = t;
    
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
    perSubjectFittedThresholds{subjectNumber} = plotAndFitThresholdsToRealData(pI,t,[b y g r],'NoiseVector',0:3:30,'NewFigure',true);
    perSubjectExperimentalThresholds{subjectNumber} = [b y g r];
    theTitle = get(gca,'title');
    theTitle = theTitle.String;
    title(strrep(theTitle,'Data fitted at',[subjectId ',']));
    % FigureSave(subjectId,gcf,'pdf');
    clearvars t;
end

if ~singlePlots
    st = suptitle('Constant');
    set(st,'FontSize',30);
end
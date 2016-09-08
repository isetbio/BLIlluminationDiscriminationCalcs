%% t_UseRealEMDistributionMatchTrials
%
% Uses a real EM Distrbution data file from the psychophysical experiments
% in order to come to a prediction of performance. In this script, we will
% match by trial instead of taking the fixation distribution during the
% whole experiment.
%
% 8/04/16  xd  wrote it

clear; close all; ieInit;
%% Set some parameters
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';

figure('Position',[150 238 2265 1061]);
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
    
    trialDataFilename1 = sprintf('%s-Constant-1-Data.mat',subjectId);
    trialDataFilename2 = sprintf('%s-Constant-2-Data.mat',subjectId);
    t1 = load(fullfile('/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Exp8ReformattedTrialData',trialDataFilename1));
    t2 = load(fullfile('/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Exp8ReformattedTrialData',trialDataFilename2));
    t1 = t1.trialData;
    t2 = t2.trialData;
    
    %% Load dummy data to preallocate results
    dummyData = loadModelData('SVM_Static_Isomerizations_Constant_1');
    result1 = zeros(size(dummyData));
    result2 = zeros(size(dummyData));
     
    %% Loop over trials and allocate trial performance as necessary
    colorToIdxMap = containers.Map({'B' 'G' 'R' 'Y'},{1 2 3 4});
    countPerEntry = zeros(size(dummyData,1),size(dummyData,2));
    for tt = 1:size(t1,1)
        fixationPatches = [r1{tt,2:3}];
        colorIdx = colorToIdxMap(t1{tt,3});
        illumIdx = t1{tt,5};
        countPerEntry(colorIdx,illumIdx) = countPerEntry(colorIdx,illumIdx) + length(fixationPatches);
        for ii = 1:length(fixationPatches)
            [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(fixationPatches(ii))]);
            result1(colorIdx,illumIdx,:) = result1(colorIdx,illumIdx,:) + currentPatchData(colorIdx,illumIdx,:);
        end
    end
    result1 = result1 ./ repmat(countPerEntry,1,1,size(dummyData,3),size(dummyData,4));
    
    %% Find stimulus levels for each color direction and extract thresholds
    for ii = 1:colorToIdxMap.length
        colors = colorToIdxMap.keys;
        theColorDir = colors{ii};
        idxs = ~cellfun('isempty',strfind(t1(:,3),theColorDir));
        stimLevels = sort(unique([t1{idxs,5}]));
        data = squeeze(result1(ii,stimLevels,:,:));
        th1{ii} = multipleThresholdExtraction(data,70.9,stimLevels);
    end

    th1 = cell2mat(th1);
    th1 = th1(:,[1 4 2 3]);
    
    %% Loop over trials and allocate trial performance as necessary
    colorToIdxMap = containers.Map({'B' 'G' 'R' 'Y'},{1 2 3 4});
    countPerEntry = zeros(size(dummyData,1),size(dummyData,2));
    for tt = 1:size(t2,1)
        fixationPatches = [r2{tt,2:3}];
        colorIdx = colorToIdxMap(t2{tt,3});
        illumIdx = t2{tt,5};
        countPerEntry(colorIdx,illumIdx) = countPerEntry(colorIdx,illumIdx) + length(fixationPatches);
        for ii = 1:length(fixationPatches)
            [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(fixationPatches(ii))]);
            result2(colorIdx,illumIdx,:) = result2(colorIdx,illumIdx,:) + currentPatchData(colorIdx,illumIdx,:);
        end
    end
    result2 = result2 ./ repmat(countPerEntry,1,1,size(dummyData,3),size(dummyData,4));
    
    %% Find stimulus levels for each color direction and extract thresholds
    for ii = 1:colorToIdxMap.length
        colors = colorToIdxMap.keys;
        theColorDir = colors{ii};
        idxs = ~cellfun('isempty',strfind(t2(:,3),theColorDir));
        stimLevels = sort(unique([t2{idxs,5}]));
        data = squeeze(result2(ii,stimLevels,:,:));
        th2{ii} = multipleThresholdExtraction(data,70.9,stimLevels);
    end

    th2 = cell2mat(th2);
    th2 = th2(:,[1 4 2 3]);
    
    pI = createPlotInfoStruct;
    pI.xlabel = 'Gaussian Noise Levels';
    pI.ylabel = 'Stimulus Levels (\DeltaE)';
    pI.title  = 'Thresholds v Noise';
    
    % plotThresholdsAgainstNoise(pI,t,(0:3:30)');
    
    %% Get subject data
    %
    % We're only looking at Constant run data for now because that's all
    % that really works.
    subjectIdx = find(not(cellfun('isempty', strfind(orderOfSubjects,subjectId))));
    d1 = subject{subjectIdx}.Constant{1};
    d2 = subject{subjectIdx}.Constant{2};
    
    % Calculate run 1 results to fit.
    b = d1.Bluer.threshold;
    g = d1.Greener.threshold;
    r = d1.Redder.threshold;
    y = d1.Yellower.threshold;
    bs = d1.Bluer.std;
    gs = d1.Greener.std;
    rs = d1.Redder.std;
    ys = d1.Yellower.std;
    [th1,n1] = plotAndFitThresholdsToRealData(pI,th1,[b y g r],'DataError',[bs ys gs rs],'CreatePlot',false);
    
    % Calculate run 2 results to fit.
    b = d2.Bluer.threshold;
    g = d2.Greener.threshold;
    r = d2.Redder.threshold;
    y = d2.Yellower.threshold;
    bs = d2.Bluer.std;
    gs = d2.Greener.std;
    rs = d2.Redder.std;
    ys = d2.Yellower.std;
    [th2,n2] = plotAndFitThresholdsToRealData(pI,th2,[b y g r],'DataError',[bs ys gs rs],'CreatePlot',false);
    t = nanmean(cat(3,th1,th2),3);
    
    % Calculate mean threshold from experiment
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
    bs = 0.5*sqrt(d1.Bluer.std^2 + d2.Bluer.std^2);
    gs = 0.5*sqrt(d1.Greener.std^2 + d2.Greener.std^2);
    rs = 0.5*sqrt(d1.Redder.std^2 + d2.Redder.std^2);
    ys = 0.5*sqrt(d1.Yellower.std^2 + d2.Yellower.std^2);
    subplot(2,5,subjectNumber);
    plotAndFitThresholdsToRealData(pI,t,[b y g r],'DataError',[bs ys gs rs],'NoiseVector',nanmean([n1,n2]),'NewFigure',false);
    
    % FigureSave(subjectId,gcf,'pdf');
    clearvars th1 th2;
    Z{subjectIdx} = t;
end
t = suptitle('Constant');
set(t,'FontSize',30);
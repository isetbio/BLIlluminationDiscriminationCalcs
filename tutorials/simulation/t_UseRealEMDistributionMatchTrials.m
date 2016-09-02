%% t_UseRealEMDistributionMatchTrials
%
% Uses a real EM Distrbution data file from the psychophysical experiments
% in order to come to a prediction of performance.
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
    % We need to load the 
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
    
    subjectIdx = find(not(cellfun('isempty', strfind(orderOfSubjects,subjectId))));
    d1 = subject{subjectIdx}.Constant{1};
    d2 = subject{subjectIdx}.Constant{2};
    b = nanmean([d1.Bluer.threshold,d2.Bluer.threshold]);
    g = nanmean([d1.Greener.threshold,d2.Greener.threshold]);
    r = nanmean([d1.Redder.threshold,d2.Redder.threshold]);
    y = nanmean([d1.Yellower.threshold,d2.Yellower.threshold]);
    bs = 0.5*sqrt(d1.Bluer.std^2 + d2.Bluer.std^2);
    gs = 0.5*sqrt(d1.Greener.std^2 + d2.Greener.std^2);
    rs = 0.5*sqrt(d1.Redder.std^2 + d2.Redder.std^2);
    ys = 0.5*sqrt(d1.Yellower.std^2 + d2.Yellower.std^2);
    
        
    th1 = plotAndFitThresholdsToRealData(pI,th1,[b y g r],'DataError',[bs ys gs rs],'CreatePlot',false);
    th2 = plotAndFitThresholdsToRealData(pI,th2,[b y g r],'DataError',[bs ys gs rs],'CreatePlot',false);
    t = nanmean(cat(3,th1,th2),3);
    
%     b = d1.Bluer.threshold;
%     g = d1.Greener.threshold;
%     r = d1.Redder.threshold;
%     y = d1.Yellower.threshold;
%     bs = d1.Bluer.std;
%     gs = d1.Greener.std;
%     rs = d1.Redder.std;
%     ys = d1.Yellower.std;
    
    subplot(2,5,subjectNumber);
    hold on;
    figParams = BLIllumDiscrFigParams([],'FitThresholdToData');
    data = [b y g r];
    dataError = [bs ys gs rs];
    for ii = 1:length(data)
        % Because the horizontal lines on the error bar function scales with
        % the range of the data set (and for some reason the range is 0->data
        % if the data is a scalar) we will create a dummy data point so that
        % the horizontal lines look roughly the same size.
        if ii < 4
            dataPad = -4 + ii; dataPadErr = 0;
        else
            dataPad = []; dataPadErr = [];
        end
        errorbar([ii dataPad],[data(ii) dataPad],[dataError(ii) dataPadErr],figParams.markerType,'Color',figParams.colors{ii},...
            'MarkerFaceColor',figParams.colors{ii},'MarkerSize',figParams.markerSize,...
            'LineWidth',figParams.lineWidth);
    end
    fittedThresholdHandle = errorbar(1:length(data),t,[0 0 0 0],...
        figParams.modelMarkerType,'Color',figParams.modelMarkerColor,'MarkerSize',figParams.modelMarkerSize,...
        'MarkerFaceColor',figParams.modelMarkerColor,'LineWidth',figParams.lineWidth);
    ylim(figParams.ylimit);
    xlim(figParams.xlimit);
    
    theTitle = get(gca,'title');
    theTitle = theTitle.String;
    title(strrep(theTitle,'Data fitted at',[subjectId ',']));
    % FigureSave(subjectId,gcf,'pdf');
    clearvars th1 th2;
    Z{subjectIdx} = t;
end
t = suptitle('Constant');
set(t,'FontSize',30);

%% OLD
%     %% 
%     dataset      = [r1.resultData{2}(:);r1.resultData{3}(:);r2.resultData{2}(:);r2.resultData{3}(:)];
%     uniqueValues = unique(dataset);
%     totalNumber  = numel(dataset);
%     
%     weightedPatchImage = zeros(p.vNum,p.hNum);
%     for ii = 1:length(uniqueValues)
%         weight = sum(dataset == uniqueValues(ii)) / totalNumber;
%         weightedPatchImage(uniqueValues(ii)) = weight;
%     end

%     %%
%     weightedPatchImage = weightedPatchImage(:);
%     nonZeroProbIdx     = find(weightedPatchImage);
%     weightedPatchImage = weightedPatchImage / sum(weightedPatchImage);
%     for ii = 1:length(nonZeroProbIdx)
%         thePatch = nonZeroProbIdx(ii);
%         [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(thePatch)]);
%         results = results + (weightedPatchImage(thePatch) * currentPatchData);
%     end
    
%     for ii = 1:4
%         t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
%     end
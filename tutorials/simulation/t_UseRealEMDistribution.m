%% t_UseRealEMDistribution
%
% Uses a real EM Distrbution data file from the psychophysical experiments
% in order to come to a prediction of performance.
%
% 8/04/16  xd  wrote it

clear; %close all; ieInit;
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
    
    %% Load dummy data to preallocate results
    dummyData = loadModelData('SVM_Static_Isomerizations_Constant_1');
    result1 = zeros(size(dummyData));
    result2 = zeros(size(dummyData));
    results = zeros(size(dummyData));
    %% 
    dataset      = [r1{:,2} r1{:,3} r2{:,2} r2{:,3}];
    uniqueValues = unique(dataset);
    totalNumber  = numel(dataset);
    
    weightedPatchImage = zeros(p.vNum,p.hNum);
    for ii = 1:length(uniqueValues)
        weight = sum(dataset == uniqueValues(ii)) / totalNumber;
        weightedPatchImage(uniqueValues(ii)) = weight;
    end

    %%
    weightedPatchImage = weightedPatchImage(:);
    nonZeroProbIdx     = find(weightedPatchImage);
    weightedPatchImage = weightedPatchImage / sum(weightedPatchImage);
    for ii = 1:length(nonZeroProbIdx)
        thePatch = nonZeroProbIdx(ii);
        [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(thePatch)]);
        results = results + (weightedPatchImage(thePatch) * currentPatchData);
    end
    
    for ii = 1:4
        t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
    end

%     %% Loop over trials and allocate trial performance as necessary
%     colorToIdxMap = containers.Map({'B' 'G' 'R' 'Y'},{1 2 3 4});
%     countPerEntry = zeros(size(dummyData,1),size(dummyData,2));
%  
%     fixationPatches = [r2{:,2:3}];
%     for ii = 1:numel(fixationPatches)
%         [currentPatchData,cp] = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(fixationPatches(ii))]);
%         result2 = result2 + currentPatchData;
%     end
%     result2 = result2 ./ numel(fixationPatches);
%     
%     %% Find stimulus levels for each color direction and extract thresholds
%     for ii = 1:colorToIdxMap.length
%         stimLevels = 1:50;
%         data = squeeze(result2(ii,stimLevels,:,:));
%         t{ii} = multipleThresholdExtraction(data,70.9,stimLevels);
%     end

    t = cell2mat(t);
    t = t(:,[1 4 2 3]);    
    stimLevels = 1:50;
    pI = createPlotInfoStruct;
    pI.stimLevels = stimLevels;
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

%     b = d1.Bluer.threshold;
%     g = d1.Greener.threshold;
%     r = d1.Redder.threshold;
%     y = d1.Yellower.threshold;
%     bs = d1.Bluer.std;
%     gs = d1.Greener.std;
%     rs = d1.Redder.std;
%     ys = d1.Yellower.std;
    
    subplot(2,5,subjectNumber);
    Z{subjectNumber} = plotAndFitThresholdsToRealData(pI,t,[b y g r],'DataError',[bs ys gs rs],'NoiseVector',0:3:30,'NewFigure',false);
    theTitle = get(gca,'title');
    theTitle = theTitle.String;
    title(strrep(theTitle,'Data fitted at',[subjectId ',']));
    % FigureSave(subjectId,gcf,'pdf');
    clearvars t;
end
t = suptitle('Constant');
set(t,'FontSize',30);
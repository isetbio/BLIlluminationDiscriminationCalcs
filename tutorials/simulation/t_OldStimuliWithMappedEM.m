%% t_OldStimuliWithMappedEM
%
% Uses eye movements from experiment 8 to calculate an estimate of the
% older experimental results. The reasoning is that subjects perhaps look
% at the same relative spots in both experiments. The eye positions were
% scaled as the two stimuli are of different sizes.
%
% 8/16/15  xd  wrote it

clear; close all; ieInit; 
%% Set some parameters

% The order of the subjects in the data file.
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';

% Variables to decide which data set to use and what the title should.
modelTag = 'SVM_Static_Isomerizations_';
titleTag = 'Neutral';

%% Load all data
%
% We want to use the fixation data from the comparison intervals in all
% experiments/subjects. This will be used to generate a probability
% distribution of where the subjects are looking during an experiment.
load(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'plotInfoMatConstant_1deg.mat'))
theData = [];
for subjectNumber = 1:length(orderOfSubjects)
    for runNumber = 1:2
        subjectId = orderOfSubjects{subjectNumber};
        
        % The data file is stored locally on my computer. 
        load(['/Users/xiaomaoding/Desktop/Exp8ImageProcessingCodeTempLocation/Exp8ProcessedData/Exp8EMByScenePatchesOldStimuli/' subjectId '-Constant-' num2str(runNumber) '-EMInPatches.mat'])
        theData = [theData; resultData{2}(:);resultData{3}(:)]; %#ok<AGROW>
    end
end

%% Generate probabilities
%
% Get the unique patches so that we can calculate a probability
% distribution of which patches are most likely to be viewed.
uniqueValues = unique(theData);
totalNumber  = numel(theData);
weightedPatchImage = zeros(p.vNum,p.hNum);
for ii = 1:length(uniqueValues)
    weight = sum(theData == uniqueValues(ii)) / totalNumber;
    weightedPatchImage(uniqueValues(ii)) = weight;
end

%% Load dummy data
%
% This let's us pre-allocate a data matrix.
dummyData = loadModelData('SVM_Static_Isomerizations_1');
results = zeros(size(dummyData));

%% Simulate results using existing data
%
% Take the weighted average of performances using old model data. This is
% effectively the same thing as running the model using the given
% distributions (assuming that the model performances are stable).
weightedPatchImage = weightedPatchImage(:);
nonZeroProbIdx   = find(weightedPatchImage);
weightedPatchImage = weightedPatchImage / sum(weightedPatchImage);
for ii = 1:length(nonZeroProbIdx)
    thePatch = nonZeroProbIdx(ii);
    currentPatchData = loadModelData([modelTag num2str(thePatch)]);
    results = results + (weightedPatchImage(thePatch) * currentPatchData);
end

% Format the data into the way the function wants
for ii = 1:4
    t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
end
t = cell2mat(t);
t = t(:,[1 4 2 3]);

% Some plot things
pI = createPlotInfoStruct;
pI.stimLevels = 1:50;
pI.xlabel = 'Gaussian Noise Levels';
pI.ylabel = 'Stimulus Levels (\DeltaE)';
pI.title  = 'Thresholds v Noise';

%% Plot model v experimental thresholds
%
% Load experimental data. Then fit and plot best fits. Also replace title
% with something sensible.
load('EasyFormatExp5Data.mat');
plotAndFitThresholdsToRealData(pI,t,neutral([1 4 2 3]),'DataError',neutralSE([1 4 2 3]),'NoiseVector',0:3:30,'NewFigure',true,'NoiseLevel',9);
theTitle = get(gca,'title');
theTitle = strrep(theTitle.String,'Data fitted at',[titleTag ',']);
title(theTitle);
%% t_UseRealEMDistribution
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
runNumber = 1;

%% 

load(['/Users/xiaomaoding/Desktop/Exp8ImageProcessingCodeTempLocation/Exp8ProcessedData/Exp8EMByScenePatches/' subjectId '-Constant-' num2str(runNumber) '-EMInPatches.mat'])
load(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'plotInfoMatConstant.mat'))
load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')

%% 
dataset      = [resultData{2}(:);resultData{3}(:)];
uniqueValues = unique(dataset);
totalNumber  = numel(dataset);

weightedPatchImage = zeros(p.vNum,p.hNum);
for ii = 1:length(uniqueValues)
    weight = sum(dataset == uniqueValues(ii)) / totalNumber;
    weightedPatchImage(uniqueValues(ii)) = weight;
end

%%
dummyData = loadModelData('SVM_Static_Isomerizations_Constant_1');
results = zeros(size(dummyData));

%%
weightedPatchImage = weightedPatchImage(:);
nonZeroProbIdx   = find(weightedPatchImage);
weightedPatchImage = weightedPatchImage / sum(weightedPatchImage);
for ii = 1:length(nonZeroProbIdx)
    thePatch = nonZeroProbIdx(ii);

    currentPatchData = loadModelData(['SVM_Static_Isomerizations_Constant_' num2str(thePatch)]);
    
    results = results + (weightedPatchImage(thePatch) * currentPatchData);
end

for ii = 1:4
    t{ii} = multipleThresholdExtraction(squeeze(results(ii,:,:)),70.9);
end
t = cell2mat(t);

pI = createPlotInfoStruct;
pI.stimLevels = 1:50;
pI.xlabel = 'Gaussian Noise Levels';
pI.ylabel = 'Stimulus Levels (\DeltaE)';
pI.title  = 'Thresholds v Noise';

% plotThresholdsAgainstNoise(pI,t,(0:3:30)');

%% Get subject data

subjectIdx = find(not(cellfun('isempty', strfind(orderOfSubjects,subjectId))));
data = subject{subjectIdx}.Constant{runNumber};
b = data.Bluer.threshold;
g = data.Greener.threshold;
r = data.Redder.threshold;
y = data.Yellower.threshold;
bs = data.Bluer.std;
gs = data.Greener.std;
rs = data.Redder.std;
ys = data.Yellower.std;
subplot(2,5,subjectNumber);
plotAndFitThresholdsToRealData(pI,t,[b g r y],'DataError',[bs gs rs ys],'NoiseVector',0:3:30,'NewFigure',false);
theTitle = get(gca,'title');
theTitle = theTitle.String;
title(strrep(theTitle,'Data fitted at',[subjectId ',']));
clearvars t;
end
t = suptitle(['Constant run ' num2str(runNumber)]);
set(t,'FontSize',30);
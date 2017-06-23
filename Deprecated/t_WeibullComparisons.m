%% t_WeibullComparisons
%
% This script will compare the psychometric fits to the experimental data
% with the model fits to see if there are any qualitative differences in
% the prediction results.
% 
% 11/3/16  xd  wrote it

clear; close all;
%% Set parameters
%
% Choose which subject's data to plot.
subjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';
subject = subjects{10};
trialsPerBin = 10;
dataPath = '/Users/xiaomaoding/Documents/MATLAB/Exp8ImageProcessingCodeTempLocation/Constant/';

%% Load data
%
% Load and extract the trial data cell arrays.
r1 = load(fullfile(dataPath,subject,['/' subject '-Constant-1.mat']));
r2 = load(fullfile(dataPath,subject,['/' subject '-Constant-2.mat']));
r1 = r1.params.trialData;
r2 = r2.params.trialData;
load('/Users/xiaomaoding/Documents/stereoChromaticDiscriminationExperiment/IlluminantsInDeltaE.mat');

% Load model data
modelPath = '/Users/xiaomaoding/Documents/MATLAB/projects/Analysis/BLIlluminationDiscriminationCalcs/tutorials/simulation/WeightedPerformances';
m = load(fullfile(modelPath,[subject '-weightedPerf.mat']));
n = m.itpN;

% The interpolated noise level is also included in the .mat file. Here, we
% will interpolate between the performance results before calculating the
% thresholds.
lower = floor(n/5) + 1;
interp = true;
if n == 50
    interp = false;
end

m = squeeze(m.results(1,:,:,:));

if interp
    lowerVal = n/5 + 1 - lower;
    upperVal = 1 - lowerVal;
    m = lowerVal*squeeze(m(:,lower)) + upperVal*squeeze(m(:,lower + 1));
else
    m = squeeze(m(:,lower));
end

%% Extract blue trials and fit psychometric curve
%
% We only want the blue data. Concatenate the trials between the two
% experimental sessions into one cell array.
blue = cellfun(@(X) strcmp(X,'B'),r1(:,3));
r1 = r1(blue,:);
blue = cellfun(@(X) strcmp(X,'B'),r2(:,3));
r2 = r2(blue,:);

%% Sort the data
%
% Sort the data primarily by the stimulus level and secondarily by the
% staircase number.
total = [r1; r2];
stims = cell2mat(total(:,5));
sortby = cell2mat(total(:,[2,5]));
[~,idx] = sortrows(sortby,[2 1]);
stims = stims(idx);
total = total(idx,:);

%% Organize
%
% Organize the data vector for threshold calculation. I think the
% experimental code bins the results by averaging over n samples. This
% procedure is done here as well. The experiment code also uses the real
% delta E values, which is also done here.

% stimLevels = zeros(length(unique(stims)),1);
stimLevels = zeros(ceil(length(stims)/trialsPerBin),1);
responseCorrect = zeros(size(stimLevels));
trialCount = zeros(size(stimLevels));

stimMap = illuminantDistance{1}(2:end,2);

thisStim = 1;
resIdx = 1;
count = 0;
for ii = 1:size(total,1)
%     if thisStim ~= stims(ii)
    % Reset the count for every trialsPerBin number of trials
    if count == trialsPerBin
        resIdx = resIdx + 1;
        count = 0;
%         thisStim = stims(ii);
%         stimLevels(resIdx) = thisStim;
    end
    
    % Add the response. 1 = correct, 0 = incorrect.
    responseCorrect(resIdx) = responseCorrect(resIdx) + total{ii,6};
    trialCount(resIdx) = trialCount(resIdx) + 1;
    stimLevels(resIdx) = stimLevels(resIdx) + stimMap(stims(ii));
    count = count + 1;
end

% Get a percentage for plotting
responsePercent = responseCorrect ./ trialCount * 100;
stimLevels = stimLevels ./ trialCount;

%% Plot Weibull
% 
% Extract the threshold and also plot it.
[t,p] = singleThresholdExtraction(responseCorrect,70.71,stimLevels,trialCount,false);
pI = createPlotInfoStruct;
pI.stimLevels = stimLevels;
plotFitForSingleThreshold(pI,responsePercent,t,p);

[t,p] = singleThresholdExtraction(m);
plotFitForSingleThreshold(createPlotInfoStruct,m,t,p);
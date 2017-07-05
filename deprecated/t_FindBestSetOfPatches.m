%% t_FindBestSetOfPatches
%
% When using the old Euclidean distance classifier, a specific subset of
% patches resulted in a near perfect fit of model results to the data. It
% is possible that a similar subset(s) of patches exists in the SVM data.
% This would provide a bit of insight into which areas of the stimuli are
% "hot spots" and should be considered ROIs. A dilemna that occurs is
% whether to average the raw performance matrices or to average the
% extracted threshold values. In this script, we will do both. Note that we
% will be weighing the patches uniformly.
%
% While the ideal approach this is calculation may to test each and every
% partition of our set of patches, this is likely impossible. We have 398
% patches for the Constant stimuli. For reference, the number of partitions
% for a set of 100 values is 4.7585e+115. I do not know what the number of
% partitions for a set of 398 is, although Matlab says it is Inf, a likely
% number for all intensive purposes.  Therefore, instead of doing this the
% brute force way, we will iteratively remove patches from our set until
% our change in our fit metric is below some threshold.
%
% 8/30/16  xd  wrote it

clear; close all;
%% Set some parameters
deltaFitThreshold = 0.00075;

%% Preload all the data (saves lots of time)
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDList  = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),'SVM_Static_Isomerizations_Constant');

% Load dummy data to get size
thresholds = loadThresholdData(calcIDList{1},['Thresholds' calcIDList{1} '.mat']);
tSize = size(thresholds);

% Load full data set
allThresholds = zeros([length(calcIDList),tSize]);
for ii = 1:length(calcIDList)
    thresholds = loadThresholdData(calcIDList{ii},['Thresholds' calcIDList{ii} '.mat']);
    allThresholds(ii,:,:) = thresholds;
end

%% Load experimental data
load('/Users/Shared/Matlab/Experiments/Newcastle/stereoChromaticDiscriminationExperiment/analysis/FitThresholdsAllSubjectsExp8.mat')
d1 = cell2mat(subject);
d1 = cell2mat([d1(:).Constant]);
d2 = [d1(:).Bluer];
b  = nanmean([d2(:).threshold]);
d2 = [d1(:).Greener];
g  = nanmean([d2(:).threshold]);
d2 = [d1(:).Redder];
r  = nanmean([d2(:).threshold]);
d2 = [d1(:).Yellower];
y  = nanmean([d2(:).threshold]);
expThreshold = [b g r y];

%% Loop over all data and combinations (this may take a while)
mThreshold = squeeze(nanmean(allThresholds,1));

mDist = interpolateBestFitToData(mThreshold,expThreshold);
deltaFit = 1;

while deltaFit > deltaFitThreshold 
    maxDelta = 0;
    idxTrack = 1;
    for ii = 1:size(allThresholds,1)
        idx = ones(size(allThresholds,1),1);
        idx(ii) = 0;
        mT = squeeze(nanmean(allThresholds(idx>0,:,:),1));
        mD = interpolateBestFitToData(mT,expThreshold);
        
        if abs(mD-mDist) > maxDelta
            idxTrack = ii;
            maxDelta = abs(mD-mDist);
        end
    end
    
    allThresholds(idxTrack,:,:) = [];
    mThreshold = squeeze(nanmean(allThresholds,1));
    mDist = interpolateBestFitToData(mThreshold,expThreshold);
    deltaFit = maxDelta;
end

%% TODO
% Don't remove things that bring dist back up
% Track things that were removed




function distanceMetric = patchByPatchComparisonToData(NeutralFolder,NM1Folder,NM2Folder)
% patchByPatchComparisonToData(NeutralFolder,NM1Folder,NM2Folder)
%
% Does a patch wise comparison to find which patches match the experimental
% data the best.
%
% 7/21/16  xd  wrote it

%% Load experimental data
expDataPath = fileparts(fileparts(fileparts(mfilename('fullpath'))));
expDataPath = fullfile(expDataPath,'psychophysics','data','FitThresholdsAveragesExp5.mat');
data = load(expDataPath);
data = data.allSubjects;

% Organize thresholds into vectors in order b,g,r,y
NeutralExp = [data.meanMatchedBlue data.meanMatchedGreen data.meanMatchedRed data.meanMatchedYellow];
NM1Exp = [data.meanNonMatched1Blue data.meanNonMatched1Green data.meanNonMatched1Red data.meanNonMatched1Yellow];
NM2Exp = [data.meanNonMatched2Blue data.meanNonMatched2Green data.meanNonMatched2Red data.meanNonMatched2Yellow];

[~,NeutralExpRank] = sort(NeutralExp);
[~,NM1ExpRank] = sort(NM1Exp);
[~,NM2ExpRank] = sort(NM2Exp);

%% Loop over patches
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
NeutralList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),NeutralFolder);
NM1List = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),NM1Folder);
NM2List = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),NM2Folder);

%% Load dummy data to get size
dummyData = loadThresholdData(NeutralList{1},['Thresholds' NeutralList{1} '.mat']);
distanceMetric = zeros(length(NeutralList),3,size(dummyData,1));
for ii = 1:length(NeutralList)
    NeutralData = loadThresholdData(NeutralList{ii},['Thresholds' NeutralList{ii} '.mat']);
    NM1Data = loadThresholdData(NM1List{ii},['Thresholds' NM1List{ii} '.mat']);
    NM2Data = loadThresholdData(NM2List{ii},['Thresholds' NM2List{ii} '.mat']);
    
    % Set any rows containing NaN to all NaN
    NeutralData(any(isnan(NeutralData),2),:) = NaN;
    NM1Data(any(isnan(NM1Data),2),:) = NaN;
    NM2Data(any(isnan(NM2Data),2),:) = NaN;
    
    % Calculate difference from experimental
    NeutralDiff = NeutralData - repmat(NeutralExp,size(NeutralData,1),1);
    NM1Diff = NM1Data - repmat(NM1Exp,size(NM1Data,1),1);
    NM2Diff = NM2Data - repmat(NM2Exp,size(NM2Data,1),1);
    
    % Calculate distance??
    distanceMetric(ii,1,:) = sqrt(sum(NeutralDiff,2).^2);
    distanceMetric(ii,2,:) = sqrt(sum(NM1Diff,2).^2);
    distanceMetric(ii,3,:) = sqrt(sum(NM2Diff,2).^2);
    
    % Calculate rank
    [~,NeutralModelRank] = sort(NeutralData,2);
    [~,NM1ModelRank] = sort(NM1Data,2);
    [~,NM2ModelRank] = sort(NM2Data,2);
    
    NeutralRankEq = NeutralModelRank == repmat(NeutralExpRank,size(NeutralData,1),1);
    NM1RankEq = NM1ModelRank == repmat(NM1ExpRank,size(NM1Data,1),1);
    NM2RankEq = NM2ModelRank == repmat(NM2ExpRank,size(NM2Data,1),1);
    
    % Calculate weighted distance
    distanceMetric(ii,1,:) = squeeze(distanceMetric(ii,1,:)) .* (1 + sum(NeutralRankEq,2));
    distanceMetric(ii,2,:) = squeeze(distanceMetric(ii,2,:)) .* (1 + sum(NM1RankEq,2));
    distanceMetric(ii,3,:) = squeeze(distanceMetric(ii,3,:)) .* (1 + sum(NM2RankEq,2)); 
end

end


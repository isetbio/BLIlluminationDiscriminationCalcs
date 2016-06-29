function [meanThreshold, stdErr] = meanThresholdOverSamples(calcIDList,criterion)
% [meanThreshold, stdErr] = meanThresholdOverSamples(calcIDList)
% 
% Given a cell array of calcID strings, this function will calculate and
% return the mean thresholds and errors in the data. This function
% presumes that the selected calcID's were run across identical
% noise/stimulus level conditions. We only take the average over data
% points in which NaN does not appear at any entry.
%
% xd  6/23/16  wrote it

%% Initialize return variables to 0
% We'll load the first calcID to get how large our mean threshold variable
% needs to be.
dummyData =loadModelData(calcIDList{1});
meanThreshold = zeros(length(calcIDList),size(dummyData,3),size(dummyData,1));

%% Loop over calcIDList and do calculations
for ii = 1:length(calcIDList)
    currentData = loadModelData(calcIDList{ii});
    for jj = 1:size(currentData,1)
        currentThresholds = multipleThresholdExtraction(squeeze(currentData(jj,:,:)),criterion);
        meanThreshold(ii,:,jj) = currentThresholds; 
    end
end

% Count how many NaN there are in the matrix
validThresholds = meanThreshold > 0;
[~,c] = find(validThresholds == 0);
validThresholds(:,c) = false;
meanThreshold = meanThreshold .* double(int32(validThresholds));
stdErr = squeeze(nanstd(meanThreshold,[],1)/sqrt(length(calcIDList)));

% Set the NaN to 0 to calulcate mean
meanThreshold(~validThresholds) = 0;
meanThreshold = squeeze(mean(meanThreshold,1));
meanThreshold(meanThreshold == 0) = NaN;

end


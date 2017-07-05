function [meanThreshold,stdErr] = meanThresholdOverSamples(calcIDList,criterion)
% [meanThreshold,stdErr] = meanThresholdOverSamples(calcIDList,criterion)
%
% Given a cell array of calcID strings, this function will calculate and
% return the mean thresholds and errors in the data. This function
% presumes that the selected calcID's were run across identical
% noise/stimulus level conditions. We only take the average over data
% points in which NaN does not appear at any entry.
%
% Inputs:
%     calcIDList  -  list of calcIDStr's to average over
%     criterion   -  percent correct at which to extract threshold
%
% Outputs:
%     meanThreshold  -  the mean threshold over the calcIDStr's
%     stdErr         -  SEM for 'meanThreshold'
% 
% 6/23/16  xd  wrote it

%% Initialize return variables to 0
%
% We'll load the first calcID to get how large our mean threshold variable
% needs to be.
dummyData = loadModelData(calcIDList{1});
meanThreshold = zeros(length(calcIDList),max(size(dummyData,3),size(dummyData,4)),size(dummyData,1));
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

%% Loop over calcIDList and do calculations
for ii = 1:length(calcIDList)
    % Save the thresholds in the same folder
    saveFile = fullfile(analysisDir,'SimpleChooserData',calcIDList{ii},['Thresholds' calcIDList{ii} '.mat']);
    
    % Load file if it exists, otherwise calculate and save
    if exist(saveFile,'file')
        thresholds = loadThresholdData(calcIDList{ii},['Thresholds' calcIDList{ii} '.mat']);
        meanThreshold(ii,:,:) = thresholds;
    else
        currentData = loadModelData(calcIDList{ii});
        for jj = 1:size(currentData,1)
            currentThresholds = multipleThresholdExtraction(squeeze(currentData(jj,:,:)),criterion);
            meanThreshold(ii,:,jj) = currentThresholds;
        end

        thresholds = squeeze(meanThreshold(ii,:,:)); %#ok<NASGU>
        save(saveFile,'thresholds');
    end
end

% Count how many NaN there are in the matrix
validThresholds = meanThreshold > 0;
for ii  = 1:size(validThresholds,2)
    for jj = 1:size(validThresholds,3)
        colSum = sum(validThresholds(:,ii,jj));
        if colSum < 0.95 * size(validThresholds,1)
            validThresholds(:,ii,jj) = false;
        end
    end
end

% Calculate the mean and standard error to return
meanThreshold = meanThreshold .* double(int32(validThresholds));
meanThreshold(meanThreshold == 0) = NaN;
stdErr = squeeze(nanstd(meanThreshold,[],1)/sqrt(length(calcIDList)));

meanThreshold = squeeze(nanmean(meanThreshold,1));

end


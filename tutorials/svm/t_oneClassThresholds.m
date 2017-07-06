%% t_oneClassThresholds
%
%
%
% 9/27/16  xd  wrote it

clear; %close all;
%% Generate probabilities
orderOfSubjects = {'azm','bmj', 'vle', 'vvu', 'idh','hul','ijj','eom','dtm','ktv'}';
theData = [];
for subjectNumber = 1:length(orderOfSubjects)
    for runNumber = 1:2
        subjectId = orderOfSubjects{subjectNumber};
        
        % The data file is stored locally on my computer. 
        load(['1deg EM/' subjectId '-Constant-' num2str(runNumber) '-EMInPatches.mat'])
        theData = [theData; resultData{2}(:);resultData{3}(:)]; %#ok<AGROW>
    end
end

%% Calc thresholds
folderToLoad = 'OneClass_Constant';
f = getFilenamesInDirectory(folderToLoad);

% Take weighted mean
uniqueValues = unique(theData);
totalNumber  = numel(theData);
weightedPatchImage = zeros(length(f),1);
% for ii = 1:length(uniqueValues)
%     weight = sum(theData == uniqueValues(ii)) / totalNumber;
%     weightedPatchImage(uniqueValues(ii)) = weight;
% end

% weighteMeanThreshold = sum(data .* repmat(weightedPatchImage,1,4));
% weightedPatchImage = (weightedPatchImage > 0) / sum(weightedPatchImage >0);
weightedPatchImage(:) = 1/length(f);
%
data = zeros(4,50);
for ii = 1:length(f)
    theCurrentData = load(fullfile(folderToLoad,f{ii}));
    theCurrentData = theCurrentData.data;
    data = data + weightedPatchImage(ii) * theCurrentData;
    fprintf('%d out of %d trials done\n',ii,length(f));
%     close all;
end

%% 
t = zeros(1,4);
colors = {'blue' 'green' 'red' 'yellow'};
for ii = 1:4
t(ii) = singleThresholdExtraction(data(ii,:)*100,70.71,1:50,1000,true,colors{ii});
end

%% 
figure;
plot(1:4,t,'ko','MarkerSize',20,'MarkerFaceColor','k');
ylim([0 25]);
xlim([0 5]);
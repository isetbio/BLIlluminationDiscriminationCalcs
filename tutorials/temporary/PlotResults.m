%% load
clear;
dataToLoad = 'ClassifierAnalysis_250_250_std.mat';
dataPath = fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'ClassifierComparisons');
load(fullfile(dataPath,dataToLoad));
allData = {NNpercentCorrect, DApercentCorrect, SVMpercentCorrect};
thresholdToExtract = 5; saveThresholds = false;

%% Plot
ColorMapping = containers.Map({'Blue' 'Green' 'Yellow' 'Red'},{'b.-' 'g.-' 'y.-' 'r.-'});

cl = {'NN' 'DA' 'SVM'};
paramsFree = [1,1,0,0];
criterion = 0.709;
stimLevels = 1:1:50;
outOfNum = repmat(100, 1, 50);
numKValue = 10;
paramsValueEst = [10 1 0.5 0];
PF = @PAL_Weibull;

options = optimset('fminsearch');
options.TolFun = 1e-09;
options.MaxFunEvals = 10000 * 100;
options.MaxIter = 500*100;

extractedThresholds = zeros(4,1);

figure;
for kk = 1:3
    subplot(1,3,kk);
    hold on;
    title(cl{kk});
    dataset = allData{kk};
    for ii = 1:length(Colors)
        threshold = zeros(numKValue, 1);
        paramsValues = zeros(numKValue, 4);
        data = dataset(:,:,ii);
        for jj = 1:numKValue
            [paramsValues(jj,:)] = PAL_PFML_Fit(stimLevels', data(:,jj), outOfNum',  paramsValueEst, paramsFree, PF, 'SearchOptions', options);
            threshold(jj) = PF(paramsValues(jj,:), criterion, 'inverse');
        end
        
        % Pick out the target of extraction
        if kk == 1
            extractedThresholds(ii) = threshold(thresholdToExtract);
            if ii == 4, plot([thresholdToExtract thresholdToExtract], [0 50], 'k'); end
        end
        
        plot(1:10, threshold, ColorMapping(Colors{ii}), 'markersize', 35);
    end
    ylim([0 50]);
    xlabel('Noise Factor');
    ylabel('Threshold');
    axis square;
end
suptitle(strrep(dataToLoad,'_','\_'));

if saveThresholds, save([dataToLoad(1:end-4) 'ExtThresh.mat'],'extractedThresholds','Colors'); end

%% Visualize the PCA's
stimLevelToPlot = [1,10,25,50];
noiseLevel = 1;
PC1 = 1;
PC2 = 2;
PCADataSize = size(pcaData{1,1,1}.score,1);

% Find the min and max of the PCA projections so we can set the axis limits
% programmatically.
pcaMinPC1 = cell2mat(cellfun(@(X)min(X.score(:,PC1)),pcaData,'uniformOutput',false));
pcaMaxPC1 = cell2mat(cellfun(@(X)max(X.score(:,PC1)),pcaData,'uniformOutput',false));
pcaMinPC2 = cell2mat(cellfun(@(X)min(X.score(:,PC2)),pcaData,'uniformOutput',false));
pcaMaxPC2 = cell2mat(cellfun(@(X)max(X.score(:,PC2)),pcaData,'uniformOutput',false));

xlimits = max(abs([pcaMinPC1(:);pcaMaxPC1(:)]));
ylimits = max(abs([pcaMinPC2(:);pcaMaxPC2(:)]));

figure;
for ii = 1:length(Colors)
    for jj = 1:length(stimLevelToPlot)
        subplot(length(stimLevelToPlot),length(Colors), (jj-1) * 4 + (ii - 1) + 1);
        hold on;
        dataToPlot = pcaData{ii,stimLevelToPlot(jj),noiseLevel};
        plot(dataToPlot.score([1:PCADataSize/4,PCADataSize/2+1:PCADataSize/4*3],PC1), dataToPlot.score([1:PCADataSize/4,PCADataSize/2+1:PCADataSize/4*3],PC2), 'go');
        plot(dataToPlot.score([PCADataSize/4+1:PCADataSize/2,PCADataSize/4*3+1:PCADataSize],PC1), dataToPlot.score([PCADataSize/4+1:PCADataSize/2,PCADataSize/4*3+1:PCADataSize],PC2), 'rx');
        title(Colors{ii});
%         xlim([-100 100]);
%         ylim([-20 20]);

        xlim(1.1*[-xlimits xlimits]);
        ylim(1.1*[-ylimits ylimits]);
        
        xlabel('Component 1');
        ylabel('Component 2');
        axis square
    end
end
suptitle(strrep(dataToLoad,'_','\_'));
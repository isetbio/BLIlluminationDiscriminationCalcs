% PlotResults
% 
% This function was written to be used in conjunction with
% ComparingClassifiersWithData. This is not guaranteed to work with data
% generated through other means.

%% Load data
clear;

% dataToLoad specifies the file name(s) to load.
dataToLoad = {'ClassifierAnalysis_100_100_std_NM2_Mean.mat' 'ClassifierAnalysis_500_500_std_NM1_Mean.mat' ...
    'ClassifierAnalysis_500_500_std_Neutral_Mean.mat'};

% This variable determines the INDEX of the threshold to extract. That is,
% if the noise levels are [1 3 5], then setting the value to 2 will extract
% the thresholds for noise level 3.
thresholdToExtract = [3 3 6]; saveThresholds = false;

%% Plot

% DO NOT TOUCH THESE VARIABLES. These are settings that are supposed to be
% constant and representative of experimental conditions and/or the
% organizational structure of the plotting code.
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

% Actual code to plot the data
for nn = 1:length(dataToLoad)
    % Load and format the data appropriately
    dataPath = fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'ClassifierComparisons');
    load(fullfile(dataPath,dataToLoad{nn}));
    allData = {NNpercentCorrect, DApercentCorrect, SVMpercentCorrect};
   
    % Check for meta-data related to the calculation
    if ~exist('NoiseSteps','var') || ~exist('Colors','var') , error('Faulty dataset! Missing metadata.'); end
    
    extractedThresholds = zeros(4,3);
    
    figure;
    for kk = 1:3
        subplot(1,3,kk);
        hold on;
        title(cl{kk});
        dataset = allData{kk};
        tN = thresholdToExtract(kk);
        for ii = 1:length(Colors)
            threshold = zeros(numKValue, 1);
            paramsValues = zeros(numKValue, 4);
            data = dataset(:,:,ii);
            for jj = 1:numKValue
                [paramsValues(jj,:)] = PAL_PFML_Fit(stimLevels', data(:,jj), outOfNum',  paramsValueEst, paramsFree, PF, 'SearchOptions', options);
                threshold(jj) = PF(paramsValues(jj,:), criterion, 'inverse');
            end
            
            % Pick out the target of extraction
            extractedThresholds(ii,kk) = threshold(tN);
            if ii == 4, plot([NoiseSteps(tN) NoiseSteps(tN)], [0 50], 'k'); end
            
            plotIdx = threshold > 0.001; % Float equality check
            plot(NoiseSteps(plotIdx), threshold(plotIdx), ColorMapping(Colors{ii}), 'markersize', 35);
        end
        plot([0 NoiseSteps(end) + 1], [10 10], 'k--');
        ylim([0 50]);
        xlim([0 NoiseSteps(end) + 1]);
        xlabel('Noise Factor');
        ylabel('Threshold');
        axis square;
    end
    suplabel(strrep(dataToLoad{nn},'_','\_'), 't');
    
    if saveThresholds, save([dataToLoad(1:end-4) 'ExtThresh.mat'],'extractedThresholds','Colors'); end
end
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
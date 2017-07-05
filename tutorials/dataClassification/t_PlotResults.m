%% t_PlotResults
% 
% This function was written to be used in conjunction with
% ComparingClassifiersWithData. This is not guaranteed to work with data
% generated through other means (due to formatting).
%
% 6/XX/16  xd  wrote it

%% Load data
clear; %close all;

% dataToLoad specifies the file name(s) to load.
dataToLoad = {'ClassifierAnalysis_1000_1000_std_Neutral_NewOI'};

savePlots = false;

%% Plot

% DO NOT TOUCH THESE VARIABLES. These are settings that are supposed to be
% constant and representative of experimental conditions and/or the
% organizational structure of the plotting code.
ColorMapping = containers.Map({'Blue' 'Green' 'Yellow' 'Red'},{'b.-' 'g.-' 'y.-' 'r.-'});

cl = {'kNN' 'DA' 'SVM'};
stimLevels = 1:2:50;
criterion  = 70.71;

tN = zeros(3,1);
% Actual code to plot the data
for nn = 1:length(dataToLoad)
    % Load and format the data appropriately
    dataPath = fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'ClassifierComparisons');
    load(fullfile(dataPath,dataToLoad{nn}));
    allData = {NNpercentCorrect, DApercentCorrect, SVMpercentCorrect};
   
    % Check for meta-data related to the calculation
    if ~exist('noiseSteps','var') || ~exist('colors','var') , error('Faulty dataset! Missing metadata.'); end
    extractedThresholds = zeros(4,3);

    figure('Position',[205 617 1698 538]);
    for kk = 1:length(cl)
        subplot(1,3,kk);
        hold on;
        
        dataset = allData{kk};
        for ii = 1:length(colors)
            thisData = dataset(:,:,ii);
            thisData(thisData(:,1)==0,:) = [];
            thresholds = multipleThresholdExtraction(thisData,criterion,stimLevels);
            plot(noiseSteps, thresholds, ColorMapping(colors{ii}), 'markersize', 35);
        end
        plot([0 noiseSteps(end) + 1], [10 10], 'k--');
        ylim([0 50]);
        xlim([0 noiseSteps(end) + 1]);
        xlabel('Noise Factor');
        ylabel('Threshold');
        title(cl{kk});
        axis square;
    end
    st = suptitle(strrep(dataToLoad{nn},'_','\_'));
    set(st,'FontSize', 30);
    
    % Save the plot if desired
    if savePlots, FigureSave(fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'Plots',dataToLoad{nn}),gcf,'pdf'); end
end

%% MAKE LOOP YAY PLEASE
%% Visualize the PCA's 
% Load and format the data appropriately
% dataPath = fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'ClassifierComparisons');
% load(fullfile(dataPath,dataToLoad{1}));
% 
% stimLevelToPlot = [1,10,25,50];
% noiseLevel = 1;
% PC1 = 1;
% PC2 = 2;
% PCADataSize = size(pcaData{1,1,1}.score,1);
% 
% % Find the min and max of the PCA projections so we can set the axis limits
% % programmatically.
% pcaMinPC1 = cell2mat(cellfun(@(X)min(X.score(:,PC1)),pcaData,'uniformOutput',false));
% pcaMaxPC1 = cell2mat(cellfun(@(X)max(X.score(:,PC1)),pcaData,'uniformOutput',false));
% pcaMinPC2 = cell2mat(cellfun(@(X)min(X.score(:,PC2)),pcaData,'uniformOutput',false));
% pcaMaxPC2 = cell2mat(cellfun(@(X)max(X.score(:,PC2)),pcaData,'uniformOutput',false));
% 
% xlimits = max(abs([pcaMinPC1(:);pcaMaxPC1(:)]));
% ylimits = max(abs([pcaMinPC2(:);pcaMaxPC2(:)]));
% 
% figure;
% for ii = 1:length(Colors)
%     for jj = 1:length(stimLevelToPlot)
%         subplot(length(stimLevelToPlot),length(Colors), (jj-1) * 4 + (ii - 1) + 1);
%         hold on;
%         dataToPlot = pcaData{ii,stimLevelToPlot(jj),noiseLevel};
%         plot(dataToPlot.score([1:PCADataSize/4,PCADataSize/2+1:PCADataSize/4*3],PC1), dataToPlot.score([1:PCADataSize/4,PCADataSize/2+1:PCADataSize/4*3],PC2), 'go');
%         plot(dataToPlot.score([PCADataSize/4+1:PCADataSize/2,PCADataSize/4*3+1:PCADataSize],PC1), dataToPlot.score([PCADataSize/4+1:PCADataSize/2,PCADataSize/4*3+1:PCADataSize],PC2), 'rx');
%         
%         if isfield(dataToPlot, 'decisionBoundary')
%             plot(1000*[0 dataToPlot.decisionBoundary(1)],1000*[0 dataToPlot.decisionBoundary(2)], 'k');
%         end
%         
%         title(Colors{ii});
% 
%         xlim(1.1*[-xlimits xlimits]);
%         ylim(1.1*[-ylimits ylimits]);
%         
%         xlabel('Component 1');
%         ylabel('Component 2');
%         axis square
%     end
% end
% suptitle(strrep(dataToLoad,'_','\_'));
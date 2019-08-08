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
    if (exist('suptitle','file'))
    	st = suptitle(strrep(dataToLoad{nn},'_','\_'));
    	set(st,'FontSize', 30);
    end
    
    % Save the plot if desired
    if savePlots, FigureSave(fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'Plots',dataToLoad{nn}),gcf,'pdf'); end
end

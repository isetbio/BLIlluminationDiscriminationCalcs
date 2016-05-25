%% load
clear;
dataPath = fullfile(getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir'), 'ClassifierComparisons');
load(fullfile(dataPath,'ClassiferAnalysis_100_100_std.mat'));
allData = {NNpercentCorrect, DApercentCorrect, SVMpercentCorrect};
PCADataSize = 200;

%% Plot
plotColors = {'b.-' 'g.-' 'y.-' 'r.-'};
Colors = {'blue' 'green' 'yellow' 'red'};
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
        
        plot(1:10, threshold, plotColors{ii}, 'markersize', 35);
    end
    ylim([0 40]);
    xlabel('Noise Factor');
    ylabel('Threshold');
    axis square;
end

%% Visualize the PCA's
stimLevelToPlot = [1,10,25,50];
noiseLevel = 1;
PC1 = 1;
PC2 = 2;

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
        xlabel('Component 1');
        ylabel('Component 2');
        axis square
    end
end
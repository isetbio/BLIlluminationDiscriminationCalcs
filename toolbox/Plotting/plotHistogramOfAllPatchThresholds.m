function plotHistogramOfAllPatchThresholds(calcIDStr)
% plotHistogramOfAllPatchThresholds(calcIDStr)
% 
% Plots histograms of the thresholds (for all patches) against noise
% levels. Each subplot contains threshold histograms for all 4 color
% directions for a particular noise level.  Noise levels with >90% NaN
% for thresholds for any color direction across the patches will be
% excluded. 
%
% Input:
%     calcIDStr  -  name of calculation to plot. Since this function plots
%                   many patches, do NOT include the number label at the
%                   end of the name
% 
% 7/18/16  xd  wrote it

%% Load file names
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
[~,calcParams] = loadModelData(calcIDList{1});

%% Aggregate the threshold data
%
% Allocate a data matrix to aggregate the data. It is in the format of
% [color noiselevel calcID]. This way, we can pull out data to plot as
% desired.
aggregateData = zeros(length(calcParams.colors),length(calcParams.KgLevels),length(calcIDList));
for ii = 1:length(calcIDList)
    theThreshold = loadThresholdData(calcIDList{ii},['Thresholds' calcIDList{ii} '.mat']);
    if ii == 54
        pause(1);
    end
    aggregateData(:,:,ii) = theThreshold';
end

% Decide what data to NOT plot by checking for >90% NaN for conditions
% across the first two dimensions of the aggregateData matrix.
findLotsOfNaNs = @(A,B) sum(isnan(A),3) > 0.5*length(calcIDList);
doNotPlot = bsxfun(findLotsOfNaNs,aggregateData,zeros(size(aggregateData)));
doNotPlot = any(doNotPlot);
numSubplots = sum(~doNotPlot);
startOffSet = find(doNotPlot,1,'last');

%% Plot
figParams = BLIllumDiscrFigParams([],'ThresholdHistogram');
figure('Position',[100 100 figParams.subplotsize*ceil(numSubplots/2) figParams.subplotsize*2]);
for ii = 1:numSubplots
    subplot(2,ceil(numSubplots/2),ii); hold on;
    numOfSamplesForLegend = zeros(4,1);
    for jj = 1:4
        % Get data to plot and remove NaN's
        thisData = aggregateData(jj,ii+startOffSet,:);
        thisData = thisData(~isnan(thisData));
        
        % Plot data and track down how many samples there were
        histogram(thisData,figParams.binNum,'FaceColor',figParams.faceColors{jj});
        numOfSamplesForLegend(jj) = length(thisData);
    end
    legend(strcat('N= ',num2str(numOfSamplesForLegend)));
    
    % Formatting stuff
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    axis square; grid on;
    
    xlabel('Threshold','FontSize',figParams.labelFontSize);
    ylabel('Num of Occurrences','FontSize',figParams.labelFontSize);
    title(['Noise Level: ' num2str(calcParams.KgLevels(ii+startOffSet))],'FontSize',figParams.titleFontSize);
end

h = findobj(gcf,'type','axes');
set(h,'XLim',figParams.xlim);
maxY = max(reshape(cell2mat(get(h,'YLim')),[],1));
set(h,'YLim',[0 maxY+2]);

end


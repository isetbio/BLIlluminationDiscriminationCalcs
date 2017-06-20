function thresholds = plotThresholdForMeanPerformance(calcIDStr,plot,criterion)
% threshold = plotThresholdForMeanPerformance(calcIDStr,plot,criterion)
%
% Instead of taking the mean over a set of thresholds, we can also
% calculate the mean performance over a set of patches. Then, using this
% mean performance we extract a single thresold.
%
% 10/27/16  xd  wrote it.

if notDefined('plot'), plot = true; end
if notDefined('criterion'), criterion = 70.71; end

%% Load and calculate mean thresholds
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDList  = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
[dummyData,calcParams] = loadModelData(calcIDList{1});

%% Find average performance
avgPerformance = zeros(size(dummyData));
for ii = 1:length(calcIDList)
    avgPerformance = avgPerformance + loadModelData(calcIDList{ii});
end
avgPerformance = avgPerformance / length(calcIDList);

%% Extract thresholds
thresholds = zeros(size(avgPerformance,4),size(avgPerformance,1));
for ii = 1:size(thresholds,2)
    thresholds(:,ii) = multipleThresholdExtraction(squeeze(avgPerformance(ii,:,:,:)),...
                                                   criterion, calcParams.illumLevels,...
                                                   calcParams.testingSetSize,...
                                                   true, calcParams.colors{ii});
end

% Remove negatives and replace with NaN's
thresholds(thresholds < 0) = nan;

%% Do plotting
if plot
    p = createPlotInfoStruct;
    p.title = 'Aggregate Thresholds';
    p.xlabel = 'Noise level';
    p.ylabel = 'Stimulus Level (\DeltaE)';
    plotThresholdsAgainstNoise(p,thresholds,calcParams.noiseLevels');
    ylim([calcParams.illumLevels(1) calcParams.illumLevels(end)]);
end

end


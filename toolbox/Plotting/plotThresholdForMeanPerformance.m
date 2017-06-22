function thresholds = plotThresholdForMeanPerformance(calcIDStr,varargin)
% threshold = plotThresholdForMeanPerformance(calcIDStr,varargin)
%
% Instead of taking the mean over a set of thresholds, we can also
% calculate the mean performance over a set of patches. Then, using this
% mean performance we extract a single set of thresolds.
%
% Inputs:
%     calcIDStr  -  shared label amongst a set of calculations
% {ordered optional}
%     plot       -  whether to plot the results (default = true)
%     criterion  -  what value to extract thresholds at (default = 70.71)
%     useTrueDE  -  use real illumination step size values (default = true)
%
% Outputs:
%     thresholds  -  calculated mean thresholds in a MxN matrix
%
% 10/27/16  xd  wrote it.

p = inputParser;
p.addOptional('plot',true,@islogical);
p.addOptional('criterion',70.71,@isnumeric);
p.addOptional('useTrueDE',true,@islogical);
p.parse(varargin{:});

plot = p.Results.plot;
criterion = p.Results.criterion;
useTrueDE = p.Results.useTrueDE;

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
                                                   criterion,calcParams.illumLevels,...
                                                   calcParams.testingSetSize,...
                                                   useTrueDE,calcParams.colors{ii});
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


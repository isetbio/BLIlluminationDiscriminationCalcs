function plotAllThresholds(calcIDStr,varargin)
% plotAllThresholds(calcParams)
%
% This function takes in a calcParams struct and attempts to plot the data
% associated with the calcID. If the data does exist in the location (set
% in preferences), then nothing will be plotted.
%
% xd  6/22/16  wrote it

%% Setup the input parser
% If the simulation was run across both Poisson and Gaussian noise, we
% might want to have a specific combination of noise indices that we want
% to plot. The default assumption is 1x Poisson noise and all Gaussian
% noise. Specify the index of 1 Noise Type and leave the other as 0, in the
% format [Poisson Gaussian].
parser = inputParser;
parser.addParameter('NoiseIndex', [1 0], @isnumeric);
parser.parse(varargin{:});

%% Load the data and calcParams here
[data,calcParams] = loadModelData(calcIDStr);


if isempty(loadChooserData(calcIDStr,['Thresholds' calcIDStr '.mat']))
    %% Format data
    % The data will be stored in a 4D matrix (depending on what type of
    % noise used for the simulation). The first index will represent the color,
    % so we should take each slice of the matrix and format accordingly.
    formattedData = cell(length(calcParams.colors),1);
    for ii = 1:length(calcParams.colors)
        currentDataToFormat = data(ii,:,:,:);
        if parser.Results.NoiseIndex(1) ~= 0
            formattedData{ii} = squeeze(currentDataToFormat(:,:,parser.Results.NoiseIndex(1),:));
        else
            formattedData{ii} = squeeze(currentDataToFormat(:,:,:,parser.Results.NoiseIndex(2)));
        end
    end
    
    %% Plot
    plotInfo = createPlotInfoStruct;
    plotInfo.stimLevels = calcParams.stimLevels;
    plotInfo.colors = calcParams.plotColor;
    plotInfo.xlabel = sprintf('%s Noise Levels',subsref({'Poisson' 'Gaussian'},struct('type','{}','subs',{{find(parser.Results.NoiseIndex==0,1)}})));
    plotInfo.ylabel = 'Stimulus Levels (\DeltaE)';
    plotInfo.title  = ['Thresholds v Noise, ' calcParams.calcIDStr];
    
    % Once the data has been nicely formatted, we can extract the thresholds.
    thresholds = zeros(size(formattedData{1},2),length(calcParams.colors));
    for ii = 1:size(thresholds,2)
        thresholds(:,ii) = multipleThresholdExtraction(formattedData{ii},plotInfo.criterion);
    end
    
    % Save the thresholds in the same folder
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    saveFile = fullfile(analysisDir,'SimpleChooserData',calcIDStr,['Thresholds' calcIDStr '.mat']);
    if ~exist(saveFile,'file')
        save(saveFile,'thresholds');
    end
end

% Do actual plotting in this function
plotThresholdsAgainstNoise(plotInfo,thresholds,calcParams.noiseLevels(:));

end


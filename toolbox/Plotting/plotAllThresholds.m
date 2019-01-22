function thresholds = plotAllThresholds(calcIDStr,varargin)
% plotAllThresholds(calcIDStr,varargin)
%
% This function takes in a calcParams struct and attempts to plot the data
% associated with the calcID. If the data does not exist in the location
% (set in preferences), then nothing will be plotted.
%
% Inputs:
%     calcIDStr  -  which threshold data to plot
% {name-value pairs}
%     'NoiseIndex'  -  whether to plot as a function of Poisson or Gaussian 
%                      noise (default = [1 0], i.e. Gaussian)
%     'Reset'       -  whether to recalculate the fits if save threshold
%                      data is already present (default = false)
%     'UseTrueDE'   -  whether to use real or nominal illumantion step
%                      sizes (default = true)
%
% 6/22/16  xd  wrote it

%% Setup the input parser
%
% If the simulation was run across both Poisson and Gaussian noise, we
% might want to have a specific combination of noise indices that we want
% to plot. The default assumption is 1x Poisson noise and all Gaussian
% noise. Specify the index of 1 Noise Type and leave the other as 0, in the
% format [Poisson Gaussian].
p = inputParser;
p.addRequired('calcIDStr',@ischar);
p.addParameter('NoiseIndex',[1 0],@isnumeric);
p.addParameter('Reset',true,@islogical);
p.addParameter('UseTrueDE',true,@islogical);
p.parse(calcIDStr,varargin{:});

%% Load the data and calcParams here
[data,calcParams] = loadModelData(calcIDStr);

% PlotInfo things
figParams = BLIllumDiscrFigParams;
plotInfo  = createPlotInfoStruct;
plotInfo.stimLevels = calcParams.stimLevels;
plotInfo.colors = figParams.colors;
plotInfo.xlabel = sprintf('%s Noise Levels',subsref({'Poisson' 'Gaussian'},struct('type','{}','subs',{{find(p.Results.NoiseIndex==0,1)}})));
plotInfo.ylabel = 'Stimulus Levels (\DeltaE)';
plotInfo.title  = ['Thresholds v Noise, ' calcParams.calcIDStr];
thresholds = loadThresholdData(calcIDStr,['Thresholds' calcIDStr '.mat']);

if isempty(thresholds) || p.Results.Reset
    %% Format data
    %
    % The data will be stored in a 4D matrix (depending on what type of
    % noise used for the simulation). The first index will represent the color,
    % so we should take each slice of the matrix and format accordingly.
    formattedData = cell(length(calcParams.colors),1);
    for ii = 1:length(calcParams.colors)
        currentDataToFormat = data(ii,:,:,:);
        if p.Results.NoiseIndex(1) ~= 0
            formattedData{ii} = squeeze(currentDataToFormat(:,:,p.Results.NoiseIndex(1),:));
        else
            formattedData{ii} = squeeze(currentDataToFormat(:,:,:,p.Results.NoiseIndex(2)));
        end
    end

    % Once the data has been nicely formatted, we can extract the thresholds.
    thresholds = zeros(size(formattedData{1},2),length(calcParams.colors));
    for ii = 1:size(thresholds,2)
        thresholds(:,ii) = multipleThresholdExtraction(formattedData{ii},...
                                                       plotInfo.criterion,calcParams.stimLevels,...
                                                       calcParams.testingSetSize,p.Results.UseTrueDE,...
                                                       calcParams.colors{ii});
    end
    
    % Save the thresholds in the same folder. This allows us to just load
    % the saved data next time instead of having to redo the calculation.
    % This saves time for things like calculating the mean, which requires
    % us to gather the threshold for many patches.
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    saveFile = fullfile(analysisDir,'SimpleChooserData',calcIDStr,['Thresholds' calcIDStr '.mat']);
    if ~exist(saveFile,'file') || p.Results.Reset
        save(saveFile,'thresholds');
    end
end

% Do actual plotting in this function
plotThresholdsAgainstNoise(plotInfo,thresholds,calcParams.noiseLevels(:));

end


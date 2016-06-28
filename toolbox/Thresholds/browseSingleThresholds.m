function browseSingleThresholds(calcIDStr,varargin)
% browseSingleThresholds(calcIDStr)
%
% Given a calcIDStr, this function allows the user to browse the
% psychometric threshold fits using the arrow keys. Press escape to end the
% program.
%
% xd  6/27/16

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
        formattedData{ii} = squeeze(currentDataToFormat(:,:,:,1));
    end
end

%% Loop browsing
global THE_ONE_KEY;
THE_ONE_KEY = 'Hello'; TheOldKey = 'Hello';

inaction = true; closeFig = true;
colorIdx = 1;
noiseIdx = 1;

while ~strcmp(THE_ONE_KEY,'escape')
    if inaction
        dataToUse = squeeze(formattedData{colorIdx}(:,noiseIdx));
        [threshold,params] = singleThresholdExtraction(dataToUse,70.9);
        
        plotInfo = createPlotInfoStruct;
        plotInfo.fitColor = calcParams.colors{colorIdx}(1);
        plotInfo.title = sprintf('Noise Level: %d',noiseIdx);
        plotFitForSingleThreshold(plotInfo,dataToUse,threshold,params);
        set(gcf,'KeyPressFcn',@myKeyPress);
        inaction = false;
        THE_ONE_KEY = TheOldKey;
    end
    
    if ~strcmp(THE_ONE_KEY,TheOldKey)
        inaction = true;
        
        switch(THE_ONE_KEY)
            case 'uparrow'
                colorIdx = mod(colorIdx,4) + 1;
            case 'downarrow'
                colorIdx = colorIdx - 1;
                if colorIdx == 0, colorIdx = 4; end
            case 'leftarrow'
                noiseIdx = noiseIdx - 1;
                if noiseIdx == 0, noiseIdx = 10; end
            case 'rightarrow'
                noiseIdx = mod(noiseIdx,10) + 1;
            case 's'
                closeFig = false;
        end
        if closeFig, close; else closeFig = true; end;
    end
    pause(0.001);
end
close;
clearvars -GLOBAL THE_ONE_KEY;
end

function myKeyPress(hObject,event)
global THE_ONE_KEY;
THE_ONE_KEY = event.Key;
end


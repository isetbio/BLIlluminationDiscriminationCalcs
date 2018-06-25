function browseSingleThresholds(calcIDStr,varargin)
% browseSingleThresholds(calcIDStr,varargin)
%
% Given a calcIDStr, this function allows the user to browse the
% psychometric threshold fits using the arrow keys. Press escape to end the
% program.
%
% Inputs:
%     calcIDStr  -  name of the data folder which contains model performances
% {name-value pairs}
%     'noiseIndex'  -  a 1x2 matrix specifying whether to fit thresholds as
%                      a function of Poisson or Gaussian noise (default = Gaussian)
%     'useTrueDE'   -  boolean flag to determine whether to use real
%                      illumination step sizes (default = true)
%
% Controls:
%     Use the arrow keys to navigate noise level (left right) and color (up down).
%     Press 's' to keep the current figure open after exiting the program.
%     Use 'escape' to exit the program (will close current window).
%
% 6/27/16  xd  wrote it

%% Setup the input parser
%
% If the simulation was run across both Poisson and Gaussian noise, we
% might want to have a specific combination of noise indices that we want
% to plot. The default assumption is 1x Poisson noise and all Gaussian
% noise. Specify the index of 1 Noise Type and leave the other as 0, in the
% format [Poisson Gaussian].
p = inputParser;
p.addParameter('NoiseIndex',[1 0],@isnumeric);
p.addParameter('useTrueDE',true,@islogical);
p.parse(varargin{:});

%% Load the data and calcParams here
[data,calcParams] = loadModelData(calcIDStr);

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
        formattedData{ii} = squeeze(currentDataToFormat(:,:,:,1));
    end
end

%% Loop browsing
%
% The code below is a bit questionable, especially the use of global
% variables. However, it does its job very well and I have not found an
% alternative that performs nearly as well.
TheOldKey = 'Hello';
global THE_ONE_KEY;
THE_ONE_KEY = TheOldKey; 

% Initialize some variables in for the loop
inaction = true; closeFig = true;
colorIdx = 1;
noiseIdx = 1;

% Extract the relevant noise levels for plot title and indexing
if p.Results.NoiseIndex(1)
    noiseLevels = calcParams.KgLevels;
else
    noiseLevels = calcParams.KpLevels;
end
maxNoiseIdx = length(noiseLevels);

% Get figure parameters
figParams = BLIllumDiscrFigParams([],'browse');

% Loop until user presses the escape key. In the loop, the arrow keys are
% used to move between illumination levels (left/right) and color
% directions (up/down). s signifies that a copy of the figure should be
% kept. This is done by opening the current plot in a new figure. We
% utilize the figure's keypressfunction to read user inputs (thus
% requiring the global variable).
while ~strcmp(THE_ONE_KEY,'escape')
    if inaction
        % Extract thresholds
        dataToUse = squeeze(formattedData{colorIdx}(:,noiseIdx));
        [threshold,params,stimLevels] = singleThresholdExtraction(dataToUse,70.71,calcParams.illumLevels,...
                                                                  calcParams.testingSetSize,p.Results.useTrueDE,...
                                                                  calcParams.colors{colorIdx});
        
        % Some plotting metadata (titles, axes, and such)
        plotInfo = createPlotInfoStruct;
        plotInfo.fitColor = figParams.colors{colorIdx};
        plotInfo.title = sprintf('Noise Level: %d',noiseLevels(noiseIdx));
        plotInfo.stimLevels = stimLevels;%calcParams.illumLevels;
        
        % This creates a new plot so we need to assign the keypressfunction
        % every time.
        plotFitForSingleThreshold(plotInfo,dataToUse,threshold,params);
        set(gcf,'KeyPressFcn',@myKeyPress);
        disp(threshold)
        
        % Reset the global variable
        inaction = false;
        THE_ONE_KEY = TheOldKey;
    end
    
    % If the global is different from the original key, then the user has
    % pressed something. Parse the input and update loop variables as
    % necessary.
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
                if noiseIdx == 0, noiseIdx = maxNoiseIdx; end
            case 'rightarrow'
                noiseIdx = mod(noiseIdx,maxNoiseIdx) + 1;
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

function myKeyPress(hObject,event) %#ok<INUSL>
global THE_ONE_KEY;
THE_ONE_KEY = event.Key;
end


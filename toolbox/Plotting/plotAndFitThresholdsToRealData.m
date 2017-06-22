function [fittedThresholds,interpNoise] = plotAndFitThresholdsToRealData(plotInfo,thresholds,data,varargin)
% fittedThresholds = plotAndFitThresholdsToRealData(plotInfo,thresholds,data,varargin)
%
% This function takes in thresholds extracted from the model simulation and
% determines the best fit to the values in data. thresholds is a NxM matrix
% which contains M sets of N thresholds. data is a M vector, and this
% function will try find the best overall fit for each column of thresholds
% to the corresponding value in data.
%
% Inputs:
%     plotInfo    -  struct with some parameters like label and title text
%     thresholds  -  NxM matrix of M sets of N thresholds. Each set of N
%                    thresholds is used together when calculating fit
%                    errors.
%     data  -  N vector containing real data to fit to.
% {name-value pairs}
%     'ThresholdError'  -  used to plot error bars on the fitted thresholds
%     'DataError'       -  used to plot error bars on the original data
%     'NoiseLevel'      -  uses this value instead of fitting a value to the
%     'NoiseVector'     -  the true noise levels (this program fits using 
%                          the nominal values, i.e. the matrix indices
%     'NewFigure'       -  whether to create a new Matlab figure when plotting
%     'CreatePlot'      -  whether to plot the results or just return them
%
% Outputs:
%     fittedThresholds  -  the best fit thresholds to the data
%     interpNoise  -  the noise level that corresponds to the best fit
%                     which will be in true noise values if 'NoiseVector'
%                     is provided, nominal otherwise
%
% 6/22/16   xd  wrote it
% 11/18/16  xd  change to LSE metric instead of abs difference

%% Create input parser for possible error bar data
parser = inputParser;
parser.addParameter('ThresholdError',[],@isnumeric);
parser.addParameter('DataError',zeros(size(data)),@isnumeric);
parser.addParameter('NoiseLevel',-1,@isnumeric);
parser.addParameter('NoiseVector',[],@isnumeric);
parser.addParameter('NewFigure',true,@islogical);
parser.addParameter('CreatePlot',true,@islogical);
parser.parse(varargin{:});

thresholdError = parser.Results.ThresholdError;
dataError = parser.Results.DataError;

%% Check that thresholds and data have the same number of entries
if size(thresholds,2) ~= length(data), error('thresholds and data size are not matching!'); end;

%% Determine the best average match
%
% We can determine the best match by finding the least squared error from
% the data points to each threshold value. We will then average the LSE's
% across all the colors. This will allow us to determine a minimal LSE. We
% can then linearly interpolate up/down 1 entry to find a better fit.
thresholdLSE = (thresholds - repmat(data(:)',size(thresholds,1),1)).^2;
sumLSE = sum(thresholdLSE,2);

[~,minLSEIdx] = min(sumLSE);
if parser.Results.NoiseLevel > 0,
    minLSEIdx = parser.Results.NoiseLevel;
end

% Set where the point we start to interpolate
interpolateStartPoint = minLSEIdx;

% Read in the threshold values from this point, so that if we do not end up
% interpolated, there is still a value set here.
fittedThresholds = thresholds(interpolateStartPoint,:);
fittedError = zeros(size(fittedThresholds));

if (~isempty(thresholdError))
    fittedError = thresholdError(interpolateStartPoint,:);
end

% Target to which to interpolate. We initialize it to the start point and
% change it accordingly if there are enough values above/below to allow for
% interpolation.
interpolateEndPoint = interpolateStartPoint;

% If x is the minimum point, we want to interpolate between x-1 and x+1
% since our error is a quadratic function, meaning that the true minimum
% must be between these two points.
if size(sumLSE,1) > 1
    % If it is the start point, just interpolate from x to x+1
    if interpolateStartPoint == 1
        interpolateEndPoint = interpolateStartPoint + 1;
        
    % If it is the end point, interpolate from x-1 to x
    elseif interpolateStartPoint == length(sumLSE)
        interpolateEndPoint = interpolateStartPoint;
        interpolateStartPoint = interpolateStartPoint - 1;
        
    % In all other cases, interpolate from x-1 to x+1
    else
        interpolateEndPoint = interpolateStartPoint + 1;
        interpolateStartPoint = interpolateStartPoint - 1;
    end
end

% Check against NaN
if isnan(sumLSE(interpolateStartPoint)), interpolateEndPoint = interpolateStartPoint; end;
if isnan(sumLSE(interpolateEndPoint)),   interpolateEndPoint = interpolateStartPoint; end;

% If the NoiseLevel field is greater than 0, than the user specified an
% input noise level. We will interpolate to that value instead of what
% we just calculated.
if parser.Results.NoiseLevel > 0,
    interpolateStartPoint = parser.Results.NoiseLevel;
    interpolateEndPoint = interpolateStartPoint;
end

% We do the interpolation if the two points are not equal. Otherwise, we
% can just proceed using the point.
if interpolateStartPoint ~= interpolateEndPoint
    
    % Get thresholds at the start and end points
    startPointThreshold = thresholds(interpolateStartPoint,:);
    endPointThreshold   = thresholds(interpolateEndPoint,:);

    % Interpolate the thresholds
    interpolatedThresholds = interp1([interpolateStartPoint interpolateEndPoint],...
        [startPointThreshold; endPointThreshold],...
        interpolateStartPoint:0.001:interpolateEndPoint);
    
    % Calculate the LSE for the interpolated thresholds and take the mean.
    interpLSE = (interpolatedThresholds - repmat(data(:)',size(interpolatedThresholds,1),1)).^2;
    interpLSE = sum(interpLSE,2);
    
    % Find the min LSE, this is the point we want.
    [~,interpIdx] = min(interpLSE);
    interpOffset = (interpIdx - 1)/1000;
    interpolatedPoint = interpolateStartPoint + interpOffset;
    
    % Use the interpolated point calculate the thresholds (and errors) that
    % we will plot.
    fittedThresholds = interpolatedThresholds(interpIdx,:);
    if ~isempty(thresholdError)
        fittedError = interp1([interpolateStartPoint interpolateEndPoint],...
            thresholdError([interpolateStartPoint,interpolateEndPoint],:),...
            interpolatedPoint);
    end
else
    interpolatedPoint = interpolateStartPoint;
end

% Here we use the noise index to find the actual noise level in the data.
% This information is used in the plot title.
noiseVector = parser.Results.NoiseVector;
if length(noiseVector) == 1
    interpNoise = noiseVector;
elseif ~isempty(noiseVector)
    interpNoise = noiseVector(floor(interpolatedPoint)) + (interpolatedPoint-floor(interpolatedPoint))*(noiseVector(2)-noiseVector(1));
else
    interpNoise = interpolatedPoint;
end

%% Plot
if parser.Results.CreatePlot
    figParams = BLIllumDiscrFigParams([],'FitThresholdToData');
    if ~isempty(plotInfo.colors), figParams.colors = plotInfo.colors; end;
    
    plotInfo.title = sprintf('Data fitted at %d noise',round(interpNoise));
    plotInfo.xlabel = 'Illumination Direction';
    plotInfo.ylabel = 'Stimulus Level (\DeltaE)';
    
    if parser.Results.NewFigure
        figure('Position',figParams.sqPosition);
    end
    hold on;
    
    for ii = 1:min(length(data),4)
        % Because the horizontal lines on the error bar function scales with
        % the range of the data set (and for some reason the range is 0->data
        % if the data is a scalar) we will create a dummy data point so that
        % the horizontal lines look roughly the same size.
        if ii < 4
            dataPad = -4 + ii; dataPadErr = 0;
        else
            dataPad = []; dataPadErr = [];
        end
        errorbar([ii dataPad],[data(ii) dataPad],[dataError(ii) dataPadErr],figParams.markerType,'Color',figParams.colors{ii},...
            'MarkerFaceColor',figParams.colors{ii},'MarkerSize',figParams.markerSize,...
            'LineWidth',figParams.lineWidth);
    end
    fittedThresholdHandle = errorbar(1:length(data),fittedThresholds,fittedError,...
        figParams.modelMarkerType,'Color',figParams.modelMarkerColor,'MarkerSize',figParams.modelMarkerSize,...
        'MarkerFaceColor',figParams.modelMarkerColor,'LineWidth',figParams.lineWidth);
    
    % Do some plot manipulations to make it look nice
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    set(gca,'XTickLabel',figParams.XTickLabel,'XTick',figParams.XTick);
    set(gca,'YGrid','on');
    axis square;
    ylim(figParams.ylimit);
    xlim(figParams.xlimit);
    
    legend(fittedThresholdHandle,{'Model Data'},'FontSize',figParams.legendFontSize);
    xl = xlabel(plotInfo.xlabel,'FontSize',figParams.labelFontSize); %#ok<*NASGU>
    yl = ylabel(plotInfo.ylabel,'FontSize',figParams.labelFontSize);
    t = title(plotInfo.title,'FontSize',figParams.titleFontSize);
    
    % If it is a new figure, then we move the label axes slightly to make it
    % look better. Otherwise, we will just leave it where the subplot puts it
    % by default.
    if parser.Results.NewFigure
%         yl.Position = yl.Position + figParams.deltaYlabelPosition;
%         xl.Position = xl.Position + figParams.deltaXlabelPosition;
    end
end
end

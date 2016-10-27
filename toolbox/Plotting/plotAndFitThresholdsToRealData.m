function [fittedThresholds,interpNoise] = plotAndFitThresholdsToRealData(plotInfo,thresholds,data,varargin)
% fittedThresholds = plotAndFitThresholdsToRealData(plotInfo,thresholds,data,varargin)
%
% This function takes in thresholds extracted from the model simulation and
% determines the best fit to the values in data. thresholds is a NxM matrix
% which contains M sets of N thresholds. data is a M vector, and this
% function will try find the best overall fit for each column of thresholds
% to the corresponding value in data.
%
% 6/22/16  xd  wrote it

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
% We can determine the best match by finding the distance from the data
% points to each threshold value. We will then average the distances across
% all the data points. This will allow us to determine a minimal point. We
% can then linearly interpolate up/down 1 entry to find a better fit.
thresholdDistToData = thresholds - repmat(data(:)',size(thresholds,1),1);
meanThresholdDistToData = mean(thresholdDistToData,2);

% Since we want the minimal distance, we find the minimum magnitude. Then
% we can interpolate using the actual values.
[~,idx] = min(abs(meanThresholdDistToData));
if parser.Results.NoiseLevel > 0,
    idx = parser.Results.NoiseLevel;
end

% We will check if the neighboring threshold distances have a different
% sign. If they do, we pick it and linearly interpolate to as close to 0 as
% possible.
pointToInterpolate = idx;
fittedThresholds = thresholds(idx,:);
fittedError = zeros(size(fittedThresholds));
if (~isempty(thresholdError))
    fittedError = thresholdError
end
interpolatedPoint = idx;
if size(meanThresholdDistToData,1) > 1
    if idx == length(meanThresholdDistToData)
        if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx - 1)), pointToInterpolate = idx - 1; end;
    else
        if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx + 1)), pointToInterpolate = idx + 1;
        elseif idx > 1
            if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx - 1)), pointToInterpolate = idx - 1; end;
        end
    end
end

% Check against NaN
if isnan(meanThresholdDistToData(pointToInterpolate)), pointToInterpolate = idx; end;

% If the NoiseLevel field is greater than 0, than the user specified an
% input noise level. We will interpolate to that value instead of what
% we just calculated.
if parser.Results.NoiseLevel > 0,
    pointToInterpolate = parser.Results.NoiseLevel;
end

% If the pointToInterpolate is not equal to the minimum magnitude, then we
% interpolate. Otherwise, just continue using the thresholds at the minimum magnitude.
if pointToInterpolate ~= idx
    startingMeanThreshold = meanThresholdDistToData(idx);
    interpolationTargetMeanThreshold = meanThresholdDistToData(pointToInterpolate);
    interpolatedThresholds = interp1([idx pointToInterpolate],...
        [startingMeanThreshold interpolationTargetMeanThreshold],...
        idx:0.001*sign(pointToInterpolate-idx):pointToInterpolate);
    [~,interpIdx] = min(abs(interpolatedThresholds));
    interpOffset = interpIdx/1000;
    interpolatedPoint = interpolatedPoint + sign(pointToInterpolate-idx) * interpOffset;
    
    % Use the interpolated point calculate the thresholds (and errors) that
    % we will plot.
    fittedThresholds = interp1([idx pointToInterpolate],thresholds([idx,pointToInterpolate],:),interpolatedPoint);
    if ~isempty(thresholdError)
        fittedError = interp1([idx pointToInterpolate],thresholdError([idx,pointToInterpolate],:),interpolatedPoint);
    end
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
    
    plotInfo.title = sprintf('Data fitted at %.3f noise',interpNoise);
    plotInfo.xlabel = 'Illumination Direction';
    plotInfo.ylabel = 'Stimulus Level (\DeltaE)';
    
    if parser.Results.NewFigure
        figure('Position',figParams.sqPosition);
    end
    hold on;
    
    for ii = 1:length(data)
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
    xl = xlabel(plotInfo.xlabel,'FontSize',figParams.labelFontSize);
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

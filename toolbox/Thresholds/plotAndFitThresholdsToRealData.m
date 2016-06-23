function plotAndFitThresholdsToRealData(plotInfo,thresholds,data)
% plotAndFitThresholdsToRealData(plotInfo,thresholds,data)
%
% This function takes in thresholds extracted from the model simulation and
% determines the best fit to the values in data. thresholds is a NxM matrix
% which contains M sets of N thresholds. data is a M vector, and this
% function will try find the best overall fit for each column of thresholds
% to the corresponding value in data.
%
% xd  6/22/16  wrote it

%% Check that thresholds and data have the same number of entries
if size(thresholds,2) ~= length(data), error('thresholds and data size are not matching!'); end;

%% Determine the best average match
% We can determine the best match by finding the distance from the data
% points to each threshold value. We will then average the distances across
% all the data points. This will allow us to determine a minimal point. We
% can then linearly interpolate up/down 1 entry to find a better fit.
thresholdDistToData = thresholds - repmat(data(:)',size(thresholds,1),1);
meanThresholdDistToData = mean(thresholdDistToData,2);

% Since we want the minimal distance, we find the minimum magnitude. Then
% we can interpolate using the actual values.
[~,idx] = min(abs(meanThresholdDistToData));

% We will check if the neighboring threshold distances have a different
% sign. If they do, we pick it and linearly interpolate to as close to 0 as
% possible.
pointToInterpolate = idx;
fittedThresholds = thresholds(idx,:);
interpolatedPoint = idx;
if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx + 1)), pointToInterpolate = idx + 1;
elseif sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx - 1)), pointToInterpolate = idx - 1; end;

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
    fittedThresholds = interp1([idx pointToInterpolate],thresholds([idx,pointToInterpolate],:),interpolatedPoint);
end

%% Plot
figParams = BLIllumDiscrFigParams([],'FitThresholdToData');
if ~isempty(plotInfo.colors), figParams.colors = plotInfo.colors; end;
plotInfo.title = sprintf('Data fitted at %.3f noise',interpolatedPoint);

figure('Position',figParams.sqPosition); hold on;
for ii = 1:length(data)
    plot(ii,data(ii),figParams.markerType,'Color',figParams.colors{ii},'MarkerFaceColor',figParams.colors{ii},'MarkerSize',figParams.markerSize); % Check for colors
end
fittedThresholdHandle = plot(1:length(data),fittedThresholds,'k.','MarkerSize',figParams.markerSize);

% Do some plot manipulations to make it look nice
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square;
ylim(figParams.ylimit);
xlim([0 5]);

legend(fittedThresholdHandle,{'Model Data'},'FontSize',figParams.legendFontSize); 
xl = xlabel(plotInfo.xlabel,'FontSize',figParams.labelFontSize);
yl = ylabel(plotInfo.ylabel,'FontSize',figParams.labelFontSize);
t = title(plotInfo.title,'FontSize',figParams.titleFontSize);
yl.Position = yl.Position + figParams.deltaYlabelPosition;
xl.Position = xl.Position + figParams.deltaXlabelPosition;


function interpDist = interpolateBestFitToData(thresholds,data)
% interpDist = interpolateBestFitToData(thresholds,data)
% 
% Interpolates and find the minimal average distance between the model data
% and the experimental data.
%
% 8/30/16  xd  extracted from plotAndFitThresholdsToRealData


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

% We will check if the neighboring threshold distances have a different
% sign. If they do, we pick it and linearly interpolate to as close to 0 as
% possible.
pointToInterpolate = idx;
interpolatedPoint = idx;
if idx == length(meanThresholdDistToData) 
    if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx - 1)), pointToInterpolate = idx - 1; end;
else
    if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx + 1)), pointToInterpolate = idx + 1;
    elseif idx > 1
        if sign(meanThresholdDistToData(idx)) ~= sign(meanThresholdDistToData(idx - 1)), pointToInterpolate = idx - 1; end;
    end
end

% Check against NaN
if isnan(meanThresholdDistToData(pointToInterpolate)), pointToInterpolate = idx; end;

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
end

interpDist = mean(abs(data-fittedThresholds));

end


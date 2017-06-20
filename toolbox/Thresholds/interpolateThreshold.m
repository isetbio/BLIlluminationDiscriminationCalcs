function threshold = interpolateThreshold(target, thresholds)
% threshold = interpolateThreshold(target, thresholds)
% 
% Interpolates the thresholds to the target value.
%
% 6/XX/17   xd  wrote it

if target == round(target), threshold = thresholds(target,:); return; end

interpolateStartPoint = floor(target);
interpolateEndPoint   = ceil(target);

% Get thresholds at the start and end points
startPointThreshold = thresholds(interpolateStartPoint,:);
endPointThreshold   = thresholds(interpolateEndPoint,:);

threshold = interp1([interpolateStartPoint interpolateEndPoint],...
    [startPointThreshold; endPointThreshold],...
    target);

end


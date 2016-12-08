function threshold = interpolateThreshold(target, thresholds)
%INTERPOLATETHRESHOLD Summary of this function goes here
%   Detailed explanation goes here


interpolateStartPoint = floor(target);
interpolateEndPoint   = ceil(target);

% Get thresholds at the start and end points
startPointThreshold = thresholds(interpolateStartPoint,:);
endPointThreshold   = thresholds(interpolateEndPoint,:);

threshold = interp1([interpolateStartPoint interpolateEndPoint],...
    [startPointThreshold; endPointThreshold],...
    target);

end


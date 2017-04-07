function [dataset,classes] = df6_ABBA_NoMCones(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% [dataset,classes] = df6_ABBA_NoMCones(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
%
% This functions removes all the M cones from the mosaic and replaces the
% values with 0. Then it creates an AB/BA format vector.  The reason we do
% it this way is to maintain the same data size (removing the M cones
% altogether will reduce vector size), but this needs testing to determine
% whether this methodology is appropriate.
%
% 9/8/16  xd  wrote it

%% Get size of photon data
numberOfCones = numel(targetPool{1});

%% Get cone pattern and set S cones to 0
for ii = 1:length(targetPool)
    tempPattern = targetPool{ii};
    tempPattern(mosaic.pattern == 3) = 0;
    targetPool{ii} = tempPattern;
end
for ii = 1:length(comparisonPool)
    tempPattern = comparisonPool{ii};
    tempPattern(mosaic.pattern == 3) = 0;
    comparisonPool{ii} = tempPattern;
end

%% Generate the data set
% Pre-allocate space for the dataset.
dataset = zeros(n,2 * numberOfCones);
classes = ones(n,1);
classes(1:n/2) = 0;

% The first half of the data will be AB format.  The second half will be BA
% format. It is often the case that the comparison pool contains only one
% sensor. Having multiple entries just means that multiple versions of the
% SAME stimuli were generated to account for pixel noise due to rendering.
for jj = 1:n/2
    targetSample = randsample(length(targetPool), 2);
    comparisonSample = randsample(length(comparisonPool), 1);
    
    dataset(jj,:) = [targetPool{targetSample(1)}(:); comparisonPool{comparisonSample}(:)]';
    dataset(jj + n/2,:) = [comparisonPool{comparisonSample}(:); targetPool{targetSample(2)}(:)]';
end

% Add desired noise
dataset = getNoisySensorImage(calcParams,dataset,kp,kg);

end

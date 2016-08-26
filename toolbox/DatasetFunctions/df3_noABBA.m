function [dataset,classes] = df3_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n,~)
% [dataset,classes] = df3_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n,~)
% 
% This data function will return data not organized into AB/BA format. The
% purpose for this function is because our data originally had been
% formatted without AB/BA and this allows us to reproduce old results.
%
% 6/2/16  xd  wrote it

%% Get size of photon data
numberOfCones = numel(targetPool{1});

%% Generate the data set
% Pre-allocate space for the dataset.
dataset = zeros(n,numberOfCones);
classes = ones(n,1);
classes(1:n/2) = 0;

% The first half of the data will be AB format.  The second half will be BA
% format. It is often the case that the comparison pool contains only one
% sensor.  Having multiple entries just means that multiple versions of the
% SAME stimuli were generated to account for pixel noise due to rendering.
for jj = 1:n/2
    targetSample = randsample(length(targetPool), 1);
    comparisonSample = randsample(length(comparisonPool), 1);
    
    dataset(jj,:) = targetPool{targetSample(1)}(:)';
    dataset(jj + n/2,:) = comparisonPool{comparisonSample}(:)';
end

% Add desired noise
dataset = getNoisySensorImage(calcParams,dataset,kp,kg);

end


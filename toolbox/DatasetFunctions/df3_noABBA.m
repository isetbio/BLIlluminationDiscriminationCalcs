function [dataset, classes] = df3_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n,~)
% [dataset, classes] = df4_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n)
% 
% This data function will return data not organized into AB/BA format. The
% purpose for this function is because our data originally had been
% formatted without AB/BA and this allows us to reproduce old results.
%
% xd  6/2/16  wrote it

%% Get size of photon data
numberOfCones = numel(targetPool{1});

%% Generate the data set
% Pre-allocate space for the dataset.
dataset = zeros(n,numberOfCones);
classes = ones(n,1);
classes(1:n/2) = 0;

% The first half of the data will be A format.  The second half will be B
% format. It is often the case that the comparison pool contains only one
% sensor. 
for jj = 1:n/2
    targetSample = randsample(length(targetPool),1);
    comparisonSample = randsample(length(comparisonPool),1);
    
    dataset(jj,:) = targetPool{targetSample}(:)';
    dataset(jj + n/2,:) = comparisonPool{comparisonSample}(:)';
end

dataset = getNoisySensorImage(calcParams,dataset,kp,kg);

end


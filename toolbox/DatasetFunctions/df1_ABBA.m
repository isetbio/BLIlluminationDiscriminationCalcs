function  [dataset,classes] = df1_ABBA(calcParams,targetPool,comparisonPool,kp,kg,n,~)
% [dataset, classes] = df1_ABBA(calcParams,targetPool,comparisonPool,kp,kg,n)
%
% This function will take the photon isomerizations in the targetPool
% sensors and comparisonPool sensors and turn them into AB and BA vectors.
% A is for the target and B is for the comparison. There will be equal
% distributions of AB and BA vectors in the training and testing sets.
%
% xd  6/1/16  wrote it

%% Get size of photon data
numberOfCones = numel(targetPool{1});

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

dataset = getNoisySensorImage(calcParams,dataset,kp,kg);

end


function [dataset, classes] = df4_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n)
% [dataset, classes] = df4_noABBA(calcParams,targetPool,comparisonPool,kp,kg,n)
% 
% 

%% Get size of photon data
numberOfCones = numel(sensorGet(targetPool{1}, 'photons'));

%% Generate the data set

% Pre-allocate space for the dataset.
dataset = zeros(n, numberOfCones);
classes = ones(n, 1);
classes(1:n/2) = 0;

% The first half of the data will be AB format.  The second half will be BA
% format. It is often the case that the comparison pool contains only one
% sensor.  Having multiple entries just means that multiple versions of the
% SAME stimuli were generated to account for pixel noise due to rendering.
for jj = 1:n/2
    targetSample = randsample(length(targetPool), 1);
    comparisonSample = randsample(length(comparisonPool), 1);
    
    photonsStandard = getNoisySensorImage(calcParams, targetPool{targetSample}, kp, kg);
    
    dataset(jj,:) = photonsStandard(:)';
    
    photonsComparison = getNoisySensorImage(calcParams, comparisonPool{comparisonSample}, kp, kg);
    
    dataset(jj + n/2,:) = photonsComparison(:)';
end

end


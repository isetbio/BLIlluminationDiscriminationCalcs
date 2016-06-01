function [dataset, classes] = df2_ABBAMeanConeSignal(calcParams,targetPool,comparisonPool,kp,kg,n)
% [dataset, classes] = df2_ABBAMeanConeSignal(calcParams,targetPool,comparisonPool,kp,kg,n)
%
%
%
% xd  6/1/16  wrote it

%% Get size of photon data and cone types
numberOfCones = numel(sensorGet(targetPool{1}, 'photons'));
coneMatrix = sensorGet(targetPool{1}, 'conetype');

%% Change signals in each cone to the mean
% For each cone, the signal will be changed to be the mean signal for that
% specific cone type.
coneTypes = unique(coneMatrix(:));
for ii = 1:length(targetPool)
    currentPhotons = sensorGet(targetPool{ii},'photons');
    for jj = 1:length(coneTypes)
        currentPhotons(coneMatrix == coneTypes(jj)) = mean2(currentPhotons(coneMatrix == coneTypes(jj)));
    end
    targetPool{ii} = sensorSet(targetPool{ii},'photons',currentPhotons);
end

for ii = 1:length(comparisonPool)
    currentPhotons = sensorGet(comparisonPool{ii},'photons');
    for jj = 1:length(coneTypes)
        currentPhotons(coneMatrix == coneTypes(jj)) = mean2(currentPhotons(coneMatrix == coneTypes(jj)));
    end
    comparisonPool{ii} = sensorSet(comparisonPool{ii},'photons',currentPhotons);
end

%% Generate the data set

% Pre-allocate space for the dataset.
dataset = zeros(n, 2 * numberOfCones);
classes = ones(n, 1);
classes(1:n/2) = 0;

% The first half of the data will be AB format.  The second half will be BA
% format. It is often the case that the comparison pool contains only one
% sensor.  Having multiple entries just means that multiple versions of the
% SAME stimuli were generated to account for pixel noise due to rendering.
for jj = 1:n/2
    targetSample = randsample(length(targetPool), 2);
    comparisonSample = randsample(length(comparisonPool), 1);
    
    sensorStandard = targetPool{targetSample(1)};
    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
    photonsComparison = getNoisySensorImage(calcParams, comparisonPool{comparisonSample}, kp, kg);
    
    dataset(jj,:) = [photonsStandard(:); photonsComparison(:)]';
    
    sensorStandard = targetPool{targetSample(2)};
    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
    photonsComparison = getNoisySensorImage(calcParams, comparisonPool{comparisonSample}, kp, kg);
    
    dataset(jj + n/2,:) = [photonsComparison(:); photonsStandard(:)]';
end

end


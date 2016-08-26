function [dataset,classes] = df2_ABBAMeanConeSignal(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% [dataset,classes] = df2_ABBAMeanConeSignal(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
%
% This function follows the same data organization as df1_ABBA, see that
% function for more details. In addition, this function will change the
% cone isomerizations in each cone to equal the mean isomerization of its
% cone type (L,M,S).
%
% 6/1/16  xd  wrote it

%% Get size of photon data and cone types
numberOfCones = numel(targetPool{1});
coneMatrix = mosaic.pattern;

%% Change signals in each cone to the mean
%
% For each cone, the signal will be changed to be the mean signal for that
% specific cone type.
coneTypes = unique(coneMatrix(:));
for ii = 1:length(targetPool)
    currentPhotons = targetPool{ii};
    for jj = 1:length(coneTypes)
        currentPhotons(coneMatrix == coneTypes(jj)) = mean2(currentPhotons(coneMatrix == coneTypes(jj)));
    end
    targetPool{ii} = currentPhotons;
end

for ii = 1:length(comparisonPool)
    currentPhotons = comparisonPool{ii};
    for jj = 1:length(coneTypes)
        currentPhotons(coneMatrix == coneTypes(jj)) = mean2(currentPhotons(coneMatrix == coneTypes(jj)));
    end
    comparisonPool{ii} = currentPhotons;
end

%% Generate the data set

% Pre-allocate space for the dataset.
dataset = zeros(n,2 * numberOfCones);
classes = ones(n,1);
classes(1:n/2) = 0;

% The first half of the data will be AB format.  The second half will be BA
% format. It is often the case that the comparison pool contains only one
% sensor.  Having multiple entries just means that multiple versions of the
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


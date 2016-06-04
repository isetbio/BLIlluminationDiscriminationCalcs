function percentCorrect = cf4_oldEuclidianDist(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData, testingData, trainingClasses, testingClasses)
% 
%
% xd   6/3/16  wrote it

%% Require equal number of training and testing data points
if length(testingClasses) ~= length(trainingClasses), error('cf4: This decision function requires equal length training and testing sets!');end
if sum(testingClasses == trainingClasses) ~= length(trainingClasses), error('cf4: Please check that training and testing classes are ordered identically!');end

%% Calculate performance
% We have half the trials as number of entries in the data.
numTrials = length(testingClasses)/2;
percentCorrect = 0;
for ii = 1:numTrials
    distToSame = norm(trainingData(ii,:) - testingData(ii,:));
    distToDiff = norm(trainingData(ii,:) - testingData(numTrials+ii,:));
    
    if distToSame < distToDiff
        percentCorrect = percentCorrect + 1;
    end
end

percentCorrect = percentCorrect / numTrials * 100;

end


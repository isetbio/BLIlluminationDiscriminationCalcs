function percentCorrect = cf1_NearestNeighbor(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData, testingData)
%
% This function determines the pairwise distance between the row vectors in
% trainingData and testingData. For each vector in testingData, it finds
% the closest vector in trainingData.  If both vectors have the same class,
% then the choice is considered corret.
%
% 5/26/16  xd  wrote it

distMatrix = pdist2(trainingData,testingData);
[~,minIdx] = min(distMatrix);
classifiedClasses = trainingClasses(minIdx);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


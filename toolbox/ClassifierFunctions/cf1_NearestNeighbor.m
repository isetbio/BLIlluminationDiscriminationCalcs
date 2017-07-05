function percentCorrect = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses)
%
% This function determines the pairwise distance between the row vectors in
% trainingData and testingData. For each vector in testingData, it finds
% the closest vector in trainingData.  If both vectors have the same class,
% then the choice is considered corret.
%
% Inputs:
%     trainingData  -  N1xM matrix containing N observations with M
%                      features. This will be used to train the classifier.
%     testingData   -  N2xM matrix containing N observations with M
%                      features. This will be used to test the classifier.
%     trainingClasses -  length N1 vector with classes corresponding to rows
%                        in 'trainingData'
%     testingClasses  -  length N2 vector with classes corresponding to rows
%                        in 'testingData'
%
% Outputs:
%     percentCorrect  -  percent correct performance of a classifier's
%                        output on 'testingData' when trained on
%                        'trainingData'
%
% 5/26/16  xd  wrote it

distMatrix = pdist2(trainingData,testingData);
[~,minIdx] = min(distMatrix);
classifiedClasses = trainingClasses(minIdx);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


function percentCorrect = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses)
%
% This function trains a Nearest Neighbor classifier using Matlab's fitcknn
% function. Only a 1-Nearest Neighbor classifier is being utilized. This
% can be changed by updating the parameters to the fitcknn call, see online
% documentation for the function for more details.
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
% 5/26/16    xd    wrote it
% 7/6/17     xd    changed algorithm to use Matlab's fitcknn

knn = fitcknn(trainingData,trainingClasses);
classifiedClasses = predict(knn,testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


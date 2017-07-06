function percentCorrect = cf4_oldEuclidianDist(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses)
% 
% The old distance based classifier takes 2 draws of target and 1 draw of
% comparison. It calculates the distance between the two targets and one of
% the targets and the comparison. Then it picks the one which was closest
% to the target. This replicates that using the data generated. This
% procedure requires twice the amount of data than the other functions
% because it uses the two halves of target stimuli from the training data
% and test data and only the comparison stimuli from the test set. Thus,
% the effective amount of data being classified is halved.
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
% 6/3/16  xd  wrote it

%% Require equal number of training and testing data points
if length(testingClasses) ~= length(trainingClasses), 
    error('cf4: This decision function requires equal length training and testing sets!');
end

if sum(testingClasses == trainingClasses) ~= length(trainingClasses), 
    error('cf4: Please check that training and testing classes are ordered identically!');
end

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


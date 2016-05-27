function percentCorrect = cf1_NearestNeighbor(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf1_NearestNeighbor(trainingData, testingData)
%
%
% xd  5/26/16  wrote it

%% Determine size of datasets
trainingSize = size(trainingData,1);
testingSize = size(testingData,1);

%% Calculate performance
percentCorrect = 0;
for ii = 1:testingSize
    currentTestSample = testingData(ii,:);
    
    trainingSampleIdx = randsample(trainingSize,1);
    trainingSample = trainingData(trainingSampleIdx,:);
    trainingSampleFlip = convertBetweenAB_BA(trainingSample);
    
    distToTraining = norm(currentTestSample - trainingSample);
    distToFlip = norm(currentTestSample - trainingSampleFlip);
    
    if (distToTraining < distToFlip) == (testingClasses(ii) == trainingClasses(trainingSampleIdx))
        percentCorrect = percentCorrect + 1;
    end
end
percentCorrect = percentCorrect/testingSize * 100;

end


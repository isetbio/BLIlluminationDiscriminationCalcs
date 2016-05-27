function percentCorrect = cf2_DiscriminantAnalysis(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf2_DiscriminantAnalysis(trainingData, testingData, trainingClasses, testingClasses)
%
%
% xd  5/26/16  wrote it

da = fitcdiscr(trainingData, trainingClasses, 'DiscrimType', 'pseudolinear');
classifiedClasses = predict(da, testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


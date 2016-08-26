function percentCorrect = cf2_DiscriminantAnalysis(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf2_DiscriminantAnalysis(trainingData, testingData, trainingClasses, testingClasses)
%
% This function classifies the testingData using a pseudolinear
% discriminant analysis. See fitcdiscr for more details.
%
% 5/26/16  xd  wrote it

da = fitcdiscr(trainingData, trainingClasses, 'DiscrimType', 'pseudolinear');
classifiedClasses = predict(da, testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


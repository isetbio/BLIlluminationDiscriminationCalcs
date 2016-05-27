function percentCorrect = cf3_SupportVectorMachine(trainingData, testingData, trainingClasses, testingClasses)
% percentCorrect = cf3_SupportVectorMachine(trainingData, testingData, trainingClasses, testingClasses)
%
%
% xd  5/26/16  wrote it

svm = fitcsvm(trainingData, trainingClasses);
classifiedClasses = predict(svm, testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


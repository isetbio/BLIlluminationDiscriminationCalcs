function [percentCorrect,svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf3_SupportVectorMachine(trainingData, testingData, trainingClasses, testingClasses)
%
% This function classifies testingData using a SVM with no optimization of 
% the classifier's hyperparameters. See fitcsvm for more details on SVM.
%
% xd  5/26/16  wrote it

svm = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','KernelFunction','linear');
classifiedClasses = predict(svm,testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

% Also return the svm in case it's needed.
svm = compact(svm);
svm = discardSupportVectors(svm);

end


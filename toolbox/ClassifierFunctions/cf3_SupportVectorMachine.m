function [percentCorrect,svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses)
%
% This function classifies testingData using a SVM with no optimization of 
% the classifier's hyperparameters. See fitcsvm for more details on SVM.
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
% xd  5/26/16  wrote it

svm = fitcsvm(trainingData,trainingClasses,'KernelScale','auto');
classifiedClasses = predict(svm,testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

% Also return the svm in case it's needed.
svm = compact(svm);
svm = discardSupportVectors(svm);

end


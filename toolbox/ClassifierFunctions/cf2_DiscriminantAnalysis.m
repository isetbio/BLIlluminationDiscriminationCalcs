function percentCorrect = cf2_DiscriminantAnalysis(trainingData,testingData,trainingClasses,testingClasses)
% percentCorrect = cf2_DiscriminantAnalysis(trainingData,testingData,trainingClasses,testingClasses)
%
% This function classifies the testingData using a pseudolinear
% discriminant analysis. See fitcdiscr for more details.
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

da = fitcdiscr(trainingData,trainingClasses,'DiscrimType','pseudolinear');
classifiedClasses = predict(da,testingData);
percentCorrect = sum(classifiedClasses == testingClasses) / size(testingData,1) * 100;

end


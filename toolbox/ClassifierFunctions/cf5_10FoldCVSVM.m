function percentCorrect = cf5_10FoldCVSVM(trainingData, ~, trainingClasses, ~)
% percentCorrect = cf5_10FoldCVSVM(trainingData, ~, trainingClasses, ~)
% 
% Performs 10-fold cross validated training. Only needs trainingData and
% classes which will be split into 10 random partitions. For each
% partition, the SVM will train on the other 9 and test on the last one.
%
% 7/18/16  xd  wrote it

%% Train cross validated SVM
svm = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','CrossVal','on','KFold',10);
percentCorrect = (1 - kfoldLoss(svm,'lossfun','classiferror'))*100;

end

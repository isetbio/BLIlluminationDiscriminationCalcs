function percentCorrect = cf5_10FoldCVSVM(trainingData, ~, trainingClasses, ~)
%CF5_10FOLDCVSVM Summary of this function goes here
%   Detailed explanation goes here

%% Train cross validated SVM
svm = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','CrossVal','on','KFold',10);
percentCorrect = 1 - kfoldLoss(svm,'lossfun','classiferror');

end


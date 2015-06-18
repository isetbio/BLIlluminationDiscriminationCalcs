clear all; close all;

%% Set some parameters

k = 10;
nDim = 10000;
trainingSetSize = 1000;

%% Generate some test data with parameters
trainingData = normrnd(1000, sqrt(1000), [trainingSetSize, nDim]);

%% Train SVM
svm = fitcsvm(trainingData, zeros(trainingSetSize,1), 'KernelScale', 10000);

%% Test SVM
k = 105;
testData = normrnd(1000, k * sqrt(1000), [10, nDim]);
[~, scores] = predict(svm, testData)
testData = normrnd(1050, k * sqrt(1050), [10, nDim]);
[~, scores] = predict(svm, testData)

% General idea behind SVM model
% Train SVM on target image with noise
% Test it against target image as well as different illumination
% Pick image with higher score
% Calculate accuracy from this process
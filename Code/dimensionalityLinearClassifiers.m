clear all; close all;

%% Set rng seed for reproducibility
rng(1);

%% Set some initial parameters

nDim = 100;
dist = 10;
trainingSetSize = 500;
k = 50;
uniformDist = false;
testSampleSize = 100;

%% Define function handles for desired distribution types
normal = @(v,k) normrnd(v,k);
poissApprox = @(v,k) normrnd(v, k * sqrt(v));
poiss = @(v,k) v + k * (poissrnd(v) - v);

funcList = {normal, poissApprox, poiss};

%% Define classifiers to train
DA = @(d,c) fitcdiscr(d,c);
NB = @(d,c) fitNaiveBayes(d,c);
SVM = @(d,c) fitcsvm(d,c);

fitList = {DA, NB, SVM};

%% Generate data for training
data = zeros(trainingSetSize, nDim, length(funcList));

% The 1st half will be target data, the second half will be test vectors
class = ones(trainingSetSize, 1, length(funcList));
class(1:trainingSetSize/2, 1, :) = 2;


targetVector = repmat(1000, 1, nDim);
if uniformDist
    testVector = targetVector + dist;
else
    rng(2);
    testVector = targetVector + 2 * dist * rand(size(targetVector));
    rng(1);
end

for ii = 1:trainingSetSize/2
    for jj = 1:length(funcList)
        data(ii,:,jj) = funcList{jj}(targetVector, 1);
        data(trainingSetSize/2 + ii,:,jj) = funcList{jj}(testVector, 1);
    end
end

%% Train classifiers
classifiers = cell(length(funcList), length(fitList));

for ii = 1:length(fitList)
    for jj = 1:length(funcList)
        classifiers{jj,ii} = fitList{ii}(data(:,:,jj), class(:,:,jj));
    end
end


%% Generate some test data
testData = zeros(testSampleSize, nDim, length(funcList));
for ff = 1:length(funcList)
    for ii = 1:testSampleSize
        testData(ii,:,ff) = funcList{ff}(targetVector,k);
    end
end

result = zeros(length(funcList), length(fitList),testSampleSize);
for ii = 1:length(fitList)
    for jj = 1:length(funcList)
        result(jj,ii,:) = predict(classifiers{jj,ii}, testData(:,:,jj));
    end
end
correct = result - 1;

correct = sum(correct, 3) / testSampleSize * 100;
printmat(correct, 'Correct rate', 'norm pApprox poiss', 'DA NB SVM');
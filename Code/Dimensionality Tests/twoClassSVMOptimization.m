clear;

%% Set rng seed for reproducibility
rng(1);

%% Set some initial parameters

nDim = 10000;
dist = 50;
trainingSetSize = 2500;
k = 1000;
uniformDist = true;
testSampleSize = 1000;
origin = 1000;
uniformOrigin = true;
originVariation = 50;
targetFunction = 2;

%% Define functions to use
poissApprox = @(v,k) normrnd(v, k * sqrt(v));
poiss = @(v,k) v + k * (poissrnd(v) - v);
funcList = {poissApprox, poiss};
SVM = @(d,c) fitcsvm(d,c);

%% Generate data for training
data = zeros(trainingSetSize, nDim);

% The 1st half will be target data, the second half will be test vectors
class = ones(trainingSetSize, 1);
class(1:trainingSetSize/2, 1) = 2;

targetVector = repmat(origin, 1, nDim);

if ~uniformOrigin
    targetVector = targetVector + originVariation * (rand(size(targetVector)) - 0.5);
end

if uniformDist
    testVector = targetVector + dist;
else
    rng(2);
    testVector = targetVector + 2 * dist * rand(size(targetVector));
    rng(1);
end

for ii = 1:trainingSetSize/2
    data(ii,:) = funcList{targetFunction}(targetVector, 1);
    data(trainingSetSize/2 + ii,:) = funcList{targetFunction}(testVector, 1);
end

%% Train classifier
classifier = SVM(data, class);

%% Generate some test data
testData = zeros(testSampleSize, nDim);

for ii = 1:testSampleSize
    testData(ii,:) = funcList{targetFunction}(targetVector,k);
end

result = predict(classifier, testData);


correct = result - 1;

correct = sum(correct) / testSampleSize * 100

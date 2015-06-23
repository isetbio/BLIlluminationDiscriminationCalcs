clear;
%% Set rng seed for reproducibility
% rng(1);

%% Set some initial parameters

trainingSetSize = 2500;
testSampleSize = 1000;
k = [1 10 100 1000];
targetFunction = 2;
%% Define functions to use
poissApprox = @(v,k) normrnd(v, k * sqrt(v));
poiss = @(v,k) v + k * (poissrnd(v) - v);
funcList = {poissApprox, poiss};
SVM = @(d,c) fitcsvm(d,c);

%% Load oi and create sensor images
sensor = getDefaultBLIllumDiscrSensor;
oiS = loadOpticalImageData('Neutral/Standard', 'TestImage0');
oiT = loadOpticalImageData('Neutral/RedIllumination', 'red1L-RGB');

sS = coneAbsorptions(sensor, oiS);
sT = coneAbsorptions(sensor, oiT);

pS = sensorGet(sS, 'photons');
pT = sensorGet(sT, 'photons');

%% Generate data for training
data = zeros(trainingSetSize, length(pS(:)));

% The 1st half will be target data, the second half will be test vectors
class = ones(trainingSetSize, 1);
class(1:trainingSetSize/2, 1) = 2;
tic
for ii = 1:trainingSetSize/2
    data(ii,:) = funcList{targetFunction}(pS(:), 1);
    data(trainingSetSize/2 + ii,:) = funcList{targetFunction}(pT(:), 1);
end
toc
%% Train classifier
tic
classifier = SVM(data, class);
toc

%% Generate some test data
testData = zeros(testSampleSize, length(pS(:)));
correctTotal = zeros(length(k), 1);
for jj = length(k)
    tic
    for ii = 1:testSampleSize
        testData(ii,:) = funcList{targetFunction}(pS(:),k(jj));
    end
    toc
    
    result = predict(classifier, testData);
    
    
    correct = result - 1;
    
    correct = sum(correct) / testSampleSize * 100
    
    testData = zeros(testSampleSize, length(pS(:)));
    
    tic
    for ii = 1:testSampleSize
        testData(ii,:) = funcList{targetFunction}(pT(:),k(jj));
    end
    toc
    
    result = predict(classifier, testData);
    
    
    correct2 = abs(result - 2);
    
    correct2 = sum(correct2) / testSampleSize * 100
    
    correctTotal(ii) = (correct + correct2) / 2;
end
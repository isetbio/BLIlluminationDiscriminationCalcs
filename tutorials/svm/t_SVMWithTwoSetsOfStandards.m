%% t_SVMWithTwoSetsOfStandards
%
% This tutorial script will go through a classification using two sets of
% the target stimulus. This is because doing so should result (on average)
% in a 50% performance rate for the SVM. If not, something has gone wrong. 
%
% The code in this script uses several functions in the toolbox folder but
% does not make use of the model function. This is because the model
% functions implement code very similar to the code in this script, albeit
% slightly more complex in order to account for different calculation
% parameters.
% 
%  8/30/16  xd  wrote it
%  7/ 6/17  xd  update comments

clear; close all;
%% Set up parameters

% The number of vectors to include in the training and testing data.
trainingSetSize = 1000;
testingSetSize  = 1000;

% Size of the cone mosaic. If the OIvMosaicResize variable is set to a
% nonzero value, it will be used to subsample the entire OI. Otherwise,
% only a small area of the OI will be used for classification.
mosaicSizeInDegrees = 1;
OIvMosaicResize     = 0;

% How many times to perform the classification.
numOfClassificationLoops = 10;

% Number of PCA components to use
numPCA = 400;

%% Create a cone mosaic
%
% We use a default mosaic for testing things. The only change needed is to
% resize the OI according to the specifications in the parameters set above
% at the top of the script.
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicSizeInDegrees;

%% Load the standards
%
% Load the standard OI from an arbitrary OI set. In this case, it is the
% Constant_FullImage OI's. It doesn't really matter what we load it from
% because we are testing the SVM performance between two identical classes.
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Constant_FullImage',mosaic);

%% Perform classification
kp = 1; kg = 0;
for ii = 1:numOfClassificationLoops
    [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,trainingSetSize);
    [testingData,testingClasses]   = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,testingSetSize);
    
    % Standardize data using training data
    [trainingData,m,s] = zscore(trainingData);
    testingData = (testingData  - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
    
    % Perform pca analysis
    coeff = pca(trainingData,'NumComponents',numPCA);
    trainingData = trainingData*coeff;
    testingData  = testingData*coeff;
    
    SVMpercentCorrect = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    fprintf('Round %d: %0.4f%%\n',ii,SVMpercentCorrect);
end
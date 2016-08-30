%% t_SVMWithTwoSetsOfStandards
%
% To verify that the SVM isn't doing something dumb, we can have it perform
% the classification using two sets of standard OI. This should result in
% 50% classification accuracy. If this doesn't happen, oh no!
%
% 8/30/16  xd  wrote it

clear; close all;
%% Set up parameters

% The number of vectors to include in the training and testing sets.
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
% Neutral_FullImage OI's. It doesn't really matter what we load it from
% because we are testing the SVM performance between two identical classes.
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData','Neutral_FullImage','Standard');
data = what(folderPath);
standardOIList = data.mat;

standardPhotonPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standardOI = loadOpticalImageData('Neutral_FullImage/Standard', strrep(standardOIList{jj},'OpticalImage.mat',''));
    standardPhotonPool{jj}  = mosaic.compute(standardOI,'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
end

%% Perform classification
kp = 1; kg = 0;
for ii = 1:numOfClassificationLoops
    [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,trainingSetSize);
    [testingData,testingClasses]   = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,testingSetSize);
    
    % Standardize data
    m = mean(trainingData,1);
    s = std(trainingData,1);
    
    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
    testingData  = (testingData  - repmat(m,testingSetSize,1))  ./ repmat(s,testingSetSize,1);
    
    % Perform pca analysis
    coeff = pca([trainingData;testingData],'NumComponents',numPCA);
    trainingData = trainingData*coeff;
    testingData  = testingData*coeff;
    
    SVMpercentCorrect = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    disp(SVMpercentCorrect);
end
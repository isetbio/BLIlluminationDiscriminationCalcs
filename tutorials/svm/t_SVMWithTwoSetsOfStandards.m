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

%% Create a cone mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicSizeInDegrees;

%% Load the standards
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
kp = 1; kg = 15;
for ii = 1:numOfClassificationLoops
    [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,trainingSetSize);
    [testingData,testingClasses]   = df1_ABBA(calcParams,standardPhotonPool,standardPhotonPool,kp,kg,testingSetSize);
    
    % Standardize data
    m = mean(trainingData,1);
    s = std(trainingData,1);
    
    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
    testingData  = (testingData  - repmat(m,testingSetSize,1))  ./ repmat(s,testingSetSize,1);
    
    % Perform pca analysis
    coeff = pca([trainingData;testingData]);
    trainingData = trainingData*coeff;
    testingData  = testingData*coeff;
    
    SVMpercentCorrect = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    disp(SVMpercentCorrect);
end
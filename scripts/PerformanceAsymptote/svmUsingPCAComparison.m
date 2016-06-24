% svmUsingPCAComparison
%
% Since dimensional reduction can provide significant (several orders of
% magnitude) boosts to SVM runtime, this script will do a few calculations
% help us have more confidence in using a select number of principal
% components rather than the whole image.
%
% The first part of this script will generate data that compares SVM
% performance using the whole sensor image v. just using the first 2
% principal components. The second part will vary the number of principal
% compenents used to train the SVM. This will give us a sense of whether
% more than 2 components should be used.
%
% xd  6/23/16

clear;
%% Set some parameters for the first calculation
% Here we define the various training set sizes that we wish to test. In
% addition, the size of the testing set will also be defined here. Since we
% are doing this for an SVM, larger training set sizes (>1000) may be
% painful to run.
testingSetSize = 5000;
trainingSetSize = 10*2^7;

% Define the size of the sensor here. For a small patch in the rest of the
% calculations, we are using a 0.83 degree sensor which we specify here.
% The OIvSensorScale variable tells the script to not downsample the
% optical image in any manner.
sSize = 0.83;
OIvSensorScale = 0;

% Some bookkeeping parameters. These should not be changed. NoiseStep is
% chosen so that the SVM asymptote does not reach 100% (since that would
% render the result rather meaningless).
folder = 'Neutral_FullImage';
color = 'Blue';
NoiseStep = 10;
illumSteps = 1:10;
numCrossVal = 10;

%% Create our sensor
rng(1); % Freeze noise
sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, sSize, [], oiCreate('human'));

%% Pre-allocate space for results
% The dimensions struct will hold meta data about the parameters used for
% the calculation. SVMpercentCorrent contains the actual performance
% values.
SVMpercentCorrect = zeros(2,length(illumSteps),numCrossVal);
SVMrunTime = zeros(size(SVMpercentCorrect));
dimensions.labels = {'Full/PCA' 'Illumination' 'TestingSet#'};
dimensions.folder = folder;
dimensions.color = color;
dimensions.illumSteps = illumSteps;
dimensions.numCrossVal = numCrossVal;

%% Calculations
%% Load all target scene sensors
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
folderPath = fullfile(analysisDir, 'OpticalImageData', folder, 'Standard');
standardOIList = getFilenamesInDirectory(folderPath);

standardSensorPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standard = loadOpticalImageData([folder '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
    standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize*OIvSensorScale));
    calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / length(standardOIList);
end

comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', folder, [color 'Illumination']);
OINames = getFilenamesInDirectory(comparisonOIPath);

for ii = 1:length(illumSteps)
    comparison = loadOpticalImageData([folder '/' color 'Illumination'], strrep(OINames{illumSteps(ii)}, 'OpticalImage.mat', ''));
    sensorComparison = coneAbsorptions(sensor, resizeOI(comparison,sSize*OIvSensorScale));
    
    % Set variables to pass into data generation functions.
    kp = 1; kg = NoiseStep;
    
    for jj = 1:numCrossVal
        %% Generate Data
        tic
        [testingData, testingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,testingSetSize);
        [trainingData, trainingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,trainingSetSize);
        fprintf('Yay! The Data has been created in %f seconds!\n',toc);
        
        % Standardize our data
        m = mean(trainingData,1);
        s = std(trainingData,1);
        trainingData = (trainingData - repmat(m, trainingSetSize, 1)) ./ repmat(s, trainingSetSize, 1);

        % Train SVM on raw data
        tic
        theSVM = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','CacheSize','maximal');
        SVMrunTime(1,ii,jj) = toc;
        fprintf('SVM trained in %f seconds!\n',SVMrunTime(1,ii,jj));
        
        % Train SVM on pca data
        tic
        [coeff,score] = pca(trainingData);
        pcaSVM = fitcsvm(score(:,1:2),trainingClasses,'KernelScale','auto','CacheSize','maximal');
        SVMrunTime(2,ii,jj) = toc;
        fprintf('SVM trained in %f seconds!\n',SVMrunTime(2,ii,jj));
        
        % Do classification
        predictedClasses = predict(theSVM,testingData);
        SVMpercentCorrect(1,ii,jj) = sum(predictedClasses == testingClasses)/testingSetSize;
        
        predictedClasses = predict(pcaSVM,testingData*coeff(:,1:2));
        SVMpercentCorrect(2,ii,jj) = sum(predictedClasses == testingClasses)/testingSetSize;
    end
end

%% Save the data
save('SVMvPCA.mat','SVMpercentCorrect','SVMrunTime','dimensions');
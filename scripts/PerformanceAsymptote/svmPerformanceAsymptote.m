% performanceAsymptotes
%
% This script is meant to explore performance of the SVM as a function of
% training data set size. This will be done for a single small patch at the
% center of the image. To avoid bias in the results due to selection of
% training/testing vectors, we will cross-validate by generating 1
% training and 10 testing sets of data at each training set size. This
% results in 10x cross-validation for each SVM. The same testing sets will
% be used for each classifier. The data will be saved into a 4-D matrix for plotting.
%
% xd  6/15/16  wrote it
% xd  6/17/16  major modifications and moved to new folder

clear;
%% Set some parameters

% Here we define the various training set sizes that we wish to test. In
% addition, the size of the testing set will also be defined here. Since we
% are doing this for an SVM, larger training set sizes (>1000) may be
% painful to run.
testingSetSize = 5000;
trainingSetSizes = 10*2.^(0:13);

% Define the size of the sensor here. For a small patch in the rest of the
% calculations, we are using a 0.83 degree sensor which we specify here.
% The OIvSensorScale variable tells the script to not downsample the
% optical image in any manner.
sSize = 0.1; % Maybe this should be 1 degree?
OIvSensorScale = 0;

% Some bookkeeping parameters. These should not be changed. NoiseStep is
% chosen so that the SVM asymptote does not reach 100% (since that would
% render the result rather meaningless).
folders = {'Neutral_FullImage' 'NM1_FullImage' 'NM2_FullImage'};
Colors = {'Blue'};
NoiseStep = 15;
numIllumStep = 1;
numCrossVal = 10;

%% Create our sensor
rng(1); % Freeze noise
sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, sSize, [], oiCreate('human'));

%% Pre-allocate space for results
% The dimensions struct will hold meta data about the parameters used for
% the calculation. SVMpercentCorrent contains the actual performance
% values.
SVMpercentCorrect = zeros(length(folders),length(Colors),length(trainingSetSizes),numCrossVal);
dimensions.labels = {'Folders' 'Colors' 'TrainingSetSizes' 'TestingSet#'};
dimensions.folders = folders;
dimensions.colors = Colors;
dimensions.trainingSetSizes = trainingSetSizes;
dimensions.numCrossVal = numCrossVal;

%% Do calculations
for ff = 1:length(folders)
    %% Load all target scene sensors
    analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
    folderPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, 'Standard');
    standardOIList = getFilenamesInDirectory(folderPath);
    
    standardSensorPool = cell(1, length(standardOIList));
    calcParams.meanStandard = 0;
    for jj = 1:length(standardOIList)
        standard = loadOpticalImageData([folders{ff} '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
        standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize*OIvSensorScale));
        calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / length(standardOIList);
    end
    
    %% Calculation body
    for cc = 1:length(Colors)
        
        % Load all Optical image names in the target directory in
        % alphanumerical order. This corresponds to increasing illumination steps.
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, [Colors{cc} 'Illumination']);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        comparison = loadOpticalImageData([folders{ff} '/' Colors{cc} 'Illumination'], strrep(OINames{numIllumStep}, 'OpticalImage.mat', ''));
        sensorComparison = coneAbsorptions(sensor, resizeOI(comparison,sSize*OIvSensorScale));
        
        % Set variables to pass into data generation functions.
        kp = 1; kg = NoiseStep;
        
        %% Generate the data set
        % We would like to generate 10 complete sets of testing data here.
        % One set of training data using the largest training set size will
        % be created. This way, all the smaller training data sets will be
        % subsets of the larger training data sets.  This makes sense to do,
        % for consistency reasons. Since the classes will be identical for
        % each data set, there is no reason to save 10 of them. 
        tic
        [testingData, testingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,testingSetSize);
        
        trainingData = cell(numCrossVal,1);
        for ii = 1:numCrossVal
            [trainingData{ii}, trainingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,max(trainingSetSizes));
        end
        fprintf('Yay! The Data has been created in %f seconds!\n',toc);
        
        %% Train and apply classifiers
        % For each training set size, we should first train the
        % SVMs and then test each one of the testingData sets.
        for ii = 1:length(trainingSetSizes);
            
            numberOfVec = trainingSetSizes(ii);
            dataToUse = [1:numberOfVec/2, max(trainingSetSizes)/2+1:max(trainingSetSizes)/2+numberOfVec/2];
            
            % Standardize data. We will use the mean and standard
            % deviation of the current training data set to standardize
            % both training and testing data.
            for kk = 1:numCrossVal
                tic
                currentTrainingData = trainingData{kk}(dataToUse,:);
                currentTrainingClasses = trainingClasses(dataToUse);
                
                m = mean(currentTrainingData,1);
                s = std(currentTrainingData,1);
                currentTrainingData = (currentTrainingData - repmat(m, numberOfVec, 1)) ./ repmat(s, numberOfVec, 1);
                
                % Since using the first 2 principal components seems to
                % work fine, we will do the transformation here.
                [coeff,score] = pca(currentTrainingData);
                currentTrainingData = score(:,1:2);
                
                theSVM = fitcsvm(currentTrainingData,currentTrainingClasses,'KernelScale','auto'); %THIS SHOULD MAKE IT ACTUALLY TRAIN ON LARGE DATA SETS
                
                % Classify each of the ten data sets using this SVM
                currentTestingData = (testingData - repmat(m, testingSetSize, 1)) ./ repmat(s, testingSetSize, 1);
                currentTestingData = currentTestingData*coeff(:,1:2);
                predictions = predict(theSVM, currentTestingData);
                SVMpercentCorrect(ff,cc,ii,kk) = sum((predictions == testingClasses)) / length(testingClasses);
                fprintf('SVM trained and tested in %f seconds for set size: %d! Run: %d\n',toc,ii,kk);
            end
        end
        
        %% Save the data
        % We save inside the loop so that if the program crashes, at least
        % we can get some data out of it.
        fileName = sprintf('SVMPerformance_%03.1fdeg_PCA.mat',sSize);
        save(fileName,'SVMpercentCorrect','dimensions');
    end
end




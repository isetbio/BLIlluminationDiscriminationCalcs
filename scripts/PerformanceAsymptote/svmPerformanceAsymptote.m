%% performanceAsymptotes
%
% This script is meant to explore performance of the SVM as a function of
% training data set size. This will be done for a single small patch at the
% center of the image. To avoid bias in the results due to selection of
% training/testing vectors, we will cross-validate by generating 1 training
% and 10 testing sets of data at each training set size. This results in
% 10x cross-validation for each SVM. The same testing sets will be used for
% each classifier. The data will be saved into a 4-D matrix for plotting.
%
% xd  6/15/16  wrote it
% xd  6/17/16  major modifications and moved to new folder

clear; close all;
%% Set some parameters

% Here we define the various training set sizes that we wish to test. In
% addition, the size of the testing set will also be defined here. Since we
% are doing this for an SVM, larger training set sizes (>1000) may be
% painful to run. 
testingSetSize   = 5000;
trainingSetSizes = 10*2.^(8);

% Define the size of the sensor here. For a small patch in the rest of the
% calculations, we are using a 0.83 degree sensor which we specify here.
% The OIvSensorScale variable tells the script to not downsample the
% optical image in any manner.
sSizes = 1;
OIvSensorScale = 0;

% Some bookkeeping parameters. These determine which folder the OI's come
% from and which color stimuli to use for this particular script. It is
% not feasible to perform this calculation for every stimuli that the model
% sees. Therefore, we can only do it for an example and assume that the
% results generalize well.
folders = {'Neutral_FullImage' 'NM1_FullImage' 'NM2_FullImage'};
colors  = {'Blue'};

% NoiseStep is chosen so that the SVM asymptote does not reach 100% (since
% that would render the result rather meaningless). illumSteps is similarly
% chosen to only include samples that are not at 100%.
noiseStep  = 15;
illumSteps = [1 5 10 15];

% We use kFold CV in this script. This variable determines how many folds
% to use. CV is performed using the default Matlab implementation for SVMs.
numCrossVal = 10;

% We are also reducing the dimensionality of our data via a PCA. This
% variable determines how many components to use. The value is chosen to
% maintain performance while minimizing runtime.
numPCA = 100;

%% Frozen noise
%
% Allows for replicating the results. Since we are using large amounts of
% data, notting freezing the noise should not affect the outcome too much.
% This is for when exact data needs to be replicated. Set to
% rng('shuffled') to unfreeze the noise.
rng(1);

%% Create metadata struct to save later


%% Pre-allocate space for results
%
% The dimensions struct will hold meta data about the parameters used for
% the calculation. SVMpercentCorrent contains the actual performance
% values.
for sSizesIdx = 1:length(sSizes)
    sSize = sSizes(sSizesIdx);

    % Create our sensor
    mosaic = getDefaultBLIllumDiscrMosaic;
    mosaic.fov = sSize;
    
    for illumStepIdx = 1:length(illumSteps)
        illumStep = illumSteps(illumStepIdx);
        
        SVMpercentCorrect = zeros(length(folders),length(colors),length(trainingSetSizes),numCrossVal);
                
        dimensions.labels           = {'Folders' 'Colors' 'TrainingSetSizes' 'CVAndTest'};
        dimensions.Folders          = folders;
        dimensions.Colors           = colors;
        dimensions.TrainingSetSizes = trainingSetSizes;
        dimensions.CVAndTest        = {'CVResult' 'CVStd' 'TestResult'};
        
        MetaData.numCrossVal  = numCrossVal;
        MetaData.sSize        = sSize;
        MetaData.numIllumStep = illumStep;
        MetaData.dimensions   = dimensions;
        
        %% Do calculations
        for folderIdx = 1:length(folders)
            %% Load all target scene sensors
            analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
            folderPath = fullfile(analysisDir, 'OpticalImageData', folders{folderIdx}, 'Standard');
            standardOIList = getFilenamesInDirectory(folderPath);
            
            standardSensorPool = cell(1, length(standardOIList));
            calcParams.meanStandard = 0;
            for jj = 1:length(standardOIList)
                standard = loadOpticalImageData([folders{folderIdx} '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
                standardSensorPool{jj} = mosaic.compute(resizeOI(standard,sSize*OIvSensorScale),'currentFlag',false);
                calcParams.meanStandard = calcParams.meanStandard + mean2(standardSensorPool{jj}) / length(standardOIList);
            end
            
            %% Calculation body
            for colorIdx = 1:length(colors)
                
                % Load all Optical image names in the target directory in
                % alphanumerical order. This corresponds to increasing
                % illumination steps.
                comparisonOIPath = fullfile(analysisDir,'OpticalImageData',folders{folderIdx},[colors{colorIdx} 'Illumination']);
                OINames = getFilenamesInDirectory(comparisonOIPath);
                comparison = loadOpticalImageData([folders{folderIdx} '/' colors{colorIdx} 'Illumination'],strrep(OINames{illumStep},'OpticalImage.mat', ''));
                sensorComparison = mosaic.compute(resizeOI(comparison,sSize*OIvSensorScale));
                
                % Set variables to pass into data generation functions. kp
                % modulates Poisson noise which is kept at 1. kg modulates
                % Gaussian noise which is determined by the noiseStep
                % parameter set at the top of the script. Both noises are
                % additive.
                kp = 1; kg = noiseStep;
                
                %% Generate the data set
                %
                % One set of training data using the largest training set
                % size will be created. This way, all the smaller training
                % data sets will be subsets of the larger training data
                % sets. This makes sense to do, for consistency reasons.
                tic
                [trainingData,trainingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,max(trainingSetSizes));
                [testingData,testingClasses]   = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,testingSetSize);
                
                % Turn into singles to save space. Necessary for the large
                % data sets.
                trainingData = single(trainingData);
                testingData  = single(testingData);
                fprintf('Yay! The Data for folder %d run %d has been created in %6.5f seconds!\n',folderIdx,kk,toc);
                
                %% Train and apply classifiers
                %
                % For each training set size, we should first train the
                % SVMs and then test each one of the sets.
                for ii = 1:length(trainingSetSizes);
                    tic
                    numberOfVec = trainingSetSizes(ii);
                    dataToUse = [1:numberOfVec/2, max(trainingSetSizes)/2+1:max(trainingSetSizes)/2+numberOfVec/2];
                    
                    currentTrainingData = trainingData(dataToUse,:);
                    currentTrainingClasses = trainingClasses(dataToUse);
                    
                    % Standardize data. We will use the mean and standard
                    % deviation of the current training data set to
                    % standardize both training and testing data.
                    m = mean(currentTrainingData,1);
                    s = std(currentTrainingData,1);
                    currentTrainingData = (currentTrainingData - repmat(m,trainingSetSizes(ii),1)) ./ repmat(s,trainingSetSizes(ii),1);
                    currentTestingData  = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
                    
                    % Reduce dimensionality via PCA.
                    coeff = pca(currentTrainingData,'NumComponents',numPCA,'Algorithm','svd');
                    currentTrainingData = currentTrainingData*coeff;
                    currentTestingData  = currentTestingData*coeff;
                    clearvars coeff
                    
                    % Train and classify using an svm
                    theSVM = fitcsvm(currentTrainingData,currentTrainingClasses,'KernelScale','auto',...
                        'CacheSize',10*1024); % THIS SHOULD MAKE IT ACTUALLY TRAIN ON LARGE DATA SETS
                    predictions = predict(theSVM,currentTestingData);
                    SVMpercentCorrect(folderIdx,colorIdx,ii,3) = sum((predictions == testingClasses)) / length(testingClasses);
                    
                    % kFold CV
                    CVSVM = crossval(theSVM,'kFold',numCrossVal);
                    percentCorrect = 1 - kfoldLoss(CVSVM,'lossfun','classiferror','mode','individual');
                    SVMpercentCorrect(colorIdx,1,illumStepIdx,1) = mean(percentCorrect);
                    SVMpercentCorrect(colorIdx,1,illumStepIdx,2) = std(percentCorrect)/sqrt(numCrossVal);
        
                    fprintf('SVM trained and tested in %f seconds for set size: %d!\n',toc,ii);
                    clearvars theSVM
                end

                %% Save the data
                %
                % We save inside the loop so that if the program crashes,
                % at least we can get some data out of it.
                fileName = sprintf('SVMPerformance_%03.1fdeg_%dPCA.mat',sSize,numPCA);
                save(fileName,'SVMpercentCorrect','MetaData');
            end
        end
    end
end
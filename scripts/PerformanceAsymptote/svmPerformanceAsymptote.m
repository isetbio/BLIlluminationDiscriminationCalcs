%% performanceAsymptotes
%
% This script is meant to explore performance of the SVM as a function of
% training data set size. This will be done for a single small patch at the
% center of the image. To avoid bias in the results due to selection of
% training/testing vectors, we will cross-validate via kFold validation.
% The user can set a variable to determine how many folds to generate. This
% script will record the cross validated performance as well as the
% performance of the data on a brand new test set.
%
% 6/15/16  xd  wrote it
% 6/17/16  xd  major modifications and moved to new folder
% 8/25/16  xd  minor updates for consistency in comments and code

clear; close all;
%% Set some parameters

% Here we define the various training set sizes that we wish to test. In
% addition, the size of the testing set will also be defined here. The
% training set sizes will be powers of 2 because the effect of trianing set
% size on performance is easier to visualize in log space. We can set the
% number of training set sizes to use below.
testingSetSize   = 5000;
trainingSetSizes = 10*2.^(6:14);

% Define the size of the sensor here. The calculations will use a 1 degree
% mosaic so that is the size that will be used here. However, the size
% variable can also be set as a vector. In this case, the script will loop
% over all the sizes. When set to 0, the OIvSensorScale variable tells the
% script to not downsample the entire image. If set to a value > 0, it will
% instead downsample the entire OI by average over a uniform grid.
sSizes = 0.3;
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
illumSteps = 1;

% We use kFold CV in this script. This variable determines how many folds
% to use. CV is performed using the default Matlab implementation for SVMs.
numCrossVal = 10;

% We are also reducing the dimensionality of our data via a PCA. This
% variable determines how many components to use. The value is chosen to
% maintain performance while minimizing runtime.
numPCA = 400;

%% Frozen noise
%
% Allows for replicating the results. Since we are using large amounts of
% data, notting freezing the noise should not affect the outcome too much.
% This is for when exact data needs to be replicated. Set to
% rng('shuffled') to unfreeze the noise.
rng(1);

%% Pre-allocate space for results
%
% The dimensions struct will hold meta data about the parameters used for
% the calculation. SVMpercentCorrent contains the actual performance
% values.
for sSizesIdx = 1:length(sSizes)
    sSize = sSizes(sSizesIdx);

    % Create our mosaic. We get a default sensor for the project, which has
    % integration time of 50 ms and a wavelength of [380 8 51]. We simply
    % need to set the fov to the desired size.
    mosaic = getDefaultBLIllumDiscrMosaic;
    mosaic.fov = sSize;
    
    for illumStepIdx = 1:length(illumSteps)
        illumStep = illumSteps(illumStepIdx);
        
        %% Create metadata struct to save with the data
        %
        % It's important to be able to decipher the data we save via this
        % scipts months/years after we run it. By including the meta data
        % in the mat file, we can keep track of what the values in this
        % matrix represent.
                
        % The dimensions struct determines what values each dimension of
        % the data matrix represents.
        dimensions.labels           = {'Folders' 'Colors' 'TrainingSetSizes' 'CVAndTest'};
        dimensions.Folders          = folders;
        dimensions.Colors           = colors;
        dimensions.TrainingSetSizes = trainingSetSizes;
        dimensions.CVAndTest        = {'CVResult' 'CVStd' 'TestResult'};
        
        % The metadata struct contains the dimensions as well as some other
        % meta data not included in the dimensions.
        MetaData.numCrossVal  = numCrossVal;
        MetaData.sSize        = sSize;
        MetaData.numIllumStep = illumStep;
        MetaData.dimensions   = dimensions;
        
        % We pre-allocate a data matrix using the dimensions struct. This
        % allows us to avoid having to set variables twice.
        SVMpercentCorrect = zeros(length(dimensions.Folders),length(dimensions.Colors),...
            length(dimensions.TrainingSetSizes),length(dimensions.CVAndTest));
        
        %% Do calculations
        for folderIdx = 1:length(folders)
            %% Load all target scene sensors
            analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
            folderPath = fullfile(analysisDir, 'OpticalImageData', folders{folderIdx}, 'Standard');
            standardOIList = getFilenamesInDirectory(folderPath);
            
            standardPhotonPool = cell(1, length(standardOIList));
            calcParams.meanStandard = 0;
            for jj = 1:length(standardOIList)
                standard = loadOpticalImageData([folders{folderIdx} '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
                standardPhotonPool{jj} = mosaic.compute(resizeOI(standard,sSize*OIvSensorScale),'currentFlag',false);
                calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
            end
            
            %% Calculation body
            for colorIdx = 1:length(colors)
                
                % Load all Optical image names in the target directory in
                % alphanumerical order. This corresponds to increasing
                % illumination steps.
                comparisonOIPath = fullfile(analysisDir,'OpticalImageData',folders{folderIdx},[colors{colorIdx} 'Illumination']);
                OINames = getFilenamesInDirectory(comparisonOIPath);
                comparisonOI = loadOpticalImageData([folders{folderIdx} '/' colors{colorIdx} 'Illumination'],strrep(OINames{illumStep},'OpticalImage.mat', ''));
                photonComparison = mosaic.compute(resizeOI(comparisonOI,sSize*OIvSensorScale));
                
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
                [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},kp,kg,max(trainingSetSizes));
                [testingData,testingClasses]   = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},kp,kg,testingSetSize);
                
                % Turn into singles to save space. Necessary for the large
                % data sets.
                trainingData = single(trainingData);
                testingData  = single(testingData);
                fprintf('Yay! The Data for folder %d has been created in %5.5f seconds!\n',folderIdx,toc);
                
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
                    SVMpercentCorrect(folderIdx,colorIdx,ii,1) = mean(percentCorrect);
                    SVMpercentCorrect(folderIdx,colorIdx,ii,2) = std(percentCorrect)/sqrt(numCrossVal);
        
                    fprintf('SVM trained and tested in %5.5f seconds for set size: %d!\n',toc,ii);
                    clearvars theSVM
                end

                %% Save the data
                %
                % We save inside the loop so that if the program crashes,
                % at least we can get some data out of it.
                fileName = params2Name_SVMAsymptote(struct('sSize',sSize,'numPCA',numPCA,'illumStep',illumStep));
                save([fileName '.mat'],'SVMpercentCorrect','MetaData');
            end
        end
    end
end
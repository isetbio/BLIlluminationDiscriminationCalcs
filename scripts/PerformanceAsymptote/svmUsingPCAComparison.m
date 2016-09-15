%% svmUsingPCAComparison
%
% Since dimensional reduction can provide significant (several orders of
% magnitude) boosts to SVM runtime, this script will do a few calculations
% help us have more confidence in using a select number of principal
% components rather than the whole image.
%
% The first part of this script will generate data that compares SVM
% performance using a mosaic with size determined by the user. This script
% then can loop over several different number of PCA components to use.
% This will give us an idea of what number of PCA components given a
% reliable result with a satisfactory trade off in runtime.
%
% 6/23/16  xd  wrote it
% 8/25/16  xd  commenting and cleaning up

clear; close all;
%% Set some parameters for the first calculation

% Here we define the various training set sizes that we wish to test. In
% addition, the size of the testing set will also be defined here. Since we
% are doing this for an SVM, larger training set sizes (>1000) may be
% painful to run.
testingSetSize  = 1000;
trainingSetSize = 1000;

% Define the size of the sensor here. For a small patch in the rest of the
% calculations, we are using a 0.83 degree sensor which we specify here.
% The OIvSensorScale variable when set to 0 tells the script to not
% downsample the optical image in any manner. If it is set to a value > 0,
% the script assumes that user wants to take the entire scene and subsample
% into an OI of size sSize*OIvSensorScale.
sSize = 1;
OIvSensorScale = 0;

% Some bookkeeping parameters. These should not be changed. Note that we
% only do this calculation on 1 stimulus sample per color direction and an
% arbitrary patch in the scene. Additionally, this is only done for 1
% stimulus condition. This is because doing such a large scale calculation
% on every single patch used for each calculation would take far too much
% time and likely would not produce any worthwhile results.
OIFolder = 'Neutral_FullImage';
colors   = {'Blue' 'Green' 'Red' 'Yellow'};

% NoiseStep is chosen so that the SVM asymptote does not reach 100% (since
% that would render the result rather meaningless). illumSteps is similarly
% chosen to only include samples that are not at 100%.
noiseStep  = 15;
illumSteps = 1:10;

% We use kFold CV in this script. This variable determines how many folds
% to use. CV is performed using the default Matlab implementation for SVMs.
numCrossVal = 10;

% The number of PCA components to use. This can be set to a vector so that
% the script loops over all values in the vector.
numPCA = [2 25 50 100 200 400 800];

%% Frozen noise
%
% Allows for replicating the results. Since we are using large amounts of
% data, notting freezing the noise should not affect the outcome too much.
% This is for when exact data needs to be replicated. Set to
% rng('shuffled') to unfreeze the noise.
rng(1);

%% Create the cone mosaic
% 
% A single mosaic will be used throughout the entire script. This allows
% for consistency (and is what the model does) in isomerization responses.
% We set the integration time 50 ms and the wavelength to [380 5 51]
% because they are what is used (generally) in the model. Tj
% getDefaultBLIllumDiscrMosaic function returns a mosaic with these
% parameters. We just need to resize it.
mosaic     = getDefaultBLIllumDiscrMosaic;
mosaic.fov = sSize;

%% Pre-allocate space for results
%
% The dimensions struct will hold meta data about the parameters used for
% the calculation. This describes the dimensions of the data matrix as well
% as what the indices for each dimension represent. By saving this with the
% data, we can avoid confusion on what is what.
dimensions.labels      = {'Colors' 'FullOrPCA' 'IllumSteps' 'CVAndTest'};
dimensions.Colors      = colors;
dimensions.FullOrPCA   = [0 numPCA];
dimensions.IllumSteps  = illumSteps;
dimensions.CVAndTest   = {'CVResult' 'CVStd' 'TestResult'};

% A meta data struct that holds all relevant metadata to the script
% including the dimensions struct.
MetaData.numCrossVal     = numCrossVal;
MetaData.OIFolder        = OIFolder;
MetaData.dimensions      = dimensions;
MetaData.trainingSetSize = trainingSetSize;
MetaData.testingSetSize  = testingSetSize;
MetaData.mosaicSize      = sSize;

% SVMpercentCorrent contains the actual performance values. The first
% dimension differentiates between the calculations done by the full data
% SVM and ones done by the PCA-SVM.
SVMpercentCorrect = zeros(length(dimensions.Colors),length(dimensions.FullOrPCA),length(dimensions.IllumSteps),length(dimensions.CVAndTest));
SVMrunTime        = zeros(length(dimensions.Colors),length(dimensions.FullOrPCA),length(dimensions.IllumSteps),length(dimensions.CVAndTest)-1);

%% Calculations
%
% The code below here will carry out the actual calculations. In general,
% we will load the desired OI and then loop over all the parameters set
% above. For each paramter combination, we calculate the performance of the
% SVM on the full data set as well as the PCA dimensionality reduced data
% set. We record both the runtime as well as the performance. This will be
% used to justify decisions on how many PCA vectors to use in the model.

%% Load all target scene sensors
%
% We load all the target sensors beforehand because they will stay the same
% for any calculation. The comparison sensors will need to be changed for
% each different stimuli.

% Get the path and filenames of the standard OI.
analysisDir    = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath     = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
standardOIList = getFilenamesInDirectory(folderPath);

% Load each standard OI and calculate the mean absorptions of the OI. We
% also keep track of the spatial mean of the absorptions because that is
% what will be used as the variance of the additive Gaussian noise.
standardIsomPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standardOI = loadOpticalImageData([OIFolder '/Standard'],strrep(standardOIList{jj},'OpticalImage.mat',''));
    standardIsomPool{jj} = mosaic.compute(resizeOI(standardOI,sSize*OIvSensorScale),'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardIsomPool{jj}) / length(standardOIList);
end

%% Loop over parameters
%
% Here, we loop over all the parameters set in the top of this script. We
% perform the calculations for each combination and then save the results
% in the appropriate location in the data matrix.

% Loop over each color
for colorIdx = 1:length(colors)
    
    % Get the names of the comparison OI. This will let us index into the
    % names (they are sorted alphanumerically) when we want to load a
    % specific OI.
    comparisonOIPath = fullfile(analysisDir,'OpticalImageData',OIFolder,[colors{colorIdx} 'Illumination']);
    OINames = getFilenamesInDirectory(comparisonOIPath);
    
    for illumStepIdx = 1:length(illumSteps)
        %% Load the comparison OI.
        %
        % Load the OI using the illumstep and OINames variable. We compute
        % the mean absorptions and save them for SVM classification.
        OISubFolder = [OIFolder '/' colors{colorIdx} 'Illumination'];
        comparison = loadOpticalImageData(OISubFolder,strrep(OINames{illumSteps(illumStepIdx)},'OpticalImage.mat',''));
        comparisonIsom = mosaic.compute(resizeOI(comparison,sSize*OIvSensorScale),'currentFlag',false);
        
        % Set variables to pass into data generation functions. kp
        % modulates Poisson noise which is kept at 1. kg modulates Gaussian
        % noise which is determined by the noiseStep parameter set at the
        % top of the script. Both noises are additive.
        kp = 1; kg = noiseStep;

        %% Generate Data
        %
        % We use one of the data generating functions available to the
        % model to generate the data for this script. This particular
        % function takes the target and comparison isomerizations and
        % concatenates them into a single vector. The two classes are
        % defined as AB and BA where A is the target and B is comparison.
        tic
        [trainingData,trainingClasses] = df1_ABBA(calcParams,standardIsomPool,{comparisonIsom},kp,kg,trainingSetSize);
        [testingData,testingClasses]   = df1_ABBA(calcParams,standardIsomPool,{comparisonIsom},kp,kg,testingSetSize);
        fprintf('Yay! The Data has been created in %f seconds!\n',toc);
        
        %% SVM Calculations
        %
        % Actual classification gets done here. We take the full data and
        % train an SVM. Afterwards, we perform kFold cross validation using
        % this SVM. We save the performance for both the SVM on the testing
        % data set and the cross validated SVM. This calculation is then
        % repeated for each numPCA.
    
        % Standardize our data. This improves classification performance.
        m = mean(trainingData,1);
        s = std(trainingData,1);
        trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
        testingData  = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
        
        % Train SVM on raw data as described above. We also keep track of
        % the runtime because that is an important factor to keep in mind
        % when we decide what number of PCA components to use.
        tic
        theSVM = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','CacheSize','maximal');
        predictedClasses = predict(theSVM,testingData);
        SVMpercentCorrect(colorIdx,1,illumStepIdx,3) = sum(predictedClasses == testingClasses)/testingSetSize;
        SVMrunTime(colorIdx,1,illumStepIdx,2) = toc;

        tic
        CVSVM = crossval(theSVM,'KFold',numCrossVal);
        percentCorrect = 1 - kfoldLoss(CVSVM,'lossfun','classiferror','mode','individual');
        SVMpercentCorrect(colorIdx,1,illumStepIdx,1) = mean(percentCorrect);
        SVMpercentCorrect(colorIdx,1,illumStepIdx,2) = std(percentCorrect)/sqrt(numCrossVal);
        SVMrunTime(colorIdx,1,illumStepIdx,1) = toc;
        
        fprintf('SVM trained in %f seconds!\n',sum(SVMrunTime(colorIdx,1,illumStepIdx,:)));
        
        % Loop and perform above calculation for each numPCA.
        for numPCAIdx = 1:length(numPCA)
            tic
            coeff = pca(trainingData,'NumComponents',numPCA(numPCAIdx));
            
            pcaSVM = fitcsvm(trainingData*coeff,trainingClasses,'KernelScale','auto','CacheSize','maximal');
            predictedClasses = predict(pcaSVM,testingData*coeff);
            SVMpercentCorrect(colorIdx,numPCAIdx+1,illumStepIdx,3) = sum(predictedClasses == testingClasses)/testingSetSize;
            SVMrunTime(colorIdx,numPCAIdx+1,illumStepIdx,2) = toc;
            
            tic
            CVSVM = crossval(pcaSVM,'KFold',numCrossVal);
            percentCorrect = 1 - kfoldLoss(CVSVM,'lossfun','classiferror','mode','individual');
            SVMpercentCorrect(colorIdx,numPCAIdx+1,illumStepIdx,1) = mean(percentCorrect);
            SVMpercentCorrect(colorIdx,numPCAIdx+1,illumStepIdx,2) = std(percentCorrect)/sqrt(numCrossVal);
            SVMrunTime(colorIdx,numPCAIdx+1,illumStepIdx,1) = toc;
            
            fprintf('PCA trained in %f seconds!\n',sum(SVMrunTime(colorIdx,numPCAIdx+1,illumStepIdx,:)));
        end
    end
end

%% Save the data
fileName = params2Name_SVMPCAComparison(struct('sSize',sSize));
save([fileName '.mat'],'SVMpercentCorrect','SVMrunTime','MetaData');

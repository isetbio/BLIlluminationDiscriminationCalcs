%% TODO:
% Comment this function

clear;
%% Set some parameters for the calculation
% These two variables determine the size of the testing and training data
% sets respectively. For the NN calculation, we compute the pairwise
% distance between each vector in the training and testing sets. Then for
% each entry in the testing set, we look at which vector it is closest to
% in the training set. If the AB/BA format for both the test and training
% vector is the same, we consider the classification as correct.
trainingSetSize = 500;
testingSetSize = 500;

% This determines the size of the sensor in degrees. The optical image will
% be scaled to OIvSensorScale times this value to avoid having parts of the edge of the
% sensor miss any stimulus. This should be OK since the optical image pads
% the original stimulus with the average color at the edges.
sSize = 0.4;
OIvSensorScale = 1.1;

% If set to true, variable Poisson noise will be used in the simulation. If
% set to false variable Gaussian noise, with a variance equal to the mean
% of all cone absorptions in the target scene will be used. However, 1x
% Poisson noise will still be enable to simulate photon transport.
usePoissonNoise = true;

% If set to true, the data will be standardized using the mean and standard
% deviation of the training set. This is generally used to help the
% performance of linear classifiers by making the feature space spherical.
standardizeData = true;

% Additional text to add to the end of the name of the saved data file.
% This will help add specificity if the current naming scheme is not
% enough. Needs one entry for each folder specified below.
additionalNamingText = {'_Mean' '_Mean' '_Mean'};

% Just some variables that tell the script which folders and data files to use
Colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Neutral_FullImage' 'NM1_FullImage' 'NM2_FullImage'}; 

% Some numbers to play with.
numIllumSteps = 50;
NoiseSteps = 1:2:20;

%% Create a sensor
% Because we are formatting the data into AB/BA vectors, we need to know
% the size of the cone responses so that we can allocate space for vectors
% with 2x the number of entries as in a single sensor's cone response matrix.
sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, sSize, [], oiCreate('human'));

%% Perform calculation
for ff = 1:length(folders)
    %% Load all target scene sensors
    analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
    folderPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, 'Standard');
    data = what(folderPath);
    standardOIList = data.mat;
    
    standardSensorPool = cell(1, length(standardOIList));
    calcParams.meanStandard = 0;
    for jj = 1:length(standardOIList)
        standard = loadOpticalImageData([folders{ff} '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
        standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize*OIvSensorScale));
        calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / length(standardOIList);
    end
    
    DApercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    NNpercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    SVMpercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    pcaData = cell(length(Colors),numIllumSteps,length(NoiseSteps));
    for cc = 1:length(Colors)
        
        % Load all Optical image names in the target directory in
        % alphanumerical order. This corresponds to increasing illumination steps.
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, [Colors{cc} 'Illumination']);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        
        for kk = 1:numIllumSteps
            
            comparison = loadOpticalImageData([folders{ff} '/' Colors{cc} 'Illumination'], strrep(OINames{kk}, 'OpticalImage.mat', ''));
            sensorComparison = coneAbsorptions(sensor, resizeOI(comparison,sSize*OIvSensorScale));
            
            tic
            for nn = NoiseSteps
                if usePoissonNoise
                    kp = nn; kg = 0;
                else
                    kg = nn; kp = 1;
                end
                
                %% Generate the data set
                [trainingData, trainingClasses] = df2_ABBAMeanConeSignal(calcParams,standardSensorPool,{sensorComparison},kp,kg,trainingSetSize);
                [testingData, testingClasses] = df2_ABBAMeanConeSignal(calcParams,standardSensorPool,{sensorComparison},kp,kg,testingSetSize);
                
                % Standardize data if flag is set to true
                if standardizeData
                    m = mean(trainingData,1);
                    s = std(trainingData,1);
                    
                    trainingData = (trainingData - repmat(m, trainingSetSize, 1)) ./ repmat(s, trainingSetSize, 1);
                    testingData = (testingData - repmat(m, testingSetSize, 1)) ./ repmat(s, testingSetSize, 1);
                end
                
                % Apply classifiers
                [SVMpercentCorrect(kk, nn, cc),svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
                DApercentCorrect(kk, nn, cc) = cf2_DiscriminantAnalysis(trainingData,testingData,trainingClasses,testingClasses);
                NNpercentCorrect(kk, nn, cc) = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses);
                
                %% Perform pca analysis
                [coeff,d.score,~,~,d.explained] = pca([trainingData;testingData]);
                d.score = d.score(:,1:10);
                
                % We take the SVM discriminant function and project onto
                % the first 2 principal components. Then, we find the
                % vector orthogonal to the projected image.  This should
                % represent the decision boundary that the SVM uses to make
                % a decision.
                transformedBeta = coeff(:,1:2)'*svm.Beta;
                d.decisionBoundary = null(transformedBeta');
                pcaData{cc,kk,nn} = d;
            end
            fprintf('Calculation time for %s, dE %.2f = %2.1f\n', Colors{cc} , kk, toc);
        end
    end
    
    %% Save stuff
    stdText = {'nostd' 'std'};
    nameOfFile = sprintf('ClassifierAnalysis_%d_%d_%s_%s%s',trainingSetSize,testingSetSize,stdText{standardizeData+1},strtok(folders{ff},'_'),additionalNamingText{ff});
    fullSavePath = fullfile(analysisDir, 'ClassifierComparisons',nameOfFile);
    save(fullSavePath, 'DApercentCorrect', 'NNpercentCorrect', 'SVMpercentCorrect', 'pcaData', 'Colors','NoiseSteps');
end


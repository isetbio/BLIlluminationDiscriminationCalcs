%% TODO:
% Comment this function
clear;
%% Set some parameters for the calculation
% These two variables determine the size of the testing and training data
% sets respectively. For the NN calculation, a new sample will be generated
% for each testing set vector. The sample will use the same draw to form AB
% and BA vectors to decide which is closer to the testing set entry.
trainingSetSize = 250;
testingSetSize = 250;

% This determines the size of the sensor in degrees. The optical image will
% be scale to 1.1x this value to avoid having parts of the edge of the
% sensor miss any stimulus. This should be OK since the optical image pads
% the original stimulus with the average color at the edges.
sSize = 0.4;

% If set to true, variable Poisson noise will be used in the simulation. If
% set to false variable Gaussian noise, with a variance equal to the mean
% of all cone absorptions in the target scene will be used. However, 1x
% Poisson noise will still be enable to simulate photon transport.
usePoissonNoise = true;

% If set to true, the data will be standardized using the mean and standard
% deviation of the training set. This is generally used to help the
% performance of linear classifiers by making the feature space spherical.
standardizeData = true;

% Just some variables that tell the script which folders and data files to use
Colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Neutral_FullImage'}; 

%% Create a sensor
% Because we are formatting the data into AB/BA vectors, we need to know
% the size of the cone responses so that we can allocate space for vectors
% with 2x the number of entries as in a single sensor's cone response matrix.
sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, sSize, [], oiCreate('human'));
oi = loadOpticalImageData('Neutral/Standard','TestImage0');
sensorA = coneAbsorptions(sensor,oi);
photons = sensorGet(sensorA, 'photons');
responseSize = length(photons(:));

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
        standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize*1.1));
        calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / length(standardOIList);
    end
    
    DApercentCorrect = zeros(50,10,4);
    NNpercentCorrect = zeros(50,10,4);
    SVMpercentCorrect = zeros(50,10,4);
    pcaData = cell(4,50,10);
    for cc = 1:length(Colors)
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, [Colors{cc} 'Illumination']);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        for kk = 1:50
            comparison = loadOpticalImageData([folders{ff} '/' Colors{cc} 'Illumination'], strrep(OINames{kk}, 'OpticalImage.mat', ''));
            sensorComparison = coneAbsorptions(sensor, resizeOI(comparison,sSize*1.1));
            
            tic
            for nn = 1:10
                if usePoissonNoise
                    kp = nn; kg = 0;
                else
                    kg = nn; kp = 1;
                end
                
                %% Generate the data set
                % Data vectors will be in the formation of AB and BA, where
                % A represents a target illumination scene and B represents
                % a comparison illumination scene. Both training and
                % testing vector data sets will contain equal numbers of AB
                % and BA vectors. 
                trainingData = zeros(trainingSetSize, 2 * responseSize);
%                 trainingData = zeros(trainingSetSize,responseSize);
                trainingClasses = ones(trainingSetSize, 1);
                trainingClasses(1:trainingSetSize/2) = 0;
  
                for jj = 1:trainingSetSize/2
                    testSample = randsample(length(standardOIList), 2);
                    
                    sensorStandard = standardSensorPool{testSample(1)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    trainingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
%                     trainingData(jj,:) = photonsStandard(:)';
                    
                    sensorStandard = standardSensorPool{testSample(2)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    trainingData(jj + trainingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
%                     trainingData(jj + trainingSetSize/2,:) = photonsComparison(:)';
                end

                testingData = zeros(testingSetSize, 2 * responseSize);
%                 testingData = zeros(testingSetSize,responseSize);
                testingClasses = ones(testingSetSize, 1);
                testingClasses(1:testingSetSize/2) = 0;
                
                for jj = 1:testingSetSize/2
                    testSample = randsample(length(standardOIList), 2);
                    
                    sensorStandard = standardSensorPool{testSample(1)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    testingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
%                     testingData(jj,:) = photonsStandard(:)';
                    sensorStandard = standardSensorPool{testSample(2)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    testingData(jj + testingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
%                     testingData(jj + testingSetSize/2,:) = photonsComparison(:)';
                end
                
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
                % vector orthogonal to the project image.  This should
                % represent the decision boundary that the SVM uses to make
                % a desision.
                transformedBeta = coeff(:,1:2)'*svm.Beta;
                d.decisionBoundary = null(transformedBeta');
                pcaData{cc,kk,nn} = d;
            end
            fprintf('Calculation time for %s, dE %.2f = %2.1f\n', Colors{cc} , kk, toc);
        end
    end
    %% Save stuff
    nameOfFile = sprintf('ClassifierAnalysis_%d_%d_%d_%s',trainingSetSize,testingSetSize,standardizeData,folders{ff});
    save(nameOfFile, 'DApercentCorrect', 'NNpercentCorrect', 'SVMpercentCorrect', 'pcaData', 'Colors');
end


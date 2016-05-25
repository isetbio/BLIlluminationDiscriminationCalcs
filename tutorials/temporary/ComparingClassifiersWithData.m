%% TODO:
% Comment this function

%% Set some parameters for the calculation
% These two variables determine the size of the testing and training data
% sets respectively. For the NN calculation, a new sample will be generated
% for each testing set vector. The sample will use the same draw to form AB
% and BA vectors to decide which is closer to the testing set entry.
trainingSetSize = 100;
testingSetSize = 100;

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
colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Constant_FullImage'}; 
fileName = {''};

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

%% Load all target scene sensors
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
folderPath = fullfile(analysisDir, 'OpticalImageData', folders{1}, 'Standard');
data = what(folderPath);
standardOIList = data.mat;

standardSensorPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standard = loadOpticalImageData([folders{1} '/Standard'], strrep(standardOIList{jj}, 'OpticalImage.mat', ''));
    standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize*1.1));
    calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / length(standardOIList);
end

%% Perform calculation
DApercentCorrect = zeros(50,10,4);
NNpercentCorrect = zeros(50,10,4);
SVMpercentCorrect = zeros(50,10,4);
pcaData = cell(4,50,10);
for ff = 1:length(folders)
    for cc = 1:length(colors)
        for kk = 1:50
            comparison = loadOpticalImageData([folders{ff} '/' colors{cc} 'Illumination'], ['C' lower(colors{cc}) num2str(kk) fileName{ff} '-RGB']);
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
                trainingClasses = ones(trainingSetSize, 1);
                trainingClasses(1:trainingSetSize/2) = 0;
  
                for jj = 1:trainingSetSize/2
                    testSample = randsample(7, 2);
                    
                    sensorStandard = standardSensorPool{testSample(1)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    trainingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
                    
                    sensorStandard = standardSensorPool{testSample(2)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    trainingData(jj + trainingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
                end

                testingData = zeros(testingSetSize, 2 * responseSize);
                testingClasses = ones(testingSetSize, 1);
                testingClasses(1:testingSetSize/2) = 0;
                
                for jj = 1:testingSetSize/2
                    testSample = randsample(7, 2);
                    
                    sensorStandard = standardSensorPool{testSample(1)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    testingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
                    
                    sensorStandard = standardSensorPool{testSample(2)};
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, kp, kg);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    testingData(jj + testingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
                end
                
                % Standardize data if flag is set to true
                if standardizeData
                    m = mean(trainingData,1);
                    s = std(trainingData,1);
                    
                    trainingData = (trainingData - repmat(m, trainingSetSize, 1)) ./ repmat(s, trainingSetSize, 1);
                    testingData = (testingData - repmat(m, testingSetSize, 1)) ./ repmat(s, testingSetSize, 1);
                end
                
                %% Train the linear classifiers
                da = fitcdiscr(trainingData, trainingClasses, 'DiscrimType', 'pseudolinear');
                svm = fitcsvm(trainingData, trainingClasses);

                %% Test the linear classifiers
                classifiedClasses = predict(da, testingData);
                DApercentCorrect(kk, nn, cc) = sum(classifiedClasses == testingClasses) / testingSetSize * 100;
                classifiedClasses = predict(svm, testingData);
                SVMpercentCorrect(kk, nn, cc) = sum(classifiedClasses == testingClasses) / testingSetSize * 100;
                
                %% Distance based classification
                correct = 0;
                for tt = 1:testingSetSize
                    standardChoice = randsample(7,1);
                    photonsS = getNoisySensorImage(calcParams, standardSensorPool{standardChoice}, kp, kg);
                    photonsC = getNoisySensorImage(calcParams, sensorComparison, kp, kg);
                    
                    AB = [photonsS(:); photonsC(:)]';
                    BA = [photonsC(:); photonsS(:)]';
                    
                    if standardizeData
                        AB = (AB - m) ./ s;
                        BA = (BA - m) ./ s;
                    end
                    
                    distToAB = norm(testingData(tt,:) - AB);
                    distToBA = norm(testingData(tt,:) - BA);
                    
                    if (distToAB > distToBA) == logical(testingClasses(tt))
                        correct = correct + 1;
                    end
                end
                NNpercentCorrect(kk, nn, cc) = correct / testingSetSize * 100;
                
                %% Perform pca analysis
                [~,~,d.latent,~,d.explained] = pca([trainingData;testingData]);
                pcaData{cc,kk,nn} = d;
            end
            fprintf('Calculation time for %s, dE %.2f = %2.1f\n', colors{cc} , kk, toc);
        end
    end
end

%% Save stuff
save('ClassifierAnalysis', 'DApercentCorrect', 'NNpercentCorrect', 'SVMpercentCorrect', 'pcaData');
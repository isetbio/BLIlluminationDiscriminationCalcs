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
trainingSetSize = 100;
testingSetSize = 100;

% This determines the size of the sensor in degrees. The optical image will
% be scaled to OIvSensorScale times this value to avoid having parts of the edge of the
% sensor miss any stimulus. This should be OK since the optical image pads
% the original stimulus with the average color at the edges.
sSize = 0.07;
OIvSensorScale = 1.3;

% If set to true, variable Poisson noise will be used in the simulation. If
% set to false variable Gaussian noise, with a variance equal to the mean
% of all cone absorptions in the target scene will be used. However, 1x
% Poisson noise will still be enable to simulate photon noise.
usePoissonNoise = true;

% If set to true, the data will be standardized using the mean and standard
% deviation of the training set. This is generally used to help the
% performance of linear classifiers by making the feature space spherical.
standardizeData = true;

% Additional text to add to the end of the name of the saved data file.
% This will help add specificity if the current naming scheme is not
% enough. 
additionalNamingText = '_NewOI';

% Just some variables that tell the script which folders and data files to use
Colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Neutral' 'NM1' 'NM2'}; % Rename to OIFolders?

% These variables specify the number of illumination steps and the noise
% multipliers to use. Generally keep the number of steps constant and vary
% the noise as necessary.
numIllumSteps = 50;
NoiseSteps = 1:2:20;

%% Create a sensor
% Create a sensor here. This sensor will be used to calculate the
% isomerizations for every optical image later in the calculation.  This
% keeps parameters related to the sensor constant.
rng(1);
%% Using the coneMosaic object here
sensor = coneMosaic;
sensor.setSizeToFOV(sSize);
sensor.integrationTime = 0.050;
sensor.wave = SToWls([380 8 51]);
sensor.noiseFlag = 0;

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
        standardSensorPool{jj} = sensor.compute(standard,'currentFlag',false);
        calcParams.meanStandard = calcParams.meanStandard + mean2(standardSensorPool{jj}) / length(standardOIList);
    end
    
    %% Calculation body
    
    % Pre-allocate space for results
    DApercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    NNpercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    SVMpercentCorrect = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    pcaData = cell(length(Colors),numIllumSteps,length(NoiseSteps));
    DApca = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    NNpca = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    SVMpca = zeros(numIllumSteps,length(NoiseSteps),length(Colors));
    for cc = 1:length(Colors)
        
        % Load all Optical image names in the target directory in
        % alphanumerical order. This corresponds to increasing illumination steps.
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', folders{ff}, [Colors{cc} 'Illumination']);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        
        for kk = 1:numIllumSteps
            
            comparison = loadOpticalImageData([folders{ff} '/' Colors{cc} 'Illumination'], strrep(OINames{kk}, 'OpticalImage.mat', ''));
            sensorComparison = sensor.compute(comparison,'currentFlag',false);

            tic
            for nn = 1:length(NoiseSteps)
                if usePoissonNoise
                    kp = NoiseSteps(nn); kg = 0;
                else
                    kg = NoiseSteps(nn); kp = 1;
                end
                
                %% Generate the data set
                [trainingData,trainingClasses] = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,trainingSetSize);
                [testingData,testingClasses]   = df1_ABBA(calcParams,standardSensorPool,{sensorComparison},kp,kg,testingSetSize);
                
                % Standardize data if flag is set to true
                if standardizeData
                    m = mean(trainingData,1);
                    s = std(trainingData,1);
                    
                    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                    testingData  = (testingData  - repmat(m,testingSetSize,1))  ./ repmat(s,testingSetSize,1);
                end
                
                %% Apply classifiers
                [SVMpercentCorrect(kk, nn, cc),svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
                DApercentCorrect(kk, nn, cc) = cf2_DiscriminantAnalysis(trainingData,testingData,trainingClasses,testingClasses);
                NNpercentCorrect(kk, nn, cc) = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses);
                
                %% Perform pca analysis
                [coeff,d.score,~,~,d.explained] = pca([trainingData;testingData]);
                d.score = d.score(:,1:10);
%                 d.firstPC = coeff(:,1);
                % We take the SVM discriminant function and project onto
                % the first 2 principal components. Then, we find the
                % vector orthogonal to the projected image.  This should
                % represent the decision boundary that the SVM uses to make
                % a decision. It seems that the SVM sometimes has issues
                % classifying the noAB vectors in high dimensional space,
                % but is capable of doing the calculation using projections
                % onto the PCA vectors.
                
%                 svm.Beta = [];
                if ~isempty(svm.Beta)
                    projectedBeta = coeff(:,1:2)'*svm.Beta;
                    d.decisionBoundary = null(projectedBeta');
                else
                    d.decisionBoundary = [0 0];
                end
                pcaData{cc,kk,nn} = d;
                
                % Run classification on the projections of data points on
                % to the first two principal components.
%                 SVMpca(kk, nn, cc) = cf3_SupportVectorMachine(d.score(1:trainingSetSize,1:2),d.score(trainingSetSize+1:end,1:2),trainingClasses,testingClasses);
%                 DApca(kk, nn, cc) = cf2_DiscriminantAnalysis(d.score(1:trainingSetSize,1:2),d.score(trainingSetSize+1:end,1:2),trainingClasses,testingClasses);
%                 NNpca(kk, nn, cc) = cf1_NearestNeighbor(d.score(1:trainingSetSize,1:2),d.score(trainingSetSize+1:end,1:2),trainingClasses,testingClasses);
            end
            fprintf('Calculation time for %s, dE %.2f = %2.1f\n', Colors{cc} , kk, toc);
        end
    end
    
    %% Save stuff
    stdText = {'nostd' 'std'};
    nameOfFile = sprintf('ClassifierAnalysis_%d_%d_%s_%s%s',trainingSetSize,testingSetSize,stdText{standardizeData+1},strtok(folders{ff},'_'),additionalNamingText);
    fullSavePath = fullfile(analysisDir, 'ClassifierComparisons',nameOfFile);
%     save(fullSavePath, 'DApercentCorrect', 'NNpercentCorrect', 'SVMpercentCorrect',...
%         'pcaData', 'Colors','NoiseSteps','SVMpca','NNpca','DApca');

    save(nameOfFile, 'DApercentCorrect', 'NNpercentCorrect', 'SVMpercentCorrect',...
        'pcaData', 'Colors','NoiseSteps');
end


%% t_ComparingClassifiersWithData
%
% Looks at how three different classfiers perform using the same set of
% data. This gives us an idea of the strengths and weaknesses of each
% classifier.  The three classifiers used in this script are a kNN, a
% linear discriminant, and a SVM. The latter two are linear classifiers and
% while the kNN can also be linear, it often is not.
%
% 6/XX/16  xd  wrote it

clear; close all;
%% Set some parameters for the calculation
%
% These two variables determine the size of the testing and training data
% sets respectively. For the NN calculation, we compute the pairwise
% distance between each vector in the training and testing sets. Then for
% each entry in the testing set, we look at which vector it is closest to
% in the training set. If the AB/BA format for both the test and training
% vector is the same, we consider the classification as correct.
trainingSetSize = 1000;
testingSetSize  = 1000;

% This determines the size of the sensor in degrees. The optical image will
% be scaled to OIvSensorScale times this value to avoid having parts of the
% edge of the sensor miss any stimulus. This should be OK since the optical
% image pads the original stimulus with the average color at the edges.
sSize = 1;
OIvSensorScale = 1.3;

% If set to true, the data will be standardized using the mean and standard
% deviation of the training set. This is generally used to help the
% performance of linear classifiers by removing inherent bias due to
% differences in feature magnitudes.
standardizeData = true;

% Additional text to add to the end of the name of the saved data file.
% This will help add specificity if the current naming scheme is not
% enough.
additionalNamingText = '_NewOI';

% Just some variables that tell the script which folders and data files to use
colors  = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Constant_CorrectSize'};

% These variables specify the number of illumination steps and the noise
% multipliers to use. Generally keep the number of steps constant and vary
% the noise as necessary.
illumSteps = 1:2:50;
noiseSteps = 1:2:20;

% Number of PCA components to use
numPCA = 400;

%% Frozen noise
%
% We'd like to keep the noise frozen so that the results can be replicated.
% Because we are doing machine learning classification with large data
% sets, it is likely that the variation due to random noise is not enough
% to offset the results by a significant amount even if the noise is not
% frozen.
rng(1);

%% Using the coneMosaic object here
mosaic = getDefaultBLIllumDiscrMosaic;
%mosaic.fov = sSize;
if (sSize ~= 1)
    error('Standard mosaic has size of 1 and we cannot change it anymore');
end

%% Perform calculation
for ff = 1:length(folders)
    %% Load all target scene sensors
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    folderPath = fullfile(analysisDir,'OpticalImageData',folders{ff},'Standard');
    data = what(folderPath);
    standardOIList = data.mat;
    
    standardPhotonPool = cell(1,length(standardOIList));
    calcParams.meanStandard = 0;
    for jj = 1:length(standardOIList)
        standardOI = loadOpticalImageData([folders{ff} '/Standard'],strrep(standardOIList{jj},'OpticalImage.mat',''));
        mosaic.compute(standardOI,'currentFlag',false);
        standardPhotonPool{jj} = mosaic.absorptions(mosaic.pattern > 0);
        calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
    end
    
    %% Calculation body
    
    % Pre-allocate space for results
    DApercentCorrect = zeros(length(illumSteps),length(noiseSteps),length(colors));
    NNpercentCorrect = zeros(length(illumSteps),length(noiseSteps),length(colors));
    SVMpercentCorrect = zeros(length(illumSteps),length(noiseSteps),length(colors));
    
    for cc = 1:length(colors)
        
        % Load all Optical image names in the target directory in
        % alphanumerical order. This corresponds to increasing illumination steps.
        comparisonOIPath = fullfile(analysisDir,'OpticalImageData',folders{ff},[colors{cc} 'Illumination']);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        
        for kk = illumSteps
            
            % Load the OI for this illumination step
            comparison = loadOpticalImageData([folders{ff} '/' colors{cc} 'Illumination'],strrep(OINames{kk},'OpticalImage.mat',''));
            mosaic.compute(comparison,'currentFlag',false);
            photonComparison = mosaic.absorptions(mosaic.pattern > 0);
            
            tic
            for nn = 1:length(noiseSteps)
                kg = noiseSteps(nn); kp = 1;
                
                %% Generate the data set
                [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},kp,kg,trainingSetSize);
                [testingData,testingClasses]   = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},kp,kg,testingSetSize);
                
                % Standardize data if flag is set to true
                if standardizeData
                    m = mean(trainingData,1);
                    s = std(trainingData,1);
                    
                    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                    testingData  = (testingData  - repmat(m,testingSetSize,1))  ./ repmat(s,testingSetSize,1);
                end
                
                %% Perform pca dimension reduction
                %
                % We calculate the first numPCA components. These should
                % explain the most variance out of all the components. We
                % then project our original dataset onto there component.
                coeff = pca(trainingData,'NumComponents',numPCA);
                trainingData = trainingData*coeff;
                testingData  = testingData*coeff;
                
                %% Apply classifiers
                SVMpercentCorrect(kk, nn, cc) = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
                DApercentCorrect(kk, nn, cc) = cf2_DiscriminantAnalysis(trainingData,testingData,trainingClasses,testingClasses);
                NNpercentCorrect(kk, nn, cc) = cf1_NearestNeighbor(trainingData,testingData,trainingClasses,testingClasses);
            end
            fprintf('Calculation time for %s, dE %.2f = %2.1f\n', colors{cc} , kk, toc);
        end
    end
    
    %% Save stuff
    stdText = {'nostd' 'std'};
    nameOfFile = sprintf('ClassifierAnalysis_%d_%d_%s_%s%s',...
                         trainingSetSize,testingSetSize,...
                         stdText{standardizeData+1},...
                         strtok(folders{ff},'_'),additionalNamingText);
    fullSavePath = fullfile(analysisDir,'ClassifierComparisons',nameOfFile);
    save(fullSavePath,'DApercentCorrect','NNpercentCorrect','SVMpercentCorrect',...
        'colors','noiseSteps');

end


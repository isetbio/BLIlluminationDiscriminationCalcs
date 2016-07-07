function results = m1_FirstOrderModel(calcParams,mosaic,color)
% results = m1_FirstOrderModel(calcParams,sensor,color)
%
% This function performs the computational observer calculation on a 'First
% Order' level. By this, we mean that a static cone mosaic (without eye
% movement) is used to calculate the number of isomerizations given a
% scene. This information is used in desired classification function to
% simulate our illumination discrimination experiment.
%
% xd  6/23/16  moved out of old code

%% Set values for variables that will be used through the function
illumLevels = calcParams.illumLevels;
KpLevels = calcParams.KpLevels;
KgLevels = calcParams.KgLevels;
trainingSetSize = calcParams.trainingSetSize;
testingSetSize = calcParams.testingSetSize;
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

%% Load standard optical images
% We will load the pool of standard OI's here. The reason we have multiple
% copies of these is to reduce the effect of rendering noise when we
% perform the calculations. We also calculate the mean photon isomerization
% here to be used for Gaussian noise later on.
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},'Standard');
standardOIList = getFilenamesInDirectory(folderPath);
standardPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for ii = 1:length(standardOIList)
    opticalImageName = standardOIList{ii};
    opticalImageName = strrep(opticalImageName,'OpticalImage.mat','');
    oi = loadOpticalImageData(fullfile(calcParams.cacheFolderList{2},'Standard'),opticalImageName);
    oi = resizeOI(oi,calcParams.sensorFOV*calcParams.OIvSensorScale);
    
    absorptionsStandard = mosaic.compute(oi,'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(absorptionsStandard)/length(standardOIList);
    standardPool{ii} = absorptionsStandard;
end

%% Get a list of images
% Here we load all the names of the optical images in the given folder
% name. These are loaded alphanumerically so we can just index them freely.
% Note: Alphanumerical loading presumes that the files are named in
% alphanumeric order (image1, image2, image3,... etc.).
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},[color 'Illumination']);
OINamesList = getFilenamesInDirectory(folderPath);

%% Do the actual calculation here
results = zeros(length(illumLevels),length(KpLevels),length(KgLevels));
for ii = 1:length(illumLevels);
<<<<<<< HEAD
=======
%     fprintf('Running trials for %s illumination step %u\n',color,illumLevels(ii));
>>>>>>> Trying to keep this up to date before branching
    
    % Precompute the test optical image to save computational time.
    imageName = OINamesList{illumLevels(ii)};
    imageName = strrep(imageName,'OpticalImage.mat','');
    oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' [color 'Illumination']],imageName);
    oiTest = resizeOI(oiTest,calcParams.sensorFOV*calcParams.OIvSensorScale);
<<<<<<< HEAD
    absorptionsTest = mosaic.compute(oiTest,'currentFlag',false);
=======
    sensorTest = coneAbsorptions(sensor,oiTest);
>>>>>>> Trying to keep this up to date before branching
    
    % Loop through the two different noise levels and perform the
    % calculation at each combination.
    tic
    for jj = 1:length(KpLevels)
        Kp = KpLevels(jj);
        
        for kk = 1:length(KgLevels);
            Kg = KgLevels(kk);
            
<<<<<<< HEAD
=======
            
>>>>>>> Trying to keep this up to date before branching
            % Choose the data generation function
            datasetFunction = masterDataFunction(calcParams.dFunction);
            [trainingData, trainingClasses] = datasetFunction(calcParams,standardPool,{absorptionsTest},Kp,Kg,trainingSetSize);
            [testingData, testingClasses]   = datasetFunction(calcParams,standardPool,{absorptionsTest},Kp,Kg,testingSetSize);
            
            % Standardize data if flag is set to true
            if calcParams.standardizeData
                m = mean(trainingData,1);
                s = std(trainingData,1);
                trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                testingData  = (testingData - repmat(m,testingSetSize,1))   ./ repmat(s,testingSetSize,1);
            end
            
            if calcParams.usePCA
                coeff = pca(trainingData,'NumComponents',calcParams.numPCA);
                trainingData = trainingData*coeff;
                testingData = testingData*coeff;
            end
            
            % Compute performance based on chosen classifier method
            classifierFunction = masterClassifierFunction(calcParams.cFunction);
            results(ii,jj,kk) = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);
<<<<<<< HEAD
        end
    end
    % Print the time the calculation took
    fprintf('Calculation time for %s illumination step %u: %04.3f s\n',color,illumLevels(ii),toc);
=======
            
            
        end
    end
    % Print the time the calculation took
    fprintf('Calculation time for %s illumination step %u\n',color,illumLevels(ii));
>>>>>>> Trying to keep this up to date before branching
end
end


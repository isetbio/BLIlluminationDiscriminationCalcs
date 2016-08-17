%% DON'T KNOW WHERE TO PUT THIS BUT THIS IS WEIRD
%
% For some reason, the classification for blue 41 - 43 DROPS a large amount
% >10%. This MAKES NO SENSE. It does not occur for other color directions
% either. MY HEAD HURTS FROM THIS ERROR. Trying to reproduce it here to
% start figuring out where the bug may be!!!
%
% 7/20/16  xd  wrote it

ieInit; clear;
%% Make the mosaic according to conditions
[~,calcParams] = loadModelData('SVM_NoEM_Isom_CompareToEM_100ms');

% Modify preset parameters here to test things
calcParams.rowPadding = 0;
calcParams.colPadding = 0;
calcParams.cFunction = 5;
calcParams.numEMPositions = 1;
calcParams.coneIntegrationTime = 0.050;

% Use calcParams to do things in calculation
mosaic = coneMosaic;
mosaic.fov = calcParams.sensorFOV;
mosaic.integrationTime = calcParams.coneIntegrationTime;
mosaic.sampleTime = calcParams.coneIntegrationTime;

Kp = 1;
Kg = 24;
trainingSetSize = calcParams.trainingSetSize;
testingSetSize = calcParams.testingSetSize;

%% Load the OI in question (41,43) as well as target OI
OIFolder = 'SVM_Static_Isomerizations_Neutral_CV_60';

% Load all target scene sensors
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
standardOIList = getFilenamesInDirectory(folderPath);

standardPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standardPool{jj} = loadOpticalImageData([OIFolder '/Standard'],strrep(standardOIList{jj},'OpticalImage.mat',''));
    standardPool{jj} = mosaic.computeSingleFrame(standardPool{jj},'FullLMS',true);
    
    % Need to multiply mask with actual mosaic
    tempMask = zeros([size(mosaic.pattern) 3]);
    for ii = 2:4
        tempMask(:,:,ii-1) = single(mosaic.pattern==ii);
    end
    calcParams.meanStandard = calcParams.meanStandard + mean2(sum(standardPool{jj}.*tempMask,3))/length(standardPool);
end

comparison41 = loadOpticalImageData([OIFolder '/BlueIllumination'],'blue41L-RGB');
comparison43 = loadOpticalImageData([OIFolder '/BlueIllumination'],'blue43L-RGB');

comparison41 = mosaic.computeSingleFrame(comparison41,'FullLMS',true);
comparison43 = mosaic.computeSingleFrame(comparison43,'FullLMS',true);

%% Do classification for 41
datasetFunction = masterDataFunction(calcParams.dFunction);
[trainingData,trainingClasses] = datasetFunction(calcParams,standardPool,{comparison41},Kp,Kg,trainingSetSize,mosaic);
[testingData,testingClasses]   = datasetFunction(calcParams,standardPool,{comparison41},Kp,Kg,testingSetSize,mosaic);

% Standardize data if flag is set to true
if calcParams.standardizeData
    m = mean(trainingData,1);
    s = std(trainingData,1);
    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
    testingData  = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
end

if calcParams.usePCA
    [~,~,coeff] = fsvd(trainingData,2.5*calcParams.numPCA);
    trainingData = trainingData*coeff;
    testingData = testingData*coeff;
end

% Perform classification
classifierFunction = masterClassifierFunction(calcParams.cFunction);
performance41 = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);

%% Do classification for 43
datasetFunction = masterDataFunction(calcParams.dFunction);
[trainingData,trainingClasses] = datasetFunction(calcParams,standardPool,{comparison43},Kp,Kg,trainingSetSize,mosaic);
[testingData,testingClasses]   = datasetFunction(calcParams,standardPool,{comparison43},Kp,Kg,testingSetSize,mosaic);

% Standardize data if flag is set to true
if calcParams.standardizeData
    m = mean(trainingData,1);
    s = std(trainingData,1);
    trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
    testingData  = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
end

if calcParams.usePCA
    [~,~,coeff] = fsvd(trainingData,2.5*calcParams.numPCA);
    trainingData = trainingData*coeff;
    testingData = testingData*coeff;
end

% Perform classification
classifierFunction = masterClassifierFunction(calcParams.cFunction);
performance43 = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);
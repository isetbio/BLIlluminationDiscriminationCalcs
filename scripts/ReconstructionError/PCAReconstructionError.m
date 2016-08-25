%% PCAReconstructionError
%
% Generates a sample data set of cone mosaic responses and performs PCA
% as done in the model code. Then reconstructs the original data using the
% principal components and calculates the error from the reconstruction.
% This should give an idea of whether the PCA for static data sets and eye
% movement data sets are having an effect on the classification
%
% 7/17/16  xd  wrote it

ieInit;
%% Set parameters for the data set to generate

% Some parameters common to both static and eye movement calculations
numPCA = 100;
wave = [380 8 51];
dataSetSize = 1000;

% Some paramters of the static cone mosaic.
staticMosaicParams.fov = 0.83;
staticMosaicParams.integrationTimeInSeconds = 0.050;

% Some parameters of the eye movement cone mosaic. We want to keep the fov
% for both mosaic the same to ensure they are the same size.
emMosaicParams.fov = staticMosaicParams.fov;
emMosaicParams.integrationTimeInSeconds = 0.010;
emMosaicParams.numberOfEM = 5;
emMosaicParams.currentFlag = true;
emMosaicParams.osType = 'linear';

%% Create the cone mosaics
%
% Create a cone mosaic object so that the cone pattern for both mosaics is
% identical.
masterMosaic = coneMosaic;
masterMosaic.fov = staticMosaicParams.fov;

% Static Mosaic
staticMosaic = masterMosaic.copy;
staticMosaic.integrationTime = staticMosaicParams.integrationTimeInMS;

% EM Mosaic
emMosaic = masterMosaic.copy;
emMosaic.integrationTime = emMosaicParams.integrationTimeInMS;
emMosaic.os = osCreate(emMosaicParams.osType);

%% Load optical image data.
%
% Load optical images here since we will do the calculations with a variety
% of sensors and conditions to test reconstruction error.

% Load all target scene sensors
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData','Neutral_FullImage','Standard');
standardOIList = getFilenamesInDirectory(folderPath);

standardOIPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    standardOIPool{jj} = loadOpticalImageData('Neutral_FullImage/Standard',strrep(standardOIList{jj},'OpticalImage.mat',''));
end

comparisonOI = loadOpticalImageData('Neutral_FullImage/BlueIllumination','blue1L-RGB');

%% Calculations
%
% Generate data sets for Static Isomerizations, EM Isomerizations, and EM
% OSlinear and check if the error in reconstruction using the PCA
% components varies greatly amongst the three cases.

%% Static Isomerizations case
staticStandardIsomerizations = cellfun(@(X)staticMosaic.compute(X,'currentFlag',false),standardOIPool,'UniformOutput',false);
staticComparisonIsomerizations = staticMosaic.compute(comparisonOI,'currentFlag',false);

calcParams.meanStandard = mean(cellfun(@(X)mean2(X),staticStandardIsomerizations));

staticDataset = df1_ABBA(calcParams,staticStandardIsomerizations,{staticComparisonIsomerizations},1,0,dataSetSize);

% Standardize the data
m = mean(staticDataset);
s = std(staticDataset);
staticDataset = (staticDataset - repmat(m,dataSetSize,1)) ./ repmat(s,dataSetSize,1);

% Do pca
staticCoeff = pca(staticDataset,'NumComponents',numPCA);
projectedStaticDataset = staticDataset*staticCoeff;

% Reconstruct data and calculate error
reconstructStaticData = projectedStaticDataset*staticCoeff';
staticError = norm(staticDataset(:)-reconstructStaticData(:))/norm(staticDataset(:));

clearvars staticDataset staticCoeff m s reconstructStaticData

%% EM Isomerizations case
calcParams.enableOS = false;
calcParams.numEMPositions = emMosaicParams.numberOfEM;
calcParams.rowPadding = 0;
calcParams.colPadding = 0;
calcParams.useSameEMPath = true;
calcParams.coneIntegrationTime = emMosaicParams.integrationTimeInSeconds;
calcParams.em = emCreate;

EMStandardIsomerizations = cellfun(@(X)emMosaic.computeSingleFrame(X,'FullLMS',true),standardOIPool,'UniformOutput',false);
EMComparisonIsomerizations = emMosaic.computeSingleFrame(comparisonOI,'FullLMS',true);

% We use df4 which is coded specifically for eye movement data. This is
% because the temporal dimension greatly expands the number of floats we
% need to track, thereby resulting in a corresponding increase in RAM
% consumption. This makes the AB/BA paradigm risky to use (with regards to
% running out of RAM and such things).
EMIsomDataset = df4_EyeMoveData(calcParams,EMStandardIsomerizations,{EMComparisonIsomerizations},1,0,dataSetSize,emMosaic);

% Standardize the data
m = mean(EMIsomDataset);
s = std(EMIsomDataset);
EMIsomDataset = (EMIsomDataset - repmat(m,dataSetSize,1)) ./ repmat(s,dataSetSize,1);

% Do pca
EMIsomCoeff = pca(EMIsomDataset,'NumComponents',numPCA);
projectedEMIsomDataset = EMIsomDataset*EMIsomCoeff;

% Reconstruct data and calculate error
reconstructEMIsomData = projectedEMIsomDataset*EMIsomCoeff';
EMIsomError = norm(EMIsomDataset(:)-reconstructEMIsomData(:))/norm(EMIsomDataset(:));

clearvars EMIsomDataset EMIsomCoeff m s reconstructEMIsomData

%% EM Cone Current Case
%
% We'll use the same settings as the EM Isomerizations case but with the OS
% turned on.
calcParams.enableOS = true;
EMCurrDataset = df4_EyeMoveData(calcParams,EMStandardIsomerizations,{EMComparisonIsomerizations},1,0,dataSetSize,emMosaic);

% Standardize the data
m = mean(EMCurrDataset);
s = std(EMCurrDataset);
EMCurrDataset = (EMCurrDataset - repmat(m,dataSetSize,1)) ./ repmat(s,dataSetSize,1);

% Do pca
EMCurrCoeff = pca(EMCurrDataset,'NumComponents',numPCA);
projectedEMCurrDataset = EMCurrDataset*EMCurrCoeff;

% Reconstruct data and calculate error
reconstructEMCurrData = projectedEMCurrDataset*EMCurrCoeff';
EMCurrError = norm(EMCurrDataset(:)-reconstructEMCurrData(:))/norm(EMCurrDataset(:));

clearvars EMIsomDataset EMIsomCoeff m s reconstructEMCurrData
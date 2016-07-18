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
staticMosaicParams.integrationTimeInMS = 0.050;

% Some parameters of the eye movement cone mosaic. We want to keep the fov
% for both mosaic the same to ensure they are the same size.
emMosaicParams.fov = staticMosaicParams.fov;
emMosaicParams.integrationTimeInMS = 0.010;
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

% Static Isomerizations case
staticStandardIsomerizations = cellfun(@(X)staticMosaic.compute(X,'currentFlag',false),standardOIPool,'UniformOutput',false);
staticComparisonIsomerizations = staticMosaic.compute(comparisonOI,'currentFlag',false);

calcParams.meanStandard = mean(cellfun(@(X)mean2(X),staticStandardIsomerizations));

staticDataset = df1_ABBA(calcParams,staticStandardIsomerizations,{staticComparisonIsomerizations},1,0,dataSetSize);
[staticCoeff,score] = pca(staticDataset,'NumComponents',numPCA);
projectedDataset = staticDataset*staticCoeff;


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

%% Calculation

%% t_SummedNoiseVariances
%
% Looks at the noise of 100 ms v 10x 10 ms slices to examine whether the
% sum of the 10 ms noise is indeed equal to the 100 ms noise as is expected
% for both Poisson and Gaussian distributions.
%
% 7/26/16  xd  wrote it

ieInit; clear; close all;
%% Set up parameters
%
% These determine the settings of calculation that this script performs. We
% can determine the number of times to this scipt tests the noise, the size
% of the Gaussian noise, as well as the size of the mosaic.
numberOfNoiseDraws = 10;
gaussianNoiseFactor = 1;
fov = 1;

% The integration time of the mosaics. The number of EM positions and the
% integration time of the EM mosaic should multiply to equal the
% integration time of the static mosaic.
staticMosaicParams.integrationTime = 0.100;
emMosaicParams.integrationTime = 0.010;
emMosaicParams.numberOfEMPositions = 10;

%% Create the cone mosaics
%
% Create a cone mosaic object so that the cone pattern for both mosaics is
% identical.
masterMosaic = coneMosaic;
masterMosaic.fov = fov;
masterMosaic.noiseFlag = false;

% Static Mosaic
staticMosaic = masterMosaic.copy;
staticMosaic.integrationTime = staticMosaicParams.integrationTime;

% EM Mosaic. We set all the EM positions to 0 because we want to simulate a
% static mosaic with sliced integration time.
emMosaic = masterMosaic.copy;
emMosaic.integrationTime = emMosaicParams.integrationTime;
emMosaic.emPositions = zeros(emMosaicParams.numberOfEMPositions,2);

%% Load OI
%
% We load an arbitrary optical image used in the model. The results in this
% script should hold irregardless of OI choice.
OI = loadOpticalImageData('Neutral_FullImage/Standard','TestImage0');

%% Calculate NF Isomerizations
%
% We compute the noise free currents. These will be used to determine the
% noise we will be testing.
staticIsom = staticMosaic.compute(OI,'currentFlag',false);
EMIsom = emMosaic.compute(OI,'currentFlag',false);

% Set variance to Gaussian noise to the mean isomerization signal for a
% single slice
staticGaussianVar = mean2(staticIsom);
emGaussianVar = mean2(EMIsom(:,:,1));

% Verify that the noise free signals are equal (something has gone wrong if
% this is not the case).
fprintf('Norm of difference between to matrices : %5.5f\n',norm(staticIsom - sum(EMIsom,3),'fro'));

% Print a few lines on how we're testing distribution equality.
fprintf('The following lines will display results of a Kolmogorov-Smirnov test, \nwith a null hypothesis of being from the same distribution.\n');
fprintf('1 is reject, 0 is accept\n');

%% Generate some noise draws for Poisson case
fprintf('Generating Poisson Noise\n');
staticNoise = cell(numberOfNoiseDraws,1);
emNoise = cell(numberOfNoiseDraws,1);
for ii = 1:numberOfNoiseDraws
    [~,staticNoise{ii}] = coneMosaic.photonNoise(staticIsom);
    [~,tempEMNoise] = coneMosaic.photonNoise(EMIsom);
    emNoise{ii} = sum(tempEMNoise,3);
    [h,p] = kstest2(staticNoise{ii}(:),emNoise{ii}(:));
    fprintf('The null hypothesis is : %d with p-value : %5.5f\n',h,p);
end

%% Generate some noise draws for Gaussian case
fprintf('Generating Gaussian Noise\n');
staticNoise = cell(numberOfNoiseDraws,1);
emNoise = cell(numberOfNoiseDraws,1);
for ii = 1:numberOfNoiseDraws
    staticNoise{ii} = gaussianNoiseFactor * sqrt(staticGaussianVar) * randn(size(staticIsom));
    tempEMNoise = gaussianNoiseFactor * sqrt(emGaussianVar) * randn(size(EMIsom));
    emNoise{ii} = sum(tempEMNoise,3);
    [h,p] = kstest2(staticNoise{ii}(:),emNoise{ii}(:));
    fprintf('The null hypothesis is : %d with p-value : %5.5f\n',h,p);
end
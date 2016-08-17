%% SignalToNoiseComparison
%
% Looks at signal to noise ratio for isomerizations and cone currents and
% their respective noises. Also looks at SNR when the noise gets scaled by
% a constant factor. Looks at noise in each cone present in the mosaic.
%
% 7/25/16  xd  wrote it

% ieInit; close all; clear;
%% 
rng(1);

fov = 0.10; 
integrationTimeInSeconds = 0.001;
numberOfEMPositions = 1000;
osType = 'biophys';
comparisonStimLevel = 50;

%% Load optical images and create mosaic
% Create a cone mosaic that will be used to calculate things throughout the
% entire script. We also create a large mosaic which will be used to
% generate the LMS for quickly calculating EM samples.
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
mosaic.sampleTime      = integrationTimeInSeconds;
mosaic.noiseFlag       = false;
mosaic.os              = osCreate(osType);
largeMosaic            = mosaic.copy;

% Load all optical images we will used
analysisDir    = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath     = fullfile(analysisDir,'OpticalImageData','Neutral_FullImage','Standard');
standardOIList = getFilenamesInDirectory(folderPath);

OI = loadOpticalImageData('Neutral_FullImage/Standard',strrep(standardOIList{1},'OpticalImage.mat',''));
OI2 = loadOpticalImageData('Neutral_FullImage/BlueIllumination',['blue' num2str(comparisonStimLevel) 'L-RGB']);

% Resize the large OI so that the difference in size is even.
largeMosaic.fov = oiGet(OI,'fov');
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;
if mod(colPadding,1), largeMosaic.cols = largeMosaic.cols + 1; end
if mod(rowPadding,1), largeMosaic.rows = largeMosaic.rows + 1; end
colPadding = (largeMosaic.cols-mosaic.cols)/2;
rowPadding = (largeMosaic.rows-mosaic.rows)/2;

LMS = largeMosaic.computeSingleFrame(OI,'FullLMS',true);
CompLMS = largeMosaic.computeSingleFrame(OI2,'FullLMS',true);
gaussianStd = sqrt(mean2(largeMosaic.applyEMPath(LMS,'padRows',0,'padCols',0)));

%% Calculate mean isomerizations and cone current data for first OI
mosaic.emGenSequence(numberOfEMPositions);
fixationalEM = mosaic.emPositions;
saccade = zeros(size(fixationalEM));
saccade(151:650,:) = repmat([500 500],500,1);
mosaic.emPositions = fixationalEM + saccade;

isomerizationData = mosaic.applyEMPath(LMS,'padRows',rowPadding,'padCols',colPadding);
coneCurrentData   = mosaic.os.compute(isomerizationData/integrationTimeInSeconds,mosaic.pattern);
compIsomerizationData = mosaic.applyEMPath(CompLMS,'padRows',rowPadding,'padCols',colPadding);
compConeCurrentData   = mosaic.os.compute(compIsomerizationData/integrationTimeInSeconds,mosaic.pattern);

%% Loop over results and calculate SNR
ZIsomDiff = compIsomerizationData - isomerizationData;
[~,ZPoissNoise] = coneMosaic.photonNoise(isomerizationData);
ZGaussian = gaussianStd * randn(size(ZIsomDiff));
snr(ZIsomDiff,ZPoissNoise)
snr(ZIsomDiff,ZPoissNoise+ZGaussian)
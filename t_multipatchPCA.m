%% t_multipatchPCA
%
% Performs pca from all the patches in a given image. This will require the
% classification to use the same mosaic throughout.

ieInit; clear; close all;
%% Parameters
numberOfSamplesPerStimulusLevel = 1;
illuminationColors = {'blue' 'green' 'red' 'yellow'};
calcIDStr = 'SVM_Static_Isom_S';

fov = 0.83;
integrationTimeInSeconds = 0.050;

%% Create a mosaic
% rng(1);
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
% mosaic.sampleTime      = integrationTimeInSeconds;
mosaic.noiseFlag       = false;
mosaic.spatialDensity  = [0 0.62 0.31 0.07];

%% Generate data set
%
% Loop over each calcID and add data to the matrix
analysisDir   = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
thePathToTheOI = fullfile(analysisDir,'OpticalImageData');
calcIDStrList  = getAllSubdirectoriesContainingString(thePathToTheOI,calcIDStr);

numberOfDataPoints = numberOfSamplesPerStimulusLevel * 201 * length(calcIDStrList);
dataMatrix = zeros(numberOfDataPoints,numel(mosaic.pattern));

dataIdx = 1;
for ii = 1:length(calcIDStrList)
    
    tic
    % Load standard OI and calculate data
    OIFolder       = calcIDStrList{ii};
    folderPath     = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
    standardOIList = getFilenamesInDirectory(folderPath);
    for jj = 1:length(standardOIList)
        standardOIList{jj} = loadOpticalImageData([OIFolder '/Standard'],standardOIList{jj}(1:end-16));
    end
    
    % Load all target scenes
    for jj = 1:length(standardOIList)
        thePhotons = mosaic.compute(standardOIList{jj},'currentFlag',false);
        thePhotons = repmat(thePhotons(:)',numberOfSamplesPerStimulusLevel,1);
        thePhotons = coneMosaic.photonNoise(thePhotons);
        dataMatrix(dataIdx:dataIdx+numberOfSamplesPerStimulusLevel-1,:) = thePhotons;
        dataIdx = dataIdx + numberOfSamplesPerStimulusLevel;
    end
    
    % Load comparison OI and calculate data
    for jj = 1:length(illuminationColors)
        comparisonFolder = [regexprep(illuminationColors{jj},'(\<[a-z])','${upper($1)}') 'Illumination'];
        folderPath       = fullfile(analysisDir,'OpticalImageData',OIFolder,comparisonFolder);
        comparisonOIListStr = getFilenamesInDirectory(folderPath);
        for kk = 1:length(comparisonOIListStr)
            theOI = loadOpticalImageData([OIFolder '/' comparisonFolder],comparisonOIListStr{kk}(1:end-16));
            thePhotons = mosaic.compute(theOI,'currentFlag',false);
            thePhotons = repmat(thePhotons(:)',numberOfSamplesPerStimulusLevel,1);
%             thePhotons = coneMosaic.photonNoise(thePhotons);
            dataMatrix(dataIdx:dataIdx+numberOfSamplesPerStimulusLevel-1,:) = thePhotons;
            dataIdx = dataIdx + numberOfSamplesPerStimulusLevel;
        end
    end
    fprintf('Completed loading %d/%d calcIDStr in %2.2f min\n',ii,length(calcIDStrList),toc/60);
end

%% Standardize
m = mean(dataMatrix,1);
s = std(dataMatrix,[],1);
dataMatrix = single(zscore(dataMatrix,[],1));

%% Do PCA
coeff = pca(dataMatrix,'NumComponents',100);
% [~,~,coeff] = svds(double(dataMatrix),100);
%%
dataMatrixPCA = dataMatrix*coeff;

%% Save things
save('MeanAndStdForShuffled.mat','m','s');
save('PCACoeffForShuffled.mat','coeff');
save('DataAndCoeffShuffled.mat','dataMatrixPCA','coeff');
save('MosaicForShuffled.mat','mosaic');
save('RawDataShuffled.mat','dataMatrix','-v7.3');
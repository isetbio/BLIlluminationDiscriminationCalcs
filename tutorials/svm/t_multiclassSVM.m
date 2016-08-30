%% t_multiclassSVM
%
% Trains an SVM on all 50 classes + target of a particular color direction.
% This is just meant to see if there are any differences in classification
% when doing so.

ieInit; clear; close all;
%% Parameters
numberOfSamplesPerClass = 100;
illuminationColor = 'blue';

fov = 0.83;
integrationTimeInSeconds = 0.050;

%% Create a mosaic
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
mosaic.sampleTime      = integrationTimeInSeconds;
mosaic.noiseFlag       = false;
mosaic.spatialDensity  = [0 0.62 0.31 0.07];

%% Load OI data

% Load all optical images we will used
analysisDir    = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
OIFolder       = 'Neutral';
folderPath     = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
standardOIList = getFilenamesInDirectory(folderPath);

for ii = 1:length(standardOIList)
    standardOIList{ii} = loadOpticalImageData([OIFolder '/Standard'],standardOIList{ii}(1:end-16));
end

colors = {'blue' 'green' 'red' 'yellow'};
for jj = 1:4
comparisonFolder = [regexprep(colors{jj},'(\<[a-z])','${upper($1)}') 'Illumination'];
folderPath       = fullfile(analysisDir,'OpticalImageData',OIFolder,comparisonFolder);
comparisonOIListStr = getFilenamesInDirectory(folderPath);
for ii = 1:length(comparisonOIListStr)
    comparisonOIList{ii,jj} = loadOpticalImageData([OIFolder '/' comparisonFolder],comparisonOIListStr{ii}(1:end-16));
end
end
comparisonOIList = comparisonOIList(:);

%% Generate data matrix
dataMatrix = zeros(numberOfSamplesPerClass*(1+length(comparisonOIList)),numel(mosaic.pattern));
% Load target data first
for ii = 1:numberOfSamplesPerClass
    thePhotons = mosaic.compute(standardOIList{randsample(length(standardOIList),1)},'currentFlag',false);
    thePhotons = coneMosaic.photonNoise(thePhotons);
    dataMatrix(ii,:) = thePhotons(:);
end

% Load comparison data
currentDataIdx = numberOfSamplesPerClass;
for jj = 1:length(comparisonOIList)
    for ii = 1:numberOfSamplesPerClass
        currentDataIdx = currentDataIdx + 1;
        thePhotons = mosaic.compute(comparisonOIList{jj},'currentFlag',false);
        thePhotons = coneMosaic.photonNoise(thePhotons);
        dataMatrix(currentDataIdx,:) = thePhotons(:);
    end
end

%% Train SVM

% First standardize data
dataMatrix = zscore(dataMatrix,[],1);

% Do PCA
coeff = pca(dataMatrix,'NumComponents',100);
dataMatrix = dataMatrix*coeff;

% Generate classes
classes = 0:(length(comparisonOIList)+1);
classes = repmat(classes,numberOfSamplesPerClass,1);
classes = classes(:);

% Train SVM

%% Plot Temp code
PC1 = 10;
PC2 = 4;
colors = {'b' 'g' 'r' 'y'};
figure; hold on;
plot(dataMatrix(1:100,PC1),dataMatrix(1:100,PC2),'k.');
for ii = 1:4
    dataRange = ((ii - 1)*5000+1:ii*5000) + 100;
    plot(dataMatrix(dataRange,PC1),dataMatrix(dataRange,PC2),'.','Color',colors{ii});
end
% desiredIllumStep = 10;
% for ii = 1:4
%     dataStart = (ii - 1)*5000+1+desiredIllumStep*100;
%     dataRange = (dataStart:dataStart+99)+100;
%     meanPoints(ii,:) = [mean(dataMatrix(dataRange,PC1)) mean(dataMatrix(dataRange,PC2))];
%     plot(meanPoints(ii,PC1),meanPoints(ii,PC2),'o','Color',colors{ii},'MarkerSize',30);
% end

axis square

% meanStandard = [mean(dataMatrix(1:100,PC1)) mean(dataMatrix(1:100,PC2))];
% for ii = 1:4
%     fprintf('Distance for color %s : %2.2f\n',colors{ii},norm(meanPoints(ii,:)-meanStandard));
% end


% plot(dataMatrix(101:end,1),dataMatrix(101:end,2),'.');
% figure;imagesc(abs(reshape(coeff(:,1),124,124)));
% vcAddAndSelectObject(standardOIList{1});oiWindow
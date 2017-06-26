%% t_multipatchPCA
%
% Performs pca from all the patches in a given image. This will require the
% classification to use the same mosaic throughout.

 clear; close all; ieInit;
%% Parameters
numberOfSamplesPerStimulusLevel = 10;
illuminationColors = {'blue' 'green' 'red' 'yellow'};
calcIDStr = 'SVM_Static_Isom';

fov = 0.83;
integrationTimeInSeconds = 0.050;

%% Create a mosaic
mosaic                 = coneMosaic;
mosaic.fov             = fov;
mosaic.integrationTime = integrationTimeInSeconds;
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
    
    % Load standard OI and calculate data
    OIFolder       = calcIDStrList{ii};
    folderPath     = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
    standardOIList = getFilenamesInDirectory(folderPath);
    for jj = 1:length(standardOIList)
        standardOIList{jj} = loadOpticalImageData([OIFolder '/Standard'],standardOIList{jj}(1:end-16));
    end
    
    for jj = 1:numberOfSamplesPerClass
        thePhotons = mosaic.compute(standardOIList{randsample(length(standardOIList),1)},'currentFlag',false);
        thePhotons = coneMosaic.photonNoise(thePhotons);
        dataMatrix(dataIdx,:) = thePhotons(:);
        dataIdx = dataIdx + 1;
    end
    
    % Load comparison OI and calculate data
    for jj = 1:length(illuminationColors)
        comparisonFolder = [regexprep(illuminationColors{jj},'(\<[a-z])','${upper($1)}') 'Illumination'];
        folderPath       = fullfile(analysisDir,'OpticalImageData',OIFolder,comparisonFolder);
        comparisonOIListStr = getFilenamesInDirectory(folderPath);
        for kk = 1:length(comparisonOIListStr)
            theOI = loadOpticalImageData([OIFolder '/' comparisonFolder],comparisonOIListStr{kk}(1:end-16));
            for ll = 1:numberOfSamplesPerClass
                thePhotons = mosaic.compute(theOI,'currentFlag',false);
                thePhotons = coneMosaic.photonNoise(thePhotons);
                dataMatrix(dataIdx,:) = thePhotons(:);
                dataIdx = dataIdx + 1;
            end
        end
    end
    fprintf('Completed loading %d/%d calcIDStr\n',ii,length(calcIDStrList));
end

%% Standardize
dataMatrix = zscore(dataMatrix,[],1);

%% Do PCA
% coeff = pca(dataMatrix,'NumComponents',100);
[~,~,coeff] = svds(dataMatrix,100);
dataMatrix = dataMatrix*coeff;

%% Some plotting code
% 10 and 4 seem to capture general illum directions! That was for the set
% where I didn't save cones...will it be different this time around?

% For shuffled 1 S-LM, 3 S-LM, 5 L-M, 6 L-M

PC1 = 3;
PC2 = 6;

standardStart = (0:201:size(dataMatrix,1)-1)+1;
standard = arrayfun(@colon,standardStart,standardStart+9,'UniformOutput',false);
standard = cell2mat(standard);
standard = standard(:);

startIdx = 1;
dataRanges = cell(4,1);
for ii = 1:4
blueStart = (startIdx:201:size(dataMatrix,1)-1)+1;
blue = arrayfun(@colon,blueStart,blueStart+49,'UniformOutput',false);
blue = cell2mat(blue);
blue = blue(:);
startIdx = startIdx + 50;
dataRanges{ii} = blue;
end

% dataRanges = {blue,green,red,yellow};
colors = {'b' 'g' 'r' 'y'};
figure('Position',[100 100 700 700]); hold on;
plot(dataMatrix(standard,PC1),dataMatrix(standard,PC2),'k.');
for ii = 1:4
    plot(dataMatrix(dataRanges{ii},PC1),dataMatrix(dataRanges{ii},PC2),'.','Color',colors{ii});
end
xlabel(['PC ' num2str(PC1)]);
ylabel(['PC ' num2str(PC2)]);
axis square

set(gca,'FontSize',18,'LineWidth',2,'FontName','Helvetica');
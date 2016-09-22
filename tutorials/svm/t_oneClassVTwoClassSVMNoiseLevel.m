%% t_oneClassVTwoClassSVMNoiseLevel
%
% For some reason, we can extract thresholds for one class SVMs at a much
% lower noise level than for two-class SVM. This script tests some ideas
% about why this may be. 
%
% 9/22/16  xd  wrote it

clear; close all;
%% 
mosaicFOV = 1;
kg = 5;

trainingSetSize = 1000;
numPCA = 2;


colors = {'Blue' 'Yellow' 'Green' 'Red'};

%%
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicFOV;

%% Load Standard
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Neutral_FullImage',mosaic);

%% Load a comparison
colorDir = 'BlueIllumination';
illumStep = 10;
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Neutral_FullImage', colorDir);
OINames = getFilenamesInDirectory(comparisonOIPath);
comparison = loadOpticalImageData(['Neutral_FullImage' '/' colorDir], strrep(OINames{illumStep}, 'OpticalImage.mat', ''));
photonComparison = mosaic.compute(comparison,'currentFlag',false);

%% Generate Data
[trainingData,trainingClasses] = df3_noABBA(calcParams,standardPhotonPool,{photonComparison},1,kg,2*trainingSetSize);
% trainingClasses(:) = 1;

s = std(trainingData,[],1);
m = mean(trainingData,1);
trainingData = zscore(trainingData);
coeff = pca(trainingData,'NumComponents',numPCA);
trainingData = trainingData*coeff;

%% Train 1-class SVM
tic
SVMModel = fitcsvm(trainingData(1:trainingSetSize,:),trainingClasses(1:trainingSetSize),...
    'KernelScale','auto','OutlierFraction',0.05,'KernelFunction','gaussian');
toc

%% Project our test vector
testVector = (photonComparison(:)-m')./s';
testVector = testVector'*coeff;

%% 
X = trainingData(:,1:2);
svInd = SVMModel.IsSupportVector;
h = 0.02; % Mesh grid step size
[X1,X2] = meshgrid(min(X(:,1)):h:max(X(:,1)),...
    min(X(:,2)):h:max(X(:,2)));
[~,score] = predict(SVMModel,[X1(:),X2(:)]);
scoreGrid = reshape(score,size(X1,1),size(X2,2));

figure
plot(X(:,1),X(:,2),'k.')
hold on
plot(X(svInd,1),X(svInd,2),'ro','MarkerSize',10)
plot(testVector(1),testVector(2),'g*','MarkerSize',20);
contour(X1,X2,scoreGrid)
colorbar;
title('{\bf Detection via One-Class SVM}')
xlabel('PC1')
ylabel('PC2')
legend('Observation','Support Vector')
hold off
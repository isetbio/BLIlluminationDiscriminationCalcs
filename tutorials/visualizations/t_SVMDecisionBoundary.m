%% t_SVMDecisionBoundary
%
% This script describes how to train an SVM and extract the decision
% boundary to allow for visualization. The SVM is trained on a PCA
% representation of the data.
%
% 10/20/16  xd  wrote it

clear; close all;
%% Some paramters
comparisonToPlot = 1;
kg = [0 6];

trainingSetSize = 200;
testingSetSize = 200;
numPCA = 400;

%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = 1;

%% Load data
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Neutral_FullImage',mosaic);
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Neutral_FullImage', 'BlueIllumination');
OINames = getFilenamesInDirectory(comparisonOIPath);

comparison = loadOpticalImageData(['Neutral_FullImage' '/' 'BlueIllumination'], strrep(OINames{comparisonToPlot}, 'OpticalImage.mat', ''));
photonComparison = mosaic.compute(comparison,'currentFlag',false);

%% Loop over the two kg values
figure('Position',[160 800 800 400]);
for ii = 1:length(kg)
    %% Generate training and testing data
    [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},1,kg(ii),trainingSetSize);
    [testingData,testingClasses] = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},1,kg(ii),testingSetSize);
    
    % Perform standardization and PCA
    testingData = zscore(testingData);
    trainingData = zscore(trainingData);
    
    coeff = pca(testingData,'NumComponents',numPCA);
    testingData = testingData * coeff;
    trainingData = trainingData * coeff;
    
    %% Do SVM
    [~,svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    
    %% Get hyperplane
    b = svm.Beta;
    n = null(b');
    
    h = n(1:2,1);
    
    subplot(1,2,ii);
    hold on;
    plot(trainingData(trainingSetSize/2+1:end,1),trainingData(trainingSetSize/2+1:end,2),'*','MarkerSize',8);
    plot(trainingData(1:trainingSetSize/2,1),trainingData(1:trainingSetSize/2,2),'o','MarkerSize',8);
    
    ylim([min(trainingData(:,2)) max(trainingData(:,2))]);
    
    plot([0,h(1)]*100,[0,h(2)]*100,'k--','LineWidth',2);
    plot([0,-h(1)]*100,[0,-h(2)]*100,'k--','LineWidth',2);
    
    axis square
    
    if ii == 1
        ylabel('Principal Component 2','FontSize',18,'FontName','Helvetica');
    end
    xlabel('Principal Component 1','FontSize',18,'FontName','Helvetica');
    tp = {'No ' ''};
    title([tp{ii} 'Gaussian Noise'],'FontSize',24,'FontName','Helvetica');
    legend({'Blue 1','Target'},'FontSize',14,'FontName','Helvetica');
    
    set(gca,'LineWidth',2,'FontSize',28,'FontName','Helvetica');
    
end
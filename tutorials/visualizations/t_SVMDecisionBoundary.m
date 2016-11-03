%% t_SVMDecisionBoundary
%
% This script describes how to train an SVM and extract the decision
% boundary to allow for visualization. The SVM is trained on a PCA
% representation of the data. We will use some blue stimulus and the target
% stimuli in the dataset for this script.
%
% 10/20/16  xd  wrote it

clear; close all;
%% Set parameters
%
% Choose which blue stimulus to plot as well as how much additive noise.
% Pick 0 (no Gaussian noise) and some value > 0.
comparisonToPlot = 1;
kg = [0 15];

% Size of the testing and training sets. The larger the training set, the
% better the reproducibility of the result. However, it will also take
% longer to run/train the PCA/SVM. The number of PCA components is limited
% to the number of testing set samples, and if set higher, will still only
% reach that limit.
trainingSetSize = 200;
testingSetSize = 200;
numPCA = 400;

% Which section of the grid to use.
calcIDStr = 'Constant_1';

%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = 1;

%% Load data
%
% Load the standard OIs and calculate isomerizations.
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(calcIDStr,mosaic);
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData',calcIDStr,'BlueIllumination');
OINames = getFilenamesInDirectory(comparisonOIPath);

% Load the specific comparison OI and calculate photons.
comparison = loadOpticalImageData([calcIDStr '/' 'BlueIllumination'], strrep(OINames{comparisonToPlot}, 'OpticalImage.mat', ''));
photonComparison = mosaic.compute(comparison,'currentFlag',false);

%% Loop over the two kg values
figure('Position',[160 800 800 400]);
for ii = 1:length(kg)
    %% Generate training and testing data
    [trainingData,trainingClasses] = df1_ABBA(calcParams,standardPhotonPool(1),{photonComparison},1,kg(ii),trainingSetSize);
    [testingData,testingClasses] = df1_ABBA(calcParams,standardPhotonPool(1),{photonComparison},1,kg(ii),testingSetSize);
    
    % Perform standardization and PCA
    [testingData,m,s] = zscore(testingData);
    trainingData = zscore(trainingData);
    
    % Project data onto PCA components
    coeff = pca(testingData,'NumComponents',numPCA);
    testingData = testingData * coeff;
    trainingData = trainingData * coeff;
    
    %% Do SVM
    [~,svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    
    %% Generate a Gaussian set of data to plot over the no noise condition
    if ii == 1
        gaussianOverlay = df1_ABBA(calcParams,standardPhotonPool(1),{photonComparison},1,kg(2),trainingSetSize);
        gaussianOverlay = (gaussianOverlay - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
        gaussianCoeff = pca(gaussianOverlay,'NumComponents',numPCA);
        gaussianOverlay = gaussianOverlay * gaussianCoeff;
    end
    
    %% Get hyperplane
    b = svm.Beta;
    n = null(b');
    h = n(1:2,1);
    
    % Plot the data
    subplot(1,2,ii);
    hold on;
    plot(trainingData(trainingSetSize/2+1:end,1),trainingData(trainingSetSize/2+1:end,2),'*','MarkerSize',8);
    plot(trainingData(1:trainingSetSize/2,1),trainingData(1:trainingSetSize/2,2),'o','MarkerSize',8);
    
    if ii == 1
        plot(gaussianOverlay(trainingSetSize/2+1:end,1),gaussianOverlay(trainingSetSize/2+1:end,2),'s','MarkerSize',8);
        plot(gaussianOverlay(1:trainingSetSize/2,1),gaussianOverlay(1:trainingSetSize/2,2),'s','MarkerSize',8);
    end
    ylim([min(trainingData(:,2)) max(trainingData(:,2))]);
    
    % Plot decision boundary
    plot([0,h(1)]*100,[0,h(2)]*100,'k--','LineWidth',2);
    plot([0,-h(1)]*100,[0,-h(2)]*100,'k--','LineWidth',2);
    
    % Plot formatting
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
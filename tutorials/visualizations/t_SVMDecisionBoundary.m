%% t_SVMDecisionBoundary
%
% This script describes how to train an SVM and extract the decision
% boundary to allow for visualization. The SVM is trained on a PCA
% representation of the data. We will use some blue stimulus and the target
% stimuli in the dataset for this script.
%
% 10/20/16  xd  wrote it
% 07/07/16  xd  update to keep noise frozen for reproducibility

clear; close all;
%% Set parameters

% Choose which blue stimulus to plot as well as how much additive noise.
% Pick 0 (no Gaussian noise) and some value > 0.
comparisonToPlot = 1;
kg = [0 15];

% Size of the testing and training sets. The larger the training set, the
% better the reproducibility of the result. However, it will also take
% longer to run/train the PCA/SVM. The number of PCA components is limited
% to the number of testing set samples, and if set higher, will still only
% reach that limit.
trainingSetSize = 1000;
testingSetSize = 1000;
numPCA = 400;

% Which section of the grid to use.
calcIDStr = 'Constant_1';

% Size of mosaic
fov = 1;

% Frozen random seed
rng(1);

%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = fov;

%% Load data

% Load the standard OIs and calculate isomerizations.
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(calcIDStr,mosaic);
calcParams.frozen = 1;
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData',calcIDStr,'BlueIllumination');
OINames = getFilenamesInDirectory(comparisonOIPath);

% Load the specific comparison OI and calculate photons.
comparison = loadOpticalImageData([calcIDStr '/' 'BlueIllumination'],strrep(OINames{comparisonToPlot},'OpticalImage.mat',''));
photonComparison = mosaic.compute(comparison,'currentFlag',false);

%% Loop over the two kg values
figure('Position',[160 800 800 400]);
for ii = 1:length(kg)
    % Generate training and testing data. The reason we only make one call
    % to the data generation function is because the noise function in
    % ISETBIO sets the rng seed internally. Thus, making two calls with
    % frozen noise would result in two identical datasets! To circumvent
    % this, we have instead made one call to create a dataset containing
    % the training and test vectors. Then, we manually split the data set
    % into two partitions.
    [data,classes] = df1_ABBA(calcParams,standardPhotonPool,{photonComparison},1,kg(ii),trainingSetSize+testingSetSize);
    trainingData = data([1:trainingSetSize/2,end/2+1:end/2+trainingSetSize/2],:);
    trainingClasses = classes([1:trainingSetSize/2,end/2+1:end/2+trainingSetSize/2]);
    data([1:trainingSetSize/2,end/2+1:end/2+trainingSetSize/2],:) = [];
    classes([1:trainingSetSize/2,end/2+1:end/2+trainingSetSize/2]) = [];
    testingData = data;
    testingClasses = classes;

    % Perform standardization using training data
    [trainingData,m,s] = zscore(trainingData);
    testingData = (testingData - repmat(m,size(testingData,1),1)) ./ repmat(s,size(testingData,1),1);
    
    % Project data onto PCA components
    coeff = pca(trainingData,'NumComponents',numPCA);
    testingData  = testingData * coeff;
    trainingData = trainingData * coeff;
    
    %% Do SVM
    [perf,svm] = cf3_SupportVectorMachine(trainingData,testingData,trainingClasses,testingClasses);
    fprintf('kg: %d, SVM perf: %0.4f\n',kg(ii), perf);
    
    %% Get hyperplane
    %
    % The svm.Beta field contains a vector that is orthogonal to the
    % hyperplane decision boundary. Thus, the null space of this vector is
    % the hyperplane.
    b = svm.Beta;
    n = null(b');
    h = n(1:2,1);
    
    %% Plot the data
    subplot(1,2,ii);
    hold on;
    plot(trainingData(trainingSetSize/2+1:end,1),trainingData(trainingSetSize/2+1:end,2),'*','MarkerSize',8);
    plot(trainingData(1:trainingSetSize/2,1),trainingData(1:trainingSetSize/2,2),'o','MarkerSize',8);
    % ylim([min(trainingData(:,2)) max(trainingData(:,2))]);
    % ylim([-4 4]);
    
    % Plot decision boundary
    plot([-h(1),h(1)]*100,[-h(2),h(2)]*100,'k--','LineWidth',2);

    % Plot formatting
    axis square
    if ii == 1
        ylabel('Principal Component 2','FontSize',18,'FontName','Helvetica');
    end
    xlabel('Principal Component 1','FontSize',18,'FontName','Helvetica');
    tp = {'No ' ''};
    title([tp{ii} 'Gaussian Noise'],'FontSize',24,'FontName','Helvetica');
    legend({'AB','BA'},'FontSize',14,'FontName','Helvetica','Location','northwest');
    set(gca,'LineWidth',2,'FontSize',28,'FontName','Helvetica');

end
function t_SVMDecisionBoundary(varargin)
% t_SVMDecisionBoundary(varargin)
%
% This script describes how to train an SVM and extract the decision
% boundary to allow for visualization. The SVM is trained on a PCA
% representation of the data. We will use some blue stimulus and the target
% stimuli in the dataset for this script.
%
% This function only takes in 1 optional params struct which must contain
% the same fields as the params below. You can just edit the parameters in
% this function to see the effects of changing them. The reason that this
% is written as a function is because it is used to generate a figure
% elsewhere.
%
% 10/20/16  xd  wrote it
% 07/07/16  xd  update to keep noise frozen for reproducibility
% 07/08/16  xd  turned into script for paper plot ease of use

%% Set default parameters

% Choose which blue stimulus to plot as well as how much additive noise.
% Pick 0 (no Gaussian noise) and some value > 0.
params.comparisonToPlot = 1;
params.kg = [0 15];

% Size of the testing and training sets. The larger the training set, the
% better the reproducibility of the result. However, it will also take
% longer to run/train the PCA/SVM. The number of PCA components is limited
% to the number of testing set samples, and if set higher, will still only
% reach that limit.
params.trainingSetSize = 1000;
params.testingSetSize = 1000;
params.numPCA = 400;

% Which section of the grid to use.
params.calcIDStr = 'Constant_CorrectSize';

% Size of mosaic
params.fov = 1.1;

% RNG Seed
params.randomSeed = 1;

%% Parse input
p = inputParser;
p.addOptional('params',params,@(X) isstruct(X) || isempty(X));
p.parse(varargin{:});

comparisonToPlot = p.Results.params.comparisonToPlot;
kg               = p.Results.params.kg;
trainingSetSize  = p.Results.params.trainingSetSize;
testingSetSize   = p.Results.params.testingSetSize;
numPCA           = p.Results.params.numPCA;
calcIDStr        = p.Results.params.calcIDStr;
fov              = p.Results.params.fov;
randomSeed       = p.Results.params.randomSeed;

%% Set random seed
rng(randomSeed);

%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
% The default mosaic is 1 degree and we can no longer
% change it.  Since this is a tutorial we don't mind
% too much, even though 1.1 appears to be the size
% we wanted.
% mosaic.fov = fov;

%% Choose patch
% calcIDStr       = OIFolder;
cacheFolderList = {calcIDStr,calcIDStr};
sensorFOV       = mosaic.fov(1);
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
fileNames         = getFilenamesInDirectory(fullfile(dataDir,'SceneData',cacheFolderList{2},'Standard'));
tempScene         = loadSceneData([cacheFolderList{2} '/Standard'],fileNames{1}(1:end-9));
tempOI            = loadOpticalImageData([cacheFolderList{1} '/Standard'],fileNames{1}(1:end-9));
[~,p]   = splitSceneIntoMultipleSmallerScenes(tempScene,sensorFOV);

% Get sizes of scene and OI
scenehFov = sceneGet(tempScene,'hfov');
scenevFov = sceneGet(tempScene,'vfov');
oihFov = oiGet(tempOI,'hfov');
oivFov = oiGet(tempOI,'vfov');
oiPadding = [oihFov - scenehFov, oivFov - scenevFov] / 2;
oiSize = oiGet(tempOI,'cols') / oihFov;

oiIdx = 162; %3;162
oiCR = convertPatchToOICropRect(oiIdx,p,oiPadding,oiSize,sensorFOV);

%% Load data
calcParams.frozen = 1;
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData',calcIDStr,'BlueIllumination');
standardOIPath = fullfile(analysisDir, 'OpticalImageData',calcIDStr,'Standard');

standardNames = getFilenamesInDirectory(standardOIPath);
OINames = getFilenamesInDirectory(comparisonOIPath);

% Load the standard OIs and calculate isomerizations.
% [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(calcIDStr,mosaic);
standard = loadOpticalImageData([calcIDStr '/' 'Standard'],strrep(standardNames{1},'OpticalImage.mat',''));
standard = oiCrop(standard,oiCR);
mosaic.compute(standard,'currentFlag',false);
standardPhotons = mosaic.absorptions(mosaic.pattern > 0);
standardPhotonPool = {standardPhotons};
calcParams.meanStandard = mean2(standardPhotons);


% Load the specific comparison OI and calculate photons.
comparison = loadOpticalImageData([calcIDStr '/' 'BlueIllumination'],strrep(OINames{comparisonToPlot},'OpticalImage.mat',''));

comparison = oiCrop(comparison,oiCR);
mosaic.compute(comparison,'currentFlag',false);
photonComparison = mosaic.absorptions(mosaic.pattern > 0);

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
    classifiedClasses = predict(svm,trainingData);
    percentCorrect = sum(classifiedClasses == trainingClasses) / size(trainingClasses,1) * 100;
    fprintf('Test kg: %d, SVM perf: %0.4f\n',kg(ii), perf);
    fprintf('Train kg: %d, SVM perf: %0.4f\n',kg(ii), percentCorrect);
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
    ylim([-30 30]);
    
end
end
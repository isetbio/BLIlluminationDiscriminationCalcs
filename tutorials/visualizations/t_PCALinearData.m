%% t_PCALinearData
%
% Shows that data is linearly separable using PCA. We will perform PCA on
% the target and a single comparions, target with all the comparisons, and
% all the targets and all the comparisons.
%
% This demonstrates that the data separated along the first principle
% component may be separated by change in illumination.
%
% 10/6/16  xd  wrote it

clear; close all;
%% Parameters to set
%
% String to define set of model calculations to use for this script.
calcIDStr = 'Constant_FullImage';

% Number of PCA components to calculate.
numPCA = 400;

%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = 1;

%% Load data
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(calcIDStr,mosaic);
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData',calcIDStr,'BlueIllumination');
OINames = getFilenamesInDirectory(comparisonOIPath);

% We allocate two testing data matrices. One uses target samples from
% multiple different renderings. The other uses all renderings of the
% target sample. This is to illustrate the difference in distribution
% caused by the pixel noise.
numberOfSamplesPerStep = 100;
testingData = zeros((length(OINames)+1)*numberOfSamplesPerStep,length(standardPhotonPool{1}(:)));
testingDataOnlyOneTarget = zeros((length(OINames)+1)*numberOfSamplesPerStep,length(standardPhotonPool{1}(:)));

% Generate the target data first so that we have an even amount of data for
% each stimulus sample.
testingData(1:numberOfSamplesPerStep,:) = df3_noABBA(calcParams,standardPhotonPool,standardPhotonPool,1,0,numberOfSamplesPerStep);
testingDataOnlyOneTarget(1:numberOfSamplesPerStep,:) = df3_noABBA(calcParams,standardPhotonPool(1),standardPhotonPool(1),1,0,numberOfSamplesPerStep);

for ii = 2:length(OINames)+1
    tic
    comparison = loadOpticalImageData([calcIDStr '/' 'BlueIllumination'], strrep(OINames{ii-1}, 'OpticalImage.mat', ''));
    photonComparison = mosaic.compute(comparison,'currentFlag',false);
    
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep + (ss-1) * length(OINames);
    endIdx = ii * numberOfSamplesPerStep + (ss-1) * length(OINames);
    testingData(startIdx:endIdx,:) = df3_noABBA(calcParams,{photonComparison},{photonComparison},1,0,numberOfSamplesPerStep);
    testingDataOnlyOneTarget(startIdx:endIdx,:) = testingData(startIdx:endIdx,:);
    fprintf('%d Comparison Stimulus: %2.2f min\n',ii,toc/60);
end
%% Standardize and do PCA
%
% We perform the PCA three ways in this section. One, we only do the PCA on
% the target stimulus and the blue 1 stimulus. This is the way the SVM
% model will perform the computations. The second method is to perform the
% PCA on a dataset containing all the stimuli (for the target as well as
% the blue illuminant) for visualization of how the first principle
% component may represent the change in illumination. Finally, we can also
% perform the PCA using all the blue stimulus and just one target stimulus
% to demonstrate the effects of rendering noise on the data.
tic
testingDataOnlyTwoStim = zscore(testingData(1:200,:));
[coeffTwoStim,scoreTwoStim] = pca(testingDataOnlyTwoStim,'NumComponents',2);
toc

tic
testingData = zscore(testingData);
[coeff,score] = pca(testingData,'NumComponents',100);
fprintf('PCA: %2.2f min\n',toc/60);

tic
testingDataOnlyOneTarget = zscore(testingDataOnlyOneTarget);
[coeffOneTarget,scoreOneTarget] = pca(testingDataOnlyOneTarget,'NumComponents',2);
fprintf('PCA: %2.2f min\n',toc/60);

%% Plotting single comparison
% Plot the results of the PCA when using only one target. This in essence
% allows us to compare the result to the case where all the target stimuli
% are used.
figure('Position',[160 800 1000 500]);
subplot(1,2,1);
hold on;

% Plot points on first 2 PCA components
plot(scoreOneTarget(101:200,1),scoreOneTarget(101:200,2),'o','MarkerSize',12)
plot(scoreOneTarget(1:100,1),scoreOneTarget(1:100,2),'*','MarkerSize',12)

axis square
box off
ylabel('PC 2','FontSize',40,'FontName','Helvetica');
xlabel('PC 1','FontSize',40,'FontName','Helvetica');
title('Blue 1 Stimulus','FontSize',50,'FontName','Helvetica');
legend({'Blue 1','Target'},'FontSize',20,'FontName','Helvetica',...
    'Position',[0.351416107382549 0.725355421686754 0.1 0.112048192771084]);

% Label the subplot
text(0.02,0.99,'A','Units', 'Normalized', 'VerticalAlignment', 'Top','FontName','Helvetica','FontSize',20);

set(gca,'LineWidth',2,'FontSize',28,'FontName','Helvetica');
set(gca,'YLim',[0 25],'XLim',[-135 -120]);

% Plot the results when using all the targets. This shows that the
% rendering noise expands the distribution of the target stimulus in PCA
% space.
subplot(1,2,2);
hold on;

% Plot points on first 2 PCA components
plot(score(101:200,1),score(101:200,2),'o','MarkerSize',12)
plot(score(1:100,1),score(1:100,2),'*','MarkerSize',12)

% Plot formatting
axis square
box off
xlabel('PC 1','FontSize',40,'FontName','Helvetica');
title('Blue 1 Stimulus','FontSize',50,'FontName','Helvetica');
legend({'Blue 1','Target'},'FontSize',20,'FontName','Helvetica',...
    'Position',[0.79141610738255 0.725355421686755 0.1 0.112048192771084]);

% Label the subplot
text(0.02,0.99,'B','Units', 'Normalized', 'VerticalAlignment', 'Top','FontName','Helvetica','FontSize',20)

set(gca,'LineWidth',2,'FontSize',28,'FontName','Helvetica');
set(gca,'YLim',[0 25],'XLim',[-135 -120]);

%% Plot all stimulus
figure('Position',[160 844 650 650]);
hold on;
for ii = 1:size(testingData,1)/numberOfSamplesPerStep
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep;
    endIdx = ii * numberOfSamplesPerStep;
    
    plot(ii-1,mean(score(startIdx:endIdx,1)),...
        'o','Color',[0 0 1/51*(ii-1)],'MarkerSize',std(score(startIdx:endIdx,1))*10);
end

% Some formatting
axis square;
xlim([0 50])

set(gca,'LineWidth',2)
set(gca,'FontSize',28,'FontName','Helvetica')
ylabel('Principal Component 1','FontSize',44,'FontName','Helvetica')
xlabel('Stimulus Level','FontSize',44,'FontName','Helvetica')
title('Mean PCA by Stimulus Level','FontSize',34,'FontName','Helvetica');

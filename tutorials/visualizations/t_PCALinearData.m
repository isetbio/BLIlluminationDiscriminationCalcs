%% t_PCALinearData
%
% Shows that data is linearly separable using PCA.
%
% 10/6/16  xd  wrote it

clear; close all;
%% Make mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = 1;

%% Load data
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Neutral_FullImage',mosaic);
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Neutral_FullImage', 'BlueIllumination');
OINames = getFilenamesInDirectory(comparisonOIPath);

numberOfSamplesPerStep = 100;
testingData = zeros(length(OINames)*100,length(standardPhotonPool{1}(:)));
testingData(1:numberOfSamplesPerStep,:) = df3_noABBA(calcParams,standardPhotonPool,standardPhotonPool,1,0,numberOfSamplesPerStep);

for ii = 2:length(OINames)
    comparison = loadOpticalImageData(['Neutral_FullImage' '/' 'BlueIllumination'], strrep(OINames{ii}, 'OpticalImage.mat', ''));
    photonComparison = mosaic.compute(comparison,'currentFlag',false);
    
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep;
    endIdx = ii * numberOfSamplesPerStep;
    testingData(startIdx:endIdx,:) = df3_noABBA(calcParams,{photonComparison},{photonComparison},1,0,numberOfSamplesPerStep);
end

%% Standardize and do PCA
testingData = zscore(testingData);
[coeff,score] = pca(testingData,'NumComponents',2);

%% Mean center y axis
for ii = 1:length(OINames)
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep;
    endIdx = ii * numberOfSamplesPerStep;
    
    score(startIdx:endIdx-50,2) = score(startIdx:endIdx-50,2) - mean(score(startIdx:endIdx-50,2));
    score(startIdx+50:endIdx,2) = score(startIdx+50:endIdx,2) - mean(score(startIdx+50:endIdx,2));
end

%% Plotting T v C1
figure('Position',[160 800 700 700]); 
hold on;
plot(score(1:100,1),score(1:100,2),'*','MarkerSize',12)
plot(score(101:200,1),score(101:200,2),'o','MarkerSize',12)
axis square
box off
ylabel('Principal Component 2','FontSize',40,'FontName','Helvetica');
xlabel('Principal Component 1','FontSize',40,'FontName','Helvetica');
title('Blue 1 Stimulus','FontSize',50,'FontName','Helvetica');
legend({'Target','Blue 1'},'FontSize',28,'FontName','Helvetica');

set(gca,'LineWidth',2,'FontSize',28,'FontName','Helvetica');
set(gca,'XTick',-95:5:-80,'YTick',-3:4);

%% Histogram thing
figure('Position',[160 844 2000 600]); 
hold on;
for ii = 1:50
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep;
    endIdx = ii * numberOfSamplesPerStep;

    
    histogram(score(startIdx:endIdx,1),'FaceColor',[0 0 1/50*(ii-1)]);
    
    if ii == 1
        x = mean(score(startIdx:endIdx,1));
        plot([x x],[0 100],'r--','LineWidth',2);
    end
end

% Some formatting
box on
xlim([-100 95])
ylim([0 35])

set(gca,'XTick',[])
set(gca,'LineWidth',2)
set(gca,'FontSize',28,'FontName','Helvetica')
ylabel('Occurences','FontSize',44,'FontName','Helvetica')
xlabel('Principal component 1','FontSize',44,'FontName','Helvetica')

%% Fit normals to individual histograms
x = get(gca,'XLim');
x = min(x):0.01:max(x);
figure; hold on;
for ii = 1:50
    startIdx = 1 + (ii-1) * numberOfSamplesPerStep;
    endIdx = ii * numberOfSamplesPerStep;
    f = fitdist(score(startIdx:endIdx,1),'normal');
    y = pdf(f,x);
    y = y / max(y) * max(histcounts(score(startIdx:endIdx,1)));
    plot(x,y,'r');
end
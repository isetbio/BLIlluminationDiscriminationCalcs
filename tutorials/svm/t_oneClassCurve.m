%% t_oneClassCurve
%
% Curve based on just % correct for a large testing set per illuminant
% level.
%
% 9/22/16  xd  wrote it

clear; %close all;
%%
trainingSetSize = 1000;
testingSetSize = 1000;

mosaicFOV = 1;
kg = 3;

colors = {'Blue'};% 'Yellow' 'Green' 'Red'};

%% Create a mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicFOV;

%% Load the standards
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Constant_FullImage',mosaic);

%% Generate Data
[trainingData,trainingClasses] = df3_noABBA(calcParams,standardPhotonPool,standardPhotonPool,1,kg,trainingSetSize);
trainingClasses(:) = 1;

%% Train 1-class SVM
tic
theSVM = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','OutlierFraction',0.00,'KernelFunction','gaussian',...
    'Standardize',false);
toc

%% Test
data = zeros(length(colors),50);

for cc = 1:length(colors)
    colorDir = [colors{cc} 'Illumination'];
    analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Constant_FullImage', colorDir);
    OINames = getFilenamesInDirectory(comparisonOIPath);
    
    tic
    for ii = 1:length(OINames)
        comparison = loadOpticalImageData(['Constant_FullImage' '/' colorDir], strrep(OINames{ii}, 'OpticalImage.mat', ''));
        photonComparison = mosaic.compute(comparison,'currentFlag',false);
        
        [testingData,testingClasses] = df3_noABBA(calcParams,standardPhotonPool,{photonComparison},1,kg,testingSetSize);
        [~,score] = predict(theSVM,testingData);
        predClass = score > 0;
        data(cc,ii) = sum(~predClass == testingClasses) / testingSetSize;
        toc
    end
end

%% Plot
load('IllumDist');
s = illuminantDistance{1}(2:end,2);
[t,p] = singleThresholdExtraction(data(1,:)*1000,70.9,[],1000);
plotFitForSingleThreshold(createPlotInfoStruct,data(1,:)*100,t,p);
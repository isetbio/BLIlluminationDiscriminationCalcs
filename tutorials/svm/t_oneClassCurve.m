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

%% Load the standards
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Constant_CorrectSize',mosaic);

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
    comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Constant_CorrectSize', colorDir);
    OINames = getFilenamesInDirectory(comparisonOIPath);
    
    tic
    for ii = 1:length(OINames)
        comparison = loadOpticalImageData(['Constant_CorrectSize' '/' colorDir], strrep(OINames{ii}, 'OpticalImage.mat', ''));
        mosaic.compute(comparison,'currentFlag',false);
        photonComparison = mosaic.absorptions(mosaic.pattern > 0);
        
        [testingData,testingClasses] = df3_noABBA(calcParams,standardPhotonPool,{photonComparison},1,kg,testingSetSize);
        [~,score] = predict(theSVM,testingData);
        predClass = score > 0;
        data(cc,ii) = sum(~predClass == testingClasses) / testingSetSize;
        toc
    end
end

%% Plot
[t,p] = singleThresholdExtraction(data(1,:)*100,70.9,1:length(OINames),1000);
plotFitForSingleThreshold(createPlotInfoStruct,data(1,:)*100,t,p);
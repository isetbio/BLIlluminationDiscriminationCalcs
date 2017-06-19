%% t_oneClassCurve
%
% Curve based on just % correct for a large testing set per illuminant
% level.
%
% 9/22/16  xd  wrote it

clear; close all;
parpool(30);
%%
trainingSetSize = 1000;
testingSetSize = 1000;

mosaicFOV = 1;
kg = 3;

colors = {'Blue' 'Yellow' 'Green' 'Red'};

%% Create a mosaic
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicFOV;

calcIDStr = 'NM1';
% parfor loop here, need list of folder names

tempScene = loadSceneData('NM1_FullImage/Standard','TestImage0');
numberofOI = numel(splitSceneIntoMultipleSmallerScenes(tempScene,mosaicFOV));
% numberofOI = generateOIForParallelComputing(c);

% This part loops through the calculations for all caldIDStrs specified
theIndex = 1:numberofOI;
parfor k1 = 1:length(theIndex)
    OIFolder = [calcIDStr '_' num2str(theIndex(k1))];
    
    %% Load the standards
    [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(OIFolder,mosaic);
    
    %% Generate Data
    [trainingData,trainingClasses] = df3_noABBA(calcParams,standardPhotonPool,standardPhotonPool,1,kg,trainingSetSize);
    trainingClasses(:) = 1;
    
    %% Train 1-class SVM
    tic
    theSVM = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','OutlierFraction',0.00,'KernelFunction','gaussian');
    toc
    
    %% Test
    data = zeros(length(colors),50);
    
    for cc = 1:length(colors)
        colorDir = [colors{cc} 'Illumination'];
        analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData',OIFolder, colorDir);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        
        tic
        for ii = 1:length(OINames)
            comparison = loadOpticalImageData([OIFolder '/' colorDir], strrep(OINames{ii}, 'OpticalImage.mat', ''));
            photonComparison = mosaic.compute(comparison,'currentFlag',false);
            
            [testingData,testingClasses] = df3_noABBA(calcParams,standardPhotonPool,{photonComparison},1,kg,testingSetSize);
            [~,score] = predict(theSVM,testingData);
            predClass = score > 0;
            data(cc,ii) = sum(~predClass == testingClasses) / testingSetSize;
            toc
        end
    end
    
    dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
    saveForOneClassCurve(fullfile(dataDir,'OneClass',[OIFolder '.mat']),...
        data,trainingSetSize,testingSetSize);
end
%% Plot
% [t,p] = singleThresholdExtraction(data(4,:)*1000,70.9,[],1000);
% plotFitForSingleThreshold(createPlotInfoStruct,data(4,:)*100,t,p);
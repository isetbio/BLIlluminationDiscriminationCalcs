%% t_IsomerizationDistance

clear; close all;
%%
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStr = 'Constant_CorrectSize';

%%
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.noiseFlag = 'none';

%%
standardOI = getFilenamesInDirectory(fullfile(analysisDir,'OpticalImageData',calcIDStr,'Standard'));

meanStandard = 0;
for ii = 1:length(standardOI)
    oi = loadOpticalImageData('Constant_CorrectSize/Standard',standardOI{ii}(1:end-16));
    
    mosaic.compute(oi,'currentFlag',false);
    absorptionsStandard = mosaic.absorptions(mosaic.pattern > 0);
    meanStandard = meanStandard + absorptionsStandard;
end
meanStandard = meanStandard / length(standardOI);

%%
blueOI = getFilenamesInDirectory(fullfile(analysisDir,'OpticalImageData',calcIDStr,'BlueIllumination'));

blueDist = zeros(length(blueOI),1);
for ii = 1:length(blueOI)
    oi = loadOpticalImageData('Constant_CorrectSize/BlueIllumination',blueOI{ii}(1:end-16));
    
    mosaic.compute(oi,'currentFlag',false);
    absorptionsBlue = mosaic.absorptions(mosaic.pattern > 0);
    
    blueDist(ii) = norm(meanStandard - absorptionsBlue);
end

%%
figure;

plot(blueDist,'o');
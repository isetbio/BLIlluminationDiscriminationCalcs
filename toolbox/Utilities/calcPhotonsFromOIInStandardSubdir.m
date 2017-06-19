function [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(OIFolder,mosaic)
% [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(OIFolder)
% 
% Loads all the standard OI for a particular OIFolder and calculates the
% response using mosaic. I do this often enough in scripts here and there
% that this should be its own function.
%
% 9/22/23  xd  wrote it


analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
data = what(folderPath);
standardOIList = data.mat;

standardPhotonPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
<<<<<<< 9a91d63a63847a79d53130f92531a22f7c498dce
    tic
    standardOI = loadOpticalImageData([OIFolder '/Standard'], strrep(standardOIList{jj},'OpticalImage.mat',''));
    standardPhotonPool{jj}  = mosaic.compute(standardOI,'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
    fprintf('%d Stimulus: %2.2f min\n',jj,toc/60);
=======
    standardOI = loadOpticalImageData([OIFolder '/Standard'], strrep(standardOIList{jj},'OpticalImage.mat',''));
    standardPhotonPool{jj}  = mosaic.compute(standardOI,'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
>>>>>>> saving most recent version
end

end


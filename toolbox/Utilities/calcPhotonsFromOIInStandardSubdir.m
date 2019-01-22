function [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(OIFolder,mosaic)
% [standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir(OIFolder,mosaic)
% 
% Loads all the standard OI for a particular OIFolder and calculates the
% response using mosaic. I do this often enough in scripts here and there
% that this should be its own function.
%
% Inputs:
%     OIFolder  -  folder where all the opticalimages reside
%     mosaic    -  ISETBIO coneMosaic to calculate isomerizations
%
% Outputs:
%     standardPhotonPool  -  cell array of isomerizations matrices
%     calcParams          -  struct describing this calculation
%
% 9/22/23  xd  wrote it


analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
data = what(folderPath);
standardOIList = data.mat;

standardPhotonPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for jj = 1:length(standardOIList)
    tic
    standardOI = loadOpticalImageData([OIFolder '/Standard'], strrep(standardOIList{jj},'OpticalImage.mat',''));
    mosaic.compute(standardOI,'currentFlag',false);
    standardPhotonPool{jj}  = mosaic.absorptions(mosaic.pattern > 0);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardPhotonPool{jj}) / length(standardOIList);
    fprintf('%d Stimulus: %2.2f min\n',jj,toc/60);
end

end


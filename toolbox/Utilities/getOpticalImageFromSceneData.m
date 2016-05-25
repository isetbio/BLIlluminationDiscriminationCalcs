function oi = getOpticalImageFromSceneData(calcParams, oi, folderName, imageName)
% oi = getOpticalImageFromSceneData(calcParams, oi, folderName, imageName)
%
% Loads the scene file from ColorShare1 and turns it into an optical
% image using default human optics
%
% Inputs:
%   oi - optical image to compute using scene
%   folderName - folder in which target scene resides on ColorShare
%   imageName - name of original image used to calculate the scene
%
% Outputs:
%   oi - newly calculated oi using input oi and target scene
%
% 3/11/15   xd       wrote it
% 5/29/15   dhb      make target dir if it doesn't yet exist

%% Load scene
scene = loadSceneData([calcParams.cacheFolderList{2} '/' folderName], imageName);

%% Compute optical image
tic
opticalimage = oiCompute(oi,scene);
fprintf('Optical image object generation took %2.1f seconds\n', toc);

%% Save the optical image where we cache these things
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
oiFilePath = fullfile(analysisDir, 'OpticalImageData', calcParams.cacheFolderList{2}, folderName, strcat(imageName, 'OpticalImage.mat'));
theDir = fileparts(oiFilePath);
if (~exist(theDir,'dir'))
    mkdir(theDir);
end
save(oiFilePath, 'opticalimage');

%% Return new oi
oi = opticalimage;
end


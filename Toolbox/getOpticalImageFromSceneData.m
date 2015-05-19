function oi = getOpticalImageFromSceneData(oi, folderName, imageName)
% oi = getOpticalImageFromSceneData(folderName, imageName)
%
% Loads the scene file from ColorShare1 and turns it into an optical
% image using default human optics
%
%   Inputs:
%   oi - optical image to compute using scene
%   folderName - folder in which target scene resides on ColorShare
%   imageName - name of original image used to calculate the scene
%
%   Outputs:
%   oi - newly calculated oi using input oi and target scene
%
% 3/11/2015   xd  wrote it

%% Load scene
scene = loadSceneData(folderName, imageName);

%% Compute optical image
tic
opticalimage = oiCompute(oi,scene);
fprintf('Optical image object generation took %2.1f seconds\n', toc);

%% Save the optical image where we cache these things
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
oiFilePath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'OpticalImage.mat'));
save(oiFilePath, 'opticalimage');

%% Return new oi
oi = opticalimage;
end


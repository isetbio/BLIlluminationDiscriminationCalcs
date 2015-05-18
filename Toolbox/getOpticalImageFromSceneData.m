function oi = getOpticalImageFromSceneData(oi, folderName, imageName)
% oi = getOpticalImageFromSceneData(folderName, imageName)
%
% Loads the scene file from ColorShare1 and turns it into an optical
% image using default human optics
%
% WANT TO PASS OI SO THAT IT IS EASY TO CUSTOMIZE.
%
% 3/11/2015   xd  wrote it

%% PROBABLY WANT TO CALL THIS ONE LEVEL UP
ieInit;

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
end


function scene = getSceneFromRGBResize(calcParams,folderName,imageName,display,fov)
%GETSCENEFROMRGBRESIZE Summary of this function goes here
%   Detailed explanation goes here


%% Get path to image
path = fullfile(calcParams.cacheFolderList{1}, folderName, imageName);

%% Load the input image
imageData  = loadImageData(path);

%% Generate scene from full image
tic;
scene = sceneFromFile(imageData, 'rgb', [], display);
fprintf('Scene object generation took %2.1f seconds\n', toc);

%% Crop scene to the size we want to use
%
% Usually not all of the original image

% First have to crop the pixels, but this doesn't adjust
% field of view
scene = sceneCrop(scene, calcParams.cropRect);
% xImgPixels = sceneGet(scene,'cols');
% xImgMeters = xImgPixels*0.0254/display.dpi;

% Need to resize field of view.  Scale size of image
% in meters by how much we're cropping out.
% fov = 2*rad2deg(atan2(xImgMeters/2,display.dist));
scene = sceneSet(scene, 'fov', fov);
scene = sceneSet(scene, 'name', strcat(imageName, 'Scene'));
scene = sceneSet(scene, 'filename', []);

%% Save scene object
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
sceneFilePath = fullfile(dataBaseDir, 'SceneData', calcParams.cacheFolderList{2}, folderName,strcat(imageName,'Scene.mat'));
theDir = fileparts(sceneFilePath);
if (~exist(theDir,'dir'))
    mkdir(theDir);
end
save(sceneFilePath, 'scene');

end


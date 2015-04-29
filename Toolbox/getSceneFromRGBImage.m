function scene = getSceneFromRGBImage(calcParams, folderName, imageName, display, imgSize)
% scene = getSceneFromRGBImage(calcParams, folderName, imageName, display, imgSize)
%
% Function to generate an ISETBIO scene from an RGB Image.  The scene
% will also be saved to the appropriate project folder, determined by
% the project preferences.
%
% 3/11/2015    xd     wrote it
% 4/1/2015     xd     updated to adjust fov to crop size

%% Get path to image
path = strcat(folderName, '/', imageName);

%% Load the input image
imageData  = loadImageData(path);
[yImgPixels xImgPixels imgColorPlanes] = size(imageData);

%% Generate scene
tic;
scene = sceneFromFile(imageData, 'rgb', [], display);
fprintf('Scene object generation took %2.1f seconds\n', toc);

%% Crop scene to the size we want to use
%
% Usually not all of the original image

% First have to crop the pixels, but this doesn't adjust
% field of view
scene = sceneCrop(scene, calcParams.cropRect);

% Need to resize field of view.  Scale size of image
% in meters by how much we're cropping out.
dist = display.dist;
yFraction = calcParams.cropRect(4) / yImgPixels;
xFraction = calcParams.cropRect(3) / xImgPixels;
imgSize = [xFraction*imgSize(1), yFraction*imgSize(2)];
fov = 2*rad2deg(atan2(imgSize(1)/2,dist));
scene = sceneSet(scene, 'fov', fov);

%% Save scene object
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
sceneFilePath = fullfile(dataBaseDir, 'SceneData', strcat(path,'Scene.mat'));
save(sceneFilePath, 'scene');

end


function scene = getSceneFromRGBImage(calcParams, folderName, imageName, display)
% scene = getSceneFromRGBImage(calcParams, folderName, imageName, display)
%
% Function to generate an ISETBIO scene from an RGB Image.  The scene
% will also be saved to the appropriate project folder, determined by
% the project preferences.
%
% Inputs:
%   calcParams - parameters for the entire calculation, will contain
%                desired crop size
%   folderName - folder on ColorShare in which image resides
%   imageName  - name of the image file
%   display    - Isetbio style display object to used for scene generation
%
% Outputs:
%   scene - the scene generated through isetbio using the input parameters
%
% 3/11/2015    xd        wrote it
% 4/1/2015     xd        updated to adjust fov to crop size
% 5/27/15      xd, dhb   use dots per inch info in display to compute image size 

%% Get path to image
path = strcat(folderName, '/', imageName);

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
xImgPixels = sceneGet(scene,'cols');
xImgMeters = xImgPixels*0.0254/display.dpi;

% Need to resize field of view.  Scale size of image
% in meters by how much we're cropping out.
fov = 2*rad2deg(atan2(xImgMeters/2,display.dist));
scene = sceneSet(scene, 'fov', fov);
scene = sceneSet(scene, 'name', strcat(imageName, 'Scene'));

%% Save scene object
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
sceneFilePath = fullfile(dataBaseDir, 'SceneData', strcat(path,'Scene.mat'));
save(sceneFilePath, 'scene');

end


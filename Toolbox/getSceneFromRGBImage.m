function scene = getSceneFromRGBImage(folderName, imageName, display, imgSize)
% scene = getSceneFromRGBImage(folderName, imageName, display, imgSize)
%
% Function to generate an ISETBIO scene from an RGB Image.  The scene
% will also be saved to the appropriate project folder, determined by
% the project preferences.
%
% 3/11/2015    xd     wrote it
% 4/1/2015     xd     updated to adjust fov to crop size

%% Get path to image
path = strcat(folderName, '/', imageName);

% Load the input image
imageData  = loadImageData(path);

%% WHERE DO WE WANT THIS TO HAPPEN?  PROBABLY NOT DOWN HERE.
ieInit;

% Generate scene
tic;
scene = sceneFromFile(imageData, 'rgb', [], display);
fprintf('Scene object generation took %2.1f seconds\n', toc);

%% THESE MAGIC NUMBERS ARE DANGEROUS.  WHAT ARE THEY?  LET'S SET THEM IN SOME 
% CLEAR PLACE.  SAME WITH CROPPING NUMBESR BELOW?
dist = display.dist;
y = 40 / 960;
x = 40 / 1280;
imgSize = [x*imgSize(1), y*imgSize(2)];

% Get scene FOV to match stimuli in experiment
fov = 2*rad2deg(atan2(imgSize(1)/2,dist));
scene = sceneSet(scene, 'fov', fov);

% Crop out black space
% scene = sceneCrop(scene, [450 350 624 574]);
% use a smaller cropping area to reduce file size
scene = sceneCrop(scene, [550 450 40 40]);

% Save scene object
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
sceneFilePath = fullfile(dataBaseDir, 'SceneData', strcat(path,'Scene.mat'));

%% THIS SAYS IT IS TEMPORARY.  IS IT?  FIX?
% Save scene data in directory, temp until write access to ColorShare
save(sceneFilePath, 'scene');

end


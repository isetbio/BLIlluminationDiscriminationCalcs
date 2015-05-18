function scene = loadSceneData(folderName, imageName)
% scene = loadSceneData(folderName, imageName)
% 
% Loads the saved scene data for BLIlluminationCalcs. 
%
% Preferences are used to find the right directory.
% 
% 3/12/2015   xd  wrote it

%% Get path to scene files
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
scenePath = fullfile(dataBaseDir, 'SceneData', folderName, strcat(imageName, 'Scene.mat'));

%% Load scene data
data = load(scenePath);
scene = data.scene;

end


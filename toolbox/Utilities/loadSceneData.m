function scene = loadSceneData(folderName, imageName)
% scene = loadSceneData(folderName, imageName)
% 
% Loads the saved scene data for BLIlluminationCalcs. 
% Preferences are used to find the right directory.
% 
% Inputs:
% folderName - name of folder on ColorShare in which the data resides
% imageNname - name of the original image used to create the scene, this is
%              not the name of the scene file
%
% 3/12/2015   xd  wrote it

%% Get path to scene files
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
scenePath = fullfile(dataBaseDir, 'SceneData', folderName, strcat(imageName, 'Scene.mat'));

%% Load scene data
data = load(scenePath);
scene = data.scene;

end


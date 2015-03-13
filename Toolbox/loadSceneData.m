function scene = loadSceneData(folderName, imageName)
%loadSceneData
%   Loads the saved scene data for BLIlluminationCalcs.  Load data from a
%   subdirectory 'folderName' in the SceneData directory on ColorShare1
%
%   3/12/2015   xd  wrote it

    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    scenePath = fullfile(dataBaseDir, 'SceneData', folderName, strcat(imageName, 'Scene.mat'));

    data = load(scenePath);
    scene = data.scene;
end


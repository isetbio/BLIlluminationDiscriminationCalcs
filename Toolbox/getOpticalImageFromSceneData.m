function optics = getOpticalImageFromSceneData(folderName, sceneName)
%getOpticalImageFromSceneData
%   Loads the scene file from ColorShare1 and turns it into an optical
%   image using default human optics
%
%   3/11/2015   xd  wrote it

    s_initISET;
    
%     dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
%     sceneFilePath = fullfile(dataBaseDir, 'SceneData', folderName, sceneName);
    
    sceneFilePath = strcat(folderName, '/', sceneName, 'Scene.mat');
    
    % load scene
    data = load(sceneFilePath);
    scene = data.scene;
    
    % load optical image
    optics = oiCreate('human');
    tic
    optics = oiCompute(optics,scene); 
    fprintf('Optical image object generation took %2.1f seconds\n', toc);

    %save data to temp until write access to ColorShare
    save(strcat('TempOptics/', sceneName, 'Optics.mat'), 'optics');
end


function optics = getOpticalImageFromSceneData(folderName, imageName)
%getOpticalImageFromSceneData
%   Loads the scene file from ColorShare1 and turns it into an optical
%   image using default human optics
%
%   3/11/2015   xd  wrote it

    s_initISET;
        
    % load scene
    scene = loadSceneData(folderName, imageName);
    
    % load optical image
    optics = oiCreate('human');
    tic
    opticalimage = oiCompute(optics,scene); 
    fprintf('Optical image object generation took %2.1f seconds\n', toc);
        
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    oiFilePath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'OpticalImage.mat'));
%     vcSaveObject(opticalimage, sceneFilePath);

    save(oiFilePath, 'opticalimage');
end


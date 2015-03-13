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
    optics = oiCompute(optics,scene); 
    fprintf('Optical image object generation took %2.1f seconds\n', toc);

    %save data to temp until write access to ColorShare
    
    % TODO, just save the DATA field of scenes and optical images to save
    % space?
    % TODO, take in standard OI and generate noise, compare to other
    % OI and subtract, find distance, make chooser based on it
    
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    sceneFilePath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'Optics.mat'));
    save(sceneFilePath, 'optics');
end


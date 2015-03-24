function scene = getSceneFromRGBImage(folderName, imageName, display, imgSize)
%getSceneFromRGBImage
%
%   Function to generate an ISETBIO scene from an RGB Image.  The scene
%   will also be saved to the appropriate folder on ColorShare1 
%   3/11/2015    xd     wrote it
    
    path = strcat(folderName, '/', imageName);

    % Load the input image
    imageData  = loadImageData(path);
    
    s_initISET;
    
    % generate scene
    tic
    scene = sceneFromFile(imageData, 'rgb', [], display);  
    fprintf('Scene object generation took %2.1f seconds\n', toc);
    
    dist = display.dist;
    
%     imgSize = [40, 40];
    
    fov = rad2deg(atan2(imgSize(1),dist));
    scene = sceneSet(scene, 'fov', fov);

    % crop out black space
    % scene = sceneCrop(scene, [450 350 624 574]);
    % use a smaller cropping area to reduce file size
    scene = sceneCrop(scene, [550 450 40 40]);
    
    % save scene object
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    sceneFilePath = fullfile(dataBaseDir, 'SceneData', strcat(path,'Scene.mat'));

    % Save scene data in directory, temp until write access to ColorShare
    save(sceneFilePath, 'scene');
    
end


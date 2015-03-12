function scene = loadSceneData(folderName, imageName)
%loadSceneData
%   Loads the saved scene data for BLIlluminationCalcs.  Currently using a
%   local temp folder until write access to ColorShare1 is attained.
%
%   3/12/2015   xd  wrote it

    path = strcat(folderName, '/', imageName, 'Scene.mat');

    data = load(path);
    scene = data.scene;
end


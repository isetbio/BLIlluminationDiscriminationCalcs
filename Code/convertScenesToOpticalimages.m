function convertScenesToOpticalimages
%convertScenesToOpticalimages
%   Convert all of the scenes in the SceneData directory on ColorShare1
%   into Optical Images
%
%   3/13/2015   xd  wrote it

    % List of where the images will be stored on ColorShare1
    folderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    
    % Loop over each image data folder
    for i = 1:length(folderList)
        % Get list of all files in directory
        imageFilePath = fullfile(dataBaseDir, 'SceneData', folderList{i});
        data = what(imageFilePath);
        fileList = data.mat;

        %   For each scene object, create a optical image object from it
        for s = 1:length(fileList)
            % Removing the 'Scene.mat' to make renaming easier
            imgName = strsplit(fileList{s}, 'Scene');
            
            % Create new Optical Image object if it does not already exist
            sceneCheckPath = fullfile(dataBaseDir, 'OpticalImageData', folderList{i}, strcat(imgName{1}, 'OpticalImage.mat'));
            if (~exist(sceneCheckPath, 'file'))
                getOpticalImageFromSceneData(folderList{i}, imgName{1});
            end
            fprintf(imgName{1});
            fprintf('\n');
        end
    end

end


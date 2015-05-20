function convertScenesToOpticalimages(calcParams, forceCompute)
%convertScenesToOpticalimages(calcParams, forceCompute)
%   Convert all of the scenes in the SceneData directory on ColorShare1
%   into Optical Images
%
%   Inputs:
%   calcParams - A set of parameters used to specify parameters such as
%       target folder names and crop size
%   forceCompute - Setting this to true will cause this function to
%       compute a new optical image even if a cached version already exists
%   3/13/2015   xd  wrote it

%% List of where the images will be stored on ColorShare1
folderList = calcParams.cacheFolderList;
    
%% Point at where input data live
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    
%% Create oi object
oi = oiCreate('human');

%% Compute the Optical Images
%
% Loop over each image data folder
for i = 1:length(folderList)
    % Get list of all files in directory
    imageFilePath = fullfile(dataBaseDir, 'SceneData', folderList{i});
    data = what(imageFilePath);
    fileList = data.mat;

    % For each scene object, create a optical image object from it
    for s = 1:length(fileList)
        % Removing the 'Scene.mat' to make renaming easier
        imgName = strsplit(fileList{s}, 'Scene');

        % Create new Optical Image object if it does not already exist
        % or if forceCompute flag is set to true
        sceneCheckPath = fullfile(dataBaseDir, 'OpticalImageData', folderList{i}, strcat(imgName{1}, 'OpticalImage.mat'));
        if (forceCompute || ~exist(sceneCheckPath, 'file'))
            getOpticalImageFromSceneData(oi, folderList{i}, imgName{1});
        end
        % For debugging purposes
        %         fprintf(imgName{1});
        %         fprintf('\n');
    end
end

end


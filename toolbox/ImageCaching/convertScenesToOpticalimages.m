function convertScenesToOpticalimages(calcParams,forceCompute)
% convertScenesToOpticalimages(calcParams,forceCompute)
%
% Convert all of the scenes in the SceneData directory on ColorShare1 into Optical Images
%
% Inputs:
%     calcParams    -  A set of parameters used to specify parameters such 
%                      as target folder names
%     forceCompute  -  Setting this to true will cause this function to
%                      compute a new optical image even if a cached version 
%                       already exists
%
% 3/13/15   xd  wrote it

%% Point at where input data live
databaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% List of where the images will be stored on ColorShare1
targetFolderList = calcParams.cacheFolderList;
sceneDir = fullfile(databaseDir, 'SceneData', targetFolderList{2});
contents = dir(sceneDir);
folderList = cell(1,5);
for ii = 1:length(contents)
    curr = contents(ii);
    if ~strcmp(curr.name,'.') && ~strcmp(curr.name,'..') && curr.isdir
        emptyCells = cellfun('isempty', folderList);
        firstIndex = find(emptyCells == 1, 1);
        % fprintf('%s', curr.name);
        folderList{firstIndex} = curr.name;
    end
end

%% Create oi object
oi = oiCreate('human');

%% Compute the optical images

% Check if target folder exists, if not, create folder and sub folders
AnalysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
targetPath = fullfile(AnalysisDir, 'OpticalImageData', targetFolderList{2});
if ~exist(targetPath, 'dir')
    parentPath = fullfile(AnalysisDir, 'OpticalImageData');
    mkdir(parentPath, targetFolderList{2});
    for i = 1:length(folderList)
        if ~isempty(folderList{i})
            mkdir(targetPath,folderList{i});
        end
    end
end

% Loop over each image data folder
for i = 1:length(folderList)
    % Get list of all files in directory
    imageFilePath = fullfile(sceneDir, folderList{i});
    data = what(imageFilePath);
    fileList = data.mat;
    
    % For each scene object, create a optical image object from it
    for s = 1:length(fileList)
        % Removing the 'Scene.mat' to make renaming easier
        imgName = strsplit(fileList{s}, 'Scene');
        
        % Create new Optical Image object if it does not already exist
        % or if forceCompute flag is set to true
        oiCheckPath = fullfile(AnalysisDir, 'OpticalImageData', targetFolderList{2}, folderList{i}, strcat(imgName{1}, 'OpticalImage.mat'));
        if (forceCompute || ~exist(oiCheckPath, 'file'))
            getOpticalImageFromSceneData(calcParams, oi, folderList{i}, imgName{1});
        end
        % For debugging purposes
        %         fprintf(imgName{1});
        %         fprintf('\n');
    end
end

end


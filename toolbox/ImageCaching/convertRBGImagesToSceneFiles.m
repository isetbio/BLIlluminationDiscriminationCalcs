function convertRBGImagesToSceneFiles(calcParams,forceCompute)
% convertRBGImagesToSceneFiles(calcParams,forceCompute)
%
% Function to take in names of folders and convert every RGB image in the
% target folders to corresponding scene data files in the SceneData
% folder
%
% Inputs:
%   calcParams   - A set of parameters used to specify parameters such as
%                  target folder names and crop size
%   forceCompute - Setting this to true will cause this function to
%                  compute a new scene even if a cached version already exists
%
% 3/12/2015   xd  wrote it

%% Point at where input data live
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% List of where the images will be stored on ColorShare1
targetFolderList = calcParams.cacheFolderList;
imageDir = fullfile(dataBaseDir, 'ImageData', targetFolderList{1});
contents = dir(imageDir);
imageFolderList = cell(1,5);
for ii = 1:length(contents)
    curr = contents(ii);
    if ~strcmp(curr.name,'.') && ~strcmp(curr.name,'..') && curr.isdir
        emptyCells = cellfun('isempty', imageFolderList);
        firstIndex = find(emptyCells == 1, 1);
        imageFolderList{firstIndex} = curr.name;
    end
end

%% Create isetbio display object from BL calibration file

% Get calibration file
calStructOBJ = loadCalibrationData(calcParams.calibrationFile);

% Create the display
extraData = ptb.ExtraCalData;
extraData.distance = calcParams.distance;
extraData.subSamplingSvector = calcParams.S;

% Generate an isetbio display object to model the display used to
% obtain the calibration data, and save this.
tic;
brainardLabDisplay = ptb.GenerateIsetbioDisplayObjectFromPTBCalStruct('BrainardLabStereoLeftDisplay', calStructOBJ.cal, extraData, false);
fprintf('Display object generation took %2.1f seconds\n', toc);

% % Set gamma table to linspace because images are already gamma corrected
% gammaTable = displayGet(brainardLabDisplay,'gtable');
% gammaLength = size(gammaTable,1);
% gammaTable = repmat(linspace(0,1,gammaLength)',1,3);
% brainardLabDisplay = displaySet(brainardLabDisplay,'gtable',gammaTable);

%% Precompute the scene files

% Check if target folder exists, if not, create folder and sub folders
targetPath = fullfile(dataBaseDir, 'SceneData', targetFolderList{2});
if ~exist(targetPath, 'dir')
    parentPath = fullfile(dataBaseDir, 'SceneData');
    mkdir(parentPath, targetFolderList{2});
    for i = 1:length(imageFolderList)
        if ~isempty(imageFolderList{i})
          mkdir(targetPath,imageFolderList{i});
        end
    end
end

% Loop over each image data folder and write out a scene
for i = 1:length(imageFolderList)
    % Point at scene directory
    imageFilePath = fullfile(imageDir, imageFolderList{i});    
    data = what(imageFilePath);
    fileList = data.mat;
    
    % For each image file, load the image and generate a scene from it
    % using the Brainard Lab Display calibration file.  We only do this
    % if the scene does not exist, or if the forceCompute flag is set to
    % true.  That makes this loop fast after the first time.
    for s = 1:length(fileList)

        imgName = strsplit(fileList{s}, '.');     
        sceneCheckPath = fullfile(dataBaseDir, 'SceneData',targetFolderList{2}, imageFolderList{i}, strcat(imgName{1}, 'Scene.mat'));
        if (forceCompute || ~exist(sceneCheckPath, 'file'))
            getSceneFromRGBImage(calcParams,imageFolderList{i}, imgName{1}, brainardLabDisplay);
        end
        
        % For debugging purposes
        % fprintf(imgName{1});
        % fprintf('\n');
    end
end
end


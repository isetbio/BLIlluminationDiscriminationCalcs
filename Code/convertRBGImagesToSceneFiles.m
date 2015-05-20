function convertRBGImagesToSceneFiles(calcParams,forceCompute)
% convertRBGImagesToSceneFiles(calcParams,forceCompute)
%
% Function to take in names of folders and convert every RGB image in the
% target folders to corresponding scene data files in the SceneData
% folder
%
%   Inputs:
%   calcParams - A set of parameters used to specify parameters such as
%       target folder names and crop size
%   forceCompute - Setting this to true will cause this function to
%       compute a new scene even if a cached version already exists
%
% 3/12/2015   xd  wrote it

%% List of where the images will be stored on ColorShare1
folderList = calcParams.cacheFolderList;

%% Point at where input data live
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% Create isetbio display object from BL calibration file
%
% Get calibration file
calStructOBJ = loadCalibrationData('StereoLCDLeft');

% Create the display
extraData = ptb.ExtraCalData;
extraData.distance = 0.764;
extraData.subSamplingSvector = [380 8 51];

% Generate an isetbio display object to model the display used to
% obtain the calibration data, and save this.
tic;
brainardLabDisplay = ptb.GenerateIsetbioDisplayObjectFromPTBCalStruct('BrainardLabStereoLeftDisplay', calStructOBJ.cal, extraData, false);
fprintf('Display object generation took %2.1f seconds\n', toc);

%% Pecompute the scene files
%
% Loop over each image data folder and write out a scene
for i = 1:length(folderList)
    % Point at scene directory
    imageFilePath = fullfile(dataBaseDir, 'ImageData', folderList{i});
    data = what(imageFilePath);
    fileList = data.mat;
    
    % For each image file, load the image and generate a scene from it
    % using the Brainard Lab Display calibration file
    for s = 1:length(fileList)
        
        % Create new Scene object if it does not already exist or if
        % forceCompute flag is set to true
        imgSize = calStructOBJ.get('screenSizeMM') / 1000;
        imgName = strsplit(fileList{s}, '.');
        
        sceneCheckPath = fullfile(dataBaseDir, 'SceneData', folderList{i}, strcat(imgName{1}, 'Scene.mat'));
        if (forceCompute || ~exist(sceneCheckPath, 'file'))
            getSceneFromRGBImage(calcParams,folderList{i}, imgName{1}, brainardLabDisplay, imgSize);
        end
        % For debugging purposes
        % fprintf(imgName{1});
        % fprintf('\n');
    end
end
end


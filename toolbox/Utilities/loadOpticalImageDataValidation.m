function opticalImage = loadOpticalImageDataValidation(folderName,imageName)
% opticalImage = loadOpticalImageDataValidation(folderName,imageName)
%
% Loads the saved optical image data for BLIlluminationCalcs.
% Uses project preferences to know where to look
%
% Inputs:
%     folderName  -  name of folder on ColorShare in which the data resides
%     imageNname  -  name of the original image used to create the scene,
%                    this is not the name of the optical image file
%
% Outputs:
%     opticalImage  -  ISETBIO opticalimage

% 3/12/2015   xd  wrote it

%% Get path to OI data files
    localFile = mfilename('fullpath');
    topDir = fileparts(fileparts(fileparts(localFile)));
    valDir = fullfile(topDir,'validation','scripts','FirstOrderModel');
    opticsPath = fullfile(valDir, folderName, strcat(imageName, 'OpticalImage.mat'));

%% Get data
    data = load(opticsPath);
    fnames = fieldnames(data);
    opticalImage = data.(fnames{1});
end
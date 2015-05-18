function opticalImage = loadOpticalImageData(folderName, imageName)
% opticalImage = loadOpticalImageData(folderName, imageName)
%
% Loads the saved optical image data for BLIlluminationCalcs.
%
% Uses project preferences to know where to look
%
%   3/12/2015   xd  wrote it

%% Get path to OI data files
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    opticsPath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'OpticalImage.mat'));

%% Get data
    data = load(opticsPath);
    opticalImage = data.opticalimage;
end


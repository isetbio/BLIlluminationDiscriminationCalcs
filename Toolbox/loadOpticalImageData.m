function opticalImage = loadOpticalImageData(folderName, imageName)
% opticalImage = loadOpticalImageData(folderName, imageName)
%
% Loads the saved optical image data for BLIlluminationCalcs.
%
% Uses project preferences to know where to look
%
%   3/12/2015   xd  wrote it

    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    opticsPath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'OpticalImage.mat'));

    data = load(opticsPath);
    opticalImage = data.opticalimage;
end


function opticalImage = loadOpticalImageData(folderName, imageName)
%loadOpticalImageData
%   Loads the saved optical image data for BLIlluminationCalcs.  Will load
%   optical data from 'folderName' subdirectory in OpticalImageData folder
%
%   3/12/2015   xd  wrote it

    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    opticsPath = fullfile(dataBaseDir, 'OpticalImageData', folderName, strcat(imageName, 'OpticalImage.mat'));

    data = load(opticsPath);
    opticalImage = data.opticalimage;
end


function imageData = loadImageData(imageFile)
% imageData = loadImageData(imageFile)
%
% Method to load data from an imageFile located in the ImageData directory of the
% BLIlluminationDiscriminationCalcs project, which currently is resides in
% scallop's ColorShare1 shared folder.
%
% 2/26/2015     npc     Wrote it.
% 
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    imageFilePath = fullfile(dataBaseDir, 'ImageData', imageFile);
    
    % Load the image and calibration filename
    data = load(imageFilePath);
    imageData = data.sensorImageLeftRGB;
end
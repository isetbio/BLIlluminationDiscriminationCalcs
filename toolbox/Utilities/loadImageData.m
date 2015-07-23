function imageData = loadImageData(imageFile)
% imageData = loadImageData(imageFile)
%
% Method to load data from an imageFile located in the ImageData directory of the
% BLIlluminationDiscriminationCalcs project, which currently is set by the
% project's preferences.
%
% 2/26/2015     npc     Wrote it.

% Get the directory find the image
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
imageFilePath = fullfile(dataBaseDir, 'ImageData', imageFile);

% Load the image
data = load(imageFilePath);
imageData = data.sensorImageLeftRGB;

end
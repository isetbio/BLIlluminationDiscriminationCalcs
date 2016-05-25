function imageData = loadImageData(imageFile)
% imageData = loadImageData(imageFile)
%
% Method to load data from an imageFile located in the ImageData directory of the
% BLIlluminationDiscriminationCalcs project, which currently is set by the
% project's preferences.
%
% 2/26/2015     npc     Wrote it.
% 5/25/2016     xd      Updated to support different variable names
% Get the directory find the image
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
imageFilePath = fullfile(dataBaseDir, 'ImageData', imageFile);

% Load the image
data = matfile(imageFilePath);

% If there is only one variable in the .mat file, then load that as the
% image. However, if there are more than one variables, look for the first
% one containing RGB in the name and load that instead.
varNames = who(data);
if length(varNames) == 1
    imageData = data.(varNames{1});
else
    for ii = 1:length(varNames)
        if ~isempty(strfind(varNames{ii}, 'RGB'))
            imageData = data.(varNames{ii});
            break;
        end
    end
end
end
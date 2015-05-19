function ChooserData = loadChooserData(fileName)
%loadChooserData(fileName)
%   This function loads the data acquired from the simple chooser model.
%   The data is currently stored on the ColorShare1 server.
%   Inputs:
%   fileName - name of the data file to be loaded
%   5/18/2015   xd  wrote it

% Get the directory find the image
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
dataFilePath = fullfile(dataBaseDir, 'SimpleChooserData', fileName);

% Load the image
data = load(dataFilePath);
ChooserData = data.matrix;

end


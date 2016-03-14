function ChooserData = loadChooserData(folderName, fileName)
% loadChooserData(fileName)
%
% This function loads the data acquired from the simple chooser model.
% The data is currently stored on the ColorShare1 server.
%
% Inputs:
%   fileName - name of the data file to be loaded
%
% 5/18/2015   xd  wrote it
% 3/14/2016   xd  editted to use DropBox paths

% Get the directory find the image
analysisDir   = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
analysisPath = fullfile(analysisDir, 'SimpleChooserData', folderName, fileName);

% Load the image
data = load(analysisPath);
ChooserData = data.matrix;

end


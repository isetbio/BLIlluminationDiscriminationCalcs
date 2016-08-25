function ThresholdData = loadThresholdData(folderName,fileName)
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
analysisPath  = fullfile(analysisDir, 'SimpleChooserData', folderName, fileName);

if ~exist(analysisPath,'file')
    ThresholdData = []; return;
end

% Load the data
data = load(analysisPath);
if isfield(data,'thresholds')
    ThresholdData = data.thresholds;
    return
end
ThresholdData = data.matrix;

end


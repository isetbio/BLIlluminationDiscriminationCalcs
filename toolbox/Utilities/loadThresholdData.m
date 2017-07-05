function thresholdData = loadThresholdData(folderName,fileName)
% thresholdData = loadThresholdData(folderName,fileName)
%
% This function loads the data acquired from the simple chooser model.
%
% Inputs:
%     folderName  -  folder containing all the data
%     fileName    -  name of the data file to be loaded
%
% Outputs:
%     thresholdData  -  matrix of the threshold data
%
% 5/18/2015   xd  wrote it
% 3/14/2016   xd  editted to use DropBox paths

% Get the directory find the image
analysisDir   = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
analysisPath  = fullfile(analysisDir, 'SimpleChooserData', folderName, fileName);

if ~exist(analysisPath,'file')
    thresholdData = []; return;
end

% Load the data
data = load(analysisPath);
if isfield(data,'thresholds')
    thresholdData = data.thresholds;
    return
end
thresholdData = data.matrix;

end


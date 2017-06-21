function setUpDirectories
% setUpDirectories
%
% This function will set up the relevant directories and subdirectories for
% this project if they do not exist yet.
%
% 7/23/15  xd  wrote it
% 6/21/17  xd  remove queue directory things, update to current file
%              structure

%% Get directories
dataDir  = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

%% Make directories
if ~exist(dataDir, 'dir')
    mkdir(dataDir);
end

if ~exist(analysisDir, 'dir')
    mkdir(analysisDir);
end

%% Make subdirectories
dataSubDir = {'CalData' 'ImageData' 'SceneData'};
for ii = 1:length(dataSubDir)
    if ~exist(fullfile(dataDir, dataSubDir{ii}), 'dir')
        mkdir(fullfile(dataDir, dataSubDir{ii}));
    end
end

analysisSubDir = {'OpticalImageData' 'SimpleChooserData'};
for ii = 1:length(analysisSubDir)
    if ~exist(fullfile(analysisDir, analysisSubDir{ii}), 'dir')
        mkdir(fullfile(analysisDir, analysisSubDir{ii}));
    end
end
end


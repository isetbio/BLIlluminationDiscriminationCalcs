function setUpDirectories
% setUpDirectories
%
% This function will set up the relevant directories and subdirectories for
% this project if they do not exist yet.
%
% 7/23/15  xd  wrote it

%% Get directories
dataDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
queueDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Make directories
if ~exist(queueDir, 'dir')
    mkdir(queueDir);
end

if ~exist(dataDir, 'dir')
    mkdir(dataDir);
end

%% Make subdirectories
dataSubDir = {'CalData' 'ImageData' 'OpticalImageData' 'SceneData' 'SimpleChooserData'};
for ii = 1:length(dataSubDir)
    if ~exist(fullfile(dataDir, dataSubDir{ii}), 'dir')
        mkdir(fullfile(dataDir, dataSubDir{ii}));
    end
end

end


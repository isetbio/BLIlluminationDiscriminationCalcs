function makeAllOISets(numCores)
% makeAllOISets(numCores)
%
% Creates all the optical images necessary for the computations. This
% script takes in the scene files that contain the full stimulus and breaks
% into 1 degree patches before computing the optical images. 
%
% This script should not be modified as it contains the parameters used for
% the paper calculations. If you are adopting code from this function, copy
% it to a new file to edit.
%
% Inputs:
%     numCores  -  number of parpool workers to allocate
%
% 06/20/17  xd  wrote it

p = parpool(numCores); 

%% Constant
% c.calcIDStr = 'Constant';
% c.cacheFolderList = {'Constant', 'Constant_FullImage'};
% c.sensorFOV = 1;
% generateOIForParallelComputing(c);

%% Neutral
c.calcIDStr = 'Neutral';
c.cacheFolderList = {'Neutral', 'Neutral_FullImage'};
c.sensorFOV = 1;
generateOIForParallelComputing(c);

%% NM1
c.calcIDStr = 'NM1';
c.cacheFolderList = {'NM1', 'NM1_FullImage'};
c.sensorFOV = 1;
generateOIForParallelComputing(c);

%% NM2
c.calcIDStr = 'NM2';
c.cacheFolderList = {'NM2', 'NM2_FullImage'};
c.sensorFOV = 1;
generateOIForParallelComputing(c);

%% Shutdown parallel stuff
delete(p);
end
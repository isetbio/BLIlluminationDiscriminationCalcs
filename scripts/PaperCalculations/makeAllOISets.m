function makeAllOISets(numCores)
%% makALlOISets
%
% Creates all the optical images necessary for the computations. This
% script takes in the scene files that contain the full stimulus and breaks
% into 1 degree patches before computing the optical images.
%
% 6/20/17   xd  wrote it

p = parpool(numCores); % set to however many the machine can reasonable handle

%% Constant
c.calcIDStr = 'Constant';
c.cacheFolderList = {'Constant', 'Constant_FullImage'};
c.sensorFOV = 1;
generateOIForParallelComputing(c);

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
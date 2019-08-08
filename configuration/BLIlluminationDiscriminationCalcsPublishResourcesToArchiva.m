%% BLIlluminationDiscriminationCalcsPublishResourcesToArchiva
%
% Publish resources for the BLIlluminationDiscrimation calculations to our
% archive server.
%
% These are currently:
%   Precomputed optical images for the experimental stimuli
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% To actually make this work, you'd need write credentials to the
% BLIlluminationDiscrminationCalcs archiva repository.
%
% We are not actually using archiva for data anymore, we've got it on
% dropbox and could provide to someone who wants it.
%
% See also rdtExampleReadData, rdtExamplePublishData as well as the
% RemoteDataToolbox documentation, in the wiki on
% gitHub.com/isetbio/RemoteDataToolbox/wiki.


%% Clear and close
clear;

%% Set up client
rd = RdtClient(fullfile('/Users/dhb/Documents/MATLAB','rdtConfig','rdt-config-BLIlluminationDiscriminationCalcs.json'));

%% We want to publish the tree of files that live on our local copy.  These were
% created by other routines within this repository.
localRootDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
localDir = fullfile(localRootDir,'OpticalImageData','Neutral');

%% For each folder in the the local dir, publish the .mat files in that folder.
version = '1';
curDir = pwd;
cd(localDir);
theDirectoriesToPublish = dir;

% Go through the things that got listed that are directories one at a time,
% but don't get fooled by '.' and '..'.
for ii = 1:length(theDirectoriesToPublish)
    % If it's an actual directory, then we publish all the .mat files in
    % it.
    if (theDirectoriesToPublish(ii).isdir & ~strcmp(theDirectoriesToPublish(ii).name,'.') & ~strcmp(theDirectoriesToPublish(ii).name,'..'))
        % This syntax publishes all the files of the corresponding type
        % that are in a directory.  See RemoteDataToolbox wiki, uploading
        % section, for more information.
        fprintf('Publishing .mat files in %s\n',theDirectoriesToPublish(ii).name);
        rd.crp(fullfile('/resources/OpticalImageData/Neutral',theDirectoriesToPublish(ii).name));
        artifact = rd.publishArtifacts(fullfile(pwd,theDirectoriesToPublish(ii).name), ...
            'version', version, ...
            'type', 'mat');
    end
end

%% Let's try downloading an artifact, to make sure it works.

% Go to one of the directories that we just pushed up
rd.crp('/resources/OpticalImageData/Neutral/BlueIllumination');

% List the artifacts that are there.
a = rd.listArtifacts('type','mat');

% Read the first artifact.
test = rd.readArtifact(a(1));

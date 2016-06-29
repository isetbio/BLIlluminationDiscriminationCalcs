function setPrefsForBLIlluminationDiscriminationCalcsTemplate
% setPrefsForBLIlluminationDiscriminationCalcsTemplate
%
% Set the preferences for the BLIlluminationDiscriminationCalcs project.
% This guesses at a sensible default if there isn't a user specific line
% entered for whoever is running it.
%
% 2/25/2015     npc     Wrote it.
% 6/4/15        xd      Added the queue directory
% 3/1/16        xd      Modified to use DropBox path

%% Figure out what computer we are running on
%
% Check if we have the IsCluster function.  If not, we are not on a
% cluster.
if (exist('IsCluster'))
    [isCluster,whichCluster] = IsCluster;
else
    isCluster = false;
end

%% Computer specific configuration
%
% Cluster.  Assume GPC since that is currently the only one we know about.
if (isCluster) 
     sharedRootDir = fullfile(filesep,'home/dhb/dropbox');
     clonedWikiDir = '';
     clonedGhPagesLocation = '';
     validationRootDir = '/home/dhb/analysis/BLIlluminationDiscriminationCalcs/validation';

    
% Brainard Lab Mac
else

sysInfo = GetComputerInfo();
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        sharedRootDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
        clonedWikiDir = '/Users/Shared/GitWebSites/BLIlluminationDiscriminationCalcs.wiki';
        clonedGhPagesLocation = '/Users/Shared/GitWebSites/BLIlluminationDiscriminationCalcs';
        validationRootDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/validation';

    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            case 'xiaomaoding'
                sharedRootDir = fullfile(filesep, 'Users', 'xiaomaoding', 'Dropbox (Aguirre-Brainard Lab)');
                clonedWikiDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcsWiki/BLIlluminationDiscriminationCalcs.wiki';
                clonedGhPagesLocation = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscrimCalcsGhPages/BLIlluminationDiscriminationCalcs';
                validationRootDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/validation';
            otherwise
                sharedRootDir = fullfile(filesep, 'Users', sysInfo.userShortName, 'Dropbox (Aguirre-Brainard Lab)');
                clonedWikiDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcsWiki/BLIlluminationDiscriminationCalcs.wiki';
                clonedGhPagesLocation = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscrimCalcsGhPages/BLIlluminationDiscriminationCalcs';
                validationRootDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/validation';
        end
end



end

%% This section might work on any computer
% Use this for DropBox data path, might need to change based on local settings
analysisBaseDir = fullfile(sharedRootDir, 'IBIO_analysis', 'BLIlluminationDiscrimination');
dataBaseDir = fullfile(sharedRootDir, 'IBIO_data', 'BLIlluminationDiscrimination');
queueDir = fullfile(analysisBaseDir, 'CalcParamQueue');

% UnitTestToolbox locations
alternateFullValidationDataDir = fullfile(dataBaseDir,'Validation','data','full');

% If the preferences group already exists, remove it
if (ispref('BLIlluminationDiscriminationCalcs'))
    rmpref('BLIlluminationDiscriminationCalcs');
end

% Set preferences
setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
setpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir', analysisBaseDir);
setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);
setpref('BLIlluminationDiscriminationCalcs', 'QueueDir', queueDir);

% Unit test toolbox preferences
p = struct(...
    'projectName',                         'BLIlluminationDiscrimCalcsValidation', ... 	                         % The project name (also the preferences group name)
    'validationRootDir',                   validationRootDir, ...                                                % Directory location where the 'scripts' subdirectory resides.
    'alternateFastDataDir',                '',  ...  	                                                         % Alternate FAST (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/fast
    'alternateFullDataDir',                alternateFullValidationDataDir,  ...                                  % Alternate FULL (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/full
    'useRemoteDataToolbox',  false, ...                                                                          % If true use Remote Data Toolbox to fetch validation data on demand.
    'remoteDataToolboxConfig', '', ...                                                                           % Struct, file path, or project name with Remote Data Toolbox configuration.
    'clonedWikiLocation',                  clonedWikiDir, ... 	                                                 % Local path to the directory where the wiki is cloned. Only relevant for publishing tutorials.
    'clonedGhPagesLocation',               clonedGhPagesLocation, ... 	                                         % Local path to the directory where the gh-pages repository is cloned. Only relevant for publishing tutorials.
    'githubRepoURL',                       'http://isetbio.github.io/BLIlluminationDiscriminationCalcs', ... 	 % Github URL for the project. This is only used for publishing tutorials.
    'generateGroundTruthDataIfNotFound',   true, ...  	                                                         % Flag indicating whether to generate ground truth if one is not found
    'numericTolerance',                    1e-12, ...      
    'listingScript',                       'illcalcsListAllValidationDirs' ...
    );

generatePreferenceGroup(p);
UnitTest.usePreferencesForProject(p.projectName);

% Add path dynamically here.  Although this isn't a preference, it is
% convenient to have one function that will make sure everything works.
myDir = fileparts(fileparts(mfilename('fullpath')));
pathDir = fullfile(myDir,'BLIlluminationDiscriminationCalcs','');
AddToMatlabPathDynamically(pathDir);

end

function generatePreferenceGroup(p)
% remove any existing preferences for this project
if ispref(p.projectName)
    rmpref(p.projectName);
end

% generate and save the project-specific preferences
setpref(p.projectName, 'projectSpecificPreferences', p);
fprintf('Generated and saved preferences specific to the ''%s'' project.\n', p.projectName);
end




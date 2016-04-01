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

sysInfo = GetComputerInfo();
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        sharedRootDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
        
    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            case 'xiaomaoding'
                sharedRootDir = fullfile(filesep, 'Users', 'xiaomaoding', 'Dropbox (Aguirre-Brainard Lab)');
            otherwise
                sharedRootDir = fullfile(filesep, 'Users', sysInfo.userShortName, 'Dropbox (Aguirre-Brainard Lab)');
        end
end

% Use this for DropBox data path, might need to change based on local settings
analysisBaseDir = fullfile(sharedRootDir, 'IBIO_analysis', 'BLIlluminationDiscrimination');
dataBaseDir = fullfile(sharedRootDir, 'IBIO_data', 'BLIlluminationDiscrimination');

% UnitTestToolbox locations
validationRootDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/validation';
clonedWikiDir = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcsWiki/BLIlluminationDiscriminationCalcs.wiki';
clonedGhPagesLocation = '/Users/Shared/Matlab/Analysis/BLIlluminationDiscrimCalcsGhPages/BLIlluminationDiscriminationCalcs';
alternateFullValidationDataDir = fullfile(dataBaseDir,'Validation','data','full');

% If the preferences group already exists, remove it
if (ispref('BLIlluminationDiscriminationCalcs'))
    rmpref('BLIlluminationDiscriminationCalcs');
end

% Set preferences
setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
setpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir', analysisBaseDir);
setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);

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




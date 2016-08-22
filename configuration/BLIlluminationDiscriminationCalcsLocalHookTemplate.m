function BLIlluminationDiscriminationCalcs
% BLIlluminationDiscrimination
%
% Configure things for working on the IBIOColorDetect project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUse({'IBIOColorDetect'}) to set up for
% this project.  You then edit your local copy to match your local machine.
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running BLIlluminationDiscriminationCalcs local hook\n');

%% Put project toolbox onto path
%
% Specify project name and location
projectName = 'BLIlluminationDiscriminationCalcs';
projectUrl = 'https://github.com/isetbio/BLIlluminationDiscriminationCalcs.git';
projectBaseDir = '/Users/xiaomaoding/Documents/MATLAB';

% Obtain or update the git repo and add subfolders to the Matlab path
fprintf('Calling tbDeployToolboxes\n');
config = [tbToolboxRecord( ...
    'name', 'BLIlluminationDiscriminationCalcs', ...
    'type', 'git', ...
    'update', 'never', ...
    'url', projectUrl, ...
    'subfolder', 'toolbox')
    tbToolboxRecord( ...
    'name', 'BLIlluminationDiscriminationCalcs', ...
    'type', 'git', ...
    'update', 'never', ...
    'url', projectUrl, ...
    'subfolder', 'scripts')
    tbToolboxRecord( ...
    'name', 'BLIlluminationDiscriminationCalcs', ...
    'type', 'git', ...
    'update', 'never', ...
    'url', projectUrl, ...
    'subfolder', 'tutorials')];
tbDeployToolboxes('config', config, 'toolboxRoot', projectBaseDir);

%% Figure out what computer we are running on
%
% Check if we have the IsCluster function.  If not, we are not on a
% cluster.
fprintf('Preference configuration\n');
if (exist('IsCluster'))
    [isCluster,whichCluster] = IsCluster;
else
    isCluster = false;
end

%% Computer specific configuration
%
% Cluster.  Assume GPC since that is currently the only one we know about.
if (isCluster)
    sharedRootDir = fullfile(filesep,'/data/shared/brainardlab/dropbox');
    clonedWikiDir = '';
    clonedGhPagesLocation = '';
    validationRootDir = '/data/shared/brainardlab/analysis/BLIlluminationDiscriminationCalcs/validation';   
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




%
% Generally, this function should be edited for your site and then run once.
%
 
function illcalcsSetUnitTestPreferences
 
    % Specify project-specific preferences
    p = struct(...
            'projectName',                         'BLIlluminationDiscrimCalcsValidation', ... 	 % The project name (also the preferences group name)
            'validationRootDir',                   '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/validation', ... 	 % Directory location where the 'scripts' subdirectory resides.
            'alternateFastDataDir',                '',  ...  	 % Alternate FAST (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/fast
            'alternateFullDataDir',                '/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcs/Validation/data/full',  ...  	 % Alternate FULL (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/full
            'useRemoteDataToolbox',  false, ...                                                                          % If true use Remote Data Toolbox to fetch validation data on demand.
            'remoteDataToolboxConfig', '/Users/dhb/Desktop/ProjectPrefs/isetbio/rdt-config-isetbio.json', ...            % Struct, file path, or project name with Remote Data Toolbox configuration.
            'clonedWikiLocation',                  '/Users/Shared/Matlab/Analysis/BLIlluminationDiscriminationCalcsWiki/BLIlluminationDiscriminationCalcs.wiki', ... 	 % Local path to the directory where the wiki is cloned. Only relevant for publishing tutorials.
            'clonedGhPagesLocation',               '/Users/Shared/Matlab/Analysis/BLIlluminationDiscrimCalcsGhPages/BLIlluminationDiscriminationCalcs', ... 	 % Local path to the directory where the gh-pages repository is cloned. Only relevant for publishing tutorials.
            'githubRepoURL',                       'http://isetbio.github.io/BLIlluminationDiscriminationCalcs', ... 	 % Github URL for the project. This is only used for publishing tutorials.
            'generateGroundTruthDataIfNotFound',   true, ...  	 % Flag indicating whether to generate ground truth if one is not found
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

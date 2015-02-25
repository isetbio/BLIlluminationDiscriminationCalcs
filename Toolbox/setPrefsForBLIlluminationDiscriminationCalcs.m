function setPrefsForBLIlluminationDiscriminationCalcs
% setPrefsForBLIlluminationDiscriminationCalcs
%
% Method to set the preferences for the BLIlluminationDiscriminationCalcs
% project.
%
% 2/25/2015     npc     Wrote it.
% 

    sharedRootDir = fullfile(filesep,'Volumes','ColorShare1','Users', 'Shared', 'Matlab', 'Analysis', 'BLIlluminationDiscriminationCalcs');
    dataBaseDir   = fullfile(sharedRootDir, 'Data');
    
    % If the preferences group already exists, remove it
    if (ispref('BLIlluminationDiscriminationCalcs'))
        rmpref('BLIlluminationDiscriminationCalcs');
    end
    
    % Set preferences
    setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
    setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);
end



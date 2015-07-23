function setPrefsForBLIlluminationDiscriminationCalcs
% setPrefsForBLIlluminationDiscriminationCalcs
%
% Method to set the preferences for the BLIlluminationDiscriminationCalcs project.
%
% 2/25/2015     npc     Wrote it.
% 6/4/15        xd      Added the queue directory

    % WHere are the image data stored for us to get at?
    sharedRootDir = fullfile(filesep,'Volumes','ColorShare1','Users', 'Shared', 'Matlab', 'Analysis', 'BLIlluminationDiscriminationCalcs');
    dataBaseDir   = fullfile(sharedRootDir, 'Data');
    queueDir      = fullfile(sharedRootDir, 'CalcParamQueue');
    
    % If the preferences group already exists, remove it
    if (ispref('BLIlluminationDiscriminationCalcs'))
        rmpref('BLIlluminationDiscriminationCalcs');
    end
    
    % Set preferences
    setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
    setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);
    setpref('BLIlluminationDiscriminationCalcs', 'QueueDir', queueDir);
end



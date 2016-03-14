function setPrefsForBLIlluminationDiscriminationCalcs
% setPrefsForBLIlluminationDiscriminationCalcs
%
% Method to set the preferences for the BLIlluminationDiscriminationCalcs project.
%
% 2/25/2015     npc     Wrote it.
% 6/4/15        xd      Added the queue directory
% 3/1/16        xd      Modified to use DropBox path

    % WHere are the image data stored for us to get at?
    sharedRootDir = fullfile(filesep,'Volumes','ColorShare1','Users', 'Shared', 'Matlab', 'Analysis', 'BLIlluminationDiscriminationCalcs');
%     dataBaseDir   = fullfile(sharedRootDir, 'Data');
    queueDir      = fullfile(sharedRootDir, 'CalcParamQueue');
    
    sysInfo = GetComputerInfo();
    switch(sysInfo.userShortName)
        case 'xiaomaoding'
            sharedRootDir = fullfile(filesep, 'Users', 'xiaomaoding', 'Dropbox (Aguirre-Brainard Lab)');
        otherwise 
            error('Non identified user.  Please edit setPrefsForBLIlluminationDiscriminationCalcs.m to set local DropBox path.');
    end

    % Use this for DropBox data path, might need to change based on local
    % settings
    
    analysisBaseDir = fullfile(sharedRootDir, 'IBIO_analysis', 'BLIlluminationDiscrimination');
    dataBaseDir = fullfile(sharedRootDir, 'IBIO_data', 'BLIlluminationDiscrimination');
    
    % If the preferences group already exists, remove it
    if (ispref('BLIlluminationDiscriminationCalcs'))
        rmpref('BLIlluminationDiscriminationCalcs');
    end
    
    % Set preferences
    setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
    setpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir', analysisBaseDir);
    setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);
    setpref('BLIlluminationDiscriminationCalcs', 'QueueDir', queueDir);
end



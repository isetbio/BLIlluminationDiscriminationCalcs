function setPrefsForBLIlluminationDiscriminationCalcs

    sharedRootDir = fullfile('Volumes','ColorShare1','Users', 'Shared', 'Matlab', 'Analysis', 'BLIlluminationDiscriminationCalcs');
    dataBaseDir   = fullfile(sharedRootDir, 'Data');
    if (ispref('BLIlluminationDiscriminationCalcs'))
        rmpref('BLIlluminationDiscriminationCalcs');
    end
    setpref('BLIlluminationDiscriminationCalcs', 'SharedRootDir', sharedRootDir);
    setpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir', dataBaseDir);
    
end



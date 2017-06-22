function calStructOBJ = loadCalibrationData(calFile)
% calStructOBJ = loadCalibrationData(calFile)
%
% Method to load calibration data from a calFile located in the CalData
% directory of the BLIlluminationDiscriminationCalcs project.  Where the
% data directory lives is controlled by a project preference file.
%
% See also: BLIlluminationDiscriminationCalcsLocalHookTemplate
%
% 2/26/2015     npc     Wrote it.

% Assemble calFileName
dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
calDir   = fullfile(dataBaseDir, 'CalData', filesep);

% Load the calibration data
cal = LoadCalFile(calFile, [], calDir);

% Generate calStructOBJ to access the calibration data
calStructOBJ = ObjectToHandleCalOrCalStruct(cal);
clear 'cal'

end
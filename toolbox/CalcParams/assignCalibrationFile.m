function updatedParams = assignCalibrationFile(calcParams)
% updatedParams = assignCalibrationFile(calcParams)
%
% Since different image sets may require different calibration files, we
% assign the calibration file to the calcParam struct. This will tell
% functions that require a calibration file to know which one to use. We
% also assign the distance associated with each monitor in this function.
%
% Inputs:
%     calcParams  -  calcParams struct that has the 'cacheFolderList' field
%                    already set
%
% Outputs:
%     updatedParams  -  calcParams struct updated with a 'distance' field
%                       and 'calibrationFile' field
%
% 5/25/16  xd  wrote it

switch (calcParams.cacheFolderList{1})
    case {'Constant' 'Shuffled'}
        calcParams.calibrationFile = 'EyeTrackerLCDNew';
        calcParams.distance = 0.683;
    case {'Neutral' 'NM1' 'NM2'}
        calcParams.calibrationFile = 'StereoLCDLeft';
        calcParams.distance = 0.764;
    otherwise
        warning('Unknown calcIDStr set');
end
updatedParams = calcParams;

end


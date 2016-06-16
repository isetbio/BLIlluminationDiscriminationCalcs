function updatedParams = assignCalibrationFile(calcParams)
% updatedParams = assignCalibrationFile(calcParams)
%
% Since different image sets may require different calibration files, we
% assign the calibration file to the calcParam struct. This will tell
% functions that require a calibration file to know which one to use. We
% also assign the distance associated with each monitor in this function.
%
% xd  5/25/16  wrote it

switch (calcParams.calcIDStr)
    case {'ConstantFullImage' 'ShuffledFullImage'}
        calcParams.calibrationFile = 'EyeTrackerLCDNew';
        calcParams.distance = 0.683;
    case {'StaticFullImageResizedOI2' 'NM1_FullImage' 'NM2_FullImage' ...
            'StaticFullImageResizedOI3' 'StaticFullImageResizedOI4'...
            'StaticFullImageResizedOI5' 'StaticFullImageResizedOI6'...
            'StaticFullImageResizedOI7' 'StaticFullImageResizedOI8'...
            'FullImageTest' 'StaticPhoton_newclass'}
        calcParams.calibrationFile = 'StereoLCDLeft';
        calcParams.distance = 0.764;
    otherwise
%         error('Unknown calcIDStr set');
        calcParams.calibrationFile = 'StereoLCDLeft';
        calcParams.distance = 0.764;
end
updatedParams = calcParams;

end


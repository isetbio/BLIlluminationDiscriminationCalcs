function updatedParams = assignCalibrationFile(calcParams)
% updatedParams = assignCalibrationFile(calcParams)
%
% Since different image sets may require different calibration files, we
% assign the calibration file to the calcParam struct. This will tell
% functions that require a calibration file to know which one to use. We
% also assign the distance associated with each monitor in this function.
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
<<<<<<< HEAD
        error('Unknown calcIDStr set');
=======
        %         error('Unknown calcIDStr set');
        if ~isempty(strfind(calcParams.calcIDStr,'Constant'))
            calcParams.calibrationFile = 'EyeTrackerLCDNew';
            calcParams.distance = 0.683;
        else
            calcParams.calibrationFile = 'StereoLCDLeft';
            calcParams.distance = 0.764;
        end
>>>>>>> 97ae84bd660df81fefddef0dca356519ec6f8176
end
updatedParams = calcParams;

end


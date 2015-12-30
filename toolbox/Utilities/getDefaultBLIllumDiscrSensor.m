function sensor = getDefaultBLIllumDiscrSensor
% sensor = getDefaultBLIllumDiscrSensor
% 
% This functions returns a default sensor used mainly for testing in
% the BLIlluminationDiscrimination Project
%
% 6/XX/15  xd  wrote it

% Create default human sensor
sensor = sensorCreate('human');

% Make it square
sensorRows = sensorGet(sensor, 'rows');
sensor = sensorSet(sensor, 'cols', sensorRows);

% 50 msec integration time
sensor = sensorSet(sensor, 'exp time', 0.050);

% Set the size to horizontal FOV of 0.83 degrees, with respect
% to human optics.
sensor = sensorSetSizeToFOV(sensor, 0.83, [], oiCreate('human'));

% Set wavelength sampling to match what we tend to use in this project
sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));

% Don't add noise to sensor responses
sensor = sensorSet(sensor, 'noise flag', 0);

end


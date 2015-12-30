function sensor = getDefaultBLIllumDiscrSensor
% sensor = getDefaultBLIllumDiscrSensor
% 
% This functions returns a default sensor used mainly for testing in
% the BLIlluminationDiscrimination Project
%
% 6/XX/15  xd  wrote it

sensor = sensorCreate('human');

sensorRows = sensorGet(sensor, 'rows');
sensor = sensorSet(sensor, 'cols', sensorRows);

sensor = sensorSet(sensor, 'exp time', 0.050);

sensor = sensorSetSizeToFOV(sensor, 0.83, [], oiCreate('human'));

sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));

sensor = sensorSet(sensor, 'noise flag', 0);

end


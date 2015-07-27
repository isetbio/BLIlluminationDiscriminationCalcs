function allPaths = getEMPaths(sensor, numPaths)
% allPaths = getEMPaths(sensor, numPaths)
% 
% This function will return numPaths eye movement paths associated with the
% input sensor.  These paths will be returned as a 3D matrix in allPaths.
% This function helps implement the second order model for the
% BLIlluminationDiscriminationCalcs
%
% 7/27/15  xd  wrote it

pathSize = size(sensorGet(sensor, 'positions'));
allPaths = zeros([pathSize numPaths]);

for ii = 1:numPaths
    sensor = emGenSequence(sensor);
    allPaths(:,:,ii) = sensorGet(sensor, 'positions');
end

end


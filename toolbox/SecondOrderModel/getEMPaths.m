function allPaths = getEMPaths(sensor, numPaths, varargin)
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

p = inputParser;
p.addParameter('bound', []);
p.parse(varargin{:});

bounded = ~isempty(p.Results.bound);
b = p.Results.bound;

for ii = 1:numPaths
    sensor = emGenSequence(sensor);
    pos = sensorGet(sensor, 'positions');
    if bounded
        while max(pos(:,1)) > b(1) || min(pos(:,1)) < b(2) || max(pos(:,2)) > b(3) || min(pos(:,2)) < b(4)
           sensor = emGenSequence(sensor);
            pos = sensorGet(sensor, 'positions');
        end        
    end
    allPaths(:,:,ii) = pos;
end

end


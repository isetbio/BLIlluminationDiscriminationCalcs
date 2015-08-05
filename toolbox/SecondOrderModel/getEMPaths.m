function allPaths = getEMPaths(sensor, numPaths, varargin)
% allPaths = getEMPaths(sensor, numPaths)
%
% This function will return numPaths eye movement paths associated with the
% input sensor.  These paths will be returned as a 3D matrix in allPaths.
% This function helps implement the second order model for the
% BLIlluminationDiscriminationCalcs
%
% 7/27/15  xd  wrote it
% 8/5/15   xd  added optional sPath parameter

p = inputParser;
p.addParameter('bound', []);
p.addParameter('saccades', []);
p.addParameter('sPath', []);

p.parse(varargin{:});

b = p.Results.bound;
s = p.Results.saccades;
sPath = p.Results.sPath;

pathSize = size(sensorGet(sensor, 'positions'));
allPaths = zeros([pathSize numPaths]);

for ii = 1:numPaths
    sensor = emGenSequence(sensor);
    pos = sensorGet(sensor, 'positions');
%     if ~isempty(b)
%         while max(pos(:,1)) > b(1) || min(pos(:,1)) < b(2) || max(pos(:,2)) > b(3) || min(pos(:,2)) < b(4)
%             sensor = emGenSequence(sensor);
%             pos = sensorGet(sensor, 'positions');
%         end
%     end
    
    if ~isempty(s) || ~isempty(sPath)
        if isempty(sPath)
            sPath = getSaccades(s.n, s.mu, s.sigma, b);
        end
        sExpand = zeros(pathSize);
        expansionFactor = pathSize(1)/s.n;
        for jj = 1:s.n
            sExpand((jj-1)*expansionFactor+1:expansionFactor*jj,:) = repmat(sPath(jj,:), expansionFactor, 1);
        end
        pos = pos + sExpand;
    end
    
    allPaths(:,:,ii) = pos;
    %     plot(allPaths(:,1,ii), allPaths(:,2,ii));
end
end
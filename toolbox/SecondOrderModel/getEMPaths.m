function allPaths = getEMPaths(sensor, numPaths, varargin)
% allPaths = getEMPaths(sensor, numPaths)
%
% This function will return numPaths eye movement paths associated with the
% input sensor.  These paths will be returned as a 3D matrix in allPaths.
% This function helps implement the second order model for the
% BLIlluminationDiscriminationCalcs
%
% 7/27/15  xd  wrote it

p = inputParser;
p.addParameter('bound', []);
p.addParameter('saccades', []);

p.parse(varargin{:});

b = p.Results.bound;
s = p.Results.saccades;

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
    
    if ~isempty(s)
        sPath = getSaccades(s.n, s.mu, s.sigma, b);
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

function path = getSaccades(n, mu, sigma, b)
% path = getSaccades(n, mu, sigma)
%
% This function generates saccadic eye movement by randomly sampling from
% a Gaussian with defined mu and sigma.

tolerance = 2.75;

% If b is not empty, boundaries have been defined and the path will be
% recreated until it fits inside the bounds.
loop = true;
while loop
    path = zeros(n,2);
    path(2:n,:) = sigma * randn(n - 1, 2);
    path = mu * sign(path) + path;
    for ii = 2:n
        while  acos(dot(path(ii-1,:), path(ii,:))/(norm(path(ii-1,:))*norm(path(ii,:)))) > tolerance
            path(ii,:) = sigma * randn(1,2);
            path(ii,:) = mu * sign(path(ii,:)) + path(ii,:);
        end
    end
    path = cumsum (path);
    if isempty(b)
        break;
    end
    loop = max(path(:,1)) > b(1) || min(path(:,1)) < b(2) || max(path(:,2)) > b(3) || min(path(:,2)) < b(4);
end
% plot(path(:,1), path(:,2))
end
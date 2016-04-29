function allPaths = getEMPaths(sensor, numPaths, varargin)
% allPaths = getEMPaths(sensor, numPaths)
%
% This function will return numPaths eye movement paths associated with the
% input sensor.  These paths will be returned as a 3D matrix in allPaths.
% This function helps implement the second order model for the
% BLIlluminationDiscriminationCalcs
%
% Inputs:
%    sensor  - The sensor with which to generate the eye movement paths.
%    numPaths - The total number of paths desired
%
%  {name-value pairs}
%    'bound'    - A boundary box for the paths.  If this is set, the paths
%                 will not exceed to boundary.  The format is [minX maxX
%                 minY maxY].
%
%    'saccades' - A struct containing information relevant for generating
%                 saccadic eye movement.  This will used along with the
%                 fixational eye movements if specified.
%       {fields}
%            n     - The total number of positions (there will be n-1 saccades)
%
%    'sPath'    - A pre-generated saccadic eye movement path.  This will
%                 used along with the fixational eye movements if specified.
%
%    'loc'      - A n-by-2 matrix containing n preselected locations as
%                 saccade targets. This is passed into the getSaccades
%                 function.
%
%    'fullPath' - A full path matrix with each (x,y) represented as a row
%                 entry. If this is set as an input, this function will
%                 only generate a set of fixation eye movements and add it
%                 to the fullPath variable.
%
% 7/27/15  xd  wrote it
% 8/5/15   xd  added optional sPath parameter
% 3/14/16  xd  mu and sigma removed as saccade parameters, may add a max
%              distance parameter later on, so left saccades as struct

%% Set up the input parser
p = inputParser;
p.addParameter('bound', []);
p.addParameter('saccades', []);
p.addParameter('sPath', []);
p.addParameter('loc', []);
p.addParameter('fullPath', []);

p.parse(varargin{:});

b = p.Results.bound;
s = p.Results.saccades;
sPath = p.Results.sPath;
loc = p.Results.loc;
fullPath = p.Results.fullPath;

%% Get path size and allocate room for the desired number of paths
pathSize = size(sensorGet(sensor, 'positions'));
allPaths = zeros([pathSize numPaths]);

% if b is not specified as a parameter, use the size of the sensor as the
% boundary
ss = sensorGet(sensor, 'size');
if isempty(b)
    b = [round(-ss(1)/2) round(ss(1)/2) round(-ss(2)/2) round(ss(2)/2)];
else
    b = [b(1) + 2*ss(1), b(2) - 2*ss(1), b(3) + 2*ss(2), b(4) - 2*ss(2)];
end

%% Calculate the paths based on the input parameters
for ii = 1:numPaths
    sensor = emGenSequence(sensor);
    pos = sensorGet(sensor, 'positions');
    
    % If there are large saccades, they will be used or implemented here.
    if s.n > 1
        if isempty(fullPath)
            if ~isempty(s) || ~isempty(sPath)
                if isempty(sPath)
                    sPath = getSaccades(s.n, b, 'loc', loc);
                end
                sExpand = zeros(pathSize);
                expansionFactor = pathSize(1)/length(sPath);
                for jj = 1:size(sPath,1)
                    sExpand((jj-1)*expansionFactor+1:expansionFactor*jj,:) = repmat(sPath(jj,:), expansionFactor, 1);
                end
                pos = pos + sExpand;
            end
        else
            pos = pos + fullPath;
        end
    end
    allPaths(:,:,ii) = pos;
    %     plot(allPaths(:,1,ii), allPaths(:,2,ii));
    
    sPath = []; % Reset this so that you actually get new paths
end

%% Adjust the final path
% Since we do not check the path locations after adding the fixational eye
% movements, it is possible that a few positions are actually out of the
% bounding area.  We fix this by simply setting any positions outside the
% bounding area equal to the extrema of the bounds.
for ii = 1:numPaths
    allPaths(allPaths(:,1,ii) > b(2),1,ii) = b(2);
    allPaths(allPaths(:,1,ii) < b(1),1,ii) = b(1);
    allPaths(allPaths(:,2,ii) > b(4),1,ii) = b(4);
    allPaths(allPaths(:,2,ii) < b(3),1,ii) = b(3);
end
end
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
%                 will not exceed to boundary.  The format is [minX maxX minY maxY]
%
%    'saccades' - A struct containing information relevant for generating
%                 saccadic eye movement.  This will used along with the 
%                 fixational eye movements if specified.
%       {fields}
%            n     - The total number of positions (there will be n-1 saccades)
%            mu    - The mean length of each saccade.
%            sigma - The standard deviation of the saccades.
%
%    'sPath'    - A pre-generated saccadic eye movement path.  This will
%                 used along with the fixational eye movements if specified.
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

p.parse(varargin{:});

b = p.Results.bound;
s = p.Results.saccades;
sPath = p.Results.sPath;

%% Get path size and allocate room for the desired number of paths
pathSize = size(sensorGet(sensor, 'positions'));
allPaths = zeros([pathSize numPaths]);

% if b is not specified as a parameter, use the size of the sensor as the
% boundary
if isempty(b)
    ss = sensorGet(sensor, 'size');
    b = [round(-ss(1)/2) round(ss(1)/2) round(-ss(2)/2) round(ss(2)/2)];
end

%% Calculate the paths based on the input parameters
for ii = 1:numPaths
    sensor = emGenSequence(sensor);
    pos = sensorGet(sensor, 'positions');
    
    % If there are large saccades, they will be used or implemented here.
    if ~isempty(s) || ~isempty(sPath)
        if isempty(sPath)
            sPath = getSaccades(s.n, b);
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
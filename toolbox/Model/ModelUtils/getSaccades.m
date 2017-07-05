function path = getSaccades(n,b,varargin)
% path = getSaccades(n,b,varargin)
%
% This function generates saccadic eye movement by randomly sampling from
% a Gaussian with defined mu and sigma.  The eye position always starts at
% x = 0, y = 0.
%
% Inputs:
%    n   - The number of saccade locations.
%    b   - The boundaries for the saccades. This is a length 4 vector in
%          the following format: [minX maxX minY maxY].
%    
%  {name-value pairs}
%    'loc'  - A set of predetermined locations. If this is provided, the
%             saccades will be randomly chosen from this set. This function
%             will check to ensure that each provided locations is within
%             bounds and error if not so. This is a n-by-2 matrix
%             representing n locations.
%
% Outputs:
%    path - path containing saccades
%
% 8/5/15   xd  moved from getEMPaths
% 3/14/16  xd  changed saccade locations to be chosen randomly instead of
%              based on current location
% 3/16/16  xd  Added option to generate saccades from existing list of
%              locations

%% InputParser for optional set of predefined locations
p = inputParser;
p.addParameter('loc', []);
p.parse(varargin{:});
loc = p.Results.loc;

%% Initialize path to zeros
path = zeros(n,2);

% Require that the boundary be specified
if isempty(b)
    warning('No boundary has been specified, all locations set to (0,0)');
    return
end

%% Use set locations if present
if ~isempty(loc)
    % Check that all preset locations are in bound
    minLoc = min(loc);
    maxLoc = max(loc);
    if (minLoc(1) < b(1) || maxLoc(1) > b(2) || minLoc(2) < b(3) || maxLoc(2) > b(4))
        error('Given set of locations contains an entry out of bounds.');
    end

    path = datasample(loc,n);
    return
end

%% Generate random locations
% If a boundary is defined, pick n random positions from inside the boundary
% Get x and y positions [minX maxX minY maxY]
xrand = (b(2) - b(1)) * rand(n,1) + b(1);
yrand = (b(4) - b(3)) * rand(n,1) + b(3);
path = [xrand yrand];

end
function path = getSaccades(n, b)
% path = getSaccades(n, mu, sigma)
%
% This function generates saccadic eye movement by randomly sampling from
% a Gaussian with defined mu and sigma.  The eye position always starts at
% x = 0, y = 0.
%
% 8/5/15  xd  moved from getEMPaths
% 3/14/16 xd  changed saccade locations to be chosen randomly instead of
%             based on current location


%% Initialize path to zeros
path = zeros(n,2);

% Require that the boundary be specified
if isempty(b)
    warning('No boundary has been specified, all locations set to (0,0)');
    return
end

%% Generate random locations
% If a boundary is defined, pick n random positions from inside the
% boundary
for ii = 1:n
    % Get x and y positions [minX maxX minY maxY]
    xrand = (b(2) - b(1)) * rand(1,1) + b(1);
    yrand = (b(4) - b(3)) * rand(1,1) + b(3);
    
    path(ii,:) = [xrand yrand];
end

end
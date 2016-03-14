function path = getSaccades(n, mu, sigma, b)
% path = getSaccades(n, mu, sigma)
%
% This function generates saccadic eye movement by randomly sampling from
% a Gaussian with defined mu and sigma.  The eye position always starts at
% x = 0, y = 0.
%
% 8/5/15  xd  moved from getEMPaths

%% Set the desired tolerance here
% (pi - tolerance) represents the minimum angle in radians between any two
% segments of the saccade path.
% tolerance = 2.75;

%% Generate the path
% If b is not empty, boundaries have been defined and the path will be
% recreated until it fits inside the bounds.
% loop = true;
% while loop 
%     % Calculate the position of the eye after the first saccade.
%     path = zeros(n,2);
%     path(2:n,:) = sigma * randn(n - 1, 2);
%     path = mu * sign(path) + path;
%     
%     % We fill in the rest of the positions, while making sure that the
%     % minimum angle tolerance is adhered to.
%     for ii = 2:n
%         while  acos(dot(path(ii-1,:), path(ii,:))/(norm(path(ii-1,:))*norm(path(ii,:)))) > tolerance
%             path(ii,:) = sigma * randn(1,2);
%             path(ii,:) = mu * sign(path(ii,:)) + path(ii,:);
%         end
%     end
%     path = cumsum(path);
%     
%     % If no boundary is defined, we are done.  Otherwise, check if the path
%     % is in bounds and repeat the process if it is not.
%     if isempty(b)
%         break;
%     end
%     loop = max(path(:,1)) < b(1) || min(path(:,1)) > b(2) || max(path(:,2)) < b(3) || min(path(:,2)) > b(4);
% end
% % plot(path(:,1), path(:,2))

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
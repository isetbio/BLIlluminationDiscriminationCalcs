function path = getSaccades(n, mu, sigma, b)
% path = getSaccades(n, mu, sigma)
%
% This function generates saccadic eye movement by randomly sampling from
% a Gaussian with defined mu and sigma.
%
% 8/5/15  xd  moved from getEMPaths

% (pi - tolerance) represents the minimum angle in radians between any two
% segments of the saccade path.
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
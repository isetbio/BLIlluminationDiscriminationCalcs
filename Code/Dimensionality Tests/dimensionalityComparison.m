clear all; close all;

%% Set rng seed for reproducibility
rng(1);

%% Set up some parameter variables for this comparison

% The number of dimensions
nDim = [10 100 1000 10000];

% Distance from unitVector -> this can be a vector as well
dist = 10;

% k values to test
k = [1 100 50000];

% number of trials to test
nTrials = 1000;

% boolean to determine whether or not to use uniform data
uniform = false;
uniformOrigin = false;
originVariation = 5;

%% Define function handles for desired test runs
normal = @(v,k) v + k * randn(size(v));
poissApprox = @(v,k) normrnd(v, k * sqrt(v));
poiss = @(v,k) v + k * (poissrnd(v) - v);

funcList = {normal, poissApprox, poiss};

%% Define different distance measures
euclid = @(X1, X2) norm(X1(:) - X2(:));
bDist = @(X1, X2) bhattacharyya(X1(:)', X2(:)');
manhattan = @(X1, X2) norm(X1(:) - X2(:), 1);
cosineAngle = @(X1, X2) 1 - dot(X1(:), X2(:)) / (norm(X1(:)) * norm(X2(:)));

distList = {euclid, bDist, manhattan, cosineAngle};
targetFunction = 4; % determines which function from above to use as distance parameter

%% Pre-allocate space for a results matrices
r = zeros(length(nDim), length(k), length(funcList));

%% Loop through desired parameters

for ii = 1:length(nDim)
    unitVector = repmat(1000, 1, nDim(ii));
    
    if ~uniformOrigin
        unitVector = unitVector + 2 * originVariation * (rand(size(unitVector)) - 0.5);
    end
    
    if uniform
        testVector = unitVector + dist;
    else
        rng(2);
        testVector = unitVector + 2 * dist * rand(size(unitVector));
        rng(1);
    end
    
    for ff = 1:length(funcList)
        tic
        for jj = 1:length(k)
            currK = k(jj);
            
            c = 0;
            
            % Allows for reproducibility regardless of param size
            seed = str2double([int2str(ii) int2str(ff) int2str(jj)]);
            rng(seed);
            
            for kk = 1:nTrials

                S = funcList{ff}(unitVector, currK);
                S2 = funcList{ff}(unitVector, currK);
                T = funcList{ff}(testVector, currK);
                
                distToS = distList{targetFunction}(S, S2);
                distToT = distList{targetFunction}(S, T);
                
                if distToS < distToT
                    c = c + 1;
                end
            end
            r(ii,jj,ff) = c / nTrials * 100;
        end
        toc
    end
end

rows = strtrim(sprintf('%d ', nDim));
cols = strtrim(sprintf('%d ', k));

% make this a loop and define a cell array for labels at top

printmat(r(:,:,1), 'Normal', rows, cols);
printmat(r(:,:,2), 'Poisson approx.', rows,cols);
printmat(r(:,:,3), 'Poisson', rows, cols);
% distanceBasedClassifierTutorial
%
% This walks through some classification techniques for deciding which
% of two classes a random draw from one of two distributions come from.
%
% This script models classification for a particular type of psychophysical
% experiment, in which the subject decides which of two comparison stimuli
% is closest to a reference stimulus. 
%
% In this tutorial, we explore the behavior of various distance based
% classifiers, as a function of dimensionality and noise properites.
%
% 6/XX/15  xd    Wrote it.
% 6/22/15  dhb   Added history and header comment. Renamed.
% 6/30/15  dhb   Minor.

%% Clear and close
clear; close all;

%% Set rng seed for reproducibility
rng(1);

%% Set up parameters that get looped over

% A vector of stimulus dimensions to test for.  Each of these
% will be done in turn.
dimensionalities = [10 100 1000 10000];

% Noise expansion factors to test. Each of these will be done in turn.
% 
% These k's are expressed in units of noise so that k == 1 correponds to
% having the mean lenght of a noise draw about the same as the vector
% length between the mean comparison and test vectors.
noiseFactorKs = [1 10 100 1000 10000 100000];

% Define function handles to specify noise type. Each of these
% will be done in turn.
% 
% These are a little awkward because we need both c and t to get the
% normal constant variance to have about the right variance, but only c for the other two.
% Look at how these are called below to see the slightly bizarre usage that comes up.
normal = @(c,t,k) normrnd(c, k*sqrt(mean([c t])));
poissApprox = @(c,t,k) normrnd(c, k * sqrt(c));
poiss = @(c,t,k) c + k * (poissrnd(c) - c);

noiseFuncList = {normal, poissApprox, poiss};
noiseFuncNames = {'Normal', 'PoissonApprox' 'Poisson'};

%% Set up fixed parameters

% Length of test vector, and distance from comparionVectorMean to testVectorMean.
% This distance is defined relative to the unit length of the comparison vector
comparisonVectorLength = 1000;
testDistanceFraction = 0.05;
testDistance = testDistanceFraction*comparisonVectorLength;

% Number of trials to simulate to obtain percent correct, and
% number of times to repead.  Repeating allows us to get mean
% and standard error, so that we can decide about reliability.
nSimulatedTrials = 1000;
nSimulations = 10;

% The direction of the test vector relative to the comparison vector.  Set
% this to 1 for positive extension along the comparison vector, 2 for a
% negative, 3 for an orthogonal direction.
testVectorDirection = 3;
testDirectionName = {'Pos' 'Neg' 'Orth'};

%% Define different distance measures and pick which one to use here.
euclid = @(X1, X2) norm(X1(:) - X2(:));
bDist = @(X1, X2) bhattacharyya(X1(:)', X2(:)');
cityBlock = @(X1, X2) norm(X1(:) - X2(:), 1);
cosineAngle = @(X1, X2) 1 - dot(X1(:), X2(:)) / (norm(X1(:)) * norm(X2(:)));
dotP = @(X1, X2) dot(X1(:), X2(:));

distMeasureList = {euclid, bDist, cityBlock, cosineAngle, dotP};
distMeasureNames = {'Euclidean', 'bhattDistance' 'City Block' 'Cosine Angle' 'Dot Product'};
whichDistanceMeasure = 1;

%% Pre-allocate space for results matrix.  This gives simulated percent 
% correct for each parameter explored.
percentCorrectRawMatrix = zeros(length(dimensionalities), length(noiseFactorKs), length(noiseFuncList), nSimulations);
ttestMatrix = zeros(length(dimensionalities), length(noiseFactorKs), length(noiseFuncList));

%% Loop through desired parameters
%
% Dimensionality is outer loop
for ii = 1:length(dimensionalities)
    theDimensionality = dimensionalities(ii);
    fprintf('Running dimension %d, %d of %d dimensions\n',theDimensionality,ii,length(dimensionalities));
    
    % Set up comparison vector mean.  This is a row vector on the unit
    % circle, living in a space of the specified dimensionality.
    % We obtain it by taking a uniform random vector of desired
    % dimensinality and then normalizing to unit length.
    comparisonVectorMean = rand(1, theDimensionality);
    comparisonVectorMean = comparisonVectorLength*comparisonVectorMean/norm(comparisonVectorMean);
 
    % Set up the test vector perturbation in accoradance to the direction
    % decision desired.
    switch(testVectorDirection)
        % Increase along comparison direction.
        case 1
            testVectorPerturbation = testDistance*comparisonVectorMean/norm(comparisonVectorMean);
        % Decrease along comparison direction.
        case 2
            testVectorPerturbation = -testDistance*comparisonVectorMean/norm(comparisonVectorMean);
        % Step in a direction orthogonal to the comparison.
        case 3
            orthogonalMatrix = null(comparisonVectorMean);
            orthogonalVector = orthogonalMatrix(:,1)';
            testVectorPerturbation = testDistance*orthogonalVector/norm(orthogonalVector);
            clear orthogonalMatrix;
    end
            
    % Set up test vector mean.  We choose a random perturbation direction in the vector
    % space and normalize it to have length testDistance.  Then we add it
    % to the comparison vector mean.
    testVectorMean = comparisonVectorMean + testVectorPerturbation;
    
    % To keep things intuitive, we want the scale of the noise for k == 1 to be
    % roughly commensurate with the vector distance between the comparison
    % and test.  The easiest way to do this is to generate a bunch of noise
    % vectors for the Poisson case, find out how long they are, and scale
    % relative to that.
    %
    % We make it so that k = 1 corresponds roughly to a mean noise vector length 
    % of testDistance.
    comparisonPoissonNoise = zeros(nSimulatedTrials,theDimensionality);
    testPoissonNoise = zeros(nSimulatedTrials,theDimensionality);
    comparisonPoissonNoiseLengths = zeros(nSimulatedTrials,1);
    testPoissonNoiseLengths = zeros(nSimulatedTrials,1);
    for zz = 1:nSimulatedTrials
        comparisonPoissonNoise(zz,:) = poiss(comparisonVectorMean,testVectorMean,1);
        comparisonPoissonNoiseLengths(zz) = norm(comparisonPoissonNoise(zz,:));
        testPoissonNoise(zz,:) = poiss(testVectorMean,comparisonVectorMean,1);
        testPoissonNoiseLengths(zz) = norm(testPoissonNoise(zz,:));
    end
    meanComparisonNoiseLength = mean(comparisonPoissonNoiseLengths);
    meanTestNoiseLength = mean(testPoissonNoiseLengths);
    meanNoiseLength = (meanComparisonNoiseLength + meanTestNoiseLength)/2;
    noiseLengthInTestDistance = meanNoiseLength/testDistance;
    adjustedNoiseFactorKs = noiseFactorKs/noiseLengthInTestDistance;
    
    % Loop over noise size
    for jj = 1:length(noiseFactorKs)
        % Get noise factor.  This scales the "natural" magnitude of
        % the noise, as defined by the noise functions.
        theAdjustedNoiseK = adjustedNoiseFactorKs(jj);
        fprintf('\tRunning noise factor %d, adjusted to %g\n',noiseFactorKs(jj),theAdjustedNoiseK);
        
        % Loop over type of noise
        for ff = 1:length(noiseFuncList)
            fprintf('\t\tRunning noise function %s\n',noiseFuncNames{ff});
                 
            % Simulate trials and count up number of trials correcct
            for ll = 1:nSimulations
                numberCorrect = 0;
                for kk = 1:nSimulatedTrials
                    % Get noisy draws from comparison, comparison, and
                    % test. Passing the other vector in the second argument
                    % allows us to properly control the variance for the
                    % normal constant variance case.
                    S = noiseFuncList{ff}(comparisonVectorMean, testVectorMean, theAdjustedNoiseK);
                    S2 = noiseFuncList{ff}(comparisonVectorMean, testVectorMean, theAdjustedNoiseK);
                    T = noiseFuncList{ff}(testVectorMean, comparisonVectorMean, theAdjustedNoiseK);
                    
                    % Compute distance between two comparison draws, and
                    % between comparison and test.
                    distToS = distMeasureList{whichDistanceMeasure}(S, S2);
                    distToT = distMeasureList{whichDistanceMeasure}(S, T);
                    
                    % It's correct if the distance to comparison is less than
                    % distance to test.
                    if distToS < distToT
                        numberCorrect = numberCorrect + 1;
                    end
                end
                
                % Store percent correct
                percentCorrectRawMatrix(ii,jj,ff,ll) = numberCorrect / nSimulatedTrials * 100;
            end
            
            % Compute t-test from 50%
            theValues = squeeze(percentCorrectRawMatrix(ii,jj,ff,:));
            [~,ttestMatrix(ii,jj,ff)] = ttest(theValues,50);
        end
    end
end

% Get mean results matrix
percentCorrectMeanMatrix = mean(percentCorrectRawMatrix,4);
percentCorrectStderrMatrix = std(percentCorrectRawMatrix,[],4)/sqrt(nSimulations);

% Show results
fprintf('\n*****************************\n');
fprintf('Percent correct for metric %s\n',distMeasureNames{whichDistanceMeasure});
rows = strtrim(sprintf('%d ', dimensionalities));
cols = strtrim(sprintf('%d ', noiseFactorKs));
for ff = 1:length(noiseFuncList)
    printmat(percentCorrectMeanMatrix(:,:,ff), noiseFuncNames{ff}, rows, cols);
end

fprintf('\n*****************************\n');
fprintf('t-test re 50%% for metric %s\n',distMeasureNames{whichDistanceMeasure});
rows = strtrim(sprintf('%d ', dimensionalities));
cols = strtrim(sprintf('%d ', noiseFactorKs));
for ff = 1:length(noiseFuncList)
    printmat(ttestMatrix(:,:,ff), noiseFuncNames{ff}, rows, cols);
end

%% Plot and save the results

directoryName = [distMeasureNames{whichDistanceMeasure} '_' ...
    testDirectionName{testVectorDirection} '_testDist' num2str(testDistanceFraction) ...
    '_' mat2str(dimensionalities)];
mkdir(directoryName);

% Load and set some common parameters
figParams = getDimensionalityTutorialFigParams;
figParams.percentXLim = [min(noiseFactorKs)/10 10*max(noiseFactorKs)];
figParams.pvalueXLim = figParams.percentXLim;
figParams.percentYLim = [0 100];
figParams.pvalueYLim = [0 1];
figParams.figDir = directoryName;

figure;
set(gcf, 'position', [0 0 1500 1500]);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
for ii = 1:length(dimensionalities)
    for jj = 1:length(noiseFuncList)
        subplot(length(dimensionalities),length(noiseFuncList),jj + (ii - 1)*length(noiseFuncList));
        h = errorbar(noiseFactorKs,percentCorrectMeanMatrix(ii,:,jj), 2*percentCorrectStderrMatrix(ii,:,jj), 'b.-', 'markersize', figParams.markerSize);
        set(get(h,'Parent'),'XScale','log')
        hold on
        plot(xlim, [50 50], 'k--');
                
        title([noiseFuncNames{jj} ' ' int2str(dimensionalities(ii))],'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        xlabel('k','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel('% correct','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        xlim(figParams.percentXLim);
        ylim(figParams.percentYLim);
    end
end
suptitle(['Mean percent correct for ' distMeasureNames{whichDistanceMeasure} ' ' testDirectionName{testVectorDirection}]);
savefig(fullfile(directoryName, 'PercentCorrect'));
FigureSave(fullfile(directoryName, 'PercentCorrect'), gcf, 'tiff');

figure;
set(gcf, 'position', [0 0 1500 1500]);
for ii = 1:length(dimensionalities)
    for jj = 1:length(noiseFuncList)
        subplot(length(dimensionalities),length(noiseFuncList),jj + (ii - 1)*length(noiseFuncList));
        h = plot(noiseFactorKs,ttestMatrix(ii,:,jj), 'r.', 'markersize', figParams.markerSize);
        set(get(h,'Parent'),'XScale','log')
        hold on
        plot(xlim, [0.05 0.05], 'k--');
        
        title([noiseFuncNames{jj} ' ' int2str(dimensionalities(ii))],'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        xlabel('k','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel('p value','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        xlim(figParams.pvalueXLim);
        ylim(figParams.pvalueYLim);
    end
end
suptitle(['p values for ' distMeasureNames{whichDistanceMeasure} ' ' testDirectionName{testVectorDirection}]);
savefig(fullfile(directoryName, 'pvalues'));
FigureSave(fullfile(directoryName, 'pvalues'), gcf, 'tiff');

% Save all the data in case we need it later.
save(fullfile(directoryName, 'data'));

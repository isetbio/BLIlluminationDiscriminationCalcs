% dimensionalityLinearClassifiers
%
% This is analogous to distanceBasedClassfierTutorial.m.  However, here we
% will be using a SVM to explore the behavior of classification as a
% function of dimensionality and noise factor.
%
% 6/XX/15  xd wrote it
% 6/24/15  xd added header and organized like distanceBasedClassfierTutorial.m

%% Clear
clear; close all;

%% Set rng seed for reproducibility
rng(1);

%% Set up parameters that get looped over

% A vector of stimulus dimensions to test for.  Each of these
% will be done in turn.
dimensionalities = [10 100];

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

%% Set fixed parameters

% The training size will define how many vectors to use to train the SVM.
% A larger training size should in theory lead to more accurate
% classification.  However, the running time will also be increased in
% accordance.  This value should be an even number due to how the code is
% set up.
trainingSetSize = 2500;

% Length of test vector, and distance from comparionVectorMean to testVectorMean.
% This distance is defined relative to the unit length of
% the comparison vector
comparisonVectorLength = 1000;
testDistanceFraction = 0.05;
testDistance = testDistanceFraction*comparisonVectorLength;

% Number of trials to simulate to obtain percent correct, and number of 
% times to repead.  Repeating allows us to get mean and standard error, 
% so that we can decide about reliability.  nSimulatedTrials represents 
% the size of the test set.  The test set will be split 50% to both
% classes.
nSimulatedTrials = 1000;
nSimulations = 10;

% The direction of the test vector relative to the comparison vector.  Set
% this to 1 for positive extension along the comparison vector, 2 for a
% negative, 3 for an orthogonal direction.
testVectorDirection = 2;
testDirectionName = {'Pos' 'Neg' 'Orth'};

%% Define the parameters to use to train the SVM
%
% This is set up as a function list so that alternate machine learning
% algorithms can be added at ease without drastically altering the code.
SVM = @(d,c) fitcsvm(d,c);

linearClassifierList = {SVM};
linearClassifierNames = {'MatlabSVM'};
whichClassifier = 1;

% Define the appropriate functions that will use the classifier to predict
% the test classes.
SVMPred = @(s,d) predict(s,d);

predictionFunctionList = {SVMPred};
whichPredictionFunction = 1;

%% Pre-allocate space for results matrix.  This gives simulated percent
% correct for each parameter explored.
percentCorrectRawMatrix = zeros(length(dimensionalities), length(noiseFactorKs), length(noiseFuncList), nSimulations);
ttestMatrix = zeros(length(dimensionalities), length(noiseFactorKs), length(noiseFuncList));


%% Loop through parameters

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
        case 1
%             testVectorPerturbation = rand(1, theDimensionality);
            testVectorPerturbation = testDistance*comparisonVectorMean/norm(comparisonVectorMean);
        case 2
%             testVectorPerturbation = rand(1, theDimensionality);
            testVectorPerturbation = -testDistance*comparisonVectorMean/norm(comparisonVectorMean);
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
        comparisonPoissonNoiseLengths(zz) = norm(comparisonPoissonNoise(ii,:));
        testPoissonNoise(zz,:) = poiss(testVectorMean,comparisonVectorMean,1);
        testPoissonNoiseLengths(zz) = norm(testPoissonNoise(zz,:));
    end
    meanComparisonNoiseLength = mean(comparisonPoissonNoiseLengths);
    meanTestNoiseLength = mean(testPoissonNoiseLengths);
    meanNoiseLength = (meanComparisonNoiseLength + meanTestNoiseLength)/2;
    noiseLengthInTestDistance = meanNoiseLength/testDistance;
    adjustedNoiseFactorKs = noiseFactorKs/noiseLengthInTestDistance;
    
    % Train the SVM's on the set of noise functions.  Each noise function
    % will have its own SVM.  The data will comprise of exactly 50% of
    % comparison vector and 50% of test vector.  For this tutorial, the
    % comparison vectors will be labeled class 0, and the test vectors will
    % be labeled class 1.  The SVM will be trained with the adjusted k
    % value for k = 1.
    trainedSVMList = cell(1,length(noiseFuncList));
    for ff = 1:length(noiseFuncList)
        data = zeros(trainingSetSize, theDimensionality);
        class = ones(trainingSetSize, 1);
        class(1:trainingSetSize/2, 1) = 0;
        for tt = 1:trainingSetSize/2
            data(tt,:) = noiseFuncList{ff}(comparisonVectorMean, testVectorMean, adjustedNoiseFactorKs(1));
            data(trainingSetSize/2 + tt,:) = noiseFuncList{ff}(testVectorMean, comparisonVectorMean, adjustedNoiseFactorKs(1));
        end
        trainedSVMList{ff} = linearClassifierList{whichClassifier}(data, class);
    end
    
    % Loop over the noise vector
    for jj = 1:length(noiseFactorKs)
        % Get noise factor.  This scales the "natural" magnitude of
        % the noise, as defined by the noise functions.
        theAdjustedNoiseK = adjustedNoiseFactorKs(jj);
        fprintf('\tRunning noise factor %d, adjusted to %g\n',noiseFactorKs(jj),theAdjustedNoiseK); 
        
        % Loop over type of noise
        for ff = 1:length(noiseFuncList)
            fprintf('\t\tRunning noise function %s\n',noiseFuncNames{ff});

            testClasses = ones(nSimulatedTrials, 1);
            testClasses(1:nSimulatedTrials/2, 1) = 0;
            % Simulate trials
            for ll = 1:nSimulations
                testData = zeros(nSimulatedTrials, theDimensionality);
                % Fill the test data matrix
                for kk = 1:nSimulatedTrials/2
                    testData(kk,:) = noiseFuncList{ff}(comparisonVectorMean, testVectorMean, theAdjustedNoiseK);
                    testData(nSimulatedTrials/2 + kk,:) = noiseFuncList{ff}(testVectorMean, comparisonVectorMean, theAdjustedNoiseK);
                end
                
                % The amount of correct classifications will be how many
                % entries in classifiedData are the same as the
                % corresponding entries in testClasses.
                classifiedData = predictionFunctionList{whichPredictionFunction}(trainedSVMList{ff}, testData);
                numberCorrect = sum(classifiedData == testClasses);
                
                % Store percent correct
                percentCorrectRawMatrix(ii,jj,ff,ll) = numberCorrect / nSimulatedTrials * 100;
            end
            
            % Compute t-test from 50%
            theValues = squeeze(percentCorrectRawMatrix(ii,jj,ff,:));
            [~,ttestMatrix(ii,jj,ff)] = ttest(theValues,50);
        end
    end
    clear trainedSVMList;
end

% Get mean results matrix
percentCorrectMeanMatrix = mean(percentCorrectRawMatrix,4);
percentCorrectStderrMatrix = std(percentCorrectRawMatrix,[],4)/sqrt(nSimulations);

% Show results
fprintf('\n*****************************\n');
fprintf('Percent correct for SVM\n');
rows = strtrim(sprintf('%d ', dimensionalities));
cols = strtrim(sprintf('%d ', noiseFactorKs));
for ff = 1:length(noiseFuncList)
    printmat(percentCorrectMeanMatrix(:,:,ff), noiseFuncNames{ff}, rows, cols);
end

fprintf('\n*****************************\n');
fprintf('t-test re 50%% for SVM\n');
rows = strtrim(sprintf('%d ', dimensionalities));
cols = strtrim(sprintf('%d ', noiseFactorKs));
for ff = 1:length(noiseFuncList)
    printmat(ttestMatrix(:,:,ff), noiseFuncNames{ff}, rows, cols);
end

%% Plot and save the results

directoryName = [linearClassifierNames{whichClassifier} '_' testDirectionName{testVectorDirection}...
    '_testDist' num2str(testDistanceFraction) '_' mat2str(dimensionalities) '_' ...
    num2str(trainingSetSize)];
mkdir(directoryName);

figure;
set(gcf, 'position', [0 0 1500 1500]);
for ii = 1:length(dimensionalities)
    for jj = 1:length(noiseFuncList)
        subplot(length(dimensionalities),length(noiseFuncList),jj + (ii - 1)*length(noiseFuncList));
        h = errorbar(noiseFactorKs,percentCorrectMeanMatrix(ii,:,jj), 2*percentCorrectStderrMatrix(ii,:,jj), 'b.-', 'markersize', 20);
        set(get(h,'Parent'),'XScale','log')
        hold on
        plot(xlim, [50 50], 'k--');
                
        title([noiseFuncNames{jj} ' ' int2str(dimensionalities(ii))]);
        xlabel('k');
        ylabel('% correct');
        xlim([min(noiseFactorKs)/10 10*max(noiseFactorKs)]);
        ylim([0 100]);
    end
end
suptitle('Mean percent correct for SVM');
savefig(fullfile(directoryName, 'PercentCorrect'));
% FigureSave(fullfile(directoryName, 'PercentCorrect'), gcf, 'pdf');

figure;
set(gcf, 'position', [0 0 1500 1500]);
for ii = 1:length(dimensionalities)
    for jj = 1:length(noiseFuncList)
        subplot(length(dimensionalities),length(noiseFuncList),jj + (ii - 1)*3);
        h = plot(noiseFactorKs,ttestMatrix(ii,:,jj), 'r.', 'markersize', 20);
        set(get(h,'Parent'),'XScale','log')
        
        hold on
        plot(xlim, [0.05 0.05], 'k--');
        title([noiseFuncNames{jj} ' ' int2str(dimensionalities(ii))]);
        xlabel('k');
        ylabel('p value');
        xlim([min(noiseFactorKs)/10 10*max(noiseFactorKs)]);
        ylim([0 1]);
    end
end
suptitle('p values for SVM');
savefig(fullfile(directoryName, 'pvalues'));
% FigureSave(fullfile(directoryName, 'pvalues'), gcf, 'pdf');

save(fullfile(directoryName, 'data'));
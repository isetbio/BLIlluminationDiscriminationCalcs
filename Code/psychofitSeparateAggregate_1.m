function psychofitSeparateAggregate_1
% psychofitSeparateAggregate_1
%
% Compare what happens if we take the same psychometric data and pass it
% the fitting routine with all trials listed separately or with those at
% the same level aggregated together.  This shouldn't make any difference,
% and it does not.
%
% 3/22/15  dhb  Wrote it.

%% Clear
clear; close all; clear classes;

%% Specify parameters
PAL_WeibParams = [0.07 1.15 0.5 0];
noiseSd = 0.06;
criterionCorrect = 0.709;
testStimulus = 100;
nComparisonFit = 100;
nComparison = 10;
nTrialsPerComparison = 20;
comparisonLevels = linspace(testStimulus,testStimulus+6*noiseSd,nComparison);
comparisonStimuliFit = linspace(testStimulus,testStimulus+6*noiseSd,nComparisonFit);

%% Set up PAL parameters for fitting these should work for al the fits below
PF = @PAL_Weibull;                  
PFI = @PAL_inverseWeibull;
paramsFree = [1 1 0 0];             % 1: free parameter, 0: fixed parameter
paramsValues0 = [mean(comparisonLevels'-testStimulus) 1/2 0.5 0];
options = optimset('fminsearch');   % Type help optimset
options.TolFun = 1e-09;             % Increase required precision on LL
options.Display = 'off';            % Suppress fminsearch messages
lapseLimits = [0 1];                % Limit range for lambda

%% Get true psychometric function
probCorrFitPalTrue = PF(PAL_WeibParams,comparisonStimuliFit'-testStimulus);

%% Simulate out the individual trials
for i = 1:nComparison
    for j = 1:nTrialsPerComparison
        theComparisonStimuli(i,j) = comparisonLevels(i);
        nCorrect(i,j) = SimulateTAFC(testStimulus,comparisonLevels(i),PAL_WeibParams,1); 
    end
end

%% Break out trials in a long list
theComparisonStimuliSeparate = theComparisonStimuli(:);
nCorrectSeparate = nCorrect(:);
nTrialsSeparate = ones(size(nCorrectSeparate));

% Aggregate the same trials
theComparisonStimuliAggregate = theComparisonStimuli(:,1);
nCorrectAggregate = sum(nCorrect,2);
nTrialsAggregate = nTrialsPerComparison*ones(size(theComparisonStimuliAggregate));

%% Fit data with each trial listed separately
[paramsValuesSeparate] = PAL_PFML_Fit(...
    theComparisonStimuliSeparate(:)-testStimulus,nCorrectSeparate(:),nTrialsSeparate(:), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probCorrFitPalSeparate = PF(paramsValuesSeparate,comparisonStimuliFit'-testStimulus);
threshPalSeparate = PFI(paramsValuesSeparate,criterionCorrect);

%% Fit aggregated data
[paramsValuesAggregate] = PAL_PFML_Fit(...
    theComparisonStimuliAggregate(:)-testStimulus,nCorrectAggregate(:),nTrialsAggregate(:), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probCorrFitPalAggregate = PF(paramsValuesAggregate,comparisonStimuliFit'-testStimulus);
threshPalAggregate = PFI(paramsValuesAggregate,criterionCorrect);

%% Plot of TAFC simulation.  When the red and green overlap (which they do in all my tests), it
% means that psignfit and Palamedes agree.
figure; clf; hold on
plot(theComparisonStimuliAggregate-testStimulus,nCorrectAggregate./nTrialsAggregate,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot(comparisonStimuliFit-testStimulus,probCorrFitPalTrue,'k','LineWidth',2);
plot(comparisonStimuliFit-testStimulus,probCorrFitPalSeparate,'r','LineWidth',5);
plot([threshPalSeparate threshPalSeparate],[0 criterionCorrect],'r','LineWidth',5);
plot(comparisonStimuliFit-testStimulus,probCorrFitPalAggregate,'g','LineWidth',3);
plot([threshPalAggregate threshPalAggregate],[0 criterionCorrect],'g','LineWidth',3);
xlabel('Delta Stimulus','FontSize',16);
ylabel('Prob Correct','FontSize',16);
title(sprintf('TAFC psychometric function'),'FontSize',16);
xlim([comparisonLevels(1)-testStimulus comparisonLevels(end)-testStimulus])
ylim([0 1]);

%% Printout thresholds
fprintf('TAFC simulated data\n');
fprintf('Threshold separated trials: %g\n',threshPalSeparate);
fprintf('Threshold aggregated trials: %g\n',threshPalAggregate);
fprintf('\n');

end


%% Subfunctions for simulating observer

function nCorrect = SimulateTAFC(testLevel,comparisonLevel,params,nSimulate)
% probYes = SimulateTAFC(testLevel,comparisonLevel,params,nSimulate)
%
% Simulate out the number of times that a TAFC task is done correctly, with judgment greater
% corresponding to greater noisy response. 

pCorrect = PAL_Weibull(params,comparisonLevel-testLevel);
nCorrect = 0;
for i = 1:nSimulate
    nCorrect = nCorrect + binornd(1,pCorrect);
end
end

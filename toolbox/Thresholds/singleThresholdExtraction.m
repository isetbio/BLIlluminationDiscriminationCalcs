function [threshold,paramsValues] = singleThresholdExtraction(data,criterion,stimLevels,numTrials)
% [threshold,paramsValues] = singleThresholdExtraction(data,criterion,stimLevels,numTrials)
% 
% This function fits a cumulative Weibull to the data variable and returns
% the threshold at the criterion as well as the parameters needed to plot the
% fitted curve. It is assumed that the data vector contains percentage
% performance and is ordered in increasing stimulus value (or however you'd
% like the data to be fit). This function requires the data vector to have
% at least 6 points. If the data cannot be fit, the threshold returned will
% be NaN and the paramsValues will a zero row vector. It is also assumed
% that the criterion is given as a percentage.
%
% 6/21/16  xd  wrote it

if notDefined('stimLevels'), stimLevels = 1:length(data); end;
if notDefined('numTrials'), numTrials = 100; end;

%% Check to make sure data is fittable
%
% We check the average value of the first 5 and last 5 numbers to get an
% idea of if the data is fittable to a curve. If the first 5 values are
% less than criterion and the last 5 are greater than criterion+10, we proceed with the
% fitting.  Otherwise, we return NaN for the threshold, which indicates that
% the data cannot be fit.
% if mean(data(1:5)) > criterion+10 || mean(data(end-4:end)) < criterion, threshold = nan; paramsValues = zeros(1,4); return; end; 

%% Set some parameters for the curve fitting
%
% Our input criterion is a percentage which needs to converted to a decimal
% value. The paramsEstimate is just a rough estimate of the results and
% shouldn't affect the outcome too much. 
criterion      = criterion/100;
paramsEstimate = [10 5 0.5 0.05];
paramsFree     = [1 1 0 (mean(data(end-4:end)) > 99.5)]; % Need to remove lapse rate if data does not reach 100%
if length(numTrials) == 1
    outOfNum = repmat(numTrials,1,length(data));
else
    outOfNum = numTrials;
end
PF             = @PAL_Weibull;
lapseLimits    = [0 0.5];

%% Some optimization settings for the fit
%
% Some parameters for the fit. These are set so that the functions make a
% solid attempt at fitting before deciding that it is not possible.
options = PAL_minimize('options');

%% Fit the data to a curve
paramsValues = PAL_PFML_Fit(stimLevels(:), data(:), outOfNum(:), ...
    paramsEstimate, paramsFree, PF, 'SearchOptions', options,...
    'lapseLimits',lapseLimits);

threshold = PF(paramsValues, criterion, 'inverse');
end


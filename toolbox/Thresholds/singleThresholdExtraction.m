function [threshold,paramsValues,stimLevels] = singleThresholdExtraction(data,varargin)
% [threshold,paramsValues] = singleThresholdExtraction(data,varargin)
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
% 6/19/17  xd  editted to match experimental set up

p = inputParser;
defaultIlluminantPath = '/Users/xiaomaoding/Documents/stereoChromaticDiscriminationExperiment/IlluminantsInDeltaE.mat';

p.addRequired('data',@isnumeric);
p.addOptional('criterion',70.71,@isnumeric);
p.addOptional('stimLevels',1:length(data),@isnumeric);
p.addOptional('numTrials',100,@isnumeric);
p.addOptional('useTrueIlluminants',false,@islogical);
p.addOptional('color','blue',@isstr);
p.addOptional('illumPath',defaultIlluminantPath,@ischar);

p.parse(data,varargin{:});

%% Set some parameters for the curve fitting
%
% Our input criterion is a percentage which needs to converted to a decimal
% value. The paramsEstimate is just a rough estimate of the results and
% shouldn't affect the outcome too much.
criterion      = p.Results.criterion/100;
stimLevels     = p.Results.stimLevels;
numTrials      = p.Results.numTrials;
data           = p.Results.data(:) * numTrials / 100;

% Need to remove lapse rate if data does not reach 100%. Palamedes gives
% unreasonable results otherwise.
paramsEstimate = [10 5 0.5 0.05];
paramsFree     = [1 1 0 (mean(data(end-4:end)) > 90)]; 
outOfNum       = repmat(numTrials,length(stimLevels),1);
PF             = @PAL_Weibull;
lapseLimits    = [0 0.5];
options        = PAL_minimize('options');
disp(num2str(mean(data(end-4:end))))

% %% Expand data into individual trials
% % Because we know the exact testing set size for each stimulus value, we
% % can expand it into individual trials using the percent correct
% % performance data. This can then be binned in a similar manner to what the
% % experimental analysis code does.
% 
% trialStim = [];
% trialData = [];
% for ii = 1:length(data)
%     trialStim = [trialStim(:); repmat(stimLevels(ii),numTrials,1)];
%     
%     numTrueResponses = ceil(numTrials * data(ii) / 100);
%     trialData = [trialData(:); ones(numTrueResponses,1); zeros(numTrials-numTrueResponses,1)];
% end
% 
% shuffleIdx = randperm(length(trialStim));
% trialStim = trialStim(shuffleIdx);
% trialData = trialData(shuffleIdx);

%% Map onto true illuminant values if needed
if p.Results.useTrueIlluminants
    % Load illuminants
    illums = load(p.Results.illumPath);
    
    % Create lookup table
    % Illuminants =  (1) 'blue' (2) 'green'  (3) 'red' (4) 'yellow'
    % Based on experimental analysis code. See AnalyzeStaircaseViaFitToTrailsExp8.m
    switch p.Results.color
        case 'blue'
            colorIdx = 1;
        case 'green'
            colorIdx = 2;
        case 'red'
            colorIdx = 3;
        case 'yellow'
            colorIdx = 4;
        otherwise
            colorIdx = nan;
    end
    illuminantLookUpTable = [(0:length(stimLevels))',  illums.illuminantDistance{colorIdx}(:,2)];    

    mapIndices = arrayfun(@(X) find(illuminantLookUpTable(:,1) == X), stimLevels);
    stimLevels = illuminantLookUpTable(mapIndices,2);
end

% %% Bin the thresholds 
% nTrialsPerBin = 10;
% [stimLevels,data,outOfNum] = GetAggregatedStairTrials(trialStim, trialData, nTrialsPerBin);

%% Fit the data to a curve
if paramsFree(4)
    paramsValues = PAL_PFML_Fit(stimLevels(:), data(:), outOfNum(:), ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options,...
        'lapseLimits',lapseLimits);
else
    paramsValues = PAL_PFML_Fit(stimLevels(:), data(:), outOfNum(:), ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options);
end

threshold = PF(paramsValues,criterion,'inverse');

end


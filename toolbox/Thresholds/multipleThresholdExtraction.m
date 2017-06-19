function [thresholds,paramsValues] = multipleThresholdExtraction(data,varargin)
% [thresholds,paramsValues] = multipleThresholdExtraction(data,varargin)
%
% Given a NxM data matrix containing M sets of data with N datapoints in
% each, this function will return a length M vector of thresholds and a Mx4
% matrix of parameters that fit the data to a cumulative Weibull. If the
% data vector cannot be fit, then the threshold at that index will be -1,
% and the data paramsValues will be a zero vector. The thresholds will be
% extracted at the given criterion, which should be a percentage.
%
% 6/21/16  xd  wrote it

p = inputParser;
defaultIlluminantPath = '/Users/xiaomaoding/Documents/stereoChromaticDiscriminationExperiment/IlluminantsInDeltaE.mat';

p.addRequired('data',@isnumeric);
p.addOptional('criterion',70.71,@isnumeric);
p.addOptional('stimLevels',1:length(data),@isnumeric);
p.addOptional('numTrials',100,@isnumeric);
p.addOptional('useTrueIlluminants',false,@islogical);
p.addOptional('color','blue',@isstr);
p.addOptional('illumPath',defaultIlluminantPath,@isstr);

p.parse(data,varargin{:});

%% Preallocate space for the data
thresholds = zeros(size(data,2),1);
paramsValues = zeros(size(data,2),4);

%% Get thresholds
for ii = 1:size(data,2)
    [thresholds(ii),paramsValues(ii,:)] = singleThresholdExtraction(p.Results.data(:,ii),p.Results.criterion,...
                                                                    p.Results.stimLevels,p.Results.numTrials,...
                                                                    p.Results.useTrueIlluminants,...
                                                                    p.Results.color,p.Results.illumPath);
end

end


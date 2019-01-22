function [thresholds,paramsValues,stimLevels] = multipleThresholdExtraction(data,varargin)
% [thresholds,paramsValues,stimLevels] = multipleThresholdExtraction(data,varargin)
%
% Given a NxM data matrix containing M sets of data with N datapoints in
% each, this function will return a length M vector of thresholds and a Mx4
% matrix of parameters that fit the data to a cumulative Weibull. If the
% data vector cannot be fit, then the threshold at that index will be -1,
% and the data paramsValues will be a zero vector. The thresholds will be
% extracted at the given criterion, which should be a percentage.
%
% Inputs:
%     data  -  model threshold data
% {ordered optional}
%     criterion           -  what percent correct to extract threshold (default = 70.71)
%     stimLevels          -  vector of all stimulus steps (default = 1:length(data))
%     numTrials           - number of trials per step (default = 100)
%     useTrueIlluminants  -  use true or nominal illumination steps (default = true)
%     color               -  string that specifies with illumination direction color (default = 'blue')
%     illumPath           -  path to where true illuminant values are stored
%
% Outputs:
%     threshold    -  thresholds determined from fitting a Weibull to the data
%     paramValues  -  a matrix of parameters for the fit given by Palamedes
%     stimLevels   -  the stimulus steps used for the fits
%
% 6/21/16  xd  wrote it
% 6/19/17  xd  update to use true delta E vals

p = inputParser;
defaultIlluminantPath = 'G:\Dropbox (Aguirre-Brainard Lab)\xColorShare\Xiaomao\IlluminantsInDeltaE.mat';

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
    [thresholds(ii),...
     paramsValues(ii,:),...
     stimLevels] = singleThresholdExtraction(p.Results.data(:,ii),p.Results.criterion,...
                                             p.Results.stimLevels,p.Results.numTrials,...
                                             p.Results.useTrueIlluminants,...
                                             p.Results.color,p.Results.illumPath);
end

end


function [bestPatchNumber,minThresh] = findBestPerformancePatch(calcIDStr,varargin)
% [bestPatchNumber,minThresh] = findBestPerformancePatch(calcIDStr,varargin)
% 
% Finds the patch that provides the best (minimum) thresholds for each
% noise level and color combination. Only returns results for combinations
% that do not have NaN threshold for any patch.
%
% Inputs:
%     calcIDStr  -  shared label for a set of calculations
% {ordered optional}
%     N - will return the 1-N best thresholds (default = 1)
%
% Outputs:
%     bestPatchNumber  -  list of numbers corresponding to the N best patches
%     minThresh  -  thresholds corresponding to the 'bestPatchNumber'
% 
% 7/20/16  xd  wrote it

p = inputParser;
p.addOptional('N',1,@isnumeric);
p.parse(varargin{:});
N = p.Results.N;

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);

% Initialize data values to something not realistic
dummyData = loadThresholdData(calcIDStrList{1},['Thresholds' calcIDStrList{1} '.mat']);
theAlmightMatrixOfThresholds = zeros([size(dummyData) length(calcIDStrList)]);

% Construct matrix of all thresholds
for ii = 1:length(calcIDStrList)
    theAlmightMatrixOfThresholds(:,:,ii) = loadThresholdData(calcIDStrList{ii},['Thresholds' calcIDStrList{ii} '.mat']);
end

% Loop over each combination, sort and put into results
bestPatchNumber = zeros([size(dummyData) N]);
minThresh = zeros([size(dummyData) N]);
for ii = 1:size(theAlmightMatrixOfThresholds,1)
    for jj = 1:size(theAlmightMatrixOfThresholds,2)
        theCurrentThresholds = squeeze(theAlmightMatrixOfThresholds(ii,jj,:));
        % If NaN exists, set values to NaN
        if any(isnan(theCurrentThresholds))
            bestPatchNumber(ii,jj,:) = NaN;
            minThresh(ii,jj,:) = NaN;
        else 
            % Otherwise, we can sort and get values
            [sortedThresh,idx] = sort(theCurrentThresholds);
            bestPatchNumber(ii,jj,:) = idx(1:N);
            minThresh(ii,jj,:) = sortedThresh(1:N);
        end
    end
end

end


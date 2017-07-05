function threshold = averageNRandomThresholds(calcIDStr,N)
% threshold = averageNRandomThresholds(calcIDStr,N)
% 
% Returns the average thresholds from N patches for a given calcIDStr set.
%
% Inputs:
%     calcIDStr  -  shared label for the set of calculations
%     N  -  number of patches to average over
% 
% Outputs:
%     threshold  -  mean threshold over N random patches
%
% 7/21/16  xd  wrote it

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
calcIDStrList = datasample(calcIDStrList,N);

% Initialize data values to zeros
dummyData = loadThresholdData(calcIDStrList{1},['Thresholds' calcIDStrList{1} '.mat']);
threshold = zeros(size(dummyData));

% Construct matrix of all thresholds
for ii = 1:length(calcIDStrList)
    theCurrentThresholds = loadThresholdData(calcIDStrList{ii},['Thresholds' calcIDStrList{ii} '.mat']);
    threshold = threshold + theCurrentThresholds;
end
threshold = threshold/N;

end


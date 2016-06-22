function [modelData, calcParams] = loadModelData(calcIDStr)
% modelData = loadModelData(calcIDStr)
% 
% 
%
% xd 6/22/16  wrote it


%% TEMPORARY CODE, CONVERT OLD STORAGE FORMAT TO NEW
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');

modelDataTemp = cell(4,1);
colors = {'blue' 'green' 'red' 'yellow'};
for ii = 1:4
    theData = load(fullfile(analysisDir,'SimpleChooserData',calcIDStr,[colors{ii} 'IllumComparison' calcIDStr '.mat']));
    modelDataTemp{ii} = theData.matrix;
end
s = size(modelDataTemp{1});
modelData = zeros([4,s]);
for ii = 1:4
    modelData(ii,:,:) = modelDataTemp{ii};
end

calcParams = load(fullfile(analysisDir,'SimpleChooserData',calcIDStr,['calcParams' calcIDStr '.mat']),'calcParams');
calcParams.colors = colors;
calcParams.stimLevels = 1:50;
calcParams.plotColor = {'b' 'g' 'r' 'y'};
calcParams.noiseLevels = (1:10)';

end


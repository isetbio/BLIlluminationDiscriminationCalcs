function plotMeanThresholds(calcIDStr)
% plotMeanThresholds(calcIDStr)
% 
% Plots the mean thresholds against noise for an input calcIDStr, which is
% the shared label. It loads the set of calculations that have filenames in
% the format calcIDStr_1, calcIDStr_2, ...
%
% The noiseLevels to plot against need to be specified as currently there is
% no single calcParams struct to read in.
%
% Inputs:
%     calcIDStr  -  shared label for a set of calculations
% 
% 7/18/16  xd  wrote it

%% Load and calculate mean thresholds
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
[~,calcParams] = loadModelData(calcIDList{1});
noiseLevels = calcParams.KgLevels;
t = meanThresholdOverSamples(calcIDList,70.9);

%% Plot
p = createPlotInfoStruct;
p.xlabel = 'Noise Level (Gaussian)';
p.ylabel = 'Stimulus Level';
p.title = ['Thresholds v Noise, ' calcIDStr];

plotThresholdsAgainstNoise(p,t,noiseLevels(:));

end


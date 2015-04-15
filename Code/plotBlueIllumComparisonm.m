% plotBlueIllumComparison
%
% Quick plot of results from blue illumination calculatons.
%
% 4/15/15  dhb, xd  Pulled this together

%% Clear
clear; close all;

%% Load
theFile = 'blueIllumComparison';
theData = load(theFile);
kValues = (1:10)';
nKValues = length(kValues);
nStimValues = size(theData.matrix,1);
stimValues = (1:nStimValues)';

%% Figure parameters
figParams.lineWidth = 2;
figParams.markerSize = 6;
figParams.fontName = 'Helvetica';
figParams.axisFontSize = 18;
figParams.labelFontSize = 20;
figParams.titleFontSize = 20;

%% Make a basic plot
theColors = ['r' 'g' 'b' 'k' 'c'];
colorIndex = 1;
figure; clf; hold on
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
for k = 1:nKValues
    if (colorIndex > length(theColors))
        colorIndex = 1;
    end
    theColor = theColors(colorIndex);
    colorIndex = colorIndex+1;
    
    plot(stimValues,theData.matrix(:,k),theColor,'LineWidth',figParams.lineWidth);
    plot(stimValues,theData.matrix(:,k),[theColor 'o'],'MarkerFaceColor',theColor,'MarkerSize',figParams.markerSize);
end
xlabel('Stimulus Difference (nominal)','FontSize',figParams.labelFontSize);
ylabel('Percent Correct','FontSize',figParams.labelFontSize);
title('Computational Observer Performance, Blue Illum','FontSize',figParams.titleFontSize);


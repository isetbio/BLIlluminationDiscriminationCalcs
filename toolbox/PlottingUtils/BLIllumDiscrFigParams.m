function figParams = BLIllumDiscrFigParams(figParams, modifier)
% figParams = BLIllumDiscrFigParams(figParams, modifier)
% 
% Sets figure parameters for this project. Adapted from example code
% by David Brainard.
%
% xd  6/20/16  wrote it

figParams.basicSize = 700;
figParams.position = [100 100 figParams.basicSize round(420/560*figParams.basicSize)];
figParams.sqPosition = [100 100 round(7/7*figParams.basicSize) round(7/7*figParams.basicSize)];
figParams.fontName = 'Helvetica';
figParams.markerSize = 22;
figParams.axisLineWidth = 2;
figParams.lineWidth = 2;
figParams.axisFontSize = 22;
figParams.labelFontSize = 24;
figParams.legendFontSize = 18;
figParams.titleFontSize = 26;
figParams.figType = {'pdf'};

figParams.deltaXlabelPosition = [0 -0.25 0];
figParams.deltaYlabelPosition = [-0.05 0 0];

switch (modifier)
    case {'sThreshold'}
        figParams.fitLineWidth = 4;
        figParams.defaultFitLineColor = [0.7 0.7 0.7];
        figParams.dataMarkerSize = 40;
        figParams.dataMarker = 'k.';
        figParams.defaultCriterionColor = [0.3 0.3 0.3];
        figParams.criterionLineWidth = 2;
        figParams.criterionLineStyle = '--';
        figParams.ylimit = [0 100];
    case {'ThresholdvNoise'}
        figParams.markerSize = 30;
        figParams.colors = {[0.1 0.1 0.1] [0.3 0.3 0.3] [0.5 0.5 0.5] [0.7 0.7 0.7]};
        figParams.lineStyle = '--';
        figParams.lineWidth = 2;
    case {'Asymptote'}
        figParams.lineStyles = {'-' '--' '-.'};
        figParams.colors = {[0.2 0.2 0.4] [0.2 0.4 0.4] [0.4 0.4 0.4]};
    case {'FitThresholdToData'}
        figParams.ylimit = [0 50];
        figParams.markerSize = 40;
        figParams.colors = {[0.1 0.1 0.1] [0.3 0.3 0.3] [0.5 0.5 0.5] [0.7 0.7 0.7]}; 
        figParams.markerType = 's';

end


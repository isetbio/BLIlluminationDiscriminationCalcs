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
        figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255}; 
        figParams.lineStyle = '--';
        figParams.lineWidth = 2;
    case {'Asymptote'}
        figParams.lineStyles = {'-' '--' '-.'};
        figParams.colors = {[0.2 0.2 0.4] [0.2 0.4 0.4] [0.4 0.4 0.4]};
    case {'FitThresholdToData'}
        figParams.ylimit = [0 25];
        figParams.xlimit = [0 5];
        figParams.markerSize = 30;
        figParams.modelMarkerType = 'o';
        figParams.modelMarkerColor = 'k';
        figParams.modelMarkerSize = 20;
        figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255}; 
        figParams.markerType = 's';
        figParams.XTickLabel = {'' 'Blue' 'Green' 'Red' 'Yellow' ''};
    case {'SVMvPCA'}
        figParams.xlimit = [0 11];
        figParams.ylimit = [50 100];
        figParams.insetPosition = [0.74 0.15 0.15 0.15];
        figParams.colors = {[0 0.4470 0.7410] [0.8500 0.3250 0.0980] [0.9290 0.6940 0.1250]};
        figParams.insetAxisLineWidth = 1;
        figParams.insetAxisFontSize = 10;
        figParams.insetTitleFontSize = 12;
end
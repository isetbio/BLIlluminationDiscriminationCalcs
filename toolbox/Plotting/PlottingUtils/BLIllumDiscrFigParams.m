function figParams = BLIllumDiscrFigParams(varargin)
% figParams = BLIllumDiscrFigParams(figParams,modifier)
% 
% Sets figure parameters for this project. Adapted from example code
% by David Brainard.
%
% Inputs:
%     figParams  -  struct containing any existing information for figure
%                   formatting. can be empty.
%     modifier   -  string determining a specific type of plot which may
%                   add or modify existing parameters
%
% Output:
%     figParams  -  struct containing figure formatting parameters tailored
%                   for the desired plot
%
% 6/20/16  xd  wrote it

%% Parse inputs
p = inputParser;
p.addOptional('figParams',[],@(X) isstruct(X) || isempty(X));
p.addOptional('modifier','',@ischar);
p.parse(varargin{:});

figParams = p.Results.figParams;
modifier  = p.Results.modifier;

%% Set params
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
figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255}; 

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
        figParams.markerSize = 15;
        figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255}; 
        figParams.lineStyle = '--';
        figParams.lineWidth = 3;
    case {'Asymptote'}
        figParams.lineStyles = {'-' '--' '-.'};
        figParams.colors = {[0.2 0.2 0.4] [0.2 0.4 0.4] [0.4 0.4 0.4]};
    case {'FitThresholdToData'}
        figParams.ylimit = [0 50];
        figParams.xlimit = [0 5];
        figParams.markerSize = 25;
        figParams.modelMarkerType = 'o';
        figParams.modelMarkerColor = 'k';
        figParams.modelMarkerSize = 20;
        figParams.colors = {[0 191 255]/255 [255 215 0]/255 [46 139 87]/255 [178,34,34]/255}; 
        figParams.markerType = 'o';
        figParams.XTickLabel = {'' 'Blue' 'Yellow' 'Green' 'Red' ''};
        figParams.XTick = 0:5;
        figParams.axisFontSize = 18;
    case {'SVMvPCA'}
        figParams.sqPosition = [100 100 1000 1000];
        figParams.xlimit = [0 50];
        figParams.ylimit = [45 100];
        figParams.insetPositions = {[0.208571428571429 0.790348101265821 0.0528571428571429 0.126898734177215]...
                                    [0.650000000000000 0.790348101265821 0.0528571428571429 0.126898734177215]...
                                    [0.208571428571429 0.316455696202528 0.0528571428571429 0.126898734177215]...
                                    [0.650000000000000 0.316455696202528 0.0528571428571429 0.126898734177215]};
        figParams.insetAxisLineWidth = 2;
        figParams.insetAxisFontSize = 10;
        figParams.insetTitleFontSize = 12;
        figParams.insetYLimit = [-9 0];
        figParams.insetXLimit = [0 500];
        figParams.insetTickLength = [0 0];
        figParams.insetDeltaXLabelPos = [0 0.2 0];
        figParams.s = 0.65;
        figParams.v = 1;
        figParams.alpha = 0.75;
    case {'ThresholdHistogram'}
        figParams.binNum = 20;
        figParams.faceColors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255}; 
        figParams.subplotsize = 600;
        figParams.xlim = [0 50];
    case {'AllPatches'}
        figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255};
        figParams.YTick = [0 35];
        figParams.XTick = [];
        figParams.superTitleFontSize = 32;
    case {'browse'}
        figParams.colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255};
end
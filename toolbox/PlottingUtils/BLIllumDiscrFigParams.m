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
figParams.lineWidth = 4;
figParams.axisFontSize = 22;
figParams.labelFontSize = 24;
figParams.legendFontSize = 18;
figParams.titleFontSize = 10;
figParams.figType = {'pdf'};

figParams.OuterPosition = [0.05 0.05 0.95 0.95];


end


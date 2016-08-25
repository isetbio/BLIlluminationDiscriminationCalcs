function plotInfo = createPlotInfoStruct
% plotInfo = createPlotInfoStruct
% 
% This function generates a default plotInfo struct which is passed around
% and used to plot various data in this project.
%
% xd  6/21/16  wrote it

plotInfo.fitColor = [];
plotInfo.stimLevels = 1:50;
plotInfo.colors = [];

plotInfo.xlabel = 'Stimulus Levels';
plotInfo.ylabel = 'Percent Correct';
plotInfo.title = 'Weibull Fit to Data';
plotInfo.criterion = 70.9;

end


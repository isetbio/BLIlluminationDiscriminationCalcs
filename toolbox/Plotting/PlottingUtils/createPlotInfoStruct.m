function plotInfo = createPlotInfoStruct
% plotInfo = createPlotInfoStruct
% 
% This function generates a default plotInfo struct which is passed around
% and used to plot various data in this project.
%
% Outputs:
%     plotInfo  -  a struct containing some basic information like text for
%                  the labels and title etc.
% 
% 6/21/16  xd  wrote it

plotInfo.fitColor = [];
plotInfo.stimLevels = 1:50;
plotInfo.colors = [];

plotInfo.xlabel = 'Stimulus Levels';
plotInfo.ylabel = 'Percent Correct';
plotInfo.title  = 'Weibull Fit to Data';
plotInfo.criterion = 70.71;

end


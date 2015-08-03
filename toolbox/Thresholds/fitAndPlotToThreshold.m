function fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams, varargin)
% fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams, varargin)
%
% This function plots the thresholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
%
% Inputs:
%   usableData  - The start index at which the data is usable for fitting
%   threshold   - The threshold data to plot
%   color       - The color to plot the data
%   kInterval   - The interval between noise samples
%   kValsFine   - The total range to plot the fit over.  This should be
%                 subdivided into many small intervals (finely) to create
%                 a line
%   figParams   - Parameters to format the plot
% 
% {Optional}
%   error       - A vector the size of threshold containing the standard
%                 error of the data.  This will cause this function to plot
%                 error bars.
%
% 7/10/15  xd  Moved to separate function from plotAllThresholds.m

%% Create an input parser to decide whether or not to plot errorbars
p = inputParser;
p.addOptional('error', []);

parse(p, varargin{:});

%% Define x-axis value range
numOfData = size(threshold);
dataStart = min(kValsFine(:)) + (usableData - 1) * kInterval;
dataEnd = dataStart + (numOfData(1) - 1) * kInterval;
kVals = dataStart:kInterval:dataEnd;

%% Plot threshold points
if isempty(p.Results.error)
    plot(kVals, threshold, strcat(color,'.'), 'markersize', figParams.markerSize);
else
    errorbar(kVals, threshold, error, strcat(color, '.'), 'markersize', figParams.markerSize);
end
%% Fit to line and get set of y values

% This will start the fit as a linear line.  Then increase the target fit
% and try again if the mean error is greater than the tolerance.
errorTolerance = .5;
delta = 1;
polynomialToFit = 1;
s = warning('error','MATLAB:polyval:ZeroDOF');
while mean(delta) > errorTolerance && polynomialToFit < 2
    try
        [p, S] = polyfit(kVals, threshold', polynomialToFit);
        [y, delta] = polyval(p, kValsFine,S);
        polynomialToFit = polynomialToFit + 1;
    catch
        [p, S] = polyfit(kVals, threshold', polynomialToFit - 1);
        y = polyval(p, kValsFine,S);
        break;
    end
end
warning(s);

hold on;
plot (kValsFine, y, color, 'linewidth', figParams.lineWidth);
end
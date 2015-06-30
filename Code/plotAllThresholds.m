function plotAllThresholds(calcParams, psychoData, figParams, varargin)
% plotAllThresholds(calcParams, psychoData, figParams, kType, kValue)
%
% This function will plot all the threshold fits.  The specified kType and
% kValue are fixed and the opposing kType will be used as the x-axis.  For
% example, the default values of 'Kg' and 0 will result in a plot of all
% the Kp thresholds for which Kg == 0.

%% Parse inputs 
p = inputParser;

defaultK = 'Kg';
defaultKValue = 0;

p.addRequired('calcParams', @isstruct);
p.addRequired('psychoData', @isstruct);
p.addRequired('figParams', @isstruct);

p.addOptional('kType', defaultK, @isstr);
p.addOptional('kValue', defaultKValue, @isnumeric);

parse(p, calcParams, psychoData, figParams, varargin{:});

%% Plot according to kType
switch p.Results.kType
    case {'Kp'}
        % Find index of desired Kp
        startKp = calcParams.startKp;
        KpIndex = (p.Results.kValue - startKp) / calcParams.KpInterval + 1;
        
        % Reorganize data into Kg format.  First Usable Kg is the first
        % index of the UsableData vector in which the entry is less than
        % KpIndex
        usable.blue = find(psychoData.uBlueTotal < KpIndex, 1);
        usable.red = find(psychoData.uRedTotal < KpIndex, 1);
        usable.green = find(psychoData.uGreenTotal < KpIndex, 1);
        usable.yellow = find(psychoData.uYellowTotal < KpIndex, 1);
        
        % Create the threshold vectors based on 
        
    case {'Kg'}
        % Find index for desired Kg
        startKg = calcParams.startKg;
        KgIndex = (p.Results.kValue - startKg) / calcParams.KgInterval + 1;
        
        % Calculate Kp Values
        KpInterval = calcParams.KpInterval;
        startKp = calcParams.startKp;
        maxKp = startKp + (calcParams.numKpSamples - 1) * KpInterval;
        KpValsFine = startKp:(maxKp-1)/1000:maxKp;
        
        % Plot all Kp for desired Kg
        figure;
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        fitAndPlotToThreshold(psychoData.uBlueTotal(KgIndex), psychoData.thresholdBlueTotal{KgIndex}, 'b', KpInterval, KpValsFine, figParams);
        fitAndPlotToThreshold(psychoData.uRedTotal(KgIndex), psychoData.thresholdRedTotal{KgIndex}, 'r', KpInterval, KpValsFine, figParams);
        fitAndPlotToThreshold(psychoData.uGreenTotal(KgIndex), psychoData.thresholdGreenTotal{KgIndex}, 'g', KpInterval, KpValsFine, figParams);
        fitAndPlotToThreshold(psychoData.uYellowTotal(KgIndex), psychoData.thresholdYellowTotal{KgIndex}, 'y', KpInterval, KpValsFine, figParams);
        
        title(['Threshold against k-values for ' calcParams.calcIDStr], 'interpreter', 'none');
        xlabel('k-values');
        ylabel('Threshold');
        ylim([0 50]);
        xlim([0 maxKp]);
    otherwise
            error('kType was not specified as Kg or Kp');
end

end

function fitAndPlotToThreshold (usableData, threshold, color, KpInterval, KpValsFine, figParams)
% fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams)
%
% This function plots the thresholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
%
% Inputs:
%   usableData  - The start index at which the data is usable for fitting
%   threshold   - The threshold data to plot
%   color       - The color to plot the data
%   KpInterval  - The interval between k-Poisson samples
%   KpValsFine  - The total range to plot the fit over.  This should be
%                 subdivided into many small intervals (finely) to create
%                 a line
%   figParams   - Parameters to format the plot

%% Define x-axis value range
numOfData = size(threshold);
dataStart = min(KpValsFine(:)) + (usableData - 1) * KpInterval;
dataEnd = dataStart + (numOfData(1) - 1) * KpInterval;
kVals = dataStart:KpInterval:dataEnd;

%% Plot threshold points
plot(kVals, threshold, strcat(color,'.'), 'markersize', figParams.markerSize);

%% Fit to line and get set of y values

% This will start the fit as a linear line.  Then increase the target fit
% and try again if the mean error is greater than the tolerance.
errorTolerance = .5;
delta = 1;
polynomialToFit = 1;
s = warning('error','MATLAB:polyval:ZeroDOF');
while mean(delta) > errorTolerance && polynomialToFit < 4
    try
        [p, S] = polyfit(kVals, threshold', polynomialToFit);
        [y, delta] = polyval(p, KpValsFine,S);
        polynomialToFit = polynomialToFit + 1;
    catch
        [p, S] = polyfit(kVals, threshold', polynomialToFit - 1);
        y = polyval(p, KpValsFine,S);
        break;
    end
end
warning(s);

hold on;
plot (KpValsFine, y, color, 'linewidth', figParams.lineWidth);
end


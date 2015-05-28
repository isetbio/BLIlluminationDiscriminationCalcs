function thresholdCalculation(displayIndividualThreshold)
%thresholdCalculation(displayIndividualThreshold)
% This function uses the Weibull as a psychometric function to
% fit the data calculated from the simple image discrimination chooser
% model.  
%
% Inputs:
%   displayIndividualThreshold - Set to true if individual fitted curves
%                                are to be displayed.  Only the final threshold 
%                                graph will be shown if set to false.
%
% 4/20/2015   xd  wrote it
% 4/22/2015   xd  finished running chooser model on all 4 illum colors
% 4/24/2015   xd  cleaned up the function for readability
%
% NOTE: Need to have a k-value vector in case the sample interval is not 1

    %% clear
    clc; clear global; close all;

    %% Load the data for each illumination matrix    
    blueMatrix  = loadChooserData('blueIllumComparisonPhoton');
    greenMatrix = loadChooserData('greenIllumComparisonPhoton');
    redMatrix = loadChooserData('redIllumComparisonPhoton');
    yellowMatrix = loadChooserData('yellowIllumComparison');
    
    %% Get number of k-values, should be the same for all four matrices
    sizeOfData = size(blueMatrix);
    
    %% Load default figure parameters
    figParams = getFigureParameters;
    
    %% Set estimations param for calculations
    %
    % NOTE : Should this be an input paramter???
    % Use same estimated parameters for all data sets
    paramsValueEst = [10 1 0.5 0];
    
    %% Calculate Thresholds
    % For each illumantion color, we find a vector of thresholds at which
    % the success rate is 0.709
    [thresholdBlue, ~] = fitToData(blueMatrix, paramsValueEst, 'b', displayIndividualThreshold);
    [thresholdRed, ~] = fitToData(redMatrix, paramsValueEst, 'r',displayIndividualThreshold);
    [thresholdGreen, ~] = fitToData(greenMatrix, paramsValueEst, 'g',displayIndividualThreshold);
    [thresholdYellow, ~] = fitToData(yellowMatrix, paramsValueEst, 'y',displayIndividualThreshold);
    
    %% Plot Thresholds
    % Plot each threshold vector against its representative k-value of
    % noise.  Also fit a line to it.
    totalRange = 1:1:sizeOfData(2);
    kValsFine = min(totalRange):(max(totalRange)-min(totalRange))/1000:max(totalRange);
    
    figure;
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    fitAndPlotToThreshold(thresholdBlue, 'b', kValsFine, figParams);
    fitAndPlotToThreshold(thresholdRed, 'r', kValsFine, figParams);
    fitAndPlotToThreshold(thresholdGreen, 'g', kValsFine, figParams);
    fitAndPlotToThreshold(thresholdYellow, 'y', kValsFine, figParams);
    
    title('Threshold against k-values');
    xlabel('k-values');
    ylabel('Threshold');
end

%[threshold, paramsValues] = fitToData (data, paramsEstimate, color, toPlot)   
% This function will fit input data to a Weibull curve.  The choice of
% psychometric function can be changed manually here.  Set "toPlot" to
% false to disable plotting of the fitted curves
%
% Inputs:
%   data           - The data with which to fit a Weibull curve.
%   paramsEstimate - The initial estimates for the fitting function.
%   color          - The color to use to plot the fit.
%   toPlot         - Boolean flag to decide whether or not to plot all the
%                    individual fitted curves
%
% Outputs:
%   threshold    - A vector of thresholds coresponding to the k-values of
%                  the data input
%   paramsValues - The updated params of the curve returned by the fitting funtion
function [threshold, paramsValues] = fitToData (data, paramsEstimate, color, toPlot)    
    %% Set common parameters
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    sizeOfData = size(data);
    StimLevels = 1:1:sizeOfData(1);
    % THIS 100 is number of trials, need to pass this in somehow
    OutofNum   = repmat(100, 1, sizeOfData(1));    
    usableDataRange = sizeOfData(2);
    
    %% Pre-allocate room for return values
    threshold = zeros(usableDataRange,1);
    paramsValues = zeros(usableDataRange, 4);
    
    %% Define functions to fit to
    PF = @PAL_Weibull;
    PFI = @PAL_inverseWeibull;
    
    %% Some optimization settings for the fit
    options = optimset('fminsearch');   
    options.TolFun = 1e-09;             
    options.MaxFunEvals = 10000 * 100;
    options.MaxIter = 500*100;
    
    %% Settings for plotting fits
    if (toPlot)
        figure;
        set(gcf,'Position',[0 0 1000 1000]); 
        set(gca,'FontName','Helvetica','FontSize',12);
    end
    
    %% Calculate thresholds and fits
    for i = 1:usableDataRange
        % Load the current column of data, each column is a different k-value
        NumPos = data(:, i)';
        
        % Fit the data to a curve
        [paramsValues(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options);
    
        % Get threshold value for current level of noise
        threshold(i) = PFI(paramsValues(i,:), criterion);
        
        % Plot fitted curves
        if (toPlot)
            subplot(usableDataRange/2,2,i);
            PropCorrectData = NumPos./OutofNum;
            StimLevelsFine  = min(StimLevels):(max(StimLevels)-...
                min(StimLevels))/1000:max(StimLevels);
            Fit = PF(paramsValues(i,:), StimLevelsFine);
            plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
            set(gca, 'fontsize', 12);
            hold on;
            plot(StimLevelsFine, Fit, color, 'linewidth', 4);
            plot([threshold(i) threshold(i)], [0, criterion], color, 'linewidth', 3);

            title(strcat('K-Value : ',int2str(i)));
            xlabel('Stimulus Difference (nominal)');
            ylabel('Percent Correct');
            ylim([0 1.0]);
        end
    end
end

%fitAndPlotToThreshold (threshold, color, kValsFine, figParams)
% This function plots the thresholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
%
% Inputs:
%   threshold - The threshold data to plot
%   color     - The color to plot the data
%   kValsFine - The total range to plot the fit over.  This should be
%               subdivided into many small intervals (finely) to create
%               a line
%   figParams - Parameters to format the plot
% NOTE: Is kValsFine still needed if usable data now encompassed the entire
%       range? Only if data sets have different k-value ranges
function fitAndPlotToThreshold (threshold, color, kValsFine, figParams)
    %% Define x-axis value range
    % Need k value interval
    kVals = 1:1:size(threshold);
    
    %% Plot threshold points
    plot(kVals, threshold, strcat(color,'.'), 'markersize', figParams.markerSize);
    
    %% Fit to line and get set of y values
    % Want to change to something that's not a linear fit
    p = polyfit(kVals, threshold', 3);
    y = polyval(p, kValsFine);
    
    hold on;
    plot (kValsFine, y, color, 'linewidth', figParams.lineWidth);
end

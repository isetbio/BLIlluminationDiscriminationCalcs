function thresholdCalculation(calcIDStr,displayIndividualThreshold)
% thresholdCalculation(calcIDStr,displayIndividualThreshold) 
%
% This function passes the pre-calculated simple chooser model data to
% fitToData to generate a fitted Weibull curve.  These curves are then
% plotted together on one figure.
%
% Inputs:
%   calcIDStr                  - Identifier for this calculation set.  This
%                                is the name of the folder in which the data is
%                                stored.
%   displayIndividualThreshold - Set to true if individual fitted curves
%                                are to be displayed.  Only the final threshold 
%                                graph will be shown if set to false.
%
% 4/20/2015   xd  wrote it
% 4/22/2015   xd  finished running chooser model on all 4 illum colors
% 4/24/2015   xd  cleaned up the function for readability
% 5/28/2015   xd  usableData range decision is now automated

    %% clear
    clc; clear global; close all;

    %% Load the data for each illumination matrix    
    blueMatrix  = loadChooserData(calcIDStr,'blueIllumComparison');
    greenMatrix = loadChooserData(calcIDStr,'greenIllumComparison');
    redMatrix = loadChooserData(calcIDStr,'redIllumComparison');
    yellowMatrix = loadChooserData(calcIDStr,'yellowIllumComparison');
    
    %% Load the calcParams used for this set of data
    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    dataFilePath = fullfile(dataBaseDir, 'SimpleChooserData', calcIDStr, 'calcParams');
    p = load(dataFilePath);
    calcParams = p.calcParams;
        
    %% Load default figure parameters
    figParams = getFigureParameters;
    
    %% Set estimation parameter for calculations

    % Use same estimated parameters for all data sets
    paramsValueEst = [10 1 0.5 0];
    
    %% Calculate Thresholds
    % For each illumantion color, we find a vector of thresholds at which
    % the success rate is 0.709
    numTrials = calcParams.numTrials;
    [thresholdBlue, ~, uBlue] = fitToData(blueMatrix, paramsValueEst, numTrials, 'b', displayIndividualThreshold);
    [thresholdRed, ~, uRed] = fitToData(redMatrix, paramsValueEst, numTrials, 'r', displayIndividualThreshold);
    [thresholdGreen, ~, uGreen] = fitToData(greenMatrix, paramsValueEst, numTrials, 'g', displayIndividualThreshold);
    [thresholdYellow, ~, uYellow] = fitToData(yellowMatrix, paramsValueEst, numTrials, 'y', displayIndividualThreshold);
    
    %% Plot Thresholds
    
    % Plot each threshold vector against its representative k-value of
    % noise.  Also fit a line to it.
    kInterval = calcParams.kInterval;
    maxK = 1 + (calcParams.numKValueSamples - 1) * kInterval;
    kValsFine = 1:(maxK-1)/1000:maxK;
    
    figure;
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    fitAndPlotToThreshold(uBlue, thresholdBlue, 'b', kInterval, kValsFine, figParams);
    fitAndPlotToThreshold(uRed, thresholdRed, 'r', kInterval, kValsFine, figParams);
    fitAndPlotToThreshold(uGreen, thresholdGreen, 'g', kInterval, kValsFine, figParams);
    fitAndPlotToThreshold(uYellow, thresholdYellow, 'y', kInterval, kValsFine, figParams);
    
    title('Threshold against k-values');
    xlabel('k-values');
    ylabel('Threshold');
    ylim([0 50]);
end

function [threshold, paramsValues, usableData] = fitToData (data, paramsEstimate, numTrials, color, toPlot)    
%[threshold, paramsValues] = fitToData (data, paramsEstimate, color, toPlot)  
%
% This function will fit input data to a Weibull curve.  The choice of
% psychometric function can be changed manually here.  Set "toPlot" to
% false to disable plotting of the fitted curves.  This function will
% automatically calculate where to start fitting the data.  This is done by
% looking at the first 5 entries in each column and setting the column
% where the average of these 5 values are less than 70 the first time as
% the usableData field.
%
% Inputs:
%   data           - The data with which to fit a Weibull curve.
%   paramsEstimate - The initial estimates for the fitting function.
%   numTrials      - The number of trials run for this data set
%   color          - The color to use to plot the fit.
%   toPlot         - Boolean flag to decide whether or not to plot all the
%                    individual fitted curves
%
% Outputs:
%   threshold    - A vector of thresholds coresponding to the k-values of
%                  the data input
%   paramsValues - The updated params of the curve returned by the fitting function
%   usableData   - The first column at which the data set is appropriate
%                  for fitting

    %% Find usable data range
    sizeOfData = size(data);
    % To find the start of the usable data, take average of 1st 5 values
    % and if it is less than 70, declare that column to be the first
    % possible start
    for ii = 1:sizeOfData(2)
        sum = data(1,ii) + data(2,ii) + data(3,ii) + data(4,ii) + data(5,ii);
        avg = sum / 5;
        
        if (avg < 70)
            usableData = ii;
            break;
        end
    end

    %% Set common parameters
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    stimLevels = 1:1:sizeOfData(1);
    outOfNum   = repmat(numTrials, 1, sizeOfData(1));    
    numKValue = sizeOfData(2) - usableData + 1;
    
    %% Pre-allocate room for return values
    threshold = zeros(numKValue,1);
    paramsValues = zeros(numKValue, 4);
    
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
        a = annotation('textbox', [0.4,0.9,0.1,0.1], ...
            'String',['Threshold fits for ' abbToWord(color) ' illumination']);
        set(a, 'FontSize', 20);
        set(a, 'LineStyle', 'none');
    end
    
    %% Define a function that converts from color abbreviation to full word
    function colorFull = abbToWord(colorAbbr)
        switch colorAbbr
            case {'r'}
                colorFull = 'red';
            case {'g'}
                colorFull = 'green';
            case {'b'} 
                colorFull = 'blue';
            case {'y'}
                colorFull = 'yellow';
        end
    end

    
    %% Calculate thresholds and fits
    for i = 1:numKValue
        % Load the current column of data, each column is a different k-value
        NumPos = data(:, i + usableData - 1)';
        
        % Fit the data to a curve
        [paramsValues(i,:)] = PAL_PFML_Fit(stimLevels, NumPos, outOfNum, ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options);
    
        % Get threshold value for current level of noise
        threshold(i) = PFI(paramsValues(i,:), criterion);
        
        % Plot fitted curves
        if (toPlot)
            subplot(ceil(numKValue/2),2,i);
            PropCorrectData = NumPos./outOfNum;
            StimLevelsFine  = min(stimLevels):(max(stimLevels)-...
                min(stimLevels))/1000:max(stimLevels);
            Fit = PF(paramsValues(i,:), StimLevelsFine);
            plot(stimLevels, PropCorrectData, 'k.', 'markersize', 40);
            set(gca, 'fontsize', 12);
            hold on;
            plot(StimLevelsFine, Fit, color, 'linewidth', 4);
            plot([threshold(i) threshold(i)], [0, criterion], color, 'linewidth', 3);

            title(strcat('K-Value : ',int2str(i + usableData - 1)));
            xlabel('Stimulus Difference (nominal)');
            ylabel('Percent Correct');
            ylim([0 1.0]);
        end
    end
end

function fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams)
%fitAndPlotToThreshold (usableData, threshold, color, kInterval, kValsFine, figParams)
%
% This function plots the thresholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
%
% Inputs:
%   usableData - The start index at which the data is usable for fitting
%   threshold  - The threshold data to plot
%   color      - The color to plot the data
%   kInterval  - The interval between k-value samples
%   kValsFine  - The total range to plot the fit over.  This should be
%                subdivided into many small intervals (finely) to create
%                a line
%   figParams  - Parameters to format the plot

    %% Define x-axis value range
    kVals = usableData:kInterval:max(kValsFine);
    
    %% Plot threshold points
    plot(kVals, threshold, strcat(color,'.'), 'markersize', figParams.markerSize);
    
    %% Fit to line and get set of y values
    % Want to change to something that's not a linear fit
    p = polyfit(kVals, threshold', 1);
    y = polyval(p, kValsFine);
    
    hold on;
    plot (kValsFine, y, color, 'linewidth', figParams.lineWidth);
end

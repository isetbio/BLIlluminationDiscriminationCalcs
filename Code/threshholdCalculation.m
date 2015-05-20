function threshholdCalculation(displayIndividualThreshhold)
%threshholdCalculation(displayIndividualThreshhold)
%   This function uses the Weibull as a psychometric function to
%   fit the data calculated from the simple image discrimination chooser
%   model.  
%
%   Inputs:
%   displayIndividualThreshhold - Set to true if individual fitted curves
%       are to be displayed.  Only the final threshhold graph will be shown
%       if set to false.
%
%   4/20/2015   xd  wrote it
%   4/22/2015   xd  finished running chooser model on all 4 illum colors
%   4/24/2015   xd  cleaned up the function for readability

    %% clear
    clc; clear global; close all;

    %% Load the data for each illumination matrix    
    blueMatrix  = loadChooserData('blueIllumComparison');
    greenMatrix = loadChooserData('greenIllumComparison');
    redMatrix = loadChooserData('redIllumComparison');
    yellowMatrix = loadChooserData('yellowIllumComparison');
    
    %% Load default figure parameters
    figParams = getFigureParameters;
    
    %% Set estimations param for calculations
    %
    % Use same estimated parameters for all data sets
    paramsValueEst = [10 1 0.5 0];

    %% Set usable data range and offset
    % Any columns that do not consistantly reach 70.9% correct rate is
    % ignored in the fit calculation
   
    % The first value is how many columns are usable. The second value is
    % the offset, so the first column used would be 1 + offset
    UsableBlue = [6 1];
    UsableRed = [8 2];
    UsableGreen = [8 2];
    UsableYellow = [8 2];
    
    %% Calculate Threshholds
    % For each illumantion color, we find a vector of threshholds at which
    % the success rate is 0.709
    [threshholdBlue, ~] = fitToData(UsableBlue(1), UsableBlue(2), blueMatrix, paramsValueEst, 'b', displayIndividualThreshhold);
    [threshholdRed, ~] = fitToData(UsableRed(1), UsableRed(2), redMatrix, paramsValueEst, 'r',displayIndividualThreshhold);
    [threshholdGreen, ~] = fitToData(UsableGreen(1), UsableGreen(2), greenMatrix, paramsValueEst, 'g',displayIndividualThreshhold);
    [threshholdYellow, ~] = fitToData(UsableYellow(1), UsableYellow(2), yellowMatrix, paramsValueEst, 'y',displayIndividualThreshhold);
    
    
    %% Plot Threshholds
    % Plot each threshhold vector against its representative k-value of
    % noise.  Also fit a line to it.
    totalRange = 1:10;
    kValsFine = min(totalRange):(max(totalRange)-min(totalRange))/1000:max(totalRange);
    
    figure;
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    fitAndPlotToThreshhold(UsableBlue(1), UsableBlue(2), threshholdBlue, 'b', kValsFine, figParams);
    fitAndPlotToThreshhold(UsableRed(1), UsableRed(2), threshholdRed, 'r', kValsFine, figParams);
    fitAndPlotToThreshhold(UsableGreen(1), UsableGreen(2), threshholdGreen, 'g', kValsFine, figParams);
    fitAndPlotToThreshhold(UsableYellow(1), UsableYellow(2), threshholdYellow, 'y', kValsFine, figParams);
    
    title('Threshhold against k-values');
    xlabel('k-values');
    ylabel('Threshhold');
end

% This function will fit input data to a Weibull curve.  The choice of
% psychometric function can be changed manually here.  Set "toPlot" to
% false to disable plotting of the fitted curves
function [threshhold, paramsValues] = fitToData (usableDataRange, usableDataOffset, data, paramsEstimate, color, toPlot)

    %% Pre-allocate room for return values
    threshhold = zeros(usableDataRange,1);
    paramsValues = zeros(usableDataRange, 4);
    
    %% Set common parameters
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    sizeOfData = size(data);
    StimLevels = 1:1:sizeOfData(1);
    OutofNum   = repmat(100, 1, sizeOfData(1));    
    
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
        set(gcf, 'Position', [0 0 1000 1000]); 
        set(gca,'FontName','Helvetica','FontSize',12);
    end
    
    %% Calculate threshholds and fits
    for i = 1:usableDataRange
        % Load the current column of data, each column is a different
        % k-value
        NumPos = data(:, i + usableDataOffset)';
        
        % Fit the data to a curve
        [paramsValues(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsEstimate, paramsFree, PF, 'SearchOptions', options);
    
        % Get threshhold value for current level of noise
        threshhold(i) = PFI(paramsValues(i,:), criterion);
        
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
            plot([threshhold(i) threshhold(i)], [0, criterion], color, 'linewidth', 3);

            title(strcat('K-Value : ',int2str(i + usableDataOffset)));
            xlabel('Stimulus Difference (nominal)');
            ylabel('Percent Correct');
        end
    end
end

% This function plots the threshholds against their respective k values of
% noise.  Currently the data is fit to a linear line.
function fitAndPlotToThreshhold (usableDataRange, usableDataOffset, threshhold, color, kValsFine, params)
    %% Define starting k-value
    start = 1 + usableDataOffset;
    kVals = start:1:(start + usableDataRange - 1);
    
    %% Plot threshhold points
    plot(kVals, threshhold, strcat(color,'.'), 'markersize', params.markerSize);
    
    %% Fit to line and get set of y values
    p = polyfit(kVals, threshhold', 1);
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, color, 'linewidth', params.lineWidth);

end

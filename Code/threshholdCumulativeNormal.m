function threshholdCumulativeNormal
%threshholdBlueCumulativeNormal
%   This function uses the cumulative normal as a psychometric function to
%   fit the data calculated from the simple image discrimination chooser
%   model.  
%
%   4/20/2015   xd  wrote it

    % clear
    clc; clear global; close all;

    % load data
    data  = load('blueIllumComparison');
    blueMatrix = data.matrix;
    data  = load('greenIllumComparison');
    greenMatrix = data.matrix;
    data  = load('redIllumComparison');
    redMatrix = data.matrix;
    data = load('yellowIllumComparison');
    yellowMatrix = data.matrix;
    
    % set data
    StimLevels = 1:1:50;
    OutofNum   = repmat(100, 1, 50);
    

    % Define estimated threshholdBlue and slope for k = 2 -> 7
    ThreshEstimateBlue = [4 7 12 20 30 40];
    SlopeEstimateBlue  = 10*[0.1 0.1 0.1 0.1 0.1 0.1];
     
    % set params
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    
    % blue data set
    paramsValuesBlue = zeros(6, 4);
    threshholdBlue = zeros(6, 1);

    % Define PF as cumulative normal
    PF = @PAL_Weibull;
    PFI = @PAL_inverseWeibull;
    
    options = optimset('fminsearch');   % Type help optimset
    options.TolFun = 1e-09;             % Increase required precision on LL
    options.MaxFunEvals = 10000 * 100;
    options.MaxIter = 500*100;
    
    
%     NumPos = redMatrix(1:50, 10)';
%     params = [30 .1 .5 0];
%     [ params ] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
%         params, paramsFree, PF, 'SearchOptions', options)
%     thresh = PFI(params, criterion)
    
    % Fit curve for blue
    for i = 1:6
        NumPos = blueMatrix(1:50, i + 1)';
        
        paramsValuesBlue(i,:) = [ThreshEstimateBlue(i) SlopeEstimateBlue(i) 0.5 0];
        
        [paramsValuesBlue(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValuesBlue(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshholdBlue
        threshholdBlue(i) = PFI(paramsValuesBlue(i,:), criterion);
        
        
        % Plot fitted curves
%         figure;
%         PropCorrectData = NumPos./OutofNum;
%         StimLevelsFine  = [min(StimLevels):(max(StimLevels)-...
%             min(StimLevels))/1000:max(StimLevels)];
%         Fit = PF(paramsValuesBlue(i,:), StimLevelsFine);
%         plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
%         set(gca, 'fontsize', 12);
%         hold on;
%         plot(StimLevelsFine, Fit, 'b-', 'linewidth', 4);
%         plot([threshholdBlue(i) threshholdBlue(i)], [0, criterion], 'b', 'linewidth', 3);
%         
%         ThisTitle = strcat('K-Value : ',int2str(i+1));
%         title(ThisTitle);
%         xlabel('Stimulus Difference (nominal)');
%         ylabel('Percent Correct');
        
    end

    % Threshholds and slope estimates for YellowIllumination
    ThreshEstimateGreen = 10*ones(size([4 10 17 24 30 38 40 45]));
    SlopeEstimateGreen  = 10*[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1];
    paramsValuesGreen = zeros(8,4);
    threshholdGreen= zeros(8,1);
    
    % Fit curve for Green
    for i = 1:8
        NumPos = greenMatrix(1:50,i+2)';
        
        paramsValuesGreen(i,:) = [ThreshEstimateGreen(i) SlopeEstimateGreen(i) 0.5 0];
        
        [paramsValuesGreen(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValuesGreen(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshholdBlue
        threshholdGreen(i) = PFI(paramsValuesGreen(i,:), criterion);
        
    end
    
    % Thresh and slop for red
    ThreshEstimateRed = 10*ones(size([2 10 17 18 20 24 24 30]));
    SlopEstimateRed = 10*[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1];
    paramsValuesRed = zeros(8,4);
    threshholdRed = zeros(8,1);
    
    % Fit curve for red
    figure;
    for i = 1:8
        NumPos = redMatrix(1:50,i+2)';
        
        paramsValuesRed(i,:) = [ThreshEstimateRed(i) SlopEstimateRed(i) 0.5 0];
        
        [paramsValuesRed(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValuesRed(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshholdBlue
        threshholdRed(i) = PFI(paramsValuesRed(i,:), criterion);
        
        
        subplot(4,2, i);
        PropCorrectData = NumPos./OutofNum;
        StimLevelsFine  = [min(StimLevels):(max(StimLevels)-...
            min(StimLevels))/1000:max(StimLevels)];
        Fit = PF(paramsValuesRed(i,:), StimLevelsFine);
        plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
        set(gca, 'fontsize', 12);
        hold on;
        plot(StimLevelsFine, Fit, 'r-', 'linewidth', 4);
        plot([threshholdRed(i) threshholdRed(i)], [0, criterion], 'r', 'linewidth', 3);
        
        ThisTitle = strcat('K-Value : ',int2str(i+1));
        title(ThisTitle);
        xlabel('Stimulus Difference (nominal)');
        ylabel('Percent Correct');
    end
    
    % Threshholds and slope estimates for YellowIllumination
    ThreshEstimateYellow = 10*ones(size([4 10 17 24 30 38 40 45]));
    SlopeEstimateYellow  = 10*[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1];
    paramsValuesYellow = zeros(8,4);
    threshholdYellow = zeros(8,1);
    
    
        figure;
    % Fit curve for Yellow
    for i = 1:8
        NumPos = yellowMatrix(1:50,i+2)';
        
        paramsValuesYellow(i,:) = [ThreshEstimateYellow(i) SlopeEstimateYellow(i) 0.5 0];
        
        [paramsValuesYellow(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValuesYellow(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshholdBlue
        threshholdYellow(i) = PFI(paramsValuesYellow(i,:), criterion);
        
        subplot(4,2,i);
        PropCorrectData = NumPos./OutofNum;
        StimLevelsFine  = [min(StimLevels):(max(StimLevels)-...
            min(StimLevels))/1000:max(StimLevels)];
        Fit = PF(paramsValuesYellow(i,:), StimLevelsFine);
        plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
        set(gca, 'fontsize', 12);
        hold on;
        plot(StimLevelsFine, Fit, 'y-', 'linewidth', 4);
        plot([threshholdYellow(i) threshholdYellow(i)], [0, criterion], 'y', 'linewidth', 3);
        
        ThisTitle = strcat('K-Value : ',int2str(i+1));
        title(ThisTitle);
        xlabel('Stimulus Difference (nominal)');
        ylabel('Percent Correct');
        
    end
    
    
    totalRange = 1:10;
    kValsFine = [min(totalRange):(max(totalRange)-min(totalRange))/1000:max(totalRange)];
    % Plot threshholdGreen against k value
    kVals = 3:10;

    figure;
    plot(kVals, threshholdGreen, 'g.', 'markersize', 40);
    p = polyfit(kVals, threshholdGreen', 1);
    
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'g', 'linewidth', 4);
    
    % Plot threshholdRed against k
    kVals = 3:10;

    
    plot(kVals, threshholdRed, 'r.', 'markersize', 40);
    p = polyfit(kVals, threshholdRed', 1);
    
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'r', 'linewidth', 4);
    
    
        
    % Plot threshholdRed against k
    kVals = 3:10;

    
    plot(kVals, threshholdYellow, 'y.', 'markersize', 40);
    p = polyfit(kVals, threshholdYellow', 1);
    
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'y', 'linewidth', 4);
        
    % Plot threshholdBlue against k value
    kVals = 2:7;

    plot(kVals, threshholdBlue, 'b.', 'markersize', 40);
    p = polyfit(kVals, threshholdBlue', 1);
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'b', 'linewidth', 4);
    
    title('Threshhold against k-values');
    xlabel('k-values');
    ylabel('Threshhold');
end


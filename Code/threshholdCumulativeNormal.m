function threshholdBlueCumulativeNormal
%threshholdBlueCumulativeNormal
%   This function uses the cumulative normal as a psychometric function to
%   fit the data calculated from the simple image discrimination chooser
%   model.  
%
%   4/20/2015   xd  wrote it

    % clear
    clc; clear all;

    % load data
    data  = load('blueIllumComparison');
    blueMatrix = data.matrix;
    data  = load('greenIllumComparison');
    greenMatrix = data.matrix;
    
    % set data
    StimLevels = 1:1:50;
    OutofNum   = repmat(100, 1, 50);
    

    % Define estimated threshholdBlue and slope for k = 2 -> 7
    ThreshEstimateBlue = [4 7 12 20 30 40];
    SlopeEstimateBlue  = [0.1 0.1 0.1 0.1 0.1 0.1];
     
    % set params
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    
    % blue data set
    paramsValuesBlue = zeros(6, 4);
    threshholdBlue = zeros(6, 1);

    % Define PF as cumulative normal
    PF = @PAL_CumulativeNormal;
    PFI = @PAL_inverseCumulativeNormal;
    
    options = optimset('fminsearch');   % Type help optimset
    options.TolFun = 1e-09;             % Increase required precision on LL
    options.MaxFunEvals = 10000 * 100;
    options.MaxIter = 500*100;
    
    
%     NumPos = greenMatrix(1:50, 10)';
%     params = [45 .1 .5 0];
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
%         plot(StimLevelsFine, Fit, 'g-', 'linewidth', 4);
%         plot([threshholdBlue(i) threshholdBlue(i)], [0, criterion], 'b', 'linewidth', 3);
%         
%         ThisTitle = strcat('K-Value : ',int2str(i+1));
%         title(ThisTitle);
%         xlabel('Stimulus Difference (nominal)');
%         ylabel('Percent Correct');
        
    end

    % Threshholds and slope estimates for greenIllumination
    ThreshEstimateGreen = [4 10 17 24 30 38 40 45];
    SlopeEstimateGreen  = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1];
    paramsValuesGreen = zeros(8,4);
    threshholdGreen = zeros(8,1);
    
    % Fit curve for green
    for i = 1:8
        NumPos = greenMatrix(1:50,i+2)';
        
        paramsValuesGreen(i,:) = [ThreshEstimateGreen(i) SlopeEstimateGreen(i) 0.5 0];
        
        [paramsValuesGreen(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValuesGreen(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshholdBlue
        threshholdGreen(i) = PFI(paramsValuesGreen(i,:), criterion);
        
    end
    
    totalRange = 1:10;
    kValsFine = [min(totalRange):(max(totalRange)-min(totalRange))/1000:max(totalRange)];
    % Plot threshholdGreen against k value
    kVals = 3:10;

    figure;
    plot(kVals, threshholdGreen, 'k.', 'markersize', 40);
    p = polyfit(kVals, threshholdGreen', 1);
    
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'g', 'linewidth', 4);
        
    % Plot threshholdBlue against k value
    kVals = 2:7;

    plot(kVals, threshholdBlue, 'k.', 'markersize', 40);
    p = polyfit(kVals, threshholdBlue', 1);
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'b', 'linewidth', 4);
    
    title('Threshhold against k-values');
    xlabel('k-values');
    ylabel('Threshhold');
end


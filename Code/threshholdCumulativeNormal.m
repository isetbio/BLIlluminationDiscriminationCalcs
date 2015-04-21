function threshholdCumulativeNormal
%threshholdCumulativeNormal
%   This function uses the cumulative normal as a psychometric function to
%   fit the data calculated from the simple image discrimination chooser
%   model.  
%
%   4/20/2015   xd  wrote it

    % clear
    clc; clear all;

    % load data
    data  = load('blueIllumComparison');
    matrix = data.matrix;
    
    % set data
    StimLevels = 1:1:50;
    NumPos     = matrix(1:50,6)';
    OutofNum   = repmat(100, 1, 50);
    

    % Define estimated threshhold and slope for k = 2 -> 7
    ThreshEstimate = [4 7 12 20 30 40];
    SlopeEstimate  = [0.1 0.1 0.1 0.1 0.1 0.1];
    
    % set params
%     paramsValues = [32, .1, .5, 0];
    paramsFree  = [1, 1, 0, 0];
    criterion = .709;
    paramsValues = zeros(6, 4);
    threshhold = zeros(6, 1);

    % Define PF as cumulative normal
    PF = @PAL_CumulativeNormal;
    PFI = @PAL_inverseCumulativeNormal;
    
    options = optimset('fminsearch');   % Type help optimset
    options.TolFun = 1e-09;             % Increase required precision on LL
    options.MaxFunEvals = 10000 * 100;
    options.MaxIter = 500*100;
    
    % Fit curve
    for i = 1:6
        NumPos = matrix(1:50, i + 1)';
        
        paramsValues(i,:) = [ThreshEstimate(i) SlopeEstimate(i) 0.5 0];
        
        [paramsValues(i,:)] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValues(i,:), paramsFree, PF, 'SearchOptions', options);
    
        % Get threshhold
        threshhold(i) = PFI(paramsValues(i,:), criterion);
        
        
        % Plot fitted curves
%         figure;
%         PropCorrectData = NumPos./OutofNum;
%         StimLevelsFine  = [min(StimLevels):(max(StimLevels)-...
%             min(StimLevels))/1000:max(StimLevels)];
%         Fit = PF(paramsValues(i,:), StimLevelsFine);
%         plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
%         set(gca, 'fontsize', 12);
%         hold on;
%         plot(StimLevelsFine, Fit, 'g-', 'linewidth', 4);
%         plot([threshhold(i) threshhold(i)], [0, criterion], 'g', 'linewidth', 3);
%         
%         ThisTitle = strcat('K-Value : ',int2str(i+1));
%         title(ThisTitle);
%         xlabel('Stimulus Difference (nominal)');
%         ylabel('Percent Correct');
        
    end

    
    

   
        
    % Plot threshhold against k value
    kVals = 2:7;

    figure;
    plot(kVals, threshhold, 'k.', 'markersize', 40);
    p = polyfit(kVals, threshhold', 1);
    kValsFine = [min(kVals):(max(kVals)-min(kVals))/1000:max(kVals)];
    y = polyval(p, kValsFine);
    hold on;
    plot (kValsFine, y, 'g', 'linewidth', 4);
end


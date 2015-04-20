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
    StimLevels = 35:1:45;
    NumPos     = matrix(35:45,7)';
    OutofNum   = repmat(100, 1, 11);
    
%     StimLevels = [0.01 0.03 0.05 0.07 0.09 0.11];
%     NumPos     = [45 55 72 85 91 100];
%     OutofNum   = repmat(100, 1, 6);
    
    % set params
    paramsValues = [39, 5, .5, 0];
    paramsFree  = [1, 1, 0, 0];
    
%     paramsValues = [0.05, 50, .5, 0];
%     paramsFree  = [1, 1, 0, 0];

    % Define PF as cumulative normal
    PF = @PAL_CumulativeNormal;
    
    options = optimset('fminsearch');   % Type help optimset
    options.TolFun = 1e-09;             % Increase required precision on LL
    options.MaxFunEvals = 500 * 100;
    options.MaxIter = 500*100;
    
    % Fit curve
    [paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels, NumPos, OutofNum, ...
        paramsValues, paramsFree, PF, 'SearchOptions', options)
    
    % Plot
    PropCorrectData = NumPos./OutofNum;
    StimLevelsFine  = [min(StimLevels):(max(StimLevels)-...
        min(StimLevels))./1000:max(StimLevels)];
    Fit = PF(paramsValues, StimLevelsFine);
    plot(StimLevels, PropCorrectData, 'k.', 'markersize', 40);
    set(gca, 'fontsize', 12);
%     axis([0 .12 .4 .1]);
    hold on;
    plot(StimLevelsFine, Fit, 'g-', 'linewidth', 4);
end


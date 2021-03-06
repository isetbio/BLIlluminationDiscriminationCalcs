function plotThresholdsAgainstNoise(plotInfo,thresholds,noiseLevels)
% plotThresholdsAgainstNoise(plotInfo,thresholds,noiseLevels)
% 
% This function will plot thresholds on the y-axis against noiseLevels on
% the x-axis. Thresholds will be a NxM matrix, where each column is a set
% of points to be plotted. noiseLevels can be either a Nx1 vector or a NxM
% matrix. If it is a vector, it will be assumed that all values in
% thresholds correspond to that one vector. If it is a matrix, columns from
% thresholds and noiseLevels will be matched up when plotted. This function
% also requires a stimLevels filed in plotInfo to be specified.
%
% Inputs:
%     plotInfo     -  struct containing some data about label and title text
%     thresholds   -  threshold data to plot 
%     noiseLevels  - noise levels to plot against (the x-axis)
% 
% 6/21/16  xd  wrote it

%% Check that inputs are correct
if size(noiseLevels,2) ~= 1 && size(noiseLevels,2) ~= size(thresholds,2),error('noiseLevels format incorrect!'); end
if isempty(plotInfo.stimLevels), error('No stimLevels specified in plotInfo!'); end

% If noiseLevels is a vector, rearrange into a matrix for ease of use later on
if size(noiseLevels,2) == 1, noiseLevels = repmat(noiseLevels,1,size(thresholds,2)); end
    
%% Generate some default parameters for this figure
figParams = BLIllumDiscrFigParams([], 'ThresholdvNoise');
if ~isempty(plotInfo.colors), figParams.colors = plotInfo.colors; end

%% Plot
figure('Position',figParams.sqPosition); hold on;
for ii = 1:size(thresholds,2)
    
    % Find locations where data makes sense
    nonzeroIdx = thresholds(:,ii) > 0;
    
    plot(noiseLevels(nonzeroIdx,ii),thresholds(nonzeroIdx,ii),'o-','Color',figParams.colors{ii},...
        'MarkerSize',figParams.markerSize,'LineWidth',figParams.lineWidth);
end

% Make figure look nicer
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
axis square; grid on;
ylim([min(plotInfo.stimLevels) max(plotInfo.stimLevels)]);
xlim([0 max([noiseLevels(:); 10])]);

xlabel(plotInfo.xlabel);
ylabel(plotInfo.ylabel);
title(plotInfo.title,'Interpreter','none');

end


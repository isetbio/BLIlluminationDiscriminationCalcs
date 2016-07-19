function plotFittedPsychometricFunctionsInterp(calcIDList,noiseIdx)
% plotFittedPsychometricFunctions(calcIDList,noiseIdx)
%
% Plots the fitted psychometric functions given a calcIDList containing
% interpolated calculations in order (e.g. Interp1, Interp2, ...). Data at
% the specified noiseIdx will be plotted on one figure for each color
% direction.
%
% 7/18/16  xd  wrote it

fitColors = repmat(linspace(0,0.7,length(calcIDList)),3,1);
figParams = BLIllumDiscrFigParams([],'sThreshold');
plotInfo = createPlotInfoStruct;
plotInfo.ylabel = 'Percent Correct';
plotInfo.xlabel = 'Stimulus Level (\DeltaE)';
colors = {'Blue' 'Green' 'Red' 'Yellow'};

figure('Position',[100 100 1000 1000]);
for cc = 1:4
    subplot(2,2,cc); hold on;
    plotInfo.title = colors{cc};
    for ii = 1:length(calcIDList)
        theCurrentData = loadModelData(calcIDList{ii});
        theCurrentData = squeeze(theCurrentData(cc,:,:,noiseIdx));
        
        [~,fitParams] = singleThresholdExtraction(theCurrentData,70.9);
        % Create a finely spaced data vector to generate data points along a curve for plotting.
        stimLevelsFine = min(plotInfo.stimLevels):(max(plotInfo.stimLevels)-min(plotInfo.stimLevels))/1000:max(plotInfo.stimLevels);
        curveFit = PAL_Weibull(fitParams,stimLevelsFine) * 100;
        
        % Plotting
        figParams.defaultFitLineColor = fitColors(:,ii);
        plot(stimLevelsFine,curveFit,'Color',figParams.defaultFitLineColor, 'LineWidth',figParams.fitLineWidth);
    end
    
    % Do some plot manipulations to make it look nice
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    axis square;
    grid on;
    ylim(figParams.ylimit);
    
    xlabel(plotInfo.xlabel,'FontSize',figParams.labelFontSize);
    ylabel(plotInfo.ylabel,'FontSize',figParams.labelFontSize);
    title(plotInfo.title,'FontSize',figParams.titleFontSize);
end

suplabel(['Noise Level: ' num2str(noiseIdx)],'t');
end


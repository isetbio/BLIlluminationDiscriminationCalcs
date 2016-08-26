%% PlotSVMwithPCA
%
% Look at SVM performance when trained on full data and only pca data. For
% more information about the calculations that generated the dataset, see
% the script svmUsingPCAComparison. This script allows the user to
% configure whether it plots the cross validated result or the result on an
% independent test set.
%
% 6/24/16  xd  wrote it
% 8/26/16  xd  update accordingly to match new data format + comments

clear; close all;
%% User options

% Saves the figure as a pdf in the directory from which this script is
% called if set to true.
saveFig = false;

% Plots the cross validated result if true. Otherwise, just plots the
% result from predictions on an independently generated test set.
plotCV  = true;

%% Load and pull out some data
%
% This is the data set that goes along with this plotting script. The data
% must be generated via the svmUsingPCAComparison script. If saveFig is
% true, the generated pdf will be named with the fileName variable.
fileName = 'SVM_FullvPCA.mat';
load(fileName);

%% Fig Params
%
% Loads some aesthetic parameters related to the plots.
figParams = BLIllumDiscrFigParams([],'SVMvPCA');

%% Format and plot
%
% We will create a subplot for each color direction. Color should be the
% first dimension of the data matrix. If it is not, check the MetaData
% struct to see what went wrong.
f = figure('Position',figParams.sqPosition); 

firstDimension = MetaData.dimensions.labels{1};
for colorIdx = 1:length(MetaData.dimensions.(firstDimension))
    
    % Pull out data for this loop. This makes indexing easier.
    dataForThisLoop = squeeze(SVMpercentCorrect(colorIdx,:,:,:));
    runTimeForThisLoop = squeeze(SVMrunTime(colorIdx,:,:,:));
    
    % Create a subplot
    subplot(2,2,colorIdx);
    hold on;
    
    % We will use our own color scheme for the different data sets plotted.
    % This is because we happen to have 1 more data set to plot than the
    % number of sets Matlab supports by default, resulting in duplicated
    % colors in the plot. Our simple scheme just involves going around the
    % hsv color wheel in uniform steps.
    secondDimension = MetaData.dimensions.labels{2};
    hueFracForPlot = 1/length(MetaData.dimensions.(secondDimension));
    for ii = 1:length(MetaData.dimensions.(secondDimension))
        if plotCV
            h = errorbar(MetaData.dimensions.IllumSteps,squeeze(dataForThisLoop(ii,:,1))*100,squeeze(dataForThisLoop(ii,:,2))*100,...
                'LineWidth',figParams.lineWidth,'Color',hsv2rgb([hueFracForPlot*ii,figParams.s,figParams.v]));
        else
            h = plot(MetaData.dimensions.IllumSteps,squeeze(dataForThisLoop(ii,:,3))*100,'LineWidth',figParams.lineWidth,...
                'Color',hsv2rgb([hueFracForPlot*ii,figParams.s,figParams.v]));
        end
        h.Color(4) = figParams.alpha;
    end
    
    % Set our axis limits
    xlim(figParams.xlimit);
    ylim(figParams.ylimit);
    
    % Set the title, legend, and labels
    legend([{'Full'} cellfun(@(X)num2str(X),num2cell(MetaData.dimensions.(secondDimension)(2:end)),'UniformOutput',false)],...
        'Location','Northwest','FontSize',figParams.legendFontSize);
    t = title(MetaData.dimensions.(firstDimension){colorIdx},'FontSize',figParams.titleFontSize);
    xl = xlabel('Stimulus Level (\DeltaE)','FontSize',figParams.labelFontSize);
    yl = ylabel('% Correct','FontSize',figParams.labelFontSize);
    
    % Some formatting to make look nice
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    axis square;
    grid on;
    
    % Create inset for runtime. We make it roughly the same size as the
    % legend, so the runtime bars line up nicely!
    inset = axes('Position',figParams.insetPositions{colorIdx}); 
    hold on;
    
    for ii = 1:length(MetaData.dimensions.(secondDimension)) 
        barh(-ii,mean2(sum(runTimeForThisLoop(ii,:,:),3)),'FaceColor',hsv2rgb([hueFracForPlot*ii,figParams.s,figParams.v]));
    end
    
    ylim(figParams.insetYLimit);
    xlim(figParams.insetXLimit);
    
    % Lots of formatting. 
    set(inset,'Box','on');
    set(inset,'YTick',[],'XTick',figParams.insetXLimit);
    set(inset,'TickLength',figParams.insetTickLength);
    set(inset,'FontName',figParams.fontName,'FontSize',figParams.insetAxisFontSize,'LineWidth',figParams.insetAxisLineWidth);
    set(inset,'FontWeight','bold');
    ixl = xlabel('Runtime (s)','FontSize',figParams.insetTitleFontSize);
    ixl.Position = ixl.Position + figParams.insetDeltaXLabelPos;
end

%% Save the figure
if saveFig, FigureSave(fileName,f,figParams.figType); end;
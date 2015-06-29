function plotIndividualPercentAndPValue(data, ii, jj)
% plotIndividualPercentAndPValue(data, ii, jj)
%
% This will plot a specific target data set from the tutorials.  Be sure to
% load the data.mat file into a variable and call this function while
% passing in the ii and jj values corresponding to the distribution and
% dimensionality of the desired plot.
%
% 6/29/15  xd  wrote it


%% Load necessary info from data
testDirectionName = data.testDirectionName;
percentCorrectMeanMatrix = data.percentCorrectMeanMatrix;
percentCorrectStderrMatrix = data.percentCorrectStderrMatrix;
noiseFuncNames = data.noiseFuncNames;
ttestMatrix = data.ttestMatrix;
testVectorDirection = data.testVectorDirection;
noiseFactorKs = data.noiseFactorKs;
dimensionalities = data.dimensionalities;
directoryName = data.directoryName;
figParams = data.figParams;

%% Plot desired figure
figure;
set(gcf, 'position', [0 0 1500 750]);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
theTitle = [noiseFuncNames{jj} ' ' int2str(dimensionalities(ii)) ' for ' testDirectionName{testVectorDirection} ' ' strtok(directoryName, '_')];

subplot(1,2,1);
h = errorbar(noiseFactorKs,percentCorrectMeanMatrix(ii,:,jj), 2*percentCorrectStderrMatrix(ii,:,jj), 'b.-', 'markersize', figParams.markerSize);
set(get(h,'Parent'),'XScale','log')
hold on
plot(xlim, [50 50], 'k--');

title('Percent Correct','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('k','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('% correct','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlim(figParams.percentXLim);
ylim(figParams.percentYLim);

% Plot p values
subplot(1,2,2);
h = plot(noiseFactorKs,ttestMatrix(ii,:,jj), 'r.', 'markersize', figParams.markerSize);
set(get(h,'Parent'),'XScale','log')
hold on
plot(xlim, [0.05 0.05], 'k--');

title('p values','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('k','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('p value','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlim(figParams.pvalueXLim);
ylim(figParams.pvalueYLim);


suptitle(theTitle);
% savefig(fullfile(directoryName, theTitle));
% FigureSave(fullfile(directoryName, theTitle), gcf, 'pdf');
end


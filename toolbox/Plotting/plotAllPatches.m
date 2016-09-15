function plotAllPatches(calcIDStr,patchInfo)
% plotAllPatches(calcIDStr,patchInfo)
%
% Plots the thresholds for all patches that share the calcIDStr in one
% figure. Plots will corresponds to the region in the image that the patch
% is located.
%
% 7/10/16  xd  wrote it

%% Load some path and metadata variables
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
patchSubplotIdx = reshape(1:patchInfo.hNum*patchInfo.vNum,patchInfo.hNum,patchInfo.vNum).';
axisHandles = zeros(length(calcIDStrList),1);
maxYValue = 0;

%% Actual plotting
%
% We want to set the size of the figure based on how many subplots there
% will be.
figParams = BLIllumDiscrFigParams([],'AllPatches');
figure('Position',[133 849 patchInfo.hNum*100 patchInfo.vNum*100]);
for jj = 1:length(calcIDStrList)
    patchNumber = str2double(regexp(calcIDStrList{jj},'[\d]+$','match'));
    
    % Get thresholds
    thresholds = loadThresholdData(calcIDStrList{jj},['Thresholds' calcIDStrList{jj} '.mat']);
    
    % Format Data. We want to remove and row that has a NaN entry. This
    % gives us thresholds that are averaged over every patch in the image.
    % We'll take the mean thresholds over noise which will be slightly
    % inaccurate because the colors may not have the same slope, but this
    % is fine for a general summary figure.
    thresholds(any(isnan(thresholds),2),:) = [];
    rankings = zeros(size(thresholds));
    for ii = 1:size(thresholds,1)
        tempThresholds = thresholds(ii,:);
        rankings(ii,:) = tempThresholds;% - min(tempThresholds)+1;
    end
    rankings = mean(rankings,1);
    
    % Plot
    axisHandles(jj) = subplot(patchInfo.vNum,patchInfo.hNum,patchSubplotIdx(patchNumber)); 
    hold on;
    for ii = 1:4
        bar(ii,rankings(ii),'FaceColor',figParams.colors{ii});
        axis square
        if rankings(ii) > maxYValue, maxYValue = rankings(ii); end;
    end
end

% Set the axis limits for all subplots to be identical
set(axisHandles,'YLim',figParams.YTick,'XTick',figParams.XTick);
sTitle = sprintf('Thresholds averaged over noise, %s',calcIDStr);
[~,superTitle] = suplabel(sTitle,'t');
set(superTitle,'FontSize',figParams.superTitleFontSize,'Interpreter','None');

end


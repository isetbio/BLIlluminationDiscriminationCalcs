function plotAllPatches(calcIDStr,patchInfo)
% plotAllPatches(calcIDStr)
%
% Plots the thresholds for all patches that share the calcIDStr in one
% figure. Plots will corresponds to the region in the image that the patch
% is located.
%
% 7/10/16  xd  wrote it

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);
patchSubplotIdx = reshape(1:patchInfo.hNum*patchInfo.vNum,patchInfo.hNum,patchInfo.vNum).';
axisHandles = zeros(length(calcIDStrList),1);
maxYValue = 0;

figure('Position',[133 849 patchInfo.hNum*100 patchInfo.vNum*100]);
for jj = 1:length(calcIDStrList)
    patchNumber = str2double(calcIDStrList{jj}(regexp(calcIDStrList{jj},'[\d]')));
    
    % Get thresholds
    thresholds = loadChooserData(calcIDStrList{jj},['Thresholds' calcIDStrList{jj} '.mat']);
    
    % Format Data
    thresholds(any(isnan(thresholds),2),:) = [];
    rankings = zeros(size(thresholds));
    for ii = 1:size(thresholds,1)
        tempThresholds = thresholds(ii,:);
        rankings(ii,:) = tempThresholds - min(tempThresholds)+1;
    end
    rankings = mean(rankings,1);
    
    % Plot
    colors = {[0 191 255]/255 [46 139 87]/255 [178,34,34]/255 [255 215 0]/255};
    axisHandles(jj) = subplot(patchInfo.vNum,patchInfo.hNum,patchSubplotIdx(patchNumber)); 
    hold on;
    for ii = 1:4
        bar(ii,rankings(ii),'FaceColor',colors{ii});
        axis square
        if rankings(ii) > maxYValue, maxYValue = rankings(ii); end;
    end
end

set(axisHandles,'YLim',[0 maxYValue+1],'XTick',[]);
[~,superTitle] = suplabel('Difference in thresholds averaged over noise','t');
set(superTitle,'FontSize',32);
% set(superTitle,'Position',[0.0902    0.0500    0.8548    0.8950])
% xlabel = num2str(1:patchInfo.hNum);
% xlabel = strrep(xlabel,' ','   ');
% [~,superXLabel] = suplabel(xlabel,'x');
% set(superXLabel,'FontSize',26.5);
end


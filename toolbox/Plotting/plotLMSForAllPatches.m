function plotLMSForAllPatches(data,patchInfo)
% plotLMSForAllPatches(sceneFolder,fov,illumLevel)
%
% Plots the LMS cone differences on each individual patch for a given
% illumination level across all four illumination colors.
%
% 7/13/16  xd  wrote it

colors = {'Blue' 'Green' 'Red' 'Yellow'};
% Plot
patchSubplotIdx = reshape(1:patchInfo.hNum*patchInfo.vNum,patchInfo.hNum,patchInfo.vNum).';
titles = {'L','M','S'};
for jj = 1:4
    axisHandles = zeros(patchInfo.hNum*patchInfo.vNum,1);
    figure('Position',[133 849 patchInfo.hNum*100 patchInfo.vNum*100]);
    maxY = 0;
    minY = 0;
    for ii = 1:size(data,3)
        axisHandles(ii) = subplot(patchInfo.vNum,patchInfo.hNum,patchSubplotIdx(ii));
        hold on;
        for bb = 1:3
            bar(bb,-data(jj,bb,ii));
            if max(data(:,bb,ii)) > maxY, maxY = max(data(:,bb,ii)); end
            if min(data(:,bb,ii)) < minY, minY = min(data(:,bb,ii)); end
        end
        axis square;
    end
    set(axisHandles,'YLim',[maxY -minY+50],'XTick',[]);
    [~,sTitle] = suplabel(colors{jj},'t');
    set(sTitle,'FontSize',28);
end
end


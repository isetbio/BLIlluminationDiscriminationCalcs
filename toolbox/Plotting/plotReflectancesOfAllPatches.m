function plotReflectancesOfAllPatches(largeScene,fov)
% plotReflectancesOfAllPatches(largeScene,fov)
% 
% Plots the mean reflectances for each patch returned by the split scenes
% function.
%
% Inputs:
%    largeScene  -  the scene to plot
%    fov  -  the size of each patch
% 
% 7/13/16  xd  wrote it

%% Set up variables
%
% Calculate the small scenes in the patch so that we can get the
% reflectance of each patch. Also load some variables that will be used for
% formatting the plot.
[smallScenes,patchInfo] = splitSceneIntoMultipleSmallerScenes(largeScene,fov);
smallScenes = smallScenes(:);
patchSubplotIdx = reshape(1:patchInfo.hNum*patchInfo.vNum,patchInfo.hNum,patchInfo.vNum).';
axisHandles = zeros(length(smallScenes),1);

%% Do plotting
%
% Size the plot so according to the number of patches we have.
figure('Position',[133 849 patchInfo.hNum*100 patchInfo.vNum*100]);
for jj = 1:length(smallScenes)
    % Get reflectances
    reflectances = sceneGet(smallScenes{jj},'reflectance');
    wave = sceneGet(smallScenes{jj},'wave');
    idx = wave>400 & wave<700;
    reflectances = reflectances(:,:,idx);
    wave = wave(idx);
    
    sizeOfReflectances = size(reflectances);

    % Format data so that the vectors will line up to be the same size. We
    % also want just the mean reflectance.
    stddev = zeros(sizeOfReflectances(3),1);
    meanReflectance = zeros(sizeOfReflectances(3),1);
    for ii = 1:sizeOfReflectances(3)
        stddev(ii) = std2(reflectances(:,:,ii));
        meanReflectance(ii) = mean2(reflectances(:,:,ii));
    end
    
    % Plot
    axisHandles(jj) = subplot(patchInfo.vNum,patchInfo.hNum,patchSubplotIdx(jj)); 
    hold on;
    shadedErrorBar(wave,meanReflectance,stddev,'b');
    axis square;
end

set(axisHandles,'XLim',[min(wave) max(wave)],'YLim',[0 0.5]);
[~,sTitle] = suplabel('Scene Reflectances and 1 std (400-700 nm)','t');
set(sTitle,'FontSize',28);
end


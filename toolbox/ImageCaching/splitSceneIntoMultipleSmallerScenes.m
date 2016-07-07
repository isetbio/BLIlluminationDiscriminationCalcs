function [smallScenes,plotInfo] = splitSceneIntoMultipleSmallerScenes(largeScene,newFOV)
% smallScenes = splitSceneIntoMultipleSmallerScenes(largeScene,newFOV)
%
% The purpose of this function is to divide a large scene into many smaller
% scenes (of equal size). This would allow us to perform calculations on
% the smaller scenes in parallel. Given a large scene and a desired FOV,
% this function will return a cell matrix of the smaller scenes. The scenes
% will be squares since that is what we would like in our project later on.
% The cell matrix will be ordered like a completed puzzle of the original
% scene.
%
% xd  6/30/16  wrote it

%% Check that the newFOV is smaller
if newFOV > sceneGet(largeScene,'fov'), error('FOV too large!'); end;

%% Do the division
% The function sceneCrop does not readjust the FOV of the cropped area. We
% must do so ourselves by setting the cropped scenes' FOV to newFOV.
% Additionally, we calculate the desired rectangle by scaling the full size
% by the ratio of the FOV.
sizeOfLargeScene = sceneGet(largeScene,'size');
largeFOV = sceneGet(largeScene,'fov');
scaleRatio = newFOV / largeFOV;
sizeOfSquare = floor(scaleRatio*sizeOfLargeScene(2));

hNum = floor(sizeOfLargeScene(2)/sizeOfSquare);
vNum = floor(sizeOfLargeScene(1)/sizeOfSquare);

plotInfo.sizeOfSquare = sizeOfSquare;
plotInfo.hNum = hNum;
plotInfo.vNum = vNum;

smallScenes = cell(vNum,hNum);
startY = 0;
for ii = 1:vNum 
    startX = 0;
    for jj = 1:hNum
        cropRect = [startX startY sizeOfSquare-1 sizeOfSquare-1];
        tempScene = sceneCrop(largeScene,cropRect);
        tempScene = sceneSet(tempScene,'fov',newFOV);
        smallScenes{ii,jj} = tempScene;
        startX = startX + sizeOfSquare;
    end
    startY = startY + sizeOfSquare;
end

end


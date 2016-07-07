function showJoinedSmallScenes(largeScene,plotInfo)
% showJoinedSmallScenes(largeScene,plotInfo)
% 
% Displays how the splitting function cuts up a large scene. This function
% takes in the large scene passing to the splitSceneIntoMultipleSmallerScenes
% as well as its second output variable to generate an image of the large
% scene divided as the splitting function does.
%
% xd  7/7/16  wrote it

%% Use the large image and the plot info obj
vcNewGraphWin;

% Pre allocate a larger image that is the size of the original+space for black bars.
sizeOfOriginal = sceneGet(largeScene,'size');
targetImage = zeros([sizeOfOriginal + [plotInfo.vNum plotInfo.hNum] 3]);

% Indexing math to put the image in the right place in our larger image.
targetIdxH = sort(repmat(1:plotInfo.hNum,1,plotInfo.sizeOfSquare)); 
targetIdxH = [targetIdxH repmat(targetIdxH(end)+1,1,sizeOfOriginal(2)-length(targetIdxH))];
targetIdxH = targetIdxH  + (1:sizeOfOriginal(2));

rgbImage = sceneGet(largeScene,'rgb');

targetImage(1:sizeOfOriginal(1),targetIdxH,:) = rgbImage;

% Same thing as above but for rows.
targetIdxV = sort(repmat(1:plotInfo.vNum,1,plotInfo.sizeOfSquare));
targetIdxV = [targetIdxV repmat(targetIdxV(end)+1,1,sizeOfOriginal(1)-length(targetIdxV))];
targetIdxV = targetIdxV + (1:sizeOfOriginal(1));

targetImageT(targetIdxV,:,:) = targetImage(1:sizeOfOriginal(1),:,:);
targetImage = targetImageT; clearvars targetImageT;

% Plot the thing.
image(targetImage);
end


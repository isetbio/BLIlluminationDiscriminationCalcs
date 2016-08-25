function showJoinedSmallScenes(largeScene,fov)
% showJoinedSmallScenes(largeScene,plotInfo)
% 
% Displays how the splitting function cuts up a large scene. This function
% takes in the large scene passing to the splitSceneIntoMultipleSmallerScenes
% as well as its second output variable to generate an image of the large
% scene divided as the splitting function does.
%
% xd  7/7/16  wrote it

%% Use the large image and the plot info obj
[~,plotInfo] = splitSceneIntoMultipleSmallerScenes(largeScene,fov);

% % Pre allocate a larger image that is the size of the original+space for black bars.
% sizeOfOriginal = sceneGet(largeScene,'size');
% targetImage = zeros([sizeOfOriginal + [plotInfo.vNum plotInfo.hNum] 3]);
% 
% % Indexing math to put the image in the right place in our larger image.
% targetIdxH = sort(repmat(1:plotInfo.hNum,1,plotInfo.sizeOfSquare)); 
% targetIdxH = [targetIdxH repmat(targetIdxH(end)+1,1,sizeOfOriginal(2)-length(targetIdxH))];
% targetIdxH = targetIdxH  + (1:sizeOfOriginal(2));
% 
% rgbImage = sceneGet(largeScene,'rgb');
% 
% targetImage(1:sizeOfOriginal(1),targetIdxH,:) = rgbImage;
% 
% % Same thing as above but for rows.
% targetIdxV = sort(repmat(1:plotInfo.vNum,1,plotInfo.sizeOfSquare));
% targetIdxV = [targetIdxV repmat(targetIdxV(end)+1,1,sizeOfOriginal(1)-length(targetIdxV))];
% targetIdxV = targetIdxV + (1:sizeOfOriginal(1));
% 
% targetImageT(targetIdxV,:,:) = targetImage(1:sizeOfOriginal(1),:,:);
% targetImage = targetImageT; clearvars targetImageT;
targetImage = sceneGet(largeScene,'rgb');

% Plot the thing.
figure;
image(targetImage);
set(gcf,'Position',[133 849 size(targetImage,2)*2 size(targetImage,1)*2]);
set(gca,'TickLength',[0 0]);
set(gca,'XTick',[],'YTick',[]);
hold on;

%% Plot lines over the image
%
% The single pixel width blanks in the enlarged image vary with the size of
% the figure apparently. We'll circumvent this issue by drawing some lines
% over them.
vLines = (1:plotInfo.sizeOfSquare:size(targetImage,1));
vLines = vLines(1:plotInfo.vNum+1);% + (1:plotInfo.vNum+1) - 1;
hLines = (1:plotInfo.sizeOfSquare:size(targetImage,2));
hLines = hLines(1:plotInfo.hNum+1);% + (1:plotInfo.hNum+1) - 1;

for ii = 1:length(vLines)
    line([0 hLines(end)],[vLines(ii) vLines(ii)],'linewidth',2,'Color','k');
end

for ii = 1:length(hLines)
    line([hLines(ii) hLines(ii)],[0 vLines(end)],'linewidth',2,'Color','k');
end

%% Make ends of image a different color
%
% Mark the parts of the image that are not used RED. Also mark a target
% patch WHITE.

% line([hLines(16) hLines(17)],[vLines(12) vLines(12)],'linewidth',2,'Color','w');
% line([hLines(16) hLines(17)],[vLines(13) vLines(13)],'linewidth',2,'Color','w');
% line([hLines(16) hLines(16)],[vLines(12) vLines(13)],'linewidth',2,'Color','w');
% line([hLines(17) hLines(17)],[vLines(12) vLines(13)],'linewidth',2,'Color','w');
end


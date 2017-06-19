function showJoinedSmallScenes(largeScene,fov)
% showJoinedSmallScenes(largeScene,fov)
% 
% Displays how the splitting function cuts up a large scene. This function
% takes in the large scene passing to the splitSceneIntoMultipleSmallerScenes
% as well as its second output variable to generate an image of the large
% scene divided as the splitting function does.
%
% 7/7/16  xd  wrote it

%% Use the large image and the plot info obj
%
% Plot the entire image first. Afterwards, we will plot the lines that
% represent the grid which splits the image for the model.
[~,plotInfo] = splitSceneIntoMultipleSmallerScenes(largeScene,fov);
targetImage = sceneGet(largeScene,'rgb');

% Plot the image.
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
vLines = vLines(1:plotInfo.vNum+1);
hLines = (1:plotInfo.sizeOfSquare:size(targetImage,2));
hLines = hLines(1:plotInfo.hNum+1);

for ii = 1:length(vLines)
    line([0 hLines(end)],[vLines(ii) vLines(ii)],'linewidth',2,'Color','k');
end

for ii = 1:length(hLines)
    line([hLines(ii) hLines(ii)],[0 vLines(end)],'linewidth',2,'Color','k');
end

%% Make ends of image a different color
%
% Mark a target patch using WHITE.

% % Block 3
% line([hLines(1) hLines(2)],[vLines(4) vLines(4)],'linewidth',2,'Color','w');
% line([hLines(1) hLines(2)],[vLines(3) vLines(3)],'linewidth',2,'Color','w');
% line([hLines(1) hLines(1)],[vLines(3) vLines(4)],'linewidth',2,'Color','w');
% line([hLines(2) hLines(2)],[vLines(3) vLines(4)],'linewidth',2,'Color','w');
% 
% % Block 162
% line([hLines(11) hLines(12)],[vLines(12) vLines(12)],'linewidth',2,'Color','w');
% line([hLines(11) hLines(12)],[vLines(13) vLines(13)],'linewidth',2,'Color','w');
% line([hLines(11) hLines(11)],[vLines(12) vLines(13)],'linewidth',2,'Color','w');
% line([hLines(12) hLines(12)],[vLines(12) vLines(13)],'linewidth',2,'Color','w');
end


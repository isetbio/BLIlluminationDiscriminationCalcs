close all; clear all;

calcIDStr = {'SystemicPercentTestLowIllum','SystemicPercentTestLowIllum_2',...
    'SystemicPercentTestLongNoRound','SystemicPercentTestNormalDist'};
for jj = 1:length(calcIDStr)
    blueMatrix  = loadChooserData(calcIDStr{jj},['blueIllumComparison' calcIDStr{jj}]);
    greenMatrix = loadChooserData(calcIDStr{jj},['greenIllumComparison' calcIDStr{jj}]);
    redMatrix = loadChooserData(calcIDStr{jj},['redIllumComparison' calcIDStr{jj}]);
    yellowMatrix = loadChooserData(calcIDStr{jj},['yellowIllumComparison' calcIDStr{jj}]);
    
    meanMatrix = zeros(1,4);
    
    meanMatrix(1,1) = mean2(blueMatrix);
    meanMatrix(1,2) = mean2(greenMatrix);
    meanMatrix(1,3) = mean2(redMatrix);
    meanMatrix(1,4) = mean2(yellowMatrix);
    
    printmat(meanMatrix, ['Means of results ' calcIDStr{jj}], 'Mean', 'blue green red yellow');
    
    x = 10:10:300;
    
    figure;
    ylim([0 100]);
    xlabel('k value');
    ylabel('% correct');
    
    title(['average of 1st 10 illum steps from choose model ' calcIDStr{jj}]);
    hold on
    color = {'b.','g.','r.','y.'};
    matrices =  zeros(10,30,4);
    matrices(:,:,1) = blueMatrix;
    matrices(:,:,2) = greenMatrix;
    matrices(:,:,3) = redMatrix;
    matrices(:,:,4) = yellowMatrix;
    
    for ii = 1:4
        plot(x, mean(matrices(:,:,ii)), color{ii}, 'markersize', 30);
    end
end
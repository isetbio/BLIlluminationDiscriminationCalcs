function results = randomSampleOnExistingData(calcIDStr,N)
% results = randomSampleOnExistingData(calcIDStr,N)
% 
% Simulates the classification by using the results from previous runs. For
% each iteration of the loop, we randomly select a patch and then generate
% some random numbers. If the random numbers are less than the percent
% correct for the selected data sample, the trial is marked correct.
%
% 7/21/16  xd  wrote it

analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);

dummyData = loadModelData(calcIDStrList{1});
results = zeros(size(dummyData));

tic
for ii = 1:N
    currentPatchSample = datasample(calcIDStrList,1);
%     disp(currentPatchSample); % For debugging
    currentPatchData = loadModelData(currentPatchSample{1});
    
    RN = 100*rand(size(currentPatchData));
    results = results + (RN < currentPatchData);
end
toc

results = results / N * 100;

end
% Z2 = squeeze(Z(2,:,:,:));
% Zg = multipleThresholdExtraction(Z2,70.9);
% Z2 = squeeze(Z(3,:,:,:));
% Zr = multipleThresholdExtraction(Z2,70.9);
% Z2 = squeeze(Z(4,:,:,:));
% Zy = multipleThresholdExtraction(Z2,70.9);
% hold on;
% plot(0:3:30,Zb,'bo')
% plot(0:3:30,Zr,'ro')
% plot(0:3:30,Zg,'go')
% plot(0:3:30,Zy,'yo')

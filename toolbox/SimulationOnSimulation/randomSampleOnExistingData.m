function results = randomSampleOnExistingData(calcIDStr,N)
% results = randomSampleOnExistingData(calcIDStr,N)
% 
% Simulates the classification by using the results from previous runs. For
% each iteration of the loop, we randomly select a patch and then generate
% some random numbers. If the random numbers are less than the percent
% correct for the selected data sample, the trial is marked correct.
%
% Inputs:
%     calcIDStr  -  shared label for the calculation set
%     N  -  number of iterations
% 
% Outputs:
%     results  -  percent correct performance gathered from the simulation
%
% 7/21/16  xd  wrote it

%% Load paths and setup data
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
calcIDStrList = getAllSubdirectoriesContainingString(fullfile(analysisDir,'SimpleChooserData'),calcIDStr);

% We load dummy data to find out how large the output matrix should be.
dummyData = loadModelData(calcIDStrList{1});
results = zeros(size(dummyData));

%% Loop over simulation
tic
for ii = 1:N
    currentPatchSample = datasample(calcIDStrList,1);
%     disp(currentPatchSample); % For debugging
    currentPatchData = loadModelData(currentPatchSample{1});
    
    % Use RNG to find out whether or not this specific trial "passes" by
    % using the random numbers and comparing against the performance of the
    % SVM.
    RN = 100*rand(size(currentPatchData));
    results = results + (RN < currentPatchData);
end
toc

% Scale results into a percentage
results = results / N * 100;

end

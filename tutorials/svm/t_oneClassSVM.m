%% t_oneClassSVM
%
% Perhaps we can do the same idea of incremental SVM simulation using just
% a 1-class SVM. This would allow us to test both the target and comparison
% light and get a score for each instead of just class labels.
%
% 9/20/16  xd  wrote it

clear; close all;
%%
up = 1;
down = -2;

staircaseStartingPoints = [10 20 30 40] + randi([0 10], [1 4]);
repeats = 4;

numOfFlips = 8;

trainingSetSize = 1000;
% numPCA = 400;

mosaicFOV = 1;
kg = 3;

colors = {'Blue' 'Yellow' 'Green' 'Red'};

%%
mosaic = getDefaultBLIllumDiscrMosaic;
mosaic.fov = mosaicFOV;

%% Load the standards
[standardPhotonPool,calcParams] = calcPhotonsFromOIInStandardSubdir('Neutral_FullImage',mosaic);

%% Generate Data
[trainingData,trainingClasses] = df3_noABBA(calcParams,standardPhotonPool,standardPhotonPool,1,kg,trainingSetSize);
trainingClasses(:) = 1;

%% Train 1-class SVM
tic
theSVM = fitcsvm(trainingData,trainingClasses,'KernelScale','auto','OutlierFraction',0.0,'KernelFunction','gaussian');
toc

%% Simulation
numCorrect = zeros(length(colors),50);
numTrials  = zeros(length(colors),50);
extractedThreshold = zeros(length(colors),repeats,length(staircaseStartingPoints));
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

totalNumTrials = 0;
for runNumber = 1:repeats
    for colorIdx = 1:length(colors)
        colorDir = [colors{colorIdx} 'Illumination'];
        comparisonOIPath = fullfile(analysisDir, 'OpticalImageData', 'Neutral_FullImage', colorDir);
        OINames = getFilenamesInDirectory(comparisonOIPath);
        
        for stairStart = 1:length(staircaseStartingPoints)
            
            % Initialize some variables per run/loop
            illumStep = staircaseStartingPoints(stairStart);
            flips = -1; % Start at -1 since the first trial is guaranteed to 'flip'
            prev = 0;
            curr = 0;

            % Actual Simulation
            tic
            while flips < numOfFlips
                % Probably most time consuming step? Pre-calc and profit?
                comparison = loadOpticalImageData(['Neutral_FullImage' '/' colorDir], strrep(OINames{illumStep}, 'OpticalImage.mat', ''));
                photonComparison = mosaic.compute(comparison,'currentFlag',false);
                
                testingData = df3_noABBA(calcParams,standardPhotonPool,{photonComparison},1,kg,2);
                
                [classi,score] = predict(theSVM,testingData);
                
                % Staircase procedure based on response
                isCorrect = (score>0) == [1; 0];
                if score(1)>score(2)
                    % If correct
                    numCorrect(colorIdx,illumStep) = numCorrect(colorIdx,illumStep) + 1;
                    illumStep = illumStep + down;
                    curr = down;
                else
                    % If incorrect
                    illumStep = illumStep + up;
                    curr = up;
                end

                % Check if we flipped
                if prev ~= curr
                    flips = flips + 1;
                end
                prev = curr;

                % Set min step to 1 and increment flip
                if illumStep < 1
                    illumStep = 1;
                    flips = flips + 1;
                end

                % Keep track of number of trials
                totalNumTrials = totalNumTrials + 1;
                numTrials(colorIdx,illumStep) = numTrials(colorIdx,illumStep) + 1;
            end
            extractedThreshold(colorIdx,runNumber,stairStart) = illumStep;
            
            % Out put finish statement?
            fprintf('Finished a combination of things in %2.2f min!\n',toc/60);
        end
    end
end
%% TODO:
% Comment this function

%% Set some parameters for the calculation
calcParams.meanStandard = 0;
trainingSetSize = 100;
testingSetSize = 100;

sSize = 0.4;

sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, sSize, [], oiCreate('human'));
oi = loadOpticalImageData('NM2/Standard', 'TestImage0');
oi = resizeOI(oi,sSize);
sensorA = coneAbsorptions(sensor, oi);
photons = sensorGet(sensorA, 'photons');

colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Neutral_FullImage'}; %'NM1' 'NM2'};
fileName = {'' 'NM1' 'NM2'};


standardSensorPool = cell(7,1);
for jj = 1:7
    standard = loadOpticalImageData([folders{1} '/Standard'], ['TestImage' num2str(jj - 1)]);
    standardSensorPool{jj} = coneAbsorptions(sensor, resizeOI(standard,sSize));
    calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(standardSensorPool{jj}, 'photons')) / 7;
end

percentCorrect = zeros(50, 10);
for ff = 1:length(folders)
    for cc = 1:length(colors)
        for kk = 1:50
            comparison = loadOpticalImageData([folders{ff} '/' colors{cc} 'Illumination'], [lower(colors{cc}) num2str(kk) fileName{ff} 'L-RGB']);
            sensorComparison = coneAbsorptions(sensor, resizeOI(comparison,sSize));
            for nn = 1:10
                noiseFactor = nn;
                testingNoiseFactor = 0;
                kp = 1;
                
%                 %% Create the training set
%                 % We need more samples than variables in each sample to avoid a singular
%                 % covariance matrix.
%                 trainingData = zeros(trainingSetSize, 2 * length(photons(:)));
% %                 trainingData = zeros(trainingSetSize, length(photons(:)));
%                 trainingClasses = ones(trainingSetSize, 1);
%                 trainingClasses(1:trainingSetSize/2) = 0;
%                 
% 
% 
%                 
%                 tic
%                 for jj = 1:trainingSetSize/2
%                     testSample = randsample(7, 2);
%                     
%                     sensorStandard = standardSensorPool{testSample(1)};
%                     photonsStandard = getNoisySensorImage(calcParams, sensorStandard, noiseFactor, 0);
%                     photonsComparison = getNoisySensorImage(calcParams, sensorComparison, noiseFactor, 0);
%                     
%                     trainingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
%                     
%                     sensorStandard = standardSensorPool{testSample(2)};
%                     photonsStandard = getNoisySensorImage(calcParams, sensorStandard, noiseFactor, 0);
%                     photonsComparison = getNoisySensorImage(calcParams, sensorComparison, noiseFactor, 0);
%                     
%                     trainingData(jj + trainingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
%                 end
%                 toc
%                 
%                 %% Train the discriminant
%                 tic
%                 classifier = fitcdiscr(trainingData, trainingClasses, 'DiscrimType', 'pseudoquadratic');
% % classifier = fitcsvm(trainingData, trainingClasses);
%                 toc
%                 
%                 %% Test the disriminant
%                 testingData = zeros(testingSetSize, 2 * length(photons(:)));
% %                 testingData = zeros(testingSetSize, length(photons(:)));
%                 testingClasses = ones(testingSetSize, 1);
%                 testingClasses(1:testingSetSize/2) = 0;
%                 
%                 for jj = 1:testingSetSize/2
%                     testSample = randsample(7, 2);
%                     
%                     sensorStandard = standardSensorPool{testSample(1)};
%                     photonsStandard = getNoisySensorImage(calcParams, sensorStandard, testingNoiseFactor, 0);
%                     photonsComparison = getNoisySensorImage(calcParams, sensorComparison, testingNoiseFactor, 0);
%                     
%                     testingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
%                     
%                     sensorStandard = standardSensorPool{testSample(2)};
%                     photonsStandard = getNoisySensorImage(calcParams, sensorStandard, testingNoiseFactor, 0);
%                     photonsComparison = getNoisySensorImage(calcParams, sensorComparison, testingNoiseFactor, 0);
%                     
%                     testingData(jj + testingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
%                 end
%                 
%                 classifiedClasses = predict(classifier, testingData);
%                 percentCorrect(kk, nn) = sum(classifiedClasses == testingClasses) / testingSetSize * 100;
                
                %% Distance based classification
                correct = 0;
                tic
                for tt = 1:testingSetSize
                    standardChoice = randsample(7,2);
          
                    photonsSR = getNoisySensorImage(calcParams, standardSensorPool{standardChoice(1)}, kp, noiseFactor);
                    photonsSC = getNoisySensorImage(calcParams, standardSensorPool{standardChoice(2)}, kp, noiseFactor);
                    photonsTC = getNoisySensorImage(calcParams, sensorComparison, kp, noiseFactor);
                    
                    distToS = norm(photonsSR(:) - photonsSC(:));
                    distToT = norm(photonsSR(:) - photonsTC(:));
                    
                    if distToS < distToT
                        correct = correct + 1;
                    end
                end
                toc
                percentCorrect(kk, nn) = correct / testingSetSize * 100;
            end
        end
        save([lower(colors{cc}) '_' folders{ff}], 'percentCorrect');
    end
end
%%
plotColors = {'b.-' 'g.-' 'y.-' 'r.-'};
Colors = {'blue' 'green' 'yellow' 'red'};
Bg = {'Neutral_FullImage'};
numTrials = 1000;
paramsFree = [1,1,0,0];
criterion = 0.709;
stimLevels = 1:1:50;
outOfNum = repmat(1000, 1, 50);
numKValue = 10;
paramsValueEst = [10 1 0.5 0];
PF = @PAL_Weibull;

options = optimset('fminsearch');
options.TolFun = 1e-09;
options.MaxFunEvals = 10000 * 100;
options.MaxIter = 500*100;

for kk = 1:length(Bg)
    figure;
    title(Bg{kk});
    for ii = 1:length(Colors)
        threshold = zeros(numKValue, 1);
        paramsValues = zeros(numKValue, 4);
        data = load([Colors{ii} '_' Bg{kk}]);
        data = data.percentCorrect;
        data = data / 100 * numTrials;
        for jj = 1:numKValue
            [paramsValues(jj,:)] = PAL_PFML_Fit(stimLevels', data(:,jj), outOfNum',  paramsValueEst, paramsFree, PF, 'SearchOptions', options);
            threshold(jj) = PF(paramsValues(jj,:), criterion, 'inverse');
        end
        hold on;
        plot(1:10, threshold, plotColors{ii}, 'markersize', 35);
    end
end
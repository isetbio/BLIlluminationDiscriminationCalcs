%% Set some parameters for the calculation
calcParams.meanStandard = 0;
trainingSetSize = 500;
testingSetSize = 500;

sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, 0.07, [], oiCreate('human'));
em = emCreate;
em = emSet(em, 'sample time', 0.001);
sensor = sensorSet(sensor, 'eye move', em);
sensor = sensorSet(sensor, 'integration time', 0.001);
sensor = sensorSet(sensor, 'positions', zeros(50, 2));

oi = loadOpticalImageData('NM2/Standard', 'TestImage0');


% colors = {'Blue' 'Yellow' 'Red' 'Green'};
colors = {'Red' 'Green'};
folders = {'Neutral'};% 'NM1' 'NM2'};
fileName = {'' 'NM1' 'NM2'};

%% Pre generate some paths
pathPool = getEMPaths(sensor, 1000);
pathSize = size(pathPool);
maxEM = max(pathPool);
maxEM = reshape(maxEM, pathSize(2:3))';
minEM = min(pathPool);
minEM = reshape(minEM, pathSize(2:3))';
LMSpath = [maxEM; minEM];
rows = round([-min([LMSpath(:,2); 0]) max([LMSpath(:,2); 0])]);
cols = round([max([LMSpath(:,1); 0]) -min([LMSpath(:,1); 0])]);
rows = [max(rows) max(rows)];
cols = [max(cols) max(cols)];

sensorA = sensorSet(sensor, 'positions', pathPool(:,:,1));
sensorA = coneAbsorptions(sensorA, oi);
photons = sensorGet(sensorA, 'photons');
photons = sum(photons, 3);

%% Do calculation
percentCorrect = zeros(50, 10);
for ff = 1:length(folders)
    for cc = 1:length(colors)
        for kk = 1:50
            for nn = 1:10
                noiseFactor = nn;
                testingNoiseFactor = nn;

                %% Create the training set
                % We need more samples than variables in each sample to avoid a singular
                % covariance matrix.
                trainingData = zeros(trainingSetSize, 2 * length(photons(:)));
                trainingClasses = ones(trainingSetSize, 1);
                trainingClasses(1:trainingSetSize/2) = 0;
                
                comparison = loadOpticalImageData([folders{ff} '/' colors{cc} 'Illumination'], [lower(colors{cc}) num2str(kk) fileName{ff} 'L-RGB']);
                standardSensorPool = cell(7,2);
                for jj = 1:7
                    standard = loadOpticalImageData([folders{ff} '/Standard'], ['TestImage' num2str(jj - 1)]);
                    sensorTemp = sensorSet(sensor, 'positions', LMSpath);
                    [standardSensorPool{jj, 1}, standardSensorPool{jj, 2}] = coneAbsorptionsLMS(sensorTemp, standard);
                end
                
                [testLMS, testMSK] = coneAbsorptionsLMS(sensorTemp, comparison);
                
                tic
                for jj = 1:trainingSetSize/2
                    
                    testSample = randsample(7, 2);
                    thePath = pathPool(:,:,randsample(1000,1));
                    theSensor = sensorSet(sensor, 'positions', thePath);
                    
                    sensorStandard = coneAbsorptionsApplyPath(theSensor, standardSensorPool{testSample(1),1}, standardSensorPool{testSample(1),2}, rows, cols);
                    sensorComparison = coneAbsorptionsApplyPath(theSensor, testLMS, testMSK, rows, cols);    
                    
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, noiseFactor, 0);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, noiseFactor, 0);
                    
                    sensorStandard = sensorSet(sensorStandard, 'photons', photonsStandard);
                    sensorComparison = sensorSet(sensorComparison, 'photons', photonsComparison);
                    
%                     [~,photonsStandard] = coneAdapt(sensorStandard, 4);
%                     [~,photonsComparison] = coneAdapt(sensorComparison, 4);
                    
                    photonsStandard = sum(photonsStandard, 3);
                    photonsComparison = sum(photonsComparison, 3);
                    
                    trainingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
                    
                    thePath = pathPool(:,:,randsample(1000,1));
                    theSensor = sensorSet(sensor, 'positions', thePath);
                    
                    sensorStandard = coneAbsorptionsApplyPath(theSensor, standardSensorPool{testSample(2),1}, standardSensorPool{testSample(2),2}, rows, cols);
                    sensorComparison = coneAbsorptionsApplyPath(theSensor, testLMS, testMSK, rows, cols);
                    
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, noiseFactor, 0);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, noiseFactor, 0);

                    sensorStandard = sensorSet(sensorStandard, 'photons', photonsStandard);
                    sensorComparison = sensorSet(sensorComparison, 'photons', photonsComparison);
                    
%                     [~,photonsStandard] = coneAdapt(sensorStandard, 4);
%                     [~,photonsComparison] = coneAdapt(sensorComparison, 4);
                    
                    photonsStandard = sum(photonsStandard, 3);
                    photonsComparison = sum(photonsComparison, 3);
                    
                    trainingData(jj + trainingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
                end
                toc
                
                %% Train the discriminant
                tic
                classifier = fitcdiscr(trainingData, trainingClasses, 'DiscrimType', 'quadratic');
% classifier = fitcsvm(trainingData, trainingClasses);
                toc
                
                %% Test the disriminant
                testingData = zeros(testingSetSize, 2 * length(photons(:)));
                testingClasses = ones(testingSetSize, 1);
                testingClasses(1:testingSetSize/2) = 0;
                
                for jj = 1:testingSetSize/2
                    testSample = randsample(7, 2);
                    
                    theSensor = sensorSet(sensor, 'positions', thePath);
                    
                    sensorStandard = coneAbsorptionsApplyPath(theSensor, standardSensorPool{testSample(1),1}, standardSensorPool{testSample(1),2}, rows, cols);
                    sensorComparison = coneAbsorptionsApplyPath(theSensor, testLMS, testMSK, rows, cols);
                   
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, testingNoiseFactor, 0);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, testingNoiseFactor, 0);
                    
                    sensorStandard = sensorSet(sensorStandard, 'photons', photonsStandard);
                    sensorComparison = sensorSet(sensorComparison, 'photons', photonsComparison);
                    
%                     [~,photonsStandard] = coneAdapt(sensorStandard, 4);
%                     [~,photonsComparison] = coneAdapt(sensorComparison, 4);
                    
                    photonsStandard = sum(photonsStandard, 3);
                    photonsComparison = sum(photonsComparison, 3);
                    
                    testingData(jj,:) = [photonsStandard(:); photonsComparison(:)]';
                    
                    sensorStandard = coneAbsorptionsApplyPath(theSensor, standardSensorPool{testSample(2),1}, standardSensorPool{testSample(2),2}, rows, cols);
                    sensorComparison = coneAbsorptionsApplyPath(theSensor, testLMS, testMSK, rows, cols);
                   
                    photonsStandard = getNoisySensorImage(calcParams, sensorStandard, testingNoiseFactor, 0);
                    photonsComparison = getNoisySensorImage(calcParams, sensorComparison, testingNoiseFactor, 0);
                    
                    sensorStandard = sensorSet(sensorStandard, 'photons', photonsStandard);
                    sensorComparison = sensorSet(sensorComparison, 'photons', photonsComparison);
                    
%                     [~,photonsStandard] = coneAdapt(sensorStandard, 4);
%                     [~,photonsComparison] = coneAdapt(sensorComparison, 4);
                    
                    photonsStandard = sum(photonsStandard, 3);
                    photonsComparison = sum(photonsComparison, 3);
                    
                    testingData(jj + testingSetSize/2,:) = [photonsComparison(:); photonsStandard(:)]';
                end
                
                classifiedClasses = predict(classifier, testingData);
                percentCorrect(kk, nn) = sum(classifiedClasses == testingClasses) / testingSetSize * 100;
                
                % Distance based classification
%                 correct = 0;
%                 tic
%                 for tt = 1:testingSetSize
%                     standardChoice = randsample(7,2);
%                     calcParams.meanStandard = 0;
%                     photonsSR = getNoisySensorImage(calcParams, standardSensorPool{standardChoice(1)}, noiseFactor, 0);
%                     photonsSC = getNoisySensorImage(calcParams, standardSensorPool{standardChoice(2)}, noiseFactor, 0);
%                     photonsTC = getNoisySensorImage(calcParams, sensorComparison, noiseFactor, 0);
%                     
%                     distToS = norm(photonsSR(:) - photonsSC(:));
%                     distToT = norm(photonsSR(:) - photonsTC(:));
%                     
%                     if distToS < distToT
%                         correct = correct + 1;
%                     end
%                 end
%                 toc
%                 percentCorrect(kk, nn) = correct / testingSetSize * 100;
            end
        end
        save([lower(colors{cc}) '_' folders{ff}], 'percentCorrect');
    end
end
%% Load maybe all the standard target OI's?
targetOI = cell(7,1);
for ii = 1:7
    targetOI{ii} = loadOpticalImageData('Neutral_FullImage/Standard', ['TestImage' num2str(ii-1)]);
    targetOI{ii} = resizeOI(targetOI{ii}, 1);
end

%% Do some sensor math?
calcParams.meanStandard = 0;

basicSensor = getDefaultBLIllumDiscrSensor; 
basicSensor = sensorSetSizeToFOV(basicSensor, 1, [], oiCreate('human'));

targetSensors = cell(7,1);
for ii = 1:7
    targetSensors{ii} = coneAbsorptions(basicSensor, targetOI{ii});
    calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(targetSensors{ii},'photons'))/7;
end

%% Load test OI's and sensors
colors = {'Green' 'Red' 'Blue' 'Yellow'};
testSensors = cell(4,1);

for ii = 1:4
    testOI = loadOpticalImageData(['Neutral_FullImage/' colors{ii} 'Illumination'], [lower(colors{ii}) '1L-RGB']);
    testOI = resizeOI(testOI, 1);
    
    testSensors{ii} = coneAbsorptions(basicSensor, testOI);
end

%% Get some distributions
distSize = 2500;
kp = 1;
kg = 0;
for ff = 1:4
    
    targetDist = zeros(distSize,1);
    testDist = zeros(distSize,1);
    
    for ii = 1:distSize
        s = randsample(7,1);
        targetDist(ii) = mean2(getNoisySensorImage(calcParams, targetSensors{s},kp,kg));
        testDist(ii) = mean2(getNoisySensorImage(calcParams, testSensors{ff},kp,kg));
        if mod(ii, 100) == 0
            disp([num2str(ii/distSize * 100) '% done']);
        end
    end
    
    %% Plot
    delete(subplot(2,2,ff));
    subplot(2,2,ff);
    hold on;
    histogram(targetDist); histogram(testDist);
    legend({'Target', 'Test'});
    axis square
    title([colors{ff} ' Illum']);
    xlabel('Mean photons');
    ylabel('Number of occurences');
end
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
coneDist = sensorGet(basicSensor, 'cfa');
coneDist = coneDist.pattern;

targetSensors = cell(7,1);
for ii = 1:7
    targetSensors{ii} = coneAbsorptions(basicSensor, targetOI{ii});
    calcParams.meanStandard = calcParams.meanStandard + mean2(sensorGet(targetSensors{ii},'photons'))/7;
end

%% Load test OI's and sensors
colors = {'Green' 'Red' 'Blue' 'Yellow'};
testSensors = cell(4,1);

for ii = 1:4
    testOI = loadOpticalImageData(['Neutral_FullImage/' colors{ii} 'Illumination'], [lower(colors{ii}) '10L-RGB']);
    testOI = resizeOI(testOI, 1);
    
    testSensors{ii} = coneAbsorptions(basicSensor, testOI);
end

%% Get some distributions
distSize = 500;
kp = 1;
kg = 0;

cones = {'L' 'M' 'S'};
xlimits = [1010,1018;760,770;70,75];
for ff = 1:4
        targetDist = zeros(distSize,3);
        testDist = zeros(distSize,3);
        
        for ii = 1:distSize
            s = randsample(7,1);
            targetAbsorptions = getNoisySensorImage(calcParams, targetSensors{s},kp,kg);
            testAbsorptions = getNoisySensorImage(calcParams, testSensors{ff},kp,kg);
            
            for jj = 1:3
                targetDist(ii,jj) = mean2(targetAbsorptions(coneDist == (jj+1)));
                testDist(ii,jj) = mean2(testAbsorptions(coneDist == (jj+1)));
            end
            if mod(ii, 100) == 0
                disp([num2str(ii/distSize * 100) '% done']);
            end
        end
        
        %% Plot
        for cc = 1:3
            plotLoc = 1 + (cc-1)*4 + (ff-1);
            delete(subplot(3,4,plotLoc));
            subplot(3,4,plotLoc);
            hold on;
            histogram(targetDist(:,cc)); histogram(testDist(:,cc));
            legend({'Target', 'Test'});
            axis square
            title([colors{ff} ' Illum ' cones{cc} ' Cones']);
            xlabel('Mean photons');
            ylabel('Number of occurences');
%             xlim(xlimits(cc,:));
%             ylim([0 0.25*distSize]);
        end
end
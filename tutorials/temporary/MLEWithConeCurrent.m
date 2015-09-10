%% Set some parameters for the calculation
calcParams.meanStandard = 0;
trainingSetSize = 5000;
testingSetSize = 1000;

sensor = getDefaultBLIllumDiscrSensor;
sensor = sensorSetSizeToFOV(sensor, 0.20, [], oiCreate('human'));
oi = loadOpticalImageData('NM2/Standard', 'TestImage0');
sensorA = coneAbsorptions(sensor, oi);
photons = sensorGet(sensorA, 'photons');

colors = {'Blue' 'Yellow' 'Red' 'Green'};
folders = {'Neutral' 'NM1' 'NM2'};
fileName = {'' 'NM1' 'NM2'};


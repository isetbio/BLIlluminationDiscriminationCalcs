%  9/10/15  xd  wrote it

%% Initialize ISETBIO
clear; close all; ieInit; 
rng(1);

%% Load files and convert PTB cal file to ISETBIO format
dataAndCal = load('HorwitzAnalysisRaw');
Cal = dataAndCal.cal;
Images = dataAndCal.im;
Images{1} = Images{1} / (2^16-1);  % Scale to 0-1
Images{2} = Images{2} / (2^16-1);

extraData = ptb.ExtraCalData;
extraData.distance = 1.0;
extraData.subSamplingSvector = [380 1 401];

% Set the size of the display manually
Cal.describe.displayDescription.screenSizePixel = [1024 768];
Cal.describe.displayDescription.screenSizeMM = [350 260];

HorwitzDisplay = ptb.GenerateIsetbioDisplayObjectFromPTBCalStruct('HorwitzDisplay', Cal, extraData, false);

%% Get the two scenes
scene1  = sceneFromFile(Images{1}, 'rgb', [], HorwitzDisplay);
scene2  = sceneFromFile(Images{2}, 'rgb', [], HorwitzDisplay);

%% Compute OI without human optics
oi = oiCreate;
oi1  = oiCompute(scene1, oi);
oi2  = oiCompute(scene2, oi);

%% Create sensors with only L,M,or S cones
sensorBase = sensorCreate('human');
sensorBase = sensorSet(sensorBase, 'noise flag', 0);
sensorBase = sensorSet(sensorBase, 'integration time', 0.100);   % Total photon integration time
sensorBase = sensorSet(sensorBase, 'wavelength', sceneGet(scene1, 'wavelength'));
sensorBase = sensorSet(sensorBase, 'rSeed', 1);          % Ensures identical cone mosaic distributions
sensorBase  = sensorSetSizeToFOV(sensorBase, sceneGet(scene1, 'fov'), scene1, oi1);

size = sensorGet(sensorBase, 'size');

sensorL = sensorSet(sensorBase, 'conetype', repmat(2, size));
sensorM = sensorSet(sensorBase, 'conetype', repmat(3, size));
sensorS = sensorSet(sensorBase, 'conetype', repmat(4, size));

%% Compute cone responses in each sensor
sensorL1 = coneAbsorptions(sensorL, oi1);
sensorL2 = coneAbsorptions(sensorL, oi2);

sensorM1 = coneAbsorptions(sensorM, oi1);
sensorM2 = coneAbsorptions(sensorM, oi2);

sensorS1 = coneAbsorptions(sensorS, oi1);
sensorS2 = coneAbsorptions(sensorS, oi2);

%% Plot absorptions
% L cones
row = round(size(1)/2);
photonsL1 = sensorGet(sensorL1, 'photons');
photonsL2 = sensorGet(sensorL2, 'photons');

plot(1:size(2), photonsL1(row,:),'b');
hold on;
plot(1:size(2), photonsL2(row,:),'r');

% M cones
photonsM1 = sensorGet(sensorM1, 'photons');
photonsM2 = sensorGet(sensorM2, 'photons');

figure;
plot(1:size(2), photonsM1(row,:),'b');
hold on;
plot(1:size(2), photonsM2(row,:),'r');

% S cones
photonsS1 = sensorGet(sensorS1, 'photons');
photonsS2 = sensorGet(sensorS2, 'photons');

figure;
plot(1:size(2), photonsS1(row,:),'b');
hold on;
plot(1:size(2), photonsS2(row,:),'r');

%% Compute OI with human optics
oi = oiCreate('human');
oi1  = oiCompute(scene1, oi);
oi2  = oiCompute(scene2, oi);

%% Create sensors with only L,M,or S cones
sensorBase = sensorCreate('human');
sensorBase = sensorSet(sensorBase, 'noise flag', 0);
sensorBase = sensorSet(sensorBase, 'integration time', 0.100);   % Total photon integration time
sensorBase = sensorSet(sensorBase, 'wavelength', sceneGet(scene1, 'wavelength'));
sensorBase = sensorSet(sensorBase, 'rSeed', 1);          % Ensures identical cone mosaic distributions
sensorBase  = sensorSetSizeToFOV(sensorBase, sceneGet(scene1, 'fov'), scene1, oi1);

size = sensorGet(sensorBase, 'size');

sensorL = sensorSet(sensorBase, 'conetype', repmat(2, size));
sensorM = sensorSet(sensorBase, 'conetype', repmat(3, size));
sensorS = sensorSet(sensorBase, 'conetype', repmat(4, size));

%% Compute cone responses in each sensor
sensorL1 = coneAbsorptions(sensorL, oi1);
sensorL2 = coneAbsorptions(sensorL, oi2);

sensorM1 = coneAbsorptions(sensorM, oi1);
sensorM2 = coneAbsorptions(sensorM, oi2);

sensorS1 = coneAbsorptions(sensorS, oi1);
sensorS2 = coneAbsorptions(sensorS, oi2);

%% Plot absorptions
% L cones
row = round(size(1)/2);
photonsL1 = sensorGet(sensorL1, 'photons');
photonsL2 = sensorGet(sensorL2, 'photons');

figure;
plot(1:size(2), photonsL1(row,:),'b');
hold on;
plot(1:size(2), photonsL2(row,:),'r');

% M cones
photonsM1 = sensorGet(sensorM1, 'photons');
photonsM2 = sensorGet(sensorM2, 'photons');

figure;
plot(1:size(2), photonsM1(row,:),'b');
hold on;
plot(1:size(2), photonsM2(row,:),'r');

% S cones
photonsS1 = sensorGet(sensorS1, 'photons');
photonsS2 = sensorGet(sensorS2, 'photons');

figure;
plot(1:size(2), photonsS1(row,:),'b');
hold on;
plot(1:size(2), photonsS2(row,:),'r');
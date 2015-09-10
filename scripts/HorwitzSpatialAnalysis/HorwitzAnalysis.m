% 8/27/15  xd  wrote it

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
%HorwitzDisplay = displaySet(HorwitzDisplay, 'gamma', 'linear');  % Comment this out if using raw RGB

%% Create scenes from the two images and the background image
% Create the background image
backgroundRGB = repmat(reshape(Cal.bgColor,1,1,3),124,124);

scene1  = sceneFromFile(Images{1}, 'rgb', [], HorwitzDisplay);
scene2  = sceneFromFile(Images{2}, 'rgb', [], HorwitzDisplay);
sceneBg = sceneFromFile(backgroundRGB, 'rgb', [], HorwitzDisplay);

%% Compute OI
oi = oiCreate('human');
oi1  = oiCompute(scene1, oi);
oi2  = oiCompute(scene2, oi);
oiBg = oiCompute(sceneBg, oi);

%% Compute sensor absorptions
sensor = sensorCreate('human');
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'integration time', 0.100);   % Total photon integration time
sensor = sensorSet(sensor, 'wavelength', sceneGet(scene1, 'wavelength'));
sensor = sensorSet(sensor, 'rSeed', 1);          % Ensures identical cone mosaic distributions

% Adjust the sensor FOV to match the scene FOV
sensor1  = sensorSetSizeToFOV(sensor, sceneGet(scene1, 'fov'), scene1, oi1);
sensor2  = sensorSetSizeToFOV(sensor, sceneGet(scene2, 'fov'), scene2, oi2);
sensorBg = sensorSetSizeToFOV(sensor, sceneGet(sceneBg, 'fov'), sceneBg, oiBg);

% Calculate absorptions
sensor1  = coneAbsorptions(sensor1, oi1);
sensor2  = coneAbsorptions(sensor2, oi2);
sensorBg = coneAbsorptions(sensorBg, oiBg);

%% Get photons and calculate contrast
photons1  = sensorGet(sensor1, 'photons');
photons2  = sensorGet(sensor2, 'photons');
photonsBg = sensorGet(sensorBg, 'photons');

photons1 = (photons1 - photonsBg) ./ photonsBg;
photons2 = (photons2 - photonsBg) ./ photonsBg;

contrast1 = sqrt(sum(photons1(:) .^ 2));
contrast2 = sqrt(sum(photons2(:) .^ 2));

pImage1 = photons1 - min(photons1(:));
pImage2 = photons2 - min(photons2(:));

figure;
imshow(pImage1/max(pImage1(:)));
title('Contrast for Image 1', 'FontSize', 15);
figure;
imshow(pImage2/max(pImage2(:)));
title('Contrast for Image 2', 'FontSize', 15);

pImage1 = photons1;
pImage1(pImage1 < 0) = 0;
figure;
imshow(pImage1/max(pImage1(:)));
title('Contrast for Image 1 No Negatives', 'FontSize', 15);

pImage2 = photons2;
pImage2(pImage2 < 0) = 0;
figure;
imshow(pImage2/max(pImage2(:)));
title('Contrast for Image 2 No Negatives', 'FontSize', 15);

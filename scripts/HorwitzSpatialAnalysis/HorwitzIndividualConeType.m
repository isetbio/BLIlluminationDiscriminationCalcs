%  9/10/15  xd  wrote it

%% Initialize ISETBIO
clear; close all; ieInit; 
rng(1);

%% Load files and convert PTB cal file to ISETBIO format
dataAndCal = load('HorwitzAnalysisNominal');
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

backgroundRGB = repmat(reshape(Cal.bgColor,1,1,3),124,124);
sceneBg = sceneFromFile(backgroundRGB, 'rgb', [], HorwitzDisplay);

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


%% Compute OI with human optics
oiH = oiCreate('human');
oi1H  = oiCompute(scene1, oiH);
oi2H  = oiCompute(scene2, oiH);

%% Create sensors with only L,M,or S cones
sensorBaseH = sensorCreate('human');
sensorBaseH = sensorSet(sensorBaseH, 'noise flag', 0);
sensorBaseH = sensorSet(sensorBaseH, 'integration time', 0.100);   % Total photon integration time
sensorBaseH = sensorSet(sensorBaseH, 'wavelength', sceneGet(scene1, 'wavelength'));
sensorBaseH = sensorSet(sensorBaseH, 'rSeed', 1);          % Ensures identical cone mosaic distributions
sensorBaseH  = sensorSetSizeToFOV(sensorBaseH, sceneGet(scene1, 'fov'), scene1, oi1H);

sizeH = sensorGet(sensorBaseH, 'size');

sensorLH = sensorSet(sensorBaseH, 'conetype', repmat(2, sizeH));
sensorMH = sensorSet(sensorBaseH, 'conetype', repmat(3, sizeH));
sensorSH = sensorSet(sensorBaseH, 'conetype', repmat(4, sizeH));

%% Compute cone responses in each sensor
sensorL1H = coneAbsorptions(sensorLH, oi1H);
sensorL2H = coneAbsorptions(sensorLH, oi2H);

sensorM1H = coneAbsorptions(sensorMH, oi1H);
sensorM2H = coneAbsorptions(sensorMH, oi2H);

sensorS1H = coneAbsorptions(sensorSH, oi1H);
sensorS2H = coneAbsorptions(sensorSH, oi2H);

%% Plot absorptions
% L cones
row = round(size(1)/2);
photonsL1 = sensorGet(sensorL1, 'photons');
photonsL2 = sensorGet(sensorL2, 'photons');

subplot(3,2,1);
plot(1:size(2), photonsL1(row,:),'b');
% plot(1:size(2), mean(photonsL1),'b');
hold on;
plot(1:size(2), photonsL2(row,:),'r');
% plot(1:size(2), mean(photonsL2),'r');
title('L cones no human optics', 'FontSize', 20);

% M cones
photonsM1 = sensorGet(sensorM1, 'photons');
photonsM2 = sensorGet(sensorM2, 'photons');

subplot(3,2,3);
plot(1:size(2), photonsM1(row,:),'b');
hold on;
plot(1:size(2), photonsM2(row,:),'r');
title('M cones no human optics', 'FontSize', 20);

% S cones
photonsS1 = sensorGet(sensorS1, 'photons');
photonsS2 = sensorGet(sensorS2, 'photons');

subplot(3,2,5);
plot(1:size(2), photonsS1(row,:),'b');
hold on;
plot(1:size(2), photonsS2(row,:),'r');
title('S cones no human optics', 'FontSize', 20);

%% Plot absorptions with human
% L cones
row = round(sizeH(1)/2);
photonsL1H = sensorGet(sensorL1H, 'photons');
photonsL2H = sensorGet(sensorL2H, 'photons');

subplot(3,2,2);
plot(1:sizeH(2), photonsL1H(row,:),'b');
% plot(1:sizeH(2), mean(photonsL1H),'b');
hold on;
plot(1:sizeH(2), photonsL2H(row,:),'r');
% plot(1:sizeH(2), mean(photonsL2H),'r');
title('L cones human optics', 'FontSize', 20);

% M cones
photonsM1H = sensorGet(sensorM1H, 'photons');
photonsM2H = sensorGet(sensorM2H, 'photons');

subplot(3,2,4);
plot(1:sizeH(2), photonsM1H(row,:),'b');
hold on;
plot(1:sizeH(2), photonsM2H(row,:),'r');
title('M cones human optics', 'FontSize', 20);

% S cones
photonsS1H = sensorGet(sensorS1H, 'photons');
photonsS2H = sensorGet(sensorS2H, 'photons');

subplot(3,2,6);
plot(1:sizeH(2), photonsS1H(row,:),'b');
hold on;
plot(1:sizeH(2), photonsS2H(row,:),'r');
title('S cones human optics', 'FontSize', 20);

% %% Compute background contrast
% oiBg = oiCompute(sceneBg, oi);
% oiBgH = oiCompute(sceneBg, oiH);
% 
% sensorBg = coneAbsorptions(sensorBase, oiBg);
% sensorBgH = coneAbsorptions(sensorBaseH, oiBgH);
% 
% photonsBg = sensorGet(sensorBg, 'photons');
% photonsBgH = sensorGet(sensorBgH, 'photons');
% 
% SDiff1 = (photonsS1 - photonsBg) ./ photonsBg;
% SDiff2 = (photonsS2 - photonsBg) ./ photonsBg;
% 
% SContrast1 = sqrt(sum(SDiff1(:) .^ 2));
% SContrast2 = sqrt(sum(SDiff2(:) .^ 2));
% 
% SDiff1H = (photonsS1H - photonsBgH) ./ photonsBgH;
% SDiff2H = (photonsS2H - photonsBgH) ./ photonsBgH;
% 
% SDiff1H = SDiff1H / 4;
% SDiff2H = SDiff2H / 4;
% 
% SContrast1H = sqrt(sum(SDiff1H(:) .^ 2));
% SContrast2H = sqrt(sum(SDiff2H(:) .^ 2));
function photons = getNoisySensorImage(calcParams, folderName, imageName, sensor, k)
%getNoisySensorImage(calcParams, folderName, imageName, sensor, k)
% Generate a single noisy sensor image of the input optical image location
% using the given input sensor
%
% Inputs:
%   calcParams - These parameters contains options defining whether or not
%                to use cone adaptation.
%   folderName - The folder in which the optical image resides.
%   imageName  - The name of original image used to make optical image.
%   sensor     - The sensor to use to calculate sensor image.
%   k          - The k-value of noise desired in this image.
%
% Outputs:
%   photons - the photon data from the generated sensor image.
%
% 3/18/2015   xd  wrote it
% 4/17/2015   xd  updated to use the human sensor
% 5/18/2015   xd  changed to use photon data instead of volt data

%% Load the optical image associated with the folder name and image name
oi = loadOpticalImageData(folderName, imageName);

%% Get a noise free version of the image
sensorNF = sensorSet(sensor, 'noise flag', 0);
sensorNF = coneAbsorptions(sensorNF, oi);
noiseFree = sensorGet(sensorNF, 'photons');

%% Use a default k-value of 1
if (nargin < 5)
    k = 1;
end

%% Calculate noisy sample

% OLD CODE: Get a noisy sensor image
% sensorR = coneAbsorptions(sensor, oi);
% 
% if (calcParams.coneAdaptEnable)
%     [~, noisySample] = coneAdapt(sensorR, calcParams.coneAdaptType);
%     
%     % Data from coneAdapt is in volts, must be converted to photons
%     % This code is taken from sensorGet('photons')
%     pixel = sensorGet(sensorR,'pixel');
%     noisySample = noisySample/pixelGet(pixel,'conversionGain');
%     noisySample = round(noisySample);
% else
%     noisySample = sensorGet(sensorR, 'photons');
% end
% 
% % Find the noise
% diff = noisySample - noiseFree;

% Get poisson noise, this is in photons
[~, noise] = noiseShot(sensorNF);

% Add noise back with k multiplier
photons = noiseFree + noise * k;

end


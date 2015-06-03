function photons = getNoisySensorImage(calcParams, sensor, k)
%getNoisySensorImage(calcParams, folderName, imageName, sensor, k)
% Generate a single noisy sensor image of the input optical image location
% using the given input sensor
%
% Inputs:
%   calcParams - These parameters contains options defining whether or not
%                to use cone adaptation.
%   sensor     - A sensor which already contains a noise free sensor image.
%                This sensor image will be used to compute a noisy image
%                with the desired k-value.
%   k          - The k-value of noise desired in this image.
%
% Outputs:
%   photons - the photon data from the generated sensor image.
%
% 3/18/2015   xd  wrote it
% 4/17/2015   xd  updated to use the human sensor
% 5/18/2015   xd  changed to use photon data instead of volt data
% 6/3/15      xd  now requires a precomputed noise free image

%% Use a default k-value of 1
if (nargin < 2)
    k = 1;
end

%% Calculate noisy sample

noiseFree = sensorGet(sensor, 'photons');

% Get poisson noise, this is in photons

% [~, noise] = noiseShot(sensor);

% Temporarily use poissonrnd while fixing noiseShot
noisyImage = poissrnd(noiseFree);
noise = noisyImage - noiseFree;

% Add noise back with k multiplier
photons = noiseFree + noise * k;

% Photons are whole numbers
photons = round(photons);

end


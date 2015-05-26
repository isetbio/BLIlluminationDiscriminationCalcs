function photons = getNoisySensorImage(calcParams, folderName, imageName, sensor, k)
%getNoisySensorImage(folderName, imageName, sensor, N, k)
%   Generate a single noisy sensor image of the input optical image location
%   using the given input sensor
%
%   Inputs:
%   folderName - folder in which the optical image resides
%   imageName - name of original image used to make optical image
%   sensor - sensor to use to calculate sensor image
%   N - number of samples desired 
%   k - k-value of noise
%   
%   Outputs:
%   photons - the photon data from the generated sensor image. If N was
%       greater than 1, this will be an matrix of N photon data samples
%
%   3/18/2015   xd  wrote it
%   4/17/2015   xd  updated to use the human sensor
%   5/18/2015   xd  changed to use photon data instead of volt data

%% Load the optical image associated with the folder name and image name
    oi = loadOpticalImageData(folderName, imageName);
    
%% Get a noise free version of the image
    sensorNF = sensorComputeNoiseFree(sensor, oi);
    noiseFree = sensorGet(sensorNF, 'photons'); % Does not work with 3D EM because of 3D

%% Use a default k-value of 1    
    if (nargin < 5)
        k = 1;
    end
  
%% Calculate noisy sample

    % Get a noisy sensor image
    sensorR = coneAbsorptions(sensor, oi); 
    
    if (calcParams.coneAdaptEnable)
        [~, noisySample] = coneAdapt(sensorR, calcParams.coneAdaptType);
        
        % Data from coneAdapt is in volts, must be converted to photons
        % This code is taken from sensorGet('photons')
        pixel = sensorGet(sensorR,'pixel');
        noisySample = noisySample/pixelGet(pixel,'conversionGain');

        % Photons are int
        noisySample = round(noisySample);
    else 
        noisySample = sensorGet(sensorR, 'photons');
    end
    
    % Find the noise
    diff = noisySample - noiseFree;

    % Add noise back with k multiplier
    noisySample = noiseFree + diff * k;

    photons = noisySample;
end


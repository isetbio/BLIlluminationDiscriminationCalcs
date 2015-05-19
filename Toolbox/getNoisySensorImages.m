function photons = getNoisySensorImages(folderName, imageName, sensor, N, k)
%getNoisySensorImages
%   Generate N noisy sensor images of the input optical image location
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
%   3/18/2015   xd  wrote it
%   4/17/2015   xd  updated to use the human sensor
%   5/18/2015   xd  changed to use photon data instead of volt data

%% Load the optical image associated with the folder name and image name
    oi = loadOpticalImageData(folderName, imageName);
    
%% Get a noise free version of the image
    sensorNF = sensorComputeNoiseFree(sensor, oi);
    %     noiseFree = sensorGet(sensorNF, 'volts'); 
    noiseFree = sensorGet(sensorNF, 'photons');
    
%% Use a default k-value of 1    
    if (nargin < 5)
        k = 1;
    end

%% Preallocate space for images
    [x,y] = size(noiseFree);
    noisySample = zeros(x, y, N);
    
%% Calculate N sets of noisy samples
    for i = 1:N
        % Get a noisy sensor image
        sensorR = coneAbsorptions(sensor, oi);
        %         noisySample(:,:,i) = sensorGet(sensorR, 'volts');
        noisySample(:,:,i) = sensorGet(sensorR, 'photons');
        % Find the noise
        diff = noisySample(:,:,i) - noiseFree;
        
        % Add noise back with k multiplier
        noisySample(:,:,i) = sensorNF.data.volts + diff * k;
    end
    
    photons = noisySample;
end


function volts = getNoisySensorImages(folderName, imageName, sensor, N, k)
%getNoisySensorImages
%   Generate N noisy sensor images of the input optical image location
%   using the given input sensor
%
%   3/18/2015   xd  wrote it
%   4/17/2015   xd  updated to use the human sensor

    oi = loadOpticalImageData(folderName, imageName);
    
    % Get a noise free sensor image
    % REALLY WE WANT PHOTONS HERE, NOT VOLTS
    sensorNF = sensorComputeNoiseFree(sensor, oi);
    noiseFree = sensorGet(sensorNF, 'volts');
    
    if (nargin < 5)
        k = 1;
    end

    % Preallocate space for images
    [x,y] = size(noiseFree);
    noisySample = zeros(x, y, N);
    
    
    for i = 1:N
        % Get a noisy sensor image
        sensorR = coneAbsorptions(sensor, oi);
        noisySample(:,:,i) = sensorGet(sensorR, 'volts');
        
        % Find the noise
        diff = noisySample(:,:,i) - noiseFree;
        
        % Add noise back with k multiplier
        noisySample(:,:,i) = sensorNF.data.volts + diff * k;
    end
    
    volts = noisySample;
end


function volts = getNoisySensorImages(folderName, imageName, sensor, N, k)
%getNoisySensorImages
%   Generate N noisy sensor images of the input optical image location
%   using the given input sensor
%   3/18/2015   xd  wrote it

    oi = loadOpticalImageData(folderName, imageName);
    sensorNF = sensorComputeNoiseFree(sensor, oi);
    
    if (nargin < 5)
        k = 1;
    end

    noisySample = sensorComputeSamples(sensorNF, N);
    
    for i = 1:N
        diff = noisySample(:,:,i) - sensorNF.data.volts;
        noisySample(:,:,i) = sensorNF.data.volts + diff * k;
    end
    
    volts = noisySample;
end


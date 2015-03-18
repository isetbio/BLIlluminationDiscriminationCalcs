function volts = getNoisySensorImages(folderName, imageName, sensor, N)
%getNoisySensorImages
%   Generate N noisy sensor images of the input optical image location
%   using the given input sensor
%   3/18/2015   xd  wrote it

    oi = loadOpticalImageData(folderName, imageName);
    sensorNF = sensorComputeNoiseFree(sensor, oi);

    volts = sensorComputeSamples(sensorNF, N);
end


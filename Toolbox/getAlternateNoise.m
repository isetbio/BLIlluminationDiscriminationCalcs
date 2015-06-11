function noise = getAlternateNoise(sensor,k)
% noise = getAlternateNoise(sensor,k)
% This function simulates poisson noise with a normal distribution.  It
% also accepts a noise multiplier which should 


noiseFree = sensorGet(sensor, 'photons');

noise = k * sqrt(noiseFree) .* randn(size(noiseFree));

end


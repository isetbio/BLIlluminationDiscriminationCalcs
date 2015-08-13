function adaptedData = temporaryConeAdapt(sensor)
% Use this for OS until that branch is merged into isetbio.
bgVolts = 0;

p = riekeInit;
expTime = sensorGet(sensor,'exposure time');
sz = sensorGet(sensor,'size');

% absRate = sensorGet(sensor,'absorptions per second');
pRate = sensorGet(sensor, 'photon rate');

% Compute background adaptation parameters
bgR = bgVolts / (sensorGet(sensor,'conversion gain')*expTime);

initialState = riekeAdaptSteadyState(bgR, p, sz);
initialState.timeInterval = sensorGet(sensor, 'time interval');
adaptedData  = riekeAdaptTemporal(pRate, initialState);


adaptedData = riekeAddNoise(adaptedData);

end


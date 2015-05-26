% This error file shows how option 2 for coneAdapt does not work when the voltage
% data is a 3D matrix.  On line 127 in coneAdapt, the function calls sensorGet to
% retrieve 'cone type'. However, this is a 2D matrix and thus cannot be subtracted
% from the volt data.  Oddly, the eye movement generating function does not update
% this field to a 3D matrix despite changing the voltage data.  'Cone type' seems
% to represent the underlying cones for the sensor image.  I think it would make
% sense that having eye movement would result in different sets of cone types for
% each time frame?

%% Setup code taken from t_coneAdapt.m

%% Init
ieInit;
ieSessionSet('gpu', 0);

%% Compute cone isomerizations
% The stimulus used here is a step Gabor patch, at 1~500 ms, the stimulus
% is of mean luminance 50 and at 501~1000 ms, the stimulus is of mean
% luminance 200

% Eet up parameters for Gabor patch
% There is no temporal drifting now. But we could have that by changing
% phase with time
fov = 2;
params.freq = 6; params.contrast = 1;
params.ph  = 0;  params.ang = 0;
params.row = 256; params.col = 256;
params.GaborFlag = 0.2; % standard deviation of the Gaussian window

% Set up scene, oi and sensor
scene = sceneCreate('harmonic', params);
scene = sceneSet(scene, 'h fov', fov);
oi  = oiCreate('wvf human');
sensor = sensorCreate('human');
sensor = sensorSetSizeToFOV(sensor, fov, scene, oi);
sensor = sensorSet(sensor, 'exp time', 0.001); % 1 ms
sensor = sensorSet(sensor, 'time interval', 0.001); % 1 ms

% Compute cone absorptions for each ms, for a second.
% This is very slow.
nSteps = 100;
volts = zeros([sensorGet(sensor, 'size') nSteps]);
stimulus = zeros(1, nSteps);
fprintf('The computation of the stimulus is very slow.\n');
fprintf('Go get a cup of coffee while this runs.\n');
fprintf('Computing cone isomerization:    ');
for t = 1 : nSteps
    fprintf('\b\b\b%02d%%', round(100*t/nSteps));
    % Low luminance for first 500 msec and the step up.
    if t < nSteps / 2
        scene = sceneAdjustLuminance(scene, 50);
    else
        scene = sceneAdjustLuminance(scene, 200);
    end
    
    % Compute optical image
    oi = oiCompute(scene, oi);
    
    % Compute absorptions
    sensor = sensorCompute(sensor, oi);
    volts(:,:,t) = sensorGet(sensor, 'volts');
    stimulus(t)  = median(median(volts(:,:,t)));
end
fprintf('\n');

% Set the stimuls into the sensor object
sensor = sensorSet(sensor, 'volts', volts);
stimulus = stimulus / sensorGet(sensor, 'conversion gain') /...
    sensorGet(sensor, 'exp time');

%% Error in option 2 -> error on line 127
[~, cur] = coneAdapt(sensor, 2);

%% Option 4 just creates a black image? -> all negative voltage values in adapted data
[~, cur] = coneAdapt(sensor, 4);
cur = cur / max(cur(:));
implay(cur);
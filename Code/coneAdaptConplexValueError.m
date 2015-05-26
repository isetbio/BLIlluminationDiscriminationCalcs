% This error script demonstrates how option 3 for coneAdapt results in a complex
% matrix.  This is due to a few negative voltage values occuring in the
% non adapted data set.  I am not sure if the negative voltages are supposed to be
% there.  I don't think the complex values should be there.

%% Put project toolbox onto path.
    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);

% Folder list to run over for conversions into isetbio format
calcParams.cacheFolderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
    'RedIllumination', 'YellowIllumination'};
    
% Specify how to crop the image.  We don't want it all.
calcParams.cropRect = [550 450 40 40];              % Use [450 350 624 574] for entire non-black region of our images

% Specify the parameters for the chooser calculation
calcParams.numTrials = 100;
calcParams.maxIllumTarget = 50;
calcParams.numKValueSamples = 10;

% Specify eye movement parameters
% EMPositions represents the number of positions of eye movement to sample,
% in this case it is 100
calcParams.enableEM = true;
calcParams.EMPositions = zeros(100, 2);
calcParams.EMSampleTime = 0.001;    % Setting sample time to 1 ms

% Specify cone adaptation parameters
calcParams.coneAdaptEnable = true;
calcParams.coneAdaptType = 3;


    %% Parameters
    fieldOfViewReductionFactor = 1;
    coneIntegrationTime = 0.001;
    S = [380 8 51];
    
    %% Load scene to get FOV.
    % Scenes are precomputed from stimulus images and stored for our
    % use here.
    scene = loadSceneData('Standard', 'TestImage0');
    fov = sceneGet(scene, 'fov');
    scene = sceneSet(scene,'fov',fov/fieldOfViewReductionFactor);
    fov = sceneGet(scene, 'fov');

    %% Load oi for FOV.
    % These are also precomputed.
    oi = loadOpticalImageData('Standard', 'TestImage0');
    
    %% Create a sensor for human foveal vision
    sensor = sensorCreate('human');
    
    % Set the sensor dimensions to a square
    sensorRows = sensorGet(sensor,'rows');
    sensor = sensorSet(sensor,'cols',sensorRows);
    
    % Set integration time
    sensor = sensorSet(sensor,'exp time',coneIntegrationTime);
    sensor = sensorSet(sensor, 'time interval', coneIntegrationTime);
    
    % Set FOV
    [sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);
    
    % Set wavelength sampling
    sensor = sensorSet(sensor, 'wavelength', SToWls(S));
    
        
    % Create eye movement object
    em = emCreate;

    % Set the sample time
    em = emSet(em, 'sample time', calcParams.EMSampleTime);

    % Attach it to the sensor
    sensor = sensorSet(sensor, 'eyemove',em);

    % This is the position every sample time interval
    sensor = sensorSet(sensor,'positions', calcParams.EMPositions);

    % Create the sequence
    sensor = emGenSequence(sensor);
    
    sensorR = coneAbsorptions(sensor, oi); 
    
    [~, noisySample] = coneAdapt(sensorR, calcParams.coneAdaptType);

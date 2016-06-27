function results = RunModel(calcParams,overWrite,frozen)
% results = RunModel(calcParams,overwrite,frozen)
%
% This function will run the computational observer model according to
% specifications in the calcParams struct. Specifically, the sensor will be
% created here in addition to deciding which order of the model to use. The
% overWrite flag must be set to true if data should be overwritten.
% Similarly, to generate reproducable results, set frozen to true.
%
% xd  6/23/16  extracted from old code

%% Set defaults for inputs
if notDefined('overWrite'), overWrite = false; end
if notDefined('frozen'), frozen = false; end

%% Take care of some housekeeping
% Here we set a constant seed in case we want to freeze the noise.  This
% allows us to generate reproducable data. Otherwise we'll use random noise
% so that the model does not do the same thing everytime.  Since we run
% many trials, this should not induce significant variability.
if (~frozen)
    rng('shuffle');
end

% We'll check if the target directory for our data exists. If it does not,
% we'll make it here. Also check if we want to overwrite existing data.
baseDir   = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
targetPath = fullfile(baseDir, 'SimpleChooserData', calcParams.calcIDStr);
if exist(targetPath, 'dir')
    if ~overWrite
        return;
    end
else
    rootPath = fullfile(baseDir, 'SimpleChooserData');
    mkdir(rootPath, calcParams.calcIDStr);
end

%% Create sensor
sensor = sensorCreate('human');

% Set the sensor dimensions to a square
sensorRows = sensorGet(sensor,'rows');
sensor = sensorSet(sensor,'cols',sensorRows);

% Set integration time
sensor = sensorSet(sensor,'exp time',calcParams.coneIntegrationTime);

% Set FOV
oi = oiCreate('human');
sensor = sensorSetSizeToFOV(sensor,calcParams.sensorFOV,[],oi);

% Set wavelength sampling
sensor = sensorSet(sensor,'wavelength',SToWls(calcParams.S));
sensor = sensorSet(sensor,'noise flag',0);

%% Run the desired model
calcParams.colors = {'blue' 'green' 'red' 'yellow'};
results = zeros(length(calcParams.colors),length(calcParams.illumLevels),length(calcParams.KpLevels),length(calcParams.KgLevels));

% Choose the appropriate model function which should be specified in calcParams.
modelPath = fileparts(mfilename('fullpath'));
modelFolder = what(fullfile(modelPath,'ModelVersions'));
modelList = modelFolder.m;
modelFunction = str2func(strrep(modelList{calcParams.MODEL_ORDER},'.m',''));

for ii = 1:length(calcParams.colors)
    results(ii,:,:,:) = modelFunction(calcParams,sensor,calcParams.colors{ii});
end

% Save the results
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
TargetPath = fullfile(analysisDir,'SimpleChooserData',calcParams.calcIDStr);
calcParamFileName = fullfile(TargetPath,['calcParams' calcParams.calcIDStr]);
dataFileName = fullfile(TargetPath,['ModelData' calcParams.calcIDStr]);
save(calcParamFileName,'calcParams');
save(dataFileName,'results');

end


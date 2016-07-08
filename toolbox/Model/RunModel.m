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
% Here we set a constant seed in case we want to freeze the noise. This
% allows us to generate reproducable data. Otherwise we'll use random noise
% so that the model does not do the same thing everytime. Since we run
% many trials, this should not induce significant variability.
if (~frozen)
    rng('shuffle');
else
    rng(1);
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
mosaic = coneMosaic;
mosaic.fov = calcParams.sensorFOV;
mosaic.wave = SToWls(calcParams.S);
mosaic.noiseFlag = false;
mosaic.integrationTime = calcParams.coneIntegrationTime;

if calcParams.MODEL_ORDER == 2
    % Adjust eye movements
    calcParams.em = emCreate;
    calcParams.em = emSet(calcParams.em, 'emFlag', [calcParams.enableTremor calcParams.enableDrift calcParams.enableMSaccades]);
    calcParams.em = emSet(calcParams.em, 'sample time', calcParams.coneIntegrationTime);
    
    mosaic.emPositions = calcParams.EMPositions;
end

%% Run the desired model
calcParams.colors = {'Blue' 'Green' 'Red' 'Yellow'};
results = zeros(length(calcParams.colors),length(calcParams.illumLevels),length(calcParams.KpLevels),length(calcParams.KgLevels));

% Choose the appropriate model function which should be specified in calcParams.
modelPath = fileparts(mfilename('fullpath'));
modelFolder = what(fullfile(modelPath,'ModelVersions'));
modelList = modelFolder.m;
modelFunction = str2func(strrep(modelList{calcParams.MODEL_ORDER},'.m',''));

for ii = 1:length(calcParams.colors)
    results(ii,:,:,:) = modelFunction(calcParams,mosaic,calcParams.colors{ii});
end
calcParams.colors = lower(calcParams.colors);

% Save the results
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
TargetPath = fullfile(analysisDir,'SimpleChooserData',calcParams.calcIDStr);
calcParamFileName = fullfile(TargetPath,['calcParams' calcParams.calcIDStr]);
dataFileName = fullfile(TargetPath,['ModelData' calcParams.calcIDStr]);
save(calcParamFileName,'calcParams');
save(dataFileName,'results');

end


function results = RunModel(calcParams,overWrite,frozen)
% results = RunModel(calcParams,overwrite,frozen)
%
% This function will run the computational observer model according to
% specifications in the calcParams struct. Specifically, the sensor will be
% created here in addition to deciding which order of the model to use. The
% overWrite flag must be set to true if data should be overwritten.
% Similarly, to generate reproducable results, set frozen to true.
%
% 6/23/16  xd  extracted from old code

%% Set defaults for inputs
if notDefined('overWrite'), overWrite = false; end
if notDefined('frozen'), frozen = false; end

%% Take care of some housekeeping
%
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
%
% Here, we create a mosaic according to the specifications in the
% calcParams struct. Certain models have more variables than others so we
% need to pay careful attention to what model is being run when performing
% this step.
mosaic = coneMosaic;
mosaic.fov = calcParams.sensorFOV;
mosaic.wave = SToWls(calcParams.S);
mosaic.noiseFlag = false;
mosaic.integrationTime = calcParams.coneIntegrationTime;
mosaic.spatialDensity = calcParams.spatialDensity;

if calcParams.MODEL_ORDER == 2
    % Adjust eye movements
    calcParams.em = emCreate;
    calcParams.em = emSet(calcParams.em,'emFlag',[calcParams.enableTremor calcParams.enableDrift calcParams.enableMSaccades]);
    
    mosaic.os = osCreate(calcParams.OSType);
    mosaic.os.noiseFlag = false;
    mosaic.sampleTime = calcParams.coneIntegrationTime;
end

%% Run the desired model
%
% We loop over the colors and compute the result. This is all saved into a
% single matrix. We'll keep the order of the colors fixed here so that
% there is less confusion when many different calculations are run.
calcParams.colors = {'Blue' 'Green' 'Red' 'Yellow'};
results = zeros(length(calcParams.colors),length(calcParams.illumLevels),length(calcParams.KpLevels),length(calcParams.KgLevels));

% Choose the appropriate model function which should be specified in calcParams.
modelPath = fileparts(mfilename('fullpath'));
modelFolder = what(fullfile(modelPath,'ModelVersions'));
modelList = modelFolder.m;
modelFunction = str2func(strrep(modelList{calcParams.MODEL_ORDER},'.m',''));

% Perform calculations and save results. Also, save the color order into
% calcParams just in case.
for ii = 1:length(calcParams.colors)
    results(ii,:,:,:) = modelFunction(calcParams,mosaic,calcParams.colors{ii});
end
calcParams.colors = lower(calcParams.colors);

% Save the results
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
TargetPath = fullfile(analysisDir,'SimpleChooserData',calcParams.calcIDStr);
calcParamFileName = fullfile(TargetPath,['calcParams' calcParams.calcIDStr '.mat']);
dataFileName = fullfile(TargetPath,['ModelData' calcParams.calcIDStr '.mat']);
save(calcParamFileName,'calcParams');
save(dataFileName,'results');

end


function sensorImageSimpleChooserModel(calcParams, colorChoice)
%sensorImageSimpleChooserModel(calcParams, computeAll, colorChoice)
%
% This function will generate several noisy versions of the standard
% image.  Then it will compare the standard with one of the noisy images
% and a test image and choose the one closest to the standard image.
% Success rate will be defined as how many times it chooses the noisy
% standard image.
%
% It is likely that calculating all four color directions in one run is
% preferable since the sensor object is not saved, and thus the cone mosaic
% which is randomly generated is not preserved across calculations.
%
% Inputs:
%       calcParams  - parameters for the calculation, contains the number of
%                     trials to run
%       colorChoice - an integer corresponding to the desired target
%                     color illumination for calculation.
%                     0 = compute all colors
%                     1 = blue
%                     2 = green
%                     3 = red
%                     4 = yellow
%
% 3/17/15     xd  wrote it
% 4/17/15     xd  update to use human sensor

%% Clear
close all; clear global; ieInit;

%% Put project toolbox onto path.
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Check if destination folder exists and has files
baseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
targetPath = fullfile(baseDir, 'SimpleChooserData', calcParams.calcIDStr);
if exist(targetPath, 'dir')
    % Pop up dialog
    d = dir(targetPath);
    if numel(d) > 2
        save = questdlg('Files found.  Override with new results?', ...
            'Warning', 'Yes', 'No', 'No');
        if (strcmp(save, 'No'))
            return;
        end
    end
else
    % Make new directory
    rootPath = fullfile(baseDir, 'SimpleChooserData');
    mkdir(rootPath, calcParams.calcIDStr);
end

%% Pull parameters from passed struct for local use
coneIntegrationTime = calcParams.coneIntegrationTime;
S = calcParams.S;

%% Load scene to get FOV.
% Scenes are precomputed from stimulus images and stored for our use here.
scene = loadSceneData('Standard', 'TestImage0');
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

% Set FOV
[sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);

% Set wavelength sampling
sensor = sensorSet(sensor, 'wavelength', SToWls(S));

%% If doing eye movements, set EM parameters
if (calcParams.enableEM)
    
    % Create eye movement object
    em = emCreate;
    
    % Set the sample time
    em = emSet(em, 'sample time', calcParams.EMSampleTime);
    
    % Set tremor amplitude
    amplitude = emGet(em, 'tremor amplitude');
    em = emSet(em, 'tremor amplitude', amplitude * calcParams.tremorAmpFactor);
    
    % Attach it to the sensor
    sensor = sensorSet(sensor,'eyemove',em);
    
    % This is the position every sample time interval
    sensor = sensorSet(sensor,'positions',calcParams.EMPositions);
    
    % Create the sequence
    sensor = emGenSequence(sensor);
end

%% Compute according to the input color choice
computeByColor(calcParams, sensor, colorChoice);

fprintf('Calculation complete');
end

function results = singleColorKValueComparison(calcParams, sensor, folderName, prefix)
%results = singleColorKValueComparison(calcParams, sensor, folderName, prefix)
%
% This function carries out the simple chooser model calculation.
%
% Inputs:
%   calcParams - This struct should contain relevant parameters for the
%                calculation, including the number of k-value samples, the
%                number of trials, and the illumination number to go up to.
%                These are specified by the fields 'numTrials',
%                'maxIllumTarget', and 'numKValueSamples'
%   sensor     - This is the sensor that will be used to generate each of the
%                sensor images
%   folderName - The folder that contains the target set of optical images
%   prefix     - The color that matches the target folder, this will be used to
%                generate the optical image name
% Outputs:
%   results - A 2D matrix that contains percentages of 'correct' decisions
%             made by the model

%% Get relevant parameters from calcParams
numTrials = calcParams.numTrials;
maxImageIllumNumber = calcParams.maxIllumTarget;
kSampleNum = calcParams.numKValueSamples;
kInterval = calcParams.kInterval;

%% Get a list of images

% This will return the list of optical images in ascending illum number order
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
folderPath = fullfile(dataBaseDir, 'OpticalImageData', folderName);
data = what(folderPath);
fileList = data.mat;
fileList = sort(fileList);
[~,b] = sort(cellfun(@numel, fileList));
fileList = fileList(b);

%% Preallocate space for the accuracy matrix which will store the results of the calculations
accuracyMatrix = zeros(maxImageIllumNumber, kSampleNum);

%% Run calculations up to illumination number and k-value limits

% Compute noise free cone absorptions for the standard image, this will be
% the same throught the entire simulation

oiStandard = loadOpticalImageData('Standard', 'TestImage0');
sensorStandard = sensorSet(sensor, 'noise flag', 0);
sensorStandard = coneAbsorptions(sensorStandard, oiStandard);

% Loop through the illumination number
for i = 1:maxImageIllumNumber
    
    % Compute the noise free cone absorptions for the current test image
    imageName = fileList{i};
    imageName = strrep(imageName, 'OpticalImage.mat', '');
    
    oiTest = loadOpticalImageData(folderName, imageName);
    sensorTest = sensorSet(sensor, 'noise flag', 0);
    sensorTest = coneAbsorptions(sensorTest, oiTest);
    
    % Loop through the k values
    for j = 1:kSampleNum
        correct = 0;
        currKValue = (1 + kInterval * (j - 1));
        % Simulate out over calcNumber simulated trials
        tic
        for t = 1:numTrials
            % Get inital noisy ref image
            photonsStandardRef = getNoisySensorImage(calcParams,sensorStandard,currKValue);
            
            % Get noisy version of standard image
            photonsStandardComp = getNoisySensorImage(calcParams,sensorStandard,currKValue);
                        
            % Get noisy version of test image
            photonsTestComp = getNoisySensorImage(calcParams,sensorTest,currKValue);
            
            % Calculate vector distance from the test image and
            % standard image to the reference image
            distToStandard = norm(photonsStandardRef(:)-photonsStandardComp(:));
            distToTest = norm(photonsStandardRef(:)-photonsTestComp(:));
            
            % Decide if 'subject' was correct on this trial
            if (distToStandard < distToTest)
                correct  = correct + 1;
            end
        end
        
        % Print the time the calculation took
        fprintf('Calculation time for color: %s, IllumNumber: %d, k-value %.1f = %2.1f\n', prefix, i, currKValue, toc);
        accuracyMatrix(i,j) = correct / numTrials * 100;
    end
end

results = accuracyMatrix;
end

function computeByColor(calcParams, sensor, colorChoice)
%computeByColor(calcParams, sensor, colorChoice)
%
% This function will run the simple chooser model on the data set specified
% by colorChoice.  This will save the results in the folder defined by
% calcIDStr in calcParams.  At the end of the calculation, the calcParams
% will also be saved in the same folder.
%
% Inputs:
%   calcParams  - This contains parameters for the model
%   sensor      - The desired sensor to be used for the calculation
%   colorChoice - This defines the color on which to run the calculation

%     folderList = {'BlueIllumination', 'GreenIllumination', ...
%         'RedIllumination', 'YellowIllumination'};
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    folderList = calcParams.cacheFolderList(2:5);
    
    BaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    TargetPath = fullfile(BaseDir, 'SimpleChooserData', calcParams.calcIDStr);
    
    if (colorChoice == 0)
        for i=1:length(folderList)
            matrix = singleColorKValueComparison(calcParams, sensor, folderList{i}, prefix{i});
            fileName = strcat(prefix{i}, ['IllumComparison' calcParams.calcIDStr]);
            saveDir = fullfile(TargetPath, fileName);
            save(saveDir, 'matrix');
        end
    else
        matrix = singleColorKValueComparison(calcParams, sensor, folderList{colorChoice}, prefix{colorChoice});
        fileName = strcat(prefix{colorChoice}, ['IllumComparison' calcParams.calcIDStr]);
        saveDir = fullfile(TargetPath, fileName);
        save(saveDir, 'matrix');
        printmat(matrix, 'Results', ...
            '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50', ...
            '1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0');
    end
    
    saveDir = fullfile(TargetPath, ['calcParams' calcParams.calcIDStr]);
    save(saveDir, 'calcParams');
    
end

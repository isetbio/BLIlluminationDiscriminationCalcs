function sensorImageSimpleChooserModel(calcParams, colorChoice)
%sensorImageSimpleChooserModel(calcParams, computeAll, colorChoice)
%
% This function will generate several noisy versions of the standard
% image.  Then it will compare the standard with one of the noisy images
% and a test image and choose the one closest to the standard image.
% Success rate will be defined as how many times it chooses the noisy
% standard image.
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

%% Define the suffix term for creating the image name
%
%  Files on the ColorShare1 server are in the format of
%  prefix + ImgNumber + suffix, where the prefix is the color and the
%  suffix is defined below
suffix = 'L-RGB';

%% Preallocate space for the accuracy matrix which will store the results of the calculations
accuracyMatrix = zeros(maxImageIllumNumber, kSampleNum);

%% Run calculations up to illumination number and k-value limits
%
% Loop through the illumination number
for i = 1:maxImageIllumNumber
    % Loop through the k values
    for j = 1:kSampleNum
        correct = 0;
        
        % Simulate out over calcNumber simulated trials
        tic
        for t = 1:numTrials
            % Get inital noisy ref image
            photonstandardRef = getNoisySensorImage(calcParams,'Standard','TestImage0',sensor,(1 + kInterval * (j - 1)));
            
            % Get noisy version of standard image
            photonsStandardComp = getNoisySensorImage(calcParams,'Standard','TestImage0',sensor,(1 + kInterval * (j - 1)));
            
            % Generate Image name
            imageName = strcat(prefix, int2str(i), suffix);
            
            % Get noisy version of test image
            photonsTestComp = getNoisySensorImage(calcParams,folderName,imageName,sensor,(1 + kInterval * (j - 1)));
            
            % Calculate vector distance from the test image and
            % standard image to the reference image
            distToStandard = norm(photonstandardRef(:)-photonsStandardComp(:));
            distToTest = norm(photonstandardRef(:)-photonsTestComp(:));
            
            % Decide if 'subject' was correct on this trial
            if (distToStandard < distToTest)
                correct  = correct + 1;
            end
        end
        
        % Print the time the calculation took
        fprintf('Calculation time for color: %s, IllumNumber: %d, k-value %.1f = %2.1f\n', prefix, i, j, toc);
        accuracyMatrix(i,j) = correct / numTrials * 100;
    end
end

results = accuracyMatrix;
end

function computeByColor(calcParams, sensor, colorChoice)
%computeByColor(calcParams, sensor, colorChoice)
%
% This function will run the simple chooser model on the data set specified
% by colorChoice
%
% Inputs:
%   calcParams  - This contains parameters for the model
%   sensor      - The desired sensor to be used for the calculation
%   colorChoice - This defines the color on which to run the calculation

    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    if (colorChoice == 0)
        for i=1:length(folderList)
            matrix = singleColorKValueComparison(calcParams, sensor, folderList{i}, prefix{i});
            fileName = strcat(prefix{i}, 'IllumComparison');
            save(fileName, 'matrix');
        end
    else
        matrix = singleColorKValueComparison(calcParams, sensor, folderList{colorChoice}, prefix{colorChoice});
        fileName = strcat(prefix{colorChoice}, 'IllumComparison');
        save(fileName, 'matrix');
        printmat(matrix, 'Results', ...
            '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50', ...
            '1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0');
    end
end

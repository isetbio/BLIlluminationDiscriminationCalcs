function sensorImageSimpleChooserModel(calcParams, computeAll, colorChoice)
%sensorImageSimpleChooserModel(calcParams, computeAll, colorChoice) 
%   This function will generate several noisy versions of the standard
%   image.  Then it will compare the standard with one of the noisy images
%   and a test image and choose the one closest to the standard image.
%   Success rate will be defined as how many times it chooses the noisy
%   standard image.
%
%   Inputs:
%       calcParams - parameters for the calculation, contains the number of
%           trials to run
%       computeAll - if set to true, the calculation will be run on all
%           color illumination. Otherwise, only the color specified by the
%           color choice input will be used
%       colorChoice - an integer corresponding to the desired target
%           color illumination for calculation.
%           1 = blue
%           2 = green
%           3 = red
%           4 = yellow
%
%   3/17/15     xd  wrote it
%   4/17/15     xd  update to use human sensor

    %% Clear
    close all; clear global; ieInit;

    %% Put project toolbox onto path.
    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);
    
    %% Parameters
    fieldOfViewReductionFactor = 1;
    coneIntegrationTime = 0.050;
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
    
    % Set FOV
    [sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);
    
    % Set wavelength sampling
    sensor = sensorSet(sensor, 'wavelength', SToWls(S));
    
    %% Set eye movement parameters
    
    % Check if eye movement enabled
    if (calcParams.enableEM)
        
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
    end
    
    %% Set cone adaptation parameters
    
    % Check if cone adaptation is enabled
    if (calcParams.coneAdaptEnable)
        [sensor, ~] = coneAdapt(sensor, calcParams.coneAdaptType);
    end
    
    %% Compute all if flag set to true, otherwise only calculate one
    if (computeAll)
        calculateAllColors(calcParams, sensor);
    else
        folderList = {'BlueIllumination', 'GreenIllumination', ...
            'RedIllumination', 'YellowIllumination'};
        prefix = {'blue' , 'green', 'red', 'yellow'};
        matrix = singleColorKValueComparison(sensor, folderList{colorChoice}, prefix{colorChoice}, 50, 10, calcParams.chooserIterations);
        fileName = strcat(prefix{colorChoice}, 'IllumComparison');
        save(fileName, 'matrix');
        printmat(matrix, 'Results', ...
            '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50', ...
            '1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0');
    end
    
    fprintf('Calculation complete');
end

% results = singleColorKValueComparison(sensor, folderName, prefix, num, k)
%
% This function carries out the simple chooser model calculation.  
% 
% Inputs:
%   sensor - This is the sensor that will be used to generate each of the
%       sensor images
%   folderName - The folder that contains the target set of optical images
%   prefix - The color that matches the target folder, this will be used to
%       generate the optical image name
%   imageIllumNumber - The image number up to which the calculations should
%       be run.  For example, if this is set to 30, only images 1-30 will
%       be analyzed
%   k - The number of desired k value samples.  The function
%       starts with a k-value of 1 and increments k times.
%       For example, an input of 10 will generate a matrix with data for
%       k-values ranging from 1 to 10, incremented by 1.
%   calcNumber - Number of times to test a single
%       color/illumination/k-value combination
%
% Outputs:
%  results - MAYBE IT SHOULD BE CALLED ACCURACY MATRIX?
function results = singleColorKValueComparison(sensor, folderName, prefix, imageIllumNumber, k, calcNumber)

%% Define the suffix term for creating the image name
%
%  Files on the ColorShare1 server are in the format of
%  prefix + ImgNumber + suffix, where the prefix is the color and the
%  suffix is defined below
    suffix = 'L-RGB';
    

%% This increment parameter is the difference between noise levels
% CHANGE THIS TO AN INPUT PARAMETER
% the current value of 1 means k values will be 1,2,3...
    incrementMultiplier = 1;

%% Preallocate space for the accuracy matrix which will store the results of the calculations
    accuracyMatrix = zeros(imageIllumNumber, k);
    
%% Run calculations up to illumination number and k-value limits
%
% Loop through the illumination number
    for i = 1:imageIllumNumber
        % Loop through the k values
        for j = 1:k
            correct = 0;
                   
            % Simulate out over calcNumber simulated trials
            tic
            for t = 1:calcNumber
                % Get inital noisy ref image
                voltsStandardRef = getNoisySensorImages('Standard','TestImage0',sensor,1,(1 + incrementMultiplier * (j - 1)));
                
                % Get noisy version of standard image
                voltsStandardComp = getNoisySensorImages('Standard','TestImage0',sensor,1,(1 + incrementMultiplier * (j - 1)));
                
                % Generate Image name
                imageName = strcat(prefix, int2str(i), suffix);
                
                % Get noisy version of test image
                voltsTestComp = getNoisySensorImages(folderName,imageName,sensor,1,(1 + incrementMultiplier * (j - 1)));
                
                % Calculate vector distance from the test image and
                % standard image to the reference image
                distToStandard = norm(voltsStandardRef(:)-voltsStandardComp(:));
                distToTest = norm(voltsStandardRef(:)-voltsTestComp(:));

                % Decide if 'subject' was correct on this trial
                if (distToStandard < distToTest)
                    correct  = correct + 1;
                end
            end
            
            % print the time the calculation took
            fprintf('Calculation time for color: %s, IllumNumber: %d, k-value %.1f = %2.1f\n', prefix, i, j, toc);
            accuracyMatrix(i,j) = correct / calcNumber * 100;
        end
    end
    
    results = accuracyMatrix;
end

% calculateAllColors(calcParams, sensor)
%
% This function will run the simple chooser model on all the data sets
% store on ColorShare
%
% Inputs:
%   calcParams - This contains a field that defines how many times to run
%       model
%   senor - the desired sensor to be used for the calculation
%
function calculateAllColors(calcParams, sensor)
    %% These will be used to loop through all the scenes
    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    for i=1:length(folderList)
        matrix = singleColorKValueComparison(sensor, folderList{i}, prefix{i}, 50, 10, calcParams.chooserIterations);
        fileName = strcat(prefix{1}, 'IllumComparison');
        save(fileName, 'matrix');
    end
end

function sensorImageSimpleChooserModel
%sensorImageSimpleChooserModel 
%   This function will generate several noisy versions of the standard
%   image.  Then it will compare the standard with one of the noisy images
%   and a test image and choose the one closest to the standard image.
%   Success rate will be defined as how many times it chooses the noisy
%   standard image.
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
    
    %% These will be used to loop through all the scenes if desired
    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
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
    
    %% Run the chooser model on one color illumanion set
    % This can be looped if running the model on all data sets at once is
    % desired
    matrix = singleColorKValueComparison(sensor, 'YellowIllumination', 'yellow', 50, 10);
    save('yellowIllumComparison', 'matrix');
    printmat(matrix, 'Results', ...
        '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50', ...
        '1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0');
    
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
%
% Outputs:
%  results - MAYBE IT SHOULD BE CALLED ACCURACY MATRIX?
function results = singleColorKValueComparison(sensor, folderName, prefix, imageIllumNumber, k)

%% Define the suffix term for creating the image name
%
%  Files on the ColorShare1 server are in the format of
%  prefix + ImgNumber + suffix, where the prefix is the color and the
%  suffix is defined below
    suffix = 'L-RGB';
    

%% This increment parameter is the difference between noise levels
%
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
                   
            % WHAT IS THE MAGIC NUMBER 100 HERE?
            tic
            for t = 1:100
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
            accuracyMatrix(i,j) = correct;
        end
    end
    
    results = accuracyMatrix;
end

% THIS FUNCTION IS NEITHER USED NOR COMMENTED
% WHAT DOES IT DO, OR SHOULD IT BE DELETED?
function results = kValueComparisonBasedOnColor(sensor)

    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    
    suffix = 'L-RGB';
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    
    voltsStandardRef = getNoisySensorImages('Standard','TestImage0',sensor,1);
        
    k = 5;
    kValue = zeros(length(folderList),k);
    for i = 1:length(folderList)
        for j = 1:k
            correct = 0;
            tic
            for t = 1:100
                voltsStandardComp = getNoisySensorImages('Standard','TestImage0',sensor,1,j);
                
                % Get sample from current folder
                imageNum  = floor(50 * rand()) + 1;
                imageNum  = min(50, imageNum);
                imageName = strcat(prefix{i}, int2str(imageNum), suffix);
                
                voltsTestComp = getNoisySensorImages(folderList{i},imageName,sensor,1);
                

                distToStandard = norm(voltsStandardRef(:)-voltsStandardComp(:));
                distToTest = norm(voltsStandardRef(:)-voltsTestComp(:));

                % Decide if 'subject' was correct on this trial
                if (distToStandard < distToTest)
                    correct  = correct + 1;
                end
            end
            fprintf('%2.1f\n', toc);
            kValue(i, j) = correct;
        end
    end
    results = kValue;
end
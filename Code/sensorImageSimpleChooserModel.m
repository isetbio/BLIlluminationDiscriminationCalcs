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

    % Clear
    close all; clear global; ieInit;

    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);
    
    % These will be used to loop through all the scenes if desired
    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    
    % Load scene to get FOV
    scene = loadSceneData('Standard', 'TestImage0');
    fov = sceneGet(scene, 'fov');
    scene = sceneSet(scene,'fov',fov/4);
    fov = sceneGet(scene, 'fov');

    % load oi for FOV
    oi = loadOpticalImageData('Standard', 'TestImage0');
    
    % Create a sensor
    sensor = sensorCreate('human');
    
    % Set the sensor dimensions to a square
    sensorRows = sensorGet(sensor,'rows');
    sensor = sensorSet(sensor,'cols',sensorRows);
    
    sensor = sensorSet(sensor,'exp time',0.050);
    [sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);
    sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));
    
    % Here we run the chooser model on one color illumanion set
    % This can be looped if running the model on all data sets at once is
    % desired
    matrix = singleColorKValueComparison(sensor, 'YellowIllumination', 'yellow', 50, 10);
    save('yellowIllumComparison', 'matrix');
    printmat(matrix, 'Results', ...
        '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50', ...
        '1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0');
    
end


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

% This function carries out the simple chooser model calculation.  The
% multipler value is the difference between noise levels, so the current
% value of 1 means k values will be 1,2,3...
function results = singleColorKValueComparison(sensor, folderName, prefix, num, k)

    suffix = 'L-RGB';
    
    multiplier = 1;
    accuracyMatrix = zeros(num, k);
    for i = 1:num
        for j = 1:k
            correct = 0;
            % Get inital noisy ref image
            voltsStandardRef = getNoisySensorImages('Standard','TestImage0',sensor,1,(1 + multiplier * (j - 1)));
            tic
            for t = 1:100
                
                % Get noisy version of standard image
                voltsStandardComp = getNoisySensorImages('Standard','TestImage0',sensor,1,(1 + multiplier * (j - 1)));
                imageName = strcat(prefix, int2str(i), suffix);
                
                % Get noisy version of test image
                voltsTestComp = getNoisySensorImages(folderName,imageName,sensor,1,(1 + multiplier * (j - 1)));
                
                distToStandard = norm(voltsStandardRef(:)-voltsStandardComp(:));
                distToTest = norm(voltsStandardRef(:)-voltsTestComp(:));

                % Decide if 'subject' was correct on this trial
                if (distToStandard < distToTest)
                    correct  = correct + 1;
                end
            end
            fprintf('%2.1f\n', toc);
            accuracyMatrix(i,j) = correct;
        end
    end
    
    results = accuracyMatrix;
end
function results = firstOrderModel(calcParams, colorChoice, overWrite, frozen)
% firstOrderModel(calcParams, colorChoice, overWrite, frozen)
%
% This function will build a sensor according to the calcParams fields.
% This sensor will then be used for the first order model calculations. The
% model compares noisy versions of the target and comparison images and
% chooses the comparison that is closest to the target in terms of
% Euclidian distance.  One of the comparisons is an alternate rendering of
% the target. The performance is defined as how accurately the model
% chooses the alternate target image.  This calculation is done in the
% function singleColorKValueComparison.
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
%       overWrite   - This flag determines whether this function will
%                     write over any existing files in a target directory.
%                     Set this to true to write over, false (default) to avoid doing so.
%       frozen      - Don't seed the rng, so that it stays nice and fixed
%                     (default false, so that rng is set via time on each call.)
%
% 3/17/15  xd  wrote it
% 4/17/15  xd  update to use human sensor
% 6/4/15   xd  added overWrite flag
% 6/25/15  xd  the standard and test now sample from a pool of images
% 7/23/15  xd  removed some things that now belong in the second order
%              model
% 1/5/15   dhb Allow frozen calculation, which doesn't reinitialize the rng.

%% Set defaults for inputs
if notDefined('overWrite'), overWrite = false; end
if notDefined('frozen'), frozen = false; end

%% Set RNG seed to be time dependent
%
% We set the seed to be time dependent so that the model doesn't do the
% same thing repeatedly.  This should not induce any significant
% variability since we run many trials in our model.  However, if you would
% like to generate repoducible data sets, change this seed to a constant
% number.
if (~frozen)
    rng('shuffle');
end

%% Check for faulty parameters
%
% A standard image pool of at least 2 is required.  This is because
% rendering noise will introduce bias into the model.  Even two is rather
% low because of possible bias introduced from the relationship between the
% two renderings.  Currently, we are running the model with 7 copies of the
% standard.
if calcParams.targetImageSetSize < 2
    error('Must have a standard image pool size of at least 2');
end

%% Check if destination folder exists and has files
baseDir   = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
targetPath = fullfile(baseDir, 'SimpleChooserData', calcParams.calcIDStr);

% Make a new directory if target is non-existant.  If it does not exist,
% create it. Otherwise, follow the overWrite flag.
if exist(targetPath, 'dir')
    if ~overWrite
        return;
    end
else
    rootPath = fullfile(baseDir, 'SimpleChooserData');
    mkdir(rootPath, calcParams.calcIDStr);
end

%% Pull parameters from passed struct for local use
coneIntegrationTime = calcParams.coneIntegrationTime;
S = calcParams.S;

%% Create a sensor for human foveal vision
sensor = sensorCreate('human');

% Set the sensor dimensions to a square
sensorRows = sensorGet(sensor,'rows');
sensor = sensorSet(sensor,'cols',sensorRows);

% Set integration time
sensor = sensorSet(sensor,'exp time',coneIntegrationTime);

% Set FOV
oi = oiCreate('human');
sensor = sensorSetSizeToFOV(sensor,calcParams.sensorFOV,[],oi);

% Set wavelength sampling
sensor = sensorSet(sensor, 'wavelength', SToWls(S));

%% Compute according to the input color choice
results = computeByColor(calcParams, sensor, colorChoice);
fprintf('Calculation complete\n');
end

function results = singleColorKValueComparison(calcParams, sensor, standardPath, folderName, prefix)
% results = singleColorKValueComparison(calcParams, sensor, standardPath, folderName, prefix)
%
% This function carries out the simple chooser model calculation.
%
% Inputs:
%   calcParams   - This struct should contain relevant parameters for the
%                  calculation, including the number of k-value samples, the
%                  number of trials, and the illumination number to go up to.
%                  These are specified by the fields 'numTrials',
%                  'maxIllumTarget', and 'numKValueSamples'
%   sensor       - This is the sensor that will be used to generate each of the
%                  sensor images
%   standardPath - The path to where the target OI are stored
%   folderName   - The folder that contains the target set of optical images
%   prefix       - The color that matches the target folder, this will be used to
%                  generate the optical image name
% Outputs:
%   results - A 2D matrix that contains percentages of 'correct' decisions
%             made by the model

%% Get relevant parameters from calcParams
numTrials = calcParams.numTrials;
maxImageIllumNumber = calcParams.maxIllumTarget;
KpSampleNum = calcParams.numKpSamples;
KpInterval = calcParams.KpInterval;
KgSampleNum = calcParams.numKgSamples;
KgInterval = calcParams.KgInterval;

%% Get a list of images

% This will return the list of optical images in ascending illum number
% order.  In addition, if a specific illumination number has more than one
% copy, the file name should formatted like 'blue1L#-RGB...' where #
% represents the copy number.  For consistency, I believe these should also
% be zero indexed like the standard are, except that the 0th term will not have a #. 
% In this case # would start with 1. Code beyond this point will assume these conditions.
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');
folderPath = fullfile(analysisDir, 'OpticalImageData', calcParams.cacheFolderList{2}, folderName);
fileList = getFilenamesInDirectory(folderPath);
fileList = fileList((cellfun(@(x)any(isempty(regexp(x,'L[\d]','once'))),fileList) == 1)); % Removes any copies of test images

%% Preallocate space for the accuracy matrix which will store the results of the calculations
accuracyMatrix = zeros(maxImageIllumNumber, KpSampleNum, KgSampleNum);

%% Run calculations up to illumination number and k-value limits
% Precompute all the sensor images from the standard pool to save
% computational time later on. Similar to the comparison optical images, we
% will find all the file names first.
folderPath = fullfile(analysisDir, 'OpticalImageData', standardPath);
data = what(folderPath);
standardOIList = data.mat;

standardPool = cell(1, length(standardOIList));
for ii = 1:length(standardOIList)
    opticalImageName = standardOIList{ii};
    opticalImageName = strrep(opticalImageName, 'OpticalImage.mat', '');
    oi = loadOpticalImageData(standardPath, opticalImageName);
    
    sensorStandard = sensorSet(sensor, 'noise flag', 0);
    oi = resizeOI(oi, sensorGet(sensorStandard, 'fov')*1.1);
    sensorStandard = coneAbsorptions(sensorStandard, oi);
    standardPool{ii} = sensorStandard;
end

% Compute the mean of the standardPool isomerizations.  The square root of
% this mean will serve as the standard deviation of an optional Gaussian
% noise factor Kg.
photonCellArray = cell(1, length(standardPool));
for ii = 1:length(photonCellArray)
    photonCellArray{ii} = sensorGet(standardPool{ii}, 'photons');
end
photonCellArray = cellfun(@(x)mean2(x),photonCellArray, 'UniformOutput', 0);
calcParams.meanStandard = mean(cat(1,photonCellArray{:}));

% Loop through the illumination number
for ii = 1:maxImageIllumNumber
    fprintf('Running trials for %s illumination step %u\n', prefix, ii);
    
    % Precompute the test image pool to save computational time.
    imageName = fileList{ii};
    imageName = strrep(imageName, 'OpticalImage.mat', '');
    testPool = cell(1, calcParams.comparisonImageSetSize);
    for oo = 1:calcParams.comparisonImageSetSize
        if oo > 1
            imageName = strrep(imageName, 'L-', ['L' int2str(oo - 1) '-']);
        end
        oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' folderName], imageName);
        sensorTest = sensorSet(sensor, 'noise flag', 0);
        oiTest = resizeOI(oiTest, sensorGet(sensorTest, 'fov')*1.1);
        sensorTest = coneAbsorptions(sensorTest, oiTest);
        testPool{oo} = sensorTest;
    end
    
    % Loop through the k values
    for jj = 1:KpSampleNum
        Kp = calcParams.startKp + KpInterval * (jj - 1);
        
        for kk = 1:KgSampleNum
            Kg = calcParams.startKg + KgInterval * (kk - 1);
            correct = 0;
            
            % Run the desired number of trials
            tic
            for tt = 1:numTrials
                
                % We choose 2 images without replacement from the standard
                % image pool. This is in order to account for the rendering
                % noise.
                standardChoice = randsample(length(standardOIList), 2);
                
                % Randomly choose one image from the test pool
                testChoice = randsample(calcParams.comparisonImageSetSize, 1);
                
                % Get inital noisy ref image
                photonsStandardRef = getNoisySensorImage(calcParams,standardPool{standardChoice(1)},Kp,Kg);
                
                % Get noisy version of standard image
                photonsStandardComp = getNoisySensorImage(calcParams,standardPool{standardChoice(2)},Kp,Kg);
                
                % Get noisy version of test image
                photonsTestComp = getNoisySensorImage(calcParams,testPool{testChoice},Kp,Kg);

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
            fprintf('Calculation time for Kp %.2f, Kg %.2f = %2.1f\n', Kp, Kg, toc);
            accuracyMatrix(ii,jj,kk) = correct / numTrials * 100;
        end
    end
end

results = accuracyMatrix;
end

function results = computeByColor(calcParams, sensor, colorChoice)
% computeByColor(calcParams, sensor, colorChoice)
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

%% This is the first part of the OI file names
prefix = {'blue' , 'green', 'red', 'yellow'};

%% Point at where the input data lives
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');

%% List where the images will be stored on ColorShare1
targetFolder = calcParams.cacheFolderList{2};

imageDir = fullfile(analysisDir, 'OpticalImageData', targetFolder);
contents = dir(imageDir);
folderList = cell(1,5);
for ii = 1:length(contents)
    curr = contents(ii);
    if ~strcmp(curr.name,'.') && ~strcmp(curr.name,'..') && curr.isdir
        emptyCells = cellfun('isempty', folderList);
        firstIndex = find(emptyCells == 1, 1);
        folderList{firstIndex} = curr.name;
    end
end

% The list is alphabetical and 'standard' is fourth
standard = folderList{4};
folderList = [folderList(1:3) folderList(5)];
TargetPath = fullfile(analysisDir, 'SimpleChooserData', calcParams.calcIDStr);

%% Allocate space for the results
if colorChoice == 0
    results = cell(4,1);
else
    results = cell(1,1);
end

%% Run the model based on the calcParam specifications
if colorChoice == 0
    for i=1:length(folderList)
        matrix = singleColorKValueComparison(calcParams, sensor, ...
            fullfile(targetFolder, standard), folderList{i}, prefix{i});
        fileName = strcat(prefix{i}, ['IllumComparison' calcParams.calcIDStr]);
        saveDir = fullfile(TargetPath, fileName);
        save(saveDir, 'matrix');
        results{i} = matrix;
    end
else
    matrix = singleColorKValueComparison(calcParams, sensor, ...
        fullfile(targetFolder, standard), folderList{colorChoice}, prefix{colorChoice});
    fileName = strcat(prefix{colorChoice}, ['IllumComparison' calcParams.calcIDStr]);
    saveDir = fullfile(TargetPath, fileName);
    save(saveDir, 'matrix');
    results = matrix;
end

saveDir = fullfile(TargetPath, ['calcParams' calcParams.calcIDStr]);
save(saveDir, 'calcParams');
end

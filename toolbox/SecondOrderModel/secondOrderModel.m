function secondOrderModel(calcParams, colorChoice, overWrite, frozen)
% secondOrderModel(calcParams, colorChoice, overWrite, frozen)
%
% This function is analogous to firstOrderModel.  Here, some additional
% features are implemented into our model.  They include fixational eye
% movements and cone adaptation code from ISETBIO.
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
% 7/27/15  xd  copied base code from first order model
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
baseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
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

% Adjust eye movements
em = emCreate;
em = emSet(em, 'emFlag', [calcParams.enableTremor calcParams.enableDrift calcParams.enableMSaccades]);
em = emSet(em, 'sample time', calcParams.coneIntegrationTime);

sensor = sensorSet(sensor, 'eye move', em);
sensor = sensorSet(sensor, 'positions', calcParams.EMPositions);

%% Compute according to the input color choice
computeByColor(calcParams, sensor, colorChoice);
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
data = what(folderPath);
fileList = data.mat;
fileList = sort(fileList);
[~,b] = sort(cellfun(@numel, fileList));
fileList = fileList(b);
fileList = fileList((cellfun(@(x)any(isempty(regexp(x,'L[\d]','once'))),fileList) == 1)); % Removes any additional renderings of test images, they will be used later

%% Preallocate space for the accuracy matrix which will store the results of the calculations
accuracyMatrix = zeros(maxImageIllumNumber, KpSampleNum, KgSampleNum);

%% Run calculations up to illumination number and k-value limits

% Load the pool of standard OI and their sensors
standardPool = cell(1, calcParams.targetImageSetSize);
for ii = 1:calcParams.targetImageSetSize
    opticalImageName = ['TestImage' int2str(ii - 1)];
    oi = loadOpticalImageData(standardPath, opticalImageName);
    sensorStandard = sensorSet(sensor, 'noise flag', 0);
    standardPool{ii} = {sensorStandard; oi; -1; -1};
end

% Normally, the mean isomerizations in the stardard images are calculated
% to in case some form of Gaussian noise is desired.  However, it is
% unclear how this should be approached in the case where the data is a
% time series. It is left at 0 for now, meaning this functionality does not
% exist of the second order model.
calcParams.meanStandard = 0;

% If saccadic movement is desired, the boundary of possible movement
% locations will be set to the size of the optical image, allowing for
% saccadic movement over the whole image.
if calcParams.numSaccades > 1
    s.n = calcParams.numSaccades;
    resizedSensor = sensorSetSizeToFOV(standardPool{1}{1}, oiGet(standardPool{1}{2}, 'fov'), [], standardPool{1}{2});
    ss = sensorGet(resizedSensor, 'size');
    bound = [-round(ss(1)/2) round(ss(1)/2) -round(ss(2)/2) round(ss(2)/2)];
end

% The LMS mask thus is the whole image.  Here we precompute it for the
% standard image pool.
rows = [bound(4) bound(4)];
cols = [bound(2) bound(2)];
LMSpath = [bound(2) bound(4); bound(1) bound(3)];
for qq = 1:length(standardPool)
    sensorTemp = sensorSet(standardPool{qq}{1}, 'positions', LMSpath);
    [standardPool{qq}{3}, standardPool{qq}{4}] = coneAbsorptionsLMS(sensorTemp, standardPool{qq}{2});
end

% If there is existing eye movement data, we will preload it here. The data
% should be in the format of a 3D matrix, with the third dimension
% representing illumination level.
if (~isempty(calcParams.pathFile))
    EMdata = load(calcParams.pathFile);
    EMdata = EMdata.EMdata;
else
    EMdata = [];
end

% Loop through the illumination number
for ii = 1:maxImageIllumNumber
    fprintf('Running trials for %s illumination step %u\n', prefix, ii);
    
    % Precompute the LMS for the test pool as well.
    imageName = fileList{ii};
    imageName = strrep(imageName, 'OpticalImage.mat', '');
    testPool = cell(1, calcParams.comparisonImageSetSize);
    for oo = 1:calcParams.comparisonImageSetSize
        if oo > 1
            imageName = strrep(imageName, 'L-', ['L' int2str(oo - 1) '-']);
        end
        oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' folderName], imageName);
        sensorTest = sensorSet(sensor, 'noise flag', 0);
        sensorTest = sensorSet(sensorTest, 'positions', LMSpath);
        [LMS, msk] = coneAbsorptionsLMS(sensorTest, oiTest);
        testPool{oo} = {sensorTest; LMS; msk};
    end
    
    % Loop through the k values
    for jj = 1:KpSampleNum
        Kp = calcParams.startKp + KpInterval * (jj - 1);
        
        for kk = 1:KgSampleNum
            Kg = calcParams.startKg + KgInterval * (kk - 1);
            correct = 0;
            
            % Simulate out over numTrials simulated trials
            tic
            for tt = 1:numTrials
                % Load or generate eye movement path based on whether there
                % is a path file loaded
                if ~isempty(EMdata)
                    sizeOfPaths = size(EMdata);
                    if sizeOfPaths(2) == 2
                        thePaths = getEMPaths(sensor, 1, 'fullPath', EMdata(:,:,ii), 'bound', bound);
                        thePaths = repmat(thePaths, [1 1 3]);
                    elseif sizeOfPaths(2) == 6
                        thePaths(:,:,1) = getEMPaths(sensor, 1, 'fullPath', EMdata(:,1:2,ii), 'bound', bound);
                        thePaths(:,:,2) = getEMPaths(sensor, 1, 'fullPath', EMdata(:,3:4,ii), 'bound', bound);
                        thePaths(:,:,3) = getEMPaths(sensor, 1, 'fullPath', EMdata(:,5:6,ii), 'bound', bound);
                    else
                        error('Invalid sized path file given!');
                    end
                else
                    if calcParams.useSameEMPath
                        % If the same path is to be used for all three images,
                        % we generate one path and duplicate it three times.
                        thePaths = getEMPaths(sensor, 1, 'saccades', s, 'bound', bound, 'loc', calcParams.EMLoc);
                        thePaths = repmat(thePaths, [1 1 3]);
                    else
                        % Need to have the option to load 3 pre-generated paths
                        thePaths = getEMPaths(sensor, 3, 'saccades', s, 'bound', bound, 'loc', calcParams.EMLoc);
                    end
                end
                
                % We choose 2 images without replacement from the standard image pool.
                % This is in order to account for the pixel noise present from the renderer.
                standardChoice = randsample(calcParams.targetImageSetSize, 2);
                
                % Randomly choose one image from the test pool
                testChoice = randsample(calcParams.comparisonImageSetSize, 1);
                
                % Set the paths
                standardRef = sensorSet(standardPool{standardChoice(1)}{1}, 'positions', thePaths(:,:,1));
                standardComp = sensorSet(standardPool{standardChoice(2)}{1}, 'positions', thePaths(:,:,2));
                testComp = sensorSet(testPool{testChoice}{1}, 'positions', thePaths(:,:,3));

                % Get absorptions
                standardRef = coneAbsorptionsApplyPath(standardRef, standardPool{standardChoice(1)}{3}, standardPool{standardChoice(1)}{4}, rows, cols);
                standardComp = coneAbsorptionsApplyPath(standardComp, standardPool{standardChoice(2)}{3}, standardPool{standardChoice(2)}{4}, rows, cols);
                testComp = coneAbsorptionsApplyPath(testComp, testPool{testChoice}{2}, testPool{testChoice}{3}, rows, cols);
                
                % Get noisy photon images. We will apply the desired
                % combination of Poisson and/or Gaussian noise.
                dataStandardRef = getNoisySensorImage(calcParams,standardRef,Kp,Kg);
                dataStandardComp = getNoisySensorImage(calcParams,standardComp,Kp,Kg);
                dataTestComp = getNoisySensorImage(calcParams,testComp,Kp,Kg);
                
                % This is in case we want to use the OS code. The type of
                % OS used is specified in the calcParams. The cone current
                % response replaces the isomerization data.= for further
                % calculations.
                if calcParams.enableOS
                    standardRef = sensorSet(standardRef, 'photons', dataStandardRef);
                    standardComp = sensorSet(standardComp, 'photons', dataStandardComp);
                    testComp = sensorSet(testComp, 'photons', dataTestComp);
                    os = osCreate(calcParams.OSType);
                    os = osSet(os, 'noiseFlag', calcParams.enableOSNoise);
                    os1 = osCompute(os, standardRef);
                    dataStandardRef = os1.coneCurrentSignal;
                    os2 = osCompute(os,standardComp);
                    dataStandardComp = os2.coneCurrentSignal;
                    os3 = osCompute(os,testComp);
                    dataTestComp = os3.coneCurrentSignal;
                end
                
                % We make sure that the summing interval divides evenly
                % into our total integration time.  If it does, we sum the
                % data accordingly.  Otherwise, throw an error.
                if calcParams.sumEM
                    if calcParams.sumEMInterval <= calcParams.totalTime
                        samples = calcParams.totalTime/calcParams.sumEMInterval;
                        if rem(100, 1)
                            error('sumEMInterval does not divide total integration time evenly')
                        end
                        dS = size(dataStandardComp);
                        dataStandardRef = sum(reshape(dataStandardRef, dS(1), dS(2), samples, []), 4);
                        dataStandardComp = sum(reshape(dataStandardComp, dS(1), dS(2), samples, []), 4);
                        dataTestComp = sum(reshape(dataTestComp, dS(1), dS(2), samples, []), 4);
                    end
                end
                
                % Calculate vector distance from the test image and
                % standard image to the reference image
                distToStandard = norm(dataStandardRef(:)-dataStandardComp(:));
                distToTest = norm(dataStandardRef(:)-dataTestComp(:));
                
                % Decide if the model was correct on this trial
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

function computeByColor(calcParams, sensor, colorChoice)
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

%% Point at where input data live
analysisDir = getpref('BLIlluminationDiscriminationCalcs', 'AnalysisDir');

%% List of where the images will be stored on ColorShare1
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

% The list is alphabetical and standard is fourth
standard = folderList{4};
folderList = [folderList(1:3) folderList(5)];

TargetPath = fullfile(analysisDir, 'SimpleChooserData', calcParams.calcIDStr);

if (colorChoice == 0)
    for i=1:length(folderList)
        matrix = singleColorKValueComparison(calcParams, sensor, ...
            fullfile(targetFolder, standard), folderList{i}, prefix{i});
        fileName = strcat(prefix{i}, ['IllumComparison' calcParams.calcIDStr]);
        saveDir = fullfile(TargetPath, fileName);
        save(saveDir, 'matrix');
    end
else
    matrix = singleColorKValueComparison(calcParams, sensor, ...
        fullfile(targetFolder, standard), folderList{colorChoice}, prefix{colorChoice});
    fileName = strcat(prefix{colorChoice}, ['IllumComparison' calcParams.calcIDStr]);
    saveDir = fullfile(TargetPath, fileName);
    save(saveDir, 'matrix');
end

if exist(['Path' calcParams.calcIDStr], 'file')
    delete(['Path' calcParams.calcIDStr]);
end

saveDir = fullfile(TargetPath, ['calcParams' calcParams.calcIDStr]);
save(saveDir, 'calcParams');
end

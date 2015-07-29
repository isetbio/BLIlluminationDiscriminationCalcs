function OSModel(calcParams, colorChoice, overWrite)
% secondOrderModel(calcParams, colorChoice, overWrite)
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
%       overWrite   - This flag determines whether this function will
%                     write over any existing files in a target directory.
%                     Set this to 1 to write over, 0 to avoid doing so.
%
% 7/28/15  xd  copied base code from second order model

%% Set defaults for inputs
if notDefined('overWrite'), overWrite = 0; end

%% Set RNG seed to be time dependent
% 
% For some reason, the RNG does the same thing everytime when run on the
% blocks computer
rng('shuffle');

%% Check for faulty parameters
if calcParams.targetImageSetSize < 2
    error('Must have a standard image pool size of at least 2');
end

%% Check if destination folder exists and has files
baseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
targetPath = fullfile(baseDir, 'SimpleChooserData', calcParams.calcIDStr);

% Make a new directory if target is non-existant, otherwise follow the
% overWrite flag
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

%% Create outersegment object
switch(calcParams.osType)
    case 1
        OS = osLinear('noiseflag', 1);
    case 2
        OS = osBioPhys('noiseflag', 1);
end

%% Get a list of images

% This will return the list of optical images in ascending illum number
% order.  In addition, if a specific illumination number has more than one
% copy, the file name should formatted like 'blue1L#-RGB...' where #
% represents the copy number.  For consistency, I believe these should also
% be zero indexed like the standard are, except that the 0th term will not have a #. 
% In this case # would start with 1. Code beyond this point will assume these conditions.
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
folderPath = fullfile(dataBaseDir, 'OpticalImageData', calcParams.cacheFolderList{2}, folderName);
data = what(folderPath);
fileList = data.mat;
fileList = sort(fileList);
[~,b] = sort(cellfun(@numel, fileList));
fileList = fileList(b);
fileList = fileList((cellfun(@(x)any(isempty(regexp(x,'L[\d]','once'))),fileList) == 1)); % Removes any copies of test images

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

% % Compute the mean of the standardPool isomerizations.  This will serve as
% % the standard deviation of an optional Gaussian noise factor Kg.
% photonCellArray = cell(1, length(standardPool));
% for ii = 1:length(photonCellArray)
%     photonCellArray{ii} = sensorGet(standardPool{ii}, 'photons');
% end
% photonCellArray = cellfun(@(x)mean2(x),photonCellArray, 'UniformOutput', 0);
% calcParams.meanStandard = mean(cat(1,photonCellArray{:}));
% 
% CHANGE THIS TO THE MEAN OF THE LMS???? or perhaps mask at 0,0
calcParams.meanStandard = 0;

% Loop through the illumination number
for ii = 1:maxImageIllumNumber
    fprintf('Running trials for %s illumination step %u\n', prefix, ii);
    
    % Get all the eye movements to be used for these trials
    if calcParams.useSameEMPath
        pathsForThisSet = getEMPaths(sensor, numTrials);
    else
        pathsForThisSet = getEMPaths(sensor, 3 * numTrials);
    end
    
    % We calculate the LMS by getting the max and min eye positions from
    % every possible path for this trial.
    pathSize = size(pathsForThisSet);
    maxEM = max(pathsForThisSet);
    maxEM = reshape(maxEM, pathSize(2:3))';
    minEM = min(pathsForThisSet);
    minEM = reshape(minEM, pathSize(2:3))';
    LMSpath = [maxEM; minEM];
    rows = [-min([LMSpath(:,2); 0]) max([LMSpath(:,2); 0])];
    cols = [max([LMSpath(:,1); 0]) -min([LMSpath(:,1); 0])];
    for qq = 1:length(standardPool)
        sensorTemp = sensorSet(standardPool{qq}{1}, 'positions', LMSpath);
        [standardPool{qq}{3}, standardPool{qq}{4}] = coneAbsorptionsLMS(sensorTemp, standardPool{qq}{2});
    end
    
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
    
%     pathIndex = 1;
    
    % Loop through the k values
    for jj = 1:KpSampleNum
        Kp = calcParams.startKp + KpInterval * (jj - 1);
        
        for kk = 1:KgSampleNum
            Kg = calcParams.startKg + KgInterval * (kk - 1);
            correct = 0;
            
            % Simulate out over calcNumber simulated trials
            tic
            for tt = 1:numTrials
                
                if calcParams.useSameEMPath
%                     thePaths = [pathIndex pathIndex pathIndex];
                    thePaths = randsample(numTrials, 1);
%                     pathIndex = pathIndex + 1;
                else
%                     thePaths = [pathIndex pathIndex+1 pathIndex+2];
                    thePaths = randsample(3 * numTrials, 3);
%                     pathIndex = pathIndex + 3;
                end
                
                % We choose 2 images without replacement from the standard image pool.
                % This is in order to account for the pixel noise present from the renderer.
                standardChoice = randsample(calcParams.targetImageSetSize, 2);
                
                % Randomly choose one image from the test pool
                testChoice = randsample(calcParams.comparisonImageSetSize, 1);
                
                % Set the paths
                standardRef = sensorSet(standardPool{standardChoice(1)}{1}, 'positions', pathsForThisSet(:,:, thePaths(1)));
                standardComp = sensorSet(standardPool{standardChoice(2)}{1}, 'positions', pathsForThisSet(:,:, thePaths(2)));
                testComp = sensorSet(testPool{testChoice}{1}, 'positions', pathsForThisSet(:,:, thePaths(3)));
                
                % Get absorptions
                standardRef = coneAbsorptionsApplyPath(standardRef, standardPool{standardChoice(1)}{3}, standardPool{standardChoice(1)}{4}, rows, cols);
                standardComp = coneAbsorptionsApplyPath(standardComp, standardPool{standardChoice(2)}{3}, standardPool{standardChoice(2)}{4}, rows, cols);
                testComp = coneAbsorptionsApplyPath(testComp, testPool{testChoice}{2}, testPool{testChoice}{3}, rows, cols);
                
                % Calculate the os response
                params.bgVolts = 0;
                os.compute(standardRef, params);
                currentStandardRef = os.ConeCurrentSignalPlusNoise;
                os.compute(standardComp, params);
                currentStandardComp = os.ConeCurrentSignalPlusNoise;
                os.compute(testComp, params);
                currentTestComp = os.ConeCurrentSignalPlusNoise;
                
%                 % Check if result is 3D, in that case take sum of slices
%                 if calcParams.enableEM
%                     photonsStandardRef = sum(photonsStandardRef,3);
%                     photonsStandardComp = sum(photonsStandardComp,3);
%                     photonsTestComp = sum(photonsTestComp,3);
%                 end
                
                % Calculate vector distance from the test image and
                % standard image to the reference image
                distToStandard = norm(currentStandardRef(:)-currentStandardComp(:));
                distToTest = norm(currentStandardRef(:)-currentTestComp(:));
                
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

%     folderList = {'BlueIllumination', 'GreenIllumination', ...
%         'RedIllumination', 'YellowIllumination'};
prefix = {'blue' , 'green', 'red', 'yellow'};

%% Point at where input data live
dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% List of where the images will be stored on ColorShare1
targetFolder = calcParams.cacheFolderList{2};

imageDir = fullfile(dataBaseDir, 'OpticalImageData', targetFolder);
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

BaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
TargetPath = fullfile(BaseDir, 'SimpleChooserData', calcParams.calcIDStr);

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

saveDir = fullfile(TargetPath, ['calcParams' calcParams.calcIDStr]);
save(saveDir, 'calcParams');
fprintf('Current calculation complete');

end
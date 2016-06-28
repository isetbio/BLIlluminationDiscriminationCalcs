function results = m2_SecondOrderModel(calcParams,sensor,color)
% results = m2_SecondOrderModel(calcParams,sensor,color)
%
%
%
% xd  6/24/16  wrote it

%% Set values for variables that will be used through the function
illumLevels = calcParams.illumLevels;
KpLevels = calcParams.KpLevels;
KgLevels = calcParams.KgLevels;
trainingSetSize = calcParams.trainingSetSize;
testingSetSize = calcParams.testingSetSize;
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

%% Load standard stuff
% The way we store these data is that we keep the full sized OI as well as
% the LMS absorptions as well as a mask which tells us which cones are at
% each location. This allows for easy extraction of the cone signal at a
% given location.
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},'Standard');
standardOIList = getFilenamesInDirectory(folderPath);
standardPool = cell(1,length(standardOIList));
for ii = 1:length(standardOIList)
    opticalImageName = standardOIList{ii};
    opticalImageName = strrep(opticalImageName,'OpticalImage.mat','');
    oi = loadOpticalImageData(fullfile(calcParams.cacheFolderList{2},'Standard'),opticalImageName);
    oi = resizeOI(oi,calcParams.sensorFOV*calcParams.OIvSensorScale);
    standardPool{ii} = {oi;-1;-1};
end

% Normally, the mean isomerizations in the stardard images are calculated
% to in case some form of Gaussian noise is desired.  However, it is
% unclear how this should be approached in the case where the data is a
% time series. It is left at 0 for now, meaning this functionality does not
% exist in the second order model.
calcParams.meanStandard = 0;

%% Set up eye movement things
% If saccadic movement is desired, the boundary of possible movement
% locations will be set to the size of the optical image, allowing for
% saccadic movement over the whole image.
s.n = calcParams.numSaccades;
resizedSensor = sensorSetSizeToFOV(sensor,oiGet(standardPool{1}{1},'fov'),[],standardPool{1}{1});
ss = sensorGet(resizedSensor,'size');
bound = [floor(-ss(1)/2) ceil(ss(1)/2) floor(-ss(2)/2) ceil(ss(2)/2)];

% The LMS mask thus is the whole image. Here we precompute it for the
% standard image pool.
rows = [bound(4) bound(4)];
cols = [bound(2) bound(2)];
LMSpath = [bound(2) bound(4); bound(1) bound(3)];
for qq = 1:length(standardPool)
    sensorTemp = sensorSet(sensor,'positions',LMSpath);
    [standardPool{qq}{2},standardPool{qq}{3}] = coneAbsorptionsLMS(sensorTemp,standardPool{qq}{1});
end

%% Calculation Body
% Get a list of images
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},[color 'Illumination']);
OINamesList = getFilenamesInDirectory(folderPath);

% Preallocate space for the results of the calculations
results = zeros(length(illumLevels),length(KpLevels),length(KgLevels));
for ii = 1:length(illumLevels)
    fprintf('Running trials for %s illumination step %u\n',color,illumLevels(ii));
    
    % Precompute the LMS for the test pool as well.
    imageName = OINamesList{illumLevels(ii)};
    imageName = strrep(imageName,'OpticalImage.mat','');
    oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' [color 'Illumination']],imageName);
    oiTest = resizeOI(oiTest,calcParams.sensorFOV*calcParams.OIvSensorScale);
    sensorTest = sensorSet(sensor,'positions',LMSpath);
    [LMS, msk] = coneAbsorptionsLMS(sensorTest,oiTest);
    testPool = {sensorTest;LMS;msk};
    
    % Loop through the k values
    for jj = 1:length(KpLevels)
        Kp = KpLevels(jj);
        
        for kk = 1:length(KgLevels)
            Kg = KgLevels(kk);
            tic
            if calcParams.useSameEMPath
                % If the same path is to be used for all three images,
                % we generate one path and duplicate it three times.
                thePaths = getEMPaths(sensor,1,'saccades',s,'bound',bound,'loc',calcParams.EMLoc);
                thePaths = repmat(thePaths, [1 1 3]);
            else
                % Need to have the option to load 3 pre-generated paths
                thePaths = getEMPaths(sensor,3,'saccades',s,'bound',bound,'loc',calcParams.EMLoc);
            end
            
            % We choose 2 images without replacement from the standard image pool.
            % This is in order to account for the pixel noise present from the renderer.
            standardChoice = randsample(length(standardOIList),2);
            
            % Set the paths
            standardRef  = sensorSet(sensor,'positions',thePaths(:,:,1));
            standardComp = sensorSet(sensor,'positions',thePaths(:,:,2));
            testComp     = sensorSet(sensor,'positions',thePaths(:,:,3));
            
            % Get absorptions
            standardRef  = coneAbsorptionsApplyPath(standardRef,standardPool{standardChoice(1)}{2},standardPool{standardChoice(1)}{3},rows,cols);
            standardComp = coneAbsorptionsApplyPath(standardComp,standardPool{standardChoice(2)}{2},standardPool{standardChoice(2)}{3},rows,cols);
            testComp     = coneAbsorptionsApplyPath(testComp,testPool{2},testPool{3},rows,cols);
            
            %% Replace below with new code
            % Create an appropriate os
            os = [];
            if calcParams.enableOS
                os = osCreate(calcParams.OSType); 
                os = osSet(os,'noise flag',calcParams.enableOSNoise);
            end
            datasetFunction = masterDataFunction(calcParams.dFunction);
            [trainingData,trainingClasses] = datasetFunction(calcParams,{standardRef;standardComp},{testComp},Kp,Kg,trainingSetSize,os);
            [testingData,testingClasses] = datasetFunction(calcParams,{standardRef;standardComp},{testComp},Kp,Kg,testingSetSize,os);
            
            % Reshape the data into its original temporal 3D matrix form.
            % This will allow us to sum the data over time if desired.
            % After summing, we take care to put it back into its matrix
            % format.
            if calcParams.sumEM
                DataSize = size(sensorGet(standardRef,'photons'));
                tempDataMatrix = zeros(trainingSetSize,DataSize(1)*DataSize(2));
                for rr = 1:trainingSetSize
                    summedA = sum(reshape(trainingData(1:end/2,:),DataSize),3);
                    summedB = sum(reshape(trainingData(end/2+1:end,:),DataSize),3);
                    tempDataMatrix(rr,:) = [summedA summedB];
                end
                trainingData = tempDataMatrix;
                tempDataMatrix = zeros(testingSetSize,DataSize(1)*DataSize(2));
                for rr = 1:testingSetSize
                    summedA = sum(reshape(testingData(1:end/2,:),DataSize),3);
                    summedB = sum(reshape(testingData(end/2+1:end,:),DataSize),3);
                    tempDataMatrix(rr,:) = [summedA summedB];
                end
                testingData = tempDataMatrix;
            end
            
            % Standardize data if flag is set to true
            if calcParams.standardizeData
                m = mean(trainingData,1);
                s = std(trainingData,1);
                trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                testingData = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
            end
            
            classifierFunction = masterClassifierFunction(calcParams.cFunction);
            results(ii,jj,kk) = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);
            
            % Print the time the calculation took
            fprintf('Calculation time for Kp %.2f, Kg %.2f = %2.1f\n', Kp, Kg, toc);
        end
    end
end

end


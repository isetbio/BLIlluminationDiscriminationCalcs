function results = m2_SecondOrderModel(calcParams,mosaic,color)
% results = m2_SecondOrderModel(calcParams,mosaic,color)
%
% The revamped code for the second order model. Computes and performs
% classification on data with eye movements and/or cone currents. 
%
% Inputs:
%     calcParams  -  calcParams struct with parameters for the calculation
%     mosaic      -  ISETBIO coneMosaic object to use for calculating the 
%                    isomerizations
%     color       -  string describing which color direction to use
%
% Outputs:
%     results  -  a matrix containing percent corrects for noise levels and
%                 illumination steps
%
% 6/24/16  xd  wrote it

%% Set values for variables that will be used through the function
illumLevels     = calcParams.illumLevels;
KpLevels        = calcParams.KpLevels;
KgLevels        = calcParams.KgLevels;
trainingSetSize = calcParams.trainingSetSize;
testingSetSize  = calcParams.testingSetSize;
analysisDir     = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

% Set a function to load optical images depending on whether we are running
% for real or validating the code.
oiLoaderFunction = @(x,y) loadOpticalImageData(x,y);
filenameFunction = @(x) getFilenamesInDirectory(x);
if calcParams.validation
    oiLoaderFunction = @(x,y) loadOpticalImageDataWithRDT(x,y);
    filenameFunction = @(x) getFilenamesInDirectoryWithRDT(x);
end

%% Load standard stuff
% The way we store these data is that we keep the full sized OI as well as
% the LMS absorptions as well as a mask which tells us which cones are at
% each location. This allows for easy extraction of the cone signal at a
% given location.
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},'Standard');
standardOIList = filenameFunction(folderPath);
standardPool = cell(1,length(standardOIList));
for ii = 1:length(standardOIList)
    opticalImageName = standardOIList{ii};
    opticalImageName = strrep(opticalImageName,'OpticalImage.mat','');
    oi = oiLoaderFunction(fullfile(calcParams.cacheFolderList{2},'Standard'),opticalImageName);
    oi = resizeOI(oi,calcParams.sensorFOV*calcParams.OIvSensorScale);
    standardPool{ii} = oi;
end

%% Set up eye movement things
% If saccadic movement is desired, the boundary of possible movement
% locations will be set to the size of the optical image, allowing for
% saccadic movement over the whole image.
tempMosaic = mosaic.copy;
tempMosaic.fov = oiGet(standardPool{1},'fov');

% Our lives will be easier if the difference in mosaic sizes is even. The
% values are used for some indexing scheme in the compute functions. There
% may be some way to fix it but I have no interest in giving myself a
% headache.
colPadding = (tempMosaic.cols-mosaic.cols)/2;
rowPadding = (tempMosaic.rows-mosaic.rows)/2;
if mod(colPadding,1), tempMosaic.cols = tempMosaic.cols + 1; end
if mod(rowPadding,1), tempMosaic.rows = tempMosaic.rows + 1; end
calcParams.colPadding = (tempMosaic.cols-mosaic.cols)/2;
calcParams.rowPadding = (tempMosaic.rows-mosaic.rows)/2;

% The LMS mask thus is the whole image. Here we precompute it for the
% standard image pool. Normally, the mean isomerizations in the stardard
% images are calculated too in case some form of Gaussian noise is desired.
% Because we can't really predict what the eye movements will be (and thus
% what paths will be sampled) ahead of time, we will just the mean of the
% entire LMS mask.
calcParams.meanStandard = 0;
for qq = 1:length(standardPool)
    standardPool{qq} = tempMosaic.computeSingleFrame(standardPool{qq},'FullLMS',true);
    
    % Need to multiply mask with actual mosaic
    tempMask = zeros([size(tempMosaic.pattern) 3]);
    for ii = 2:4
        tempMask(:,:,ii-1) = single(tempMosaic.pattern==ii);
    end
    calcParams.meanStandard = calcParams.meanStandard + mean2(sum(standardPool{qq}.*tempMask,3))/length(standardPool);
end
clearvars tempMask

%% Calculation Body
% Get a list of images
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},[color 'Illumination']);
OINamesList = filenameFunction(folderPath);

% Set a starting Kg value. This will allow us to stop calculating Kg values
% when it is clear the remaining stimulus levels will return 100%. We set
% this by checking the last five calculated performance values.
startKg = 1;

% Preallocate space for the results of the calculations
results = zeros(length(illumLevels),length(KpLevels),length(KgLevels));
for ii = 1:length(illumLevels)
    % Precompute the LMS for the test pool as well.
    imageName = OINamesList{illumLevels(ii)};
    imageName = strrep(imageName,'OpticalImage.mat','');
    oiTest = oiLoaderFunction([calcParams.cacheFolderList{2} '/' [color 'Illumination']],imageName);
    oiTest = resizeOI(oiTest,calcParams.sensorFOV*calcParams.OIvSensorScale);
    LMS = tempMosaic.computeSingleFrame(oiTest,'FullLMS',true);
    testPool = {LMS};
    
    % Loop through the k values
    tic
    for jj = 1:length(KpLevels)
        Kp = KpLevels(jj);
        
        for kk = startKg:length(KgLevels)
            Kg = KgLevels(kk);
            
            %% Replace below with new code
            datasetFunction = masterDataFunction(calcParams.dFunction);
            [trainingData,trainingClasses] = datasetFunction(calcParams,standardPool,testPool,Kp,Kg,trainingSetSize,mosaic);
            [testingData,testingClasses]   = datasetFunction(calcParams,standardPool,testPool,Kp,Kg,testingSetSize,mosaic);
            
            % Standardize data if flag is set to true
            if calcParams.standardizeData
                m = mean(trainingData,1);
                s = std(trainingData,1);
                trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                testingData  = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
            end
            
            if calcParams.usePCA
                coeff = pca(trainingData,'NumComponents',calcParams.numPCA);
                trainingData = trainingData*coeff;
                testingData = testingData*coeff;
            end
            
            % Perform classification
            classifierFunction = masterClassifierFunction(calcParams.cFunction);
            results(ii,jj,kk) = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);
        end
    end
    
    % Print the time the calculation took
    fprintf('Calculation time for %s illumination step %u: %04.3f s\n',color,illumLevels(ii),toc);
    
    % Update the last 5 correct and check if startKg needs to be shifted.
    % If the average of the last 5 is greater than 99.5%, we set the
    % remaining values for each illumination level for the startKg noise
    % level to equal 100%. We then add 1 to the start Kg. This should
    % provide a nice boost to performance speed without affecting the model
    % results.
    if ii >= 5
        lastFiveCorrect = squeeze(results(ii-4:ii,1,startKg));
        if mean(lastFiveCorrect) > 99.6 
            results(ii+1:end,1,startKg) = 100;
            startKg = startKg + 1;
        end
        
        % If startKg is greater than the number of kg levels, break out of
        % this loop (since the calculation has effectively ended).
        if startKg > length(KgLevels)
            break
        end
    end
end

end


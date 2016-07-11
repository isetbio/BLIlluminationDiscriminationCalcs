function results = m2_SecondOrderModel(calcParams,mosaic,color)
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
    standardPool{ii} = oi;
end

% Normally, the mean isomerizations in the stardard images are calculated
% too in case some form of Gaussian noise is desired.  However, it is
% unclear how this should be approached in the case where the data is a
% time series. It is left at 0 for now, meaning this functionality does not
% exist in the second order model.
calcParams.meanStandard = 0;

%% Set up eye movement things
% If saccadic movement is desired, the boundary of possible movement
% locations will be set to the size of the optical image, allowing for
% saccadic movement over the whole image.
tempMosaic = mosaic.copy;
tempMosaic.fov = oiGet(standardPool{1},'fov');

colPadding = (tempMosaic.cols-mosaic.cols)/2;
rowPadding = (tempMosaic.rows-mosaic.rows)/2;
if ~isinteger(colPadding), tempMosaic.cols = tempMosaic.cols - 1; end
if ~isinteger(rowPadding), tempMosaic.rows = tempMosaic.rows - 1; end
calcParams.colPadding = (tempMosaic.cols-mosaic.cols)/2;
calcParams.rowPadding = (tempMosaic.rows-mosaic.rows)/2;

% The LMS mask thus is the whole image. Here we precompute it for the
% standard image pool.
for qq = 1:length(standardPool)
    standardPool{qq} = tempMosaic.computeSingleFrame(standardPool{qq},'FullLMS',true);
    calcParams.meanStandard = calcParams.meanStandard + mean2(standardPool{qq})/length(standardPool);
end

%% Calculation Body
% Get a list of images
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},[color 'Illumination']);
OINamesList = getFilenamesInDirectory(folderPath);

% Preallocate space for the results of the calculations
results = zeros(length(illumLevels),length(KpLevels),length(KgLevels));
for ii = 1:length(illumLevels)
    % Precompute the LMS for the test pool as well.
    imageName = OINamesList{illumLevels(ii)};
    imageName = strrep(imageName,'OpticalImage.mat','');
    oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' [color 'Illumination']],imageName);
    oiTest = resizeOI(oiTest,calcParams.sensorFOV*calcParams.OIvSensorScale);
    LMS = tempMosaic.computeSingleFrame(oiTest,'FullLMS',true);
    testPool = {LMS};
    
    % Loop through the k values
    tic
    for jj = 1:length(KpLevels)
        Kp = KpLevels(jj);
        
        for kk = 1:length(KgLevels)
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
                testingData = (testingData - repmat(m,testingSetSize,1)) ./ repmat(s,testingSetSize,1);
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
end

end


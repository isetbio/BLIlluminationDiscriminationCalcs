function results = m1_FirstOrderModel(calcParams,mosaic,color)
% results = m1_FirstOrderModel(calcParams,mosaic,color)
%
% This function performs the computational observer calculation on a 'First
% Order' level. By this, we mean that a static cone mosaic (without eye
% movement) is used to calculate the number of isomerizations given a
% scene. This information is used in desired classification function to
% simulate our illumination discrimination experiment.
%
% 6/23/16  xd  moved out of old code

%% Set values for variables that will be used through the function
illumLevels     = calcParams.illumLevels;
KpLevels        = calcParams.KpLevels;
KgLevels        = calcParams.KgLevels;
trainingSetSize = calcParams.trainingSetSize;
testingSetSize  = calcParams.testingSetSize;
analysisDir     = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

%% Load standard optical images
% We will load the pool of standard OI's here. The reason we have multiple
% copies of these is to reduce the effect of rendering noise when we
% perform the calculations. We also calculate the mean photon isomerization
% here to be used for Gaussian noise later on.
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},'Standard');
standardOIList = getFilenamesInDirectory(folderPath);
standardPool = cell(1, length(standardOIList));
calcParams.meanStandard = 0;
for ii = 1:length(standardOIList)
    opticalImageName = standardOIList{ii};
    opticalImageName = strrep(opticalImageName,'OpticalImage.mat','');
    oi = loadOpticalImageData(fullfile(calcParams.cacheFolderList{2},'Standard'),opticalImageName);
    oi = resizeOI(oi,calcParams.sensorFOV*calcParams.OIvSensorScale);
    
    absorptionsStandard = mosaic.compute(oi,'currentFlag',false);
    calcParams.meanStandard = calcParams.meanStandard + mean2(absorptionsStandard)/length(standardOIList);
    standardPool{ii} = absorptionsStandard;
end

%% Get a list of images
% Here we load all the names of the optical images in the given folder
% name. These are loaded alphanumerically so we can just index them freely.
% Note: Alphanumerical loading presumes that the files are named in
% alphanumeric order (image1, image2, image3,... etc.).
folderPath = fullfile(analysisDir,'OpticalImageData',calcParams.cacheFolderList{2},[color 'Illumination']);
OINamesList = getFilenamesInDirectory(folderPath);

% Set a starting Kg value. This will allow us to stop calculating Kg values
% when it is clear the remaining stimulus levels will return 100%. We set
% this to be the last 5 by default.
startKg = 1;

%% Do the actual calculation here
results = zeros(length(illumLevels),length(KpLevels),length(KgLevels));
for ii = 1:length(illumLevels);

    % Precompute the test optical image to save computational time.
    imageName = OINamesList{illumLevels(ii)};
    imageName = strrep(imageName,'OpticalImage.mat','');
    oiTest = loadOpticalImageData([calcParams.cacheFolderList{2} '/' [color 'Illumination']],imageName);
    oiTest = resizeOI(oiTest,calcParams.sensorFOV*calcParams.OIvSensorScale);
    absorptionsTest = mosaic.compute(oiTest,'currentFlag',false);

    % Loop through the two different noise levels and perform the
    % calculation at each combination.
    tic
    for jj = 1:length(KpLevels)
        Kp = KpLevels(jj);
        
        for kk = startKg:length(KgLevels);
            Kg = KgLevels(kk);

            % Choose the data generation function
            datasetFunction = masterDataFunction(calcParams.dFunction);
            [trainingData, trainingClasses] = datasetFunction(calcParams,standardPool,{absorptionsTest},Kp,Kg,trainingSetSize,mosaic);
            [testingData, testingClasses]   = datasetFunction(calcParams,standardPool,{absorptionsTest},Kp,Kg,testingSetSize,mosaic);
            
            % Standardize data if flag is set to true
            if calcParams.standardizeData
                m = mean(trainingData,1);
                s = std(trainingData,1);
                trainingData = (trainingData - repmat(m,trainingSetSize,1)) ./ repmat(s,trainingSetSize,1);
                testingData  = (testingData - repmat(m,testingSetSize,1))   ./ repmat(s,testingSetSize,1);
            end
            
            trainingData(isnan(trainingData)) = 0;
            testingData(isnan(testingData)) = 0;
            
            if calcParams.usePCA
                coeff = pca(trainingData,'NumComponents',calcParams.numPCA);
                trainingData = trainingData*coeff;
                testingData = testingData*coeff;
            end
            
            % Compute performance based on chosen classifier method
            classifierFunction = masterClassifierFunction(calcParams.cFunction);
            results(ii,jj,kk) = classifierFunction(trainingData,testingData,trainingClasses,testingClasses);
        end
    end
<<<<<<< HEAD

=======
    
>>>>>>> Trying to keep this up to date before branching
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
%         fprintf(num2str(lastFiveCorrect'));
%         fprintf([' StartKg: ' num2str(startKg) '\n']);
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


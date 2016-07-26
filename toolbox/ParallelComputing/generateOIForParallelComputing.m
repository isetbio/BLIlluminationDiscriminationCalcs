function numberOfOI = generateOIForParallelComputing(calcParams)
% generateOIForParallelComputing(calcParams)
% 
% In order to maximize the use of a computing cluster, we may be
% interested in running the calculations in this project en masse, across
% the whole image. To do so, we need need to generate small cropped areas
% one at a time. This function should be run before doing a parallel
% computation as it will split a large scene into many small optical
% images, which then be used for the calculation. This function has a
% sister function which when run after the calculation, will clean up all
% the files generated. This way we are not stuck with hundreds of folders
% of optical images.
%
% xd  7/1/16 wrote it

%% Get some paths which we will use later
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
fileNames = getFilenamesInDirectory(fullfile(dataDir,'SceneData',calcParams.cacheFolderList{2},'Standard'));
tempScene = loadSceneData([calcParams.cacheFolderList{2} '/Standard'],fileNames{1}(1:end-9));

% We also want to precompute the split on a 'dummy' image so that we know
% how many OI we will be getting.
numberOfOI = numel(splitSceneIntoMultipleSmallerScenes(tempScene,calcParams.sensorFOV));
sceneFolder = dir(fullfile(dataDir,'SceneData',calcParams.cacheFolderList{2}));
isDir = [sceneFolder(:).isdir];
sceneFolder = {sceneFolder(isDir).name};
sceneFolder(ismember(sceneFolder,{'.','..'})) = [];

for ii = 1:length(sceneFolder)
    % First, we need to create folders for each and every one of the splits
    % that we will be creating. This can be done in a long for loop.
    for ff = 1:numberOfOI
        dirName = [calcParams.calcIDStr '_' num2str(ff)];
        dirPath = fullfile(analysisDir,'OpticalImageData',dirName);
        if ~exist(dirPath,'dir')
            mkdir(dirPath);
        end
        mkdir(fullfile(dirPath,sceneFolder{ii}));
    end
    
    % We will then parfor over all the files in the directory. This will
    % allow us to quickly split each scene and save the OI in the desired
    % location.
    sceneCacheFolder = calcParams.cacheFolderList{2};
    currentSceneSubDir = sceneFolder{ii};
    theFOV = calcParams.sensorFOV;
    theCalcIDStr = calcParams.calcIDStr;
    filesInThisFolder = getFilenamesInDirectory(fullfile(dataDir,'SceneData',calcParams.cacheFolderList{2},sceneFolder{ii}));
    parfor ff = 1:length(filesInThisFolder)
        theCurrentFilename = filesInThisFolder{ff};
        theCurrentScene = loadSceneData([sceneCacheFolder '/' currentSceneSubDir],theCurrentFilename(1:end-9));
        splicedScenes = splitSceneIntoMultipleSmallerScenes(theCurrentScene,theFOV);
        theOIs = sceneArrayToOIArray(oiCreate('human'),splicedScenes);
        theOIs = theOIs(:);
        for ss = 1:numberOfOI
            dirName = [theCalcIDStr '_' num2str(ss)];
            savePath = fullfile(analysisDir,'OpticalImageData',dirName,currentSceneSubDir,strrep(theCurrentFilename,'Scene','OpticalImage'));
            parforSave(savePath,theOIs{ss});
        end
    end
end

end

function parforSave(fileName,opticalimage)
    save(fileName,'opticalimage');
end


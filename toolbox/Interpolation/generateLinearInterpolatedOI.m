function generateLinearInterpolatedOI(calcParams,patchInfo,hIdx,vIdx)
% generateInterpolatedOI(calcParams,patchInfo,hIdx,vIdx)
% 
% Interpolates spatial positions between two adjacent patches from the
% split. New patches are generated from the interpolated positions. The OI
% are then calculated and then saved.
%
% 7/12/16  xd  wrote it

%% Check that h and v are valid
%
% We want two patches that are side by side. Therefore, we expect 2 entries
% in both hIdx and vIdx. Furthermore, either hIdx or vIdx must contain two
% identical values (xor condition).
if numel(hIdx) ~= 2 || numel(vIdx) ~= 2, error('Only 2 values please!'); end;
if ~xor(hIdx(1)==hIdx(2),vIdx(1)==vIdx(2)), error('hIdx/vIdx XOR condition not filled!');end;

%% Interpolate the relevant axis
if hIdx(1)==hIdx(2)
    vIdx = linspace(vIdx(1),vIdx(2),5);
    vIdx = vIdx(2:end-1);
    numberOfOI = numel(vIdx);
    hIdx = repmat(unique(hIdx),numberOfOI,1);
else
    hIdx = linspace(hIdx(1),hIdx(2),5); 
    hIdx = hIdx(2:end-1);
    numberOfOI = numel(hIdx);
    vIdx = repmat(unique(vIdx),numberOfOI,1);
end;

%% Generate OI for the interpolated spaces
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

sceneFolder = dir(fullfile(dataDir,'SceneData',calcParams.cacheFolderList{2}));
isDir = [sceneFolder(:).isdir];
sceneFolder = {sceneFolder(isDir).name};
sceneFolder(ismember(sceneFolder,{'.','..'})) = [];

for ii = 1:length(sceneFolder)
    % First, we need to create folders for each and every one of the splits
    % that we will be creating. This can be done in a long for loop.
    for ff = 1:numberOfOI
        dirName = [calcParams.calcIDStr '_Interp_' num2str(ff)];
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
        
        for ss = 1:numberOfOI
            cropRect = [floor((hIdx(ss)-1)*patchInfo.sizeOfSquare) floor((vIdx(ss)-1)*patchInfo.sizeOfSquare)...
                patchInfo.sizeOfSquare-1 patchInfo.sizeOfSquare-1];
            
            tempScene = sceneCrop(theCurrentScene,cropRect);
            tempScene = sceneSet(tempScene,'fov',theFOV);
            theOI = oiCompute(oiCreate('human'),tempScene);
            
            dirName = [theCalcIDStr '_Interp_' num2str(ss)];
            savePath = fullfile(analysisDir,'OpticalImageData',dirName,currentSceneSubDir,strrep(theCurrentFilename,'Scene','OpticalImage'));
            parforSave(savePath,theOI);
        end
    end
end

end

function parforSave(fileName,opticalimage)
    save(fileName,'opticalimage');
end



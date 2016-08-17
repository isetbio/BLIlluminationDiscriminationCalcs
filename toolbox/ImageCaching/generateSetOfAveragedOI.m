function generateSetOfAveragedOI(sceneDir,fov)
% generateSetOfAveragedOI(sceneDir,fov)
% 
% Loads all scenes in the scene directory. Averages the photons and then
% crops to the size determined by fov. Saves the results in an OI folder
% with the name sceneDir_'UNIFORM'.
%
% 7/26/16  xd  wrote it

dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');

sceneFolder = dir(fullfile(dataDir,'SceneData',sceneDir));
isDir = [sceneFolder(:).isdir];
sceneFolder = {sceneFolder(isDir).name};
sceneFolder(ismember(sceneFolder,{'.','..'})) = [];

for ii = 1:length(sceneFolder)
    % Make an OI directory if it does not exist
    dirPath = fullfile(analysisDir,'OpticalImageData',[sceneDir '_UNIFORM']);
    if ~exist(dirPath,'dir')
        mkdir(dirPath);
    end
    if ~exist(fullfile(dirPath,sceneFolder{ii}),'dir')
        mkdir(fullfile(dirPath,sceneFolder{ii}));
    end 
    
    % Calculate means
    filesInThisFolder = getFilenamesInDirectory(fullfile(dataDir,'SceneData',sceneDir,sceneFolder{ii}));
    currentSceneSubDir = sceneFolder{ii};
    for ff = 1:length(filesInThisFolder)
        % Load scene and calculate mean photons
        theCurrentFilename = filesInThisFolder{ff};
        theCurrentScene = loadSceneData([sceneDir '/' currentSceneSubDir],theCurrentFilename(1:end-9));
        thePhotons = sceneGet(theCurrentScene,'photons');
        for pp = 1:size(thePhotons,3)
            thePhotons(:,:,pp) = mean2(thePhotons(:,:,pp));
        end
        theCurrentScene = sceneSet(theCurrentScene,'photons',thePhotons);
        
        % Determine area of scene to crop
        sizeOfLargeScene = sceneGet(theCurrentScene,'size');
        largeFOV = sceneGet(theCurrentScene,'fov');
        scaleRatio = fov / largeFOV;
        sizeOfSquare = floor(scaleRatio*sizeOfLargeScene(2));
        
        % Crop scene and set the fov
        cropRect = [1 1 sizeOfSquare-1 sizeOfSquare-1];
        theCurrentScene = sceneCrop(theCurrentScene,cropRect);
        theCurrentScene = sceneSet(theCurrentScene,'fov',fov);
        
        % Compute OI and save
        theOI = oiCompute(oiCreate('human'),theCurrentScene);
        savePath = fullfile(analysisDir,'OpticalImageData',[sceneDir '_UNIFORM'],currentSceneSubDir,strrep(theCurrentFilename,'Scene','OpticalImage'));
        parforSave(savePath,theOI);
    end
end

end

function parforSave(fileName,opticalimage)
    save(fileName,'opticalimage');
end

function [data,patchInfo] = LMSDifferenceFromStandardForAllPatches(sceneFolder,fov,illumLevel)
% [data,patchInfo] = LMSDifferenceFromStandardForAllPatches(sceneFolder,fov,illumLevel)
% 
% Generates data representing the difference between the mean cone
% absorptions for each color direction and the standard stimulus at a given
% illumLevel across L, M, and S cones.
%
% 7/13/16  xd  wrote it

%% Some variables and things
colors = {'Blue' 'Green' 'Red' 'Yellow'};

mosaic = coneMosaic;
mosaic.fov = fov;

dataBaseDir = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

%% Load and get mean absorption for standard
targetScenes = getFilenamesInDirectory(fullfile(dataBaseDir,'SceneData',sceneFolder,'Standard'));
tempScene = loadSceneData([sceneFolder '/Standard'],'TestImage0');
[~,patchInfo] = splitSceneIntoMultipleSmallerScenes(tempScene,fov);

% Loop over the scenes and calculate mean absorptions for each cone type
meanTargetIsomerizationsLMS = zeros(3,patchInfo.hNum*patchInfo.vNum);
for ii = 1:length(targetScenes)
    theScene = loadSceneData([sceneFolder '/Standard'],strrep(targetScenes{ii},'Scene.mat',''));
    smallScenes = splitSceneIntoMultipleSmallerScenes(theScene,fov);
    smallOIs = sceneArrayToOIArray(oiCreate('human'),smallScenes);
    smallOIs = smallOIs(:);
    for jj = 1:length(smallOIs)
        isomerizations = mosaic.compute(smallOIs{jj},'currentFlag',false);
        mosaic.clearData;
        meanTargetIsomerizationsLMS(1,jj) = mean2(isomerizations(mosaic.pattern==2)) / length(targetScenes);
        meanTargetIsomerizationsLMS(2,jj) = mean2(isomerizations(mosaic.pattern==3)) / length(targetScenes);
        meanTargetIsomerizationsLMS(3,jj) = mean2(isomerizations(mosaic.pattern==4)) / length(targetScenes);
    end
end

%% Loop over each color direction and compute LMS difference
data = zeros(4,3,patchInfo.hNum*patchInfo.vNum);
for ii = 1:length(colors)
    theScene = loadSceneData(sprintf('%s/%sIllumination',sceneFolder,colors{ii}),sprintf('%s%dL-RGB',lower(colors{ii}),illumLevel));
    smallScenes = splitSceneIntoMultipleSmallerScenes(theScene,fov);
    smallOIs = sceneArrayToOIArray(oiCreate('human'),smallScenes);
    smallOIs = smallOIs(:);
    for jj = 1:length(smallOIs)
        isomerizations = mosaic.compute(smallOIs{jj},'currentFlag',false);
        mosaic.clearData;
        Lcones = mean2(isomerizations(mosaic.pattern==2));
        Mcones = mean2(isomerizations(mosaic.pattern==3));
        Scones = mean2(isomerizations(mosaic.pattern==4));
        
        data(ii,1,jj) = meanTargetIsomerizationsLMS(1,jj) - Lcones;
        data(ii,2,jj) = meanTargetIsomerizationsLMS(2,jj) - Mcones;
        data(ii,3,jj) = meanTargetIsomerizationsLMS(3,jj) - Scones;
    end
end

%% L-M and (L+M)-S?

end


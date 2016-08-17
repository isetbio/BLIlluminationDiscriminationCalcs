OIFolder = 'Neutral_FullImage';
CompFolder = 'BlueIllumination';

% Load all target scene sensors
analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
folderPath = fullfile(analysisDir,'OpticalImageData',OIFolder,'Standard');
standardOIList = getFilenamesInDirectory(folderPath);

standardPool = cell(length(standardOIList),1);
for jj = 1:length(standardOIList)
    standardPool{jj} = loadOpticalImageData([OIFolder '/Standard'],strrep(standardOIList{jj},'OpticalImage.mat',''));
end

mosaic = coneMosaic;
mosaic.fov = oiGet(standardPool{1},'fov');
mosaic.integrationTime = 0.050;
mosaic.noiseFlag = false;
mosaic.spatialDensity = [0 0 0 1];
mosaic.wave = SToWls([380 8 51]);

standardIsom = 0;
for ii = 1:length(standardOIList)
    standardIsom = standardIsom + mosaic.compute(standardPool{ii},'currentFlag',false)/length(standardOIList);
%     standardIsom = standardIsom + oiGet(standardPool{ii},'photons')/length(standardOIList);
end

%% Load all blue scene sensors
folderPath = fullfile(analysisDir,'OpticalImageData',OIFolder,CompFolder);
blueOIList = getFilenamesInDirectory(folderPath);

distanceBlues = zeros(length(blueOIList),1);
for ii = 1:length(blueOIList)
    tempBlueOI = loadOpticalImageData([OIFolder '/' CompFolder],strrep(blueOIList{ii},'OpticalImage.mat',''));
    tempBlueIsom = mosaic.compute(tempBlueOI,'currentFlag',false);
%     tempBlueIsom = oiGet(tempBlueOI,'photons');
    distanceBlues(ii) = norm(tempBlueIsom(:)-standardIsom(:));
end

%% PLOT IT
figure;
plot(distanceBlues,'o','MarkerSize',16);
hold on;
plot([41 41],[0 max(distanceBlues)],'k--','LineWidth',2);
plot([43 43],[0 max(distanceBlues)],'--','Color',[0.2 0.2 0.2],'LineWidth',2);

%% Scenes??
SceneFolder = 'Neutral_FullImage';
CompFolder = 'BlueIllumination';

% Load all target scene sensors
dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
folderPath = fullfile(dataDir,'SceneData',SceneFolder,'Standard');
standardOIList = getFilenamesInDirectory(folderPath);
standardOIList = standardOIList(2);
numberOfOIToUse = 1;

standardPool = cell(numberOfOIToUse,1);
for jj = 1:numberOfOIToUse
    standardPool{jj} = loadSceneData([SceneFolder '/Standard'],strrep(standardOIList{jj},'Scene.mat',''));
%     Z = splitSceneIntoMultipleSmallerScenes(standardPool{jj},0.83);
%     standardPool{jj} = Z{60};
end

wave = sceneGet(standardPool{1},'wave');
standardIsom = 0;
for ii = 1:numberOfOIToUse
    standardIsom = standardIsom + sceneGet(standardPool{ii},'photons')/numberOfOIToUse;
end

folderPath = fullfile(dataDir,'SceneData',SceneFolder,CompFolder);
blueOIList = getFilenamesInDirectory(folderPath);

distanceBlues = zeros(length(blueOIList),length(wave));
for ii = 1:length(blueOIList)
    tempBlueOI = loadSceneData([SceneFolder '/' CompFolder],strrep(blueOIList{ii},'Scene.mat',''));
%     tempBlueOI = splitSceneIntoMultipleSmallerScenes(tempBlueOI,0.83);
%     tempBlueOI = tempBlueOI{60};
    tempBlueIsom = sceneGet(tempBlueOI,'photons');
    for jj = 1:length(wave)
        ttempBlue = tempBlueIsom(:,:,jj);
        ttempStnd = standardIsom(:,:,jj);
        distanceBlues(ii,jj) = norm(ttempBlue(:)-ttempStnd(:));
    end
end

%% PLOT IT
figure;
for ii = 1:51
    subplot(6,10,ii);
    plot(distanceBlues(:,ii),'o','MarkerSize',16);
    hold on;
    plot([41 41],[0 max(distanceBlues(:,ii))],'k--','LineWidth',2);
    plot([43 43],[0 max(distanceBlues(:,ii))],'--','Color',[0.2 0.2 0.2],'LineWidth',2);
    title(num2str(wave(ii)));
end
% h = findobj(gcf,'type','axes');
% set(h,'YLim',[0 10e16]);
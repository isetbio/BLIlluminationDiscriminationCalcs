%% ContrastCheck
%
% Look at the contrast in each cone type for two small patches in the
% stimuli. This is to check that the contrast values follow a pattern that
% would explain the model thresholds. The two patches that correspond to
% the results shown in Figure 5 in the paper are 3 and 162 at 1 degree fov.
%
% 6/1/17    xd  wrote it

clear; close all;
%% Set Parameters
dE = 15;                % Which illumination change step size
patches = [3 162];      % Which patches in the stimuli to compare
fov = 1;                % Size of the patches/cone mosaic

%% Load scenes
% 
% We will load one scene for each illuminant color direction at the
% specified illumination change step size, in addition to loading a scene
% illuminanted by the target illuminant.

t = loadSceneData('Constant_FullImage/Standard','CT1Blue0-RGB');
b = loadSceneData('Constant_FullImage/BlueIllumination',sprintf('Cblue%d-RGB',dE));
y = loadSceneData('Constant_FullImage/YellowIllumination',sprintf('Cyellow%d-RGB',dE));
g = loadSceneData('Constant_FullImage/GreenIllumination',sprintf('Cgreen%d-RGB',dE));
r = loadSceneData('Constant_FullImage/RedIllumination',sprintf('Cred%d-RGB',dE));

%% Split into patches
%
% Split each of the loaded scenes into patches of the specified size. Then,
% select the desired patches for analysis.

t = splitSceneIntoMultipleSmallerScenes(t,fov);
b = splitSceneIntoMultipleSmallerScenes(b,fov);
y = splitSceneIntoMultipleSmallerScenes(y,fov);
g = splitSceneIntoMultipleSmallerScenes(g,fov);
r = splitSceneIntoMultipleSmallerScenes(r,fov);

t = t(patches);
b = b(patches);
y = y(patches);
g = g(patches);
r = r(patches);

%% Calculate mean isomerizations
oi = oiCreate('human');
mosaic = getDefaultBLIllumDiscrMosaic;

for ii = 1:length(patches)
    t{ii} = mosaic.compute(oiCompute(oi,t{ii}));
    b{ii} = mosaic.compute(oiCompute(oi,b{ii}));
    y{ii} = mosaic.compute(oiCompute(oi,y{ii}));
    g{ii} = mosaic.compute(oiCompute(oi,g{ii}));
    r{ii} = mosaic.compute(oiCompute(oi,r{ii}));
end

%% Calculate and plot contrast
%
% Calculate the contrast for each of the patches for each cone type. This
% is done by calculating the mean isomerizations for a cone type in the
% mosaic in response to the target illuminated stimulus and also the
% changed illuminant illuminated stimulus. The constrast is the difference
% of the two divided by the mean isomerization response to the target.

contrasts = cell(2,1);
for ii = 1:length(patches)
    tempContrasts = zeros(4,3);
    
    % Loop over cones
    for jj = 2:4
        cones = mosaic.pattern == jj;
        
        t_m = t{ii};
        t_m = mean2(t_m(cones));
        
        b_m = b{ii};
        b_m = mean2(b_m(cones));
        tempContrasts(1,jj-1) = ((b_m - t_m) ./ t_m);
        
        y_m = y{ii};
        y_m = mean2(y_m(cones));
        tempContrasts(2,jj-1) = ((y_m - t_m) ./ t_m);
        
        g_m = g{ii};
        g_m = mean2(g_m(cones));
        tempContrasts(3,jj-1) = ((g_m - t_m) ./ t_m);
        
        r_m = r{ii};
        r_m = mean2(r_m(cones));
        tempContrasts(4,jj-1) = ((r_m - t_m) ./ t_m);
        
    end
    
    contrasts{ii} = tempContrasts;
end

%% Plot
figure('Position',[0 0 2100 500]);
subplot(1,3,1);
p = bar(1:4, contrasts{1},'grouped');
set(p(1),'FaceColor','r');
set(p(2),'FaceColor','g');
set(p(3),'FaceColor','b');
set(gca,'XTick',1:4,'XTickLabel',{'Blue' 'Yellow' 'Green' 'Red'});
set(gca,'LineWidth',2,'FontSize',20);
xlabel('Illumination Direction','FontSize',26);
ylabel('Contrast','FontSize',26);
title('Patch 1','FontSize',26);

subplot(1,3,2);
p = bar(1:4, contrasts{2},'grouped');
set(p(1),'FaceColor','r');
set(p(2),'FaceColor','g');
set(p(3),'FaceColor','b');
set(gca,'XTick',1:4,'XTickLabel',{'Blue' 'Yellow' 'Green' 'Red'});
set(gca,'LineWidth',2,'FontSize',20);
xlabel('Illumination Direction','FontSize',26);
ylabel('Contrast','FontSize',26);
title('Patch 2','FontSize',26);

subplot(1,3,3);
p = bar(1:4, abs(contrasts{1}) - abs(contrasts{2}),'grouped');
set(p(1),'FaceColor','r');
set(p(2),'FaceColor','g');
set(p(3),'FaceColor','b');
set(gca,'XTick',1:4,'XTickLabel',{'Blue' 'Yellow' 'Green' 'Red'});
set(gca,'LineWidth',2,'FontSize',20);
xlabel('Illumination Direction','FontSize',26);
ylabel('Contrast','FontSize',26);
title('Delta','FontSize',26);

ylim([-0.2 0.2]);
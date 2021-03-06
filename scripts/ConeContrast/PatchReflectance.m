%% PatchReflectance
%
% This script plots the mean patch reflectance of two different patches in
% a stimuli on top of one another. By default, it loads the target scene
% from the constant-scene condition experiment.
%
% 6/XX/17  xd  wrote it

clear; close all;
%% Choose patched and fov
patches = [3 162];          % Which patches in the stimuli to compare
fov = 1;                    % Size of the patches/cone mosaic

%% Load scene and split into patches
t = loadSceneData('Constant_FullImage/Standard','CT1Blue0-RGB');
t = splitSceneIntoMultipleSmallerScenes(t,fov);
t = t(patches);

%% Retrieve and calculate mean reflectance
%
% Use the ISETBIO built in functions to calculate the reflectance
% properties of the scene.

r1 = sceneGet(t{1},'reflectance');
r2 = sceneGet(t{2},'reflectance');

m1 = mean(reshape(r1,[],51));
m2 = mean(reshape(r2,[],51));

w = sceneGet(t{1},'wavelength');

%% Plot
figure; hold on;
plot(w,m1,'LineWidth',2);
plot(w,m2,'LineWidth',2);
xlim([350 810]);

set(gca,'FontSize',20,'LineWidth',2);
xlabel('\lambda','FontSize',26);
ylabel('Reflectance','FontSize',26);
legend({'Patch 1','Patch 2'},'FontSize',20,'Location','Southeast');

clear; close all;
%%
patches = [3 162];
fov = 1;

%%
t = loadSceneData('Constant_FullImage/Standard','CT1Blue0-RGB');
t = splitSceneIntoMultipleSmallerScenes(t,fov);
t = t(patches);

%%
r1 = sceneGet(t{1},'reflectance');
r2 = sceneGet(t{2},'reflectance');

m1 = mean(reshape(r1,[],51));
m2 = mean(reshape(r2,[],51));

w = sceneGet(t{1},'wavelength');

%%
figure; hold on;
plot(w,m1,'LineWidth',2);
plot(w,m2,'LineWidth',2);
xlim([350 810]);

set(gca,'FontSize',20,'LineWidth',2);
xlabel('\lambda','FontSize',26);
ylabel('Reflectance','FontSize',26);
legend({'Patch 1','Patch 2'},'FontSize',20,'Location','Southeast');
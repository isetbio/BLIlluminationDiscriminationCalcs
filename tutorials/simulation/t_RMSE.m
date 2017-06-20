%% t_RMSE
%
% Plots the RMSE for each of the different mosaic conditions. Uses
% data saved from fits done in another script.
%
% 3/31/17  xd  wrote it

clear; 
%% List all the data file names

% Data mat file names
dataFiles = {'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
             'FirstOrderModel_LMS_0.62_0.31_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
             'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat'};

% dataFiles = {'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_WeightedModelFits.mat',...
%              'FirstOrderModel_LMS_1.00_0.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_1.00_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_0.00_1.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
%              'FirstOrderModel_LMS_0.66_0.34_0.00_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
%              'FirstOrderModel_LMS_0.93_0.00_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat',...
%              'FirstOrderModel_LMS_0.00_0.93_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_UniformModelFits.mat'};
           
% Corresponding labels for x axis
xAxisLabels = {'Standard_w', 'L_w', 'M_w', 'S_w',...
               'LM_w', 'LS_w', 'MS_w',...
               'Standard_u','L_u', 'M_u', 'S_u',...
               'LM_u', 'LS_u', 'MS_u'};
% xAxisLabels = {'L_w', 'M_w', 'S_w',...
%                'LM_w', 'LS_w', 'MS_w',...
%                'L_u', 'M_u', 'S_u',...
%                'LM_u', 'LS_u', 'MS_u'};

%% Load LSE(RMSE) data for each mosaic

% Vectors to save mean and std error
meanRMSE = zeros(length(dataFiles),1);
stderrRMSE = zeros(size(meanRMSE));

% Loop over data files and calculate mean and std error
for i = 1:length(dataFiles)
    load(dataFiles{i});
    meanRMSE(i) = mean(LSE);
    stderrRMSE(i) = std(LSE)/sqrt(length(LSE));
end

%% Plot the data
figParams = BLIllumDiscrFigParams;

figure('Position',[1000 900 960 420]); 
hold on;
bar(1:length(dataFiles), meanRMSE);
errorbar(1:length(dataFiles),meanRMSE,stderrRMSE,'.','LineWidth',figParams.lineWidth);

set(gca, 'XTick', 1:length(dataFiles), 'XTickLabels', xAxisLabels);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

title('Model RMSEs','FontSize',figParams.titleFontSize);
xlabel('Mosaic type','FontSize',figParams.labelFontSize);
ylabel('RMSE','FontSize',figParams.labelFontSize);

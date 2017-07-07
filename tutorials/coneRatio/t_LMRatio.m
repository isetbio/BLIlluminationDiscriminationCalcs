%% t_LMRatio
%
% Plots thresholds from calculations that used cone mosaics with differing
% L:M ratios. This helps demonstrate any effect that the L:M ratio has on
% the SVM's performance.
% 
% The data used for this script were calculations already executed. Contact
% David Brainard (brainard@psych.upenn.edu) for data requests.
%
% 10/28/16  xd  wrote it

clear; close all;
%% Set up calcIDStr's
dataIDStrings = {
'FirstOrderModel_LMS_0.05_0.88_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.14_0.79_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.23_0.70_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.33_0.60_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.42_0.51_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.51_0.42_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.60_0.33_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.70_0.23_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.79_0.14_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'
'FirstOrderModel_LMS_0.88_0.05_0.07_FOV1.00_PCA400_ABBA_SVM_Constant_1'};

%% Plot
for ii = 1:length(dataIDStrings)
    plotAllThresholds(dataIDStrings{ii},'reset',true);
end
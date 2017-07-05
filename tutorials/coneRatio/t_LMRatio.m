%% t_LMRatio
%
% This script uses data generated using mosaics of differing LM cone ratios
% to see the effect of M% on SVM performance. It could be the case the
% green performance is most affected, as there is some evidence of this.
%
% 10/28/16  xd  wrote it

clear; close all;
%%
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

%%
for ii = 1:length(dataIDStrings)
    plotAllThresholds(dataIDStrings{ii},'reset',true);
end
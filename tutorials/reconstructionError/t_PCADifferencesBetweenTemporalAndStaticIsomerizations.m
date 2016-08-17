%% t_PCADifferencesBetweenTemporalAndStaticIsomerizations
%
% With the SVM classification, we know that the temporal (no eye movement)
% version of the isomerizations should contain the same information as the
% static case, as long as the total integration time is equal. This is
% confirmed by doing a simple addition of the time slices.  However, there
% is a tremendous difference in performance between the two data formats.
% This scripts explores some ideas as to why there is such a difference.
%
% 7/29/16  xd  wrote it 

ieInit; clear; close all;
%%
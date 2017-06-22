function deleteOIForParallelComputing(calcParams)
% deleteOIForParallelComputing(calcParams)
% 
% This function should be run after a parallel computation. This will
% remove any OI folders used in the calculation so that we are not
% clustered with hundreds of OI.
%
% Inputs: 
%     calcParams  -  struct which contains parameters for the calculation
% 
% 7/1/16  xd  wrote it


analysisDir = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
tempScene   = loadSceneData([calcParams.cacheFolderList{2} '/Standard'],'TestImage0');
numberOfOI  = numel(splitSceneIntoMultipleSmallerScenes(tempScene,calcParams.sensorFOV));

for ii = 1:numberOfOI
    dirName = [calcParams.calcIDStr '_' num2str(ii)];
    dirToRemovePath = fullfile(analysisDir,'OpticalImageData',dirName);
    rmdir(dirToRemovePath,'s');
end

end


function updatedParams = updateCacheFolderList(calcParams)
% updatedParams = updateCacheFolderList(calcParams)
% 
% This function will update the input calcParams so that its
% cacheFolderList appropriate matches its calcIDStr.  
%
% Inputs:
%    calcParams - A calcParam file with at least the calcIDStr field set.
%
% Outputs:
%    updatedParams - A calcParam file with the correct cacheFolderList field
%
% 6/4/15  xd  wrote it

% The first folder represents the raw RGB image source.  The second folder
% is the subdirectory in which the scene data and oi data will be stored.
% If the second directory does not exist, it will be created.
switch (calcParams.calcIDStr)
    case {'StaticPhoton', 'ThreeFrameEM','StaticPhoton_MatlabRNG', ...
            'StaticPhoton_iePoisson', 'BugTests', ...
            'StaticPhoton_5EM_10MS','StaticPhoton_10MS','StaticPhoton_5EM_10MS_SUM',...
            'SystemicPercentTest','SystemicPercentTestLong','SensorFOV',...
            'SystemicPercentTestEM','SystemicPercentTestLowIllum','SystemicPercentTestLongNoRound','SystemicPercentTestNormalDist',...
            'SystemicPercentTestNormrnd','StaticPhoton_AfterMerge','StaticPhoton_AfterMergeLong',...
            'StaticPhoton_CosineSim','StaticPhoton_CosineSimT','StaticPhoton_Dot',...
            'StaticPhoton_Angle','StaticPhoton_DiffStandard','StaticPhoton_DiffStandardN',...
            'StaticPhoton_DiffStandardN2','StaticPhoton_Gaussian'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral'};
    case {'StaticPhoton_NM1','StaticPhoton_NM1_MatlabRNG'}
        calcParams.cacheFolderList = {'NM1', 'NM1'};
    case {'StaticPhoton_NM2','StaticPhoton_NM2_MatlabRNG'}
        calcParams.cacheFolderList = {'NM2', 'NM2'};
    case {'StaticPhoton_2','SystemicPercentTestLowIllum_2','StaticPhoton_2_Cosine'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_2'};
    case {'PixelNoiseTest'}
        calcParams.cacheFolderList = {'New Images', 'PixelNoise'};
    case {'PixelNoiseAffirm'}
        calcParams.cacheFolderList = {'NewNewImages', 'PixelNoise2'};
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


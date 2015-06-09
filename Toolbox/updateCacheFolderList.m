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

switch (calcParams.calcIDStr)
    case {'StaticPhoton', 'ThreeFrameEM','StaticPhoton_MatlabRNG', ...
            'StaticPhoton_iePoisson', 'BugTests', ...
            'StaticPhoton_5EM_10MS','StaticPhoton_10MS','StaticPhoton_5EM_10MS_SUM',...
            'SystemicPercentTest','SystemicPercentTestLong','SensorFOV',...
            'SystemicPercentTestEM'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral'};
    case {'StaticPhoton_NM1','StaticPhoton_NM1_MatlabRNG'}
        calcParams.cacheFolderList = {'NM1', 'NM1'};
    case {'StaticPhoton_NM2','StaticPhoton_NM2_MatlabRNG'}
        calcParams.cacheFolderList = {'NM2', 'NM2'};
    case {'StaticPhoton_2'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_2'};
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


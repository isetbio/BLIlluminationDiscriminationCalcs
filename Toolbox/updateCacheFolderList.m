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
    case {'StaticPhoton', 'ThreeFrameEM','ConeIntegrationTime_Tests', ...
            'StaticPhoton_MatlabRNG','StaticPhoton_iePoisson', 'BugTests', ...
            'StaticPhoton_5EM_10MS','StaticPhoton_10MS','StaticPhoton_5EM_10MS_SUM',...
            'SystemicPercentTest','SystemicPercentTestLong','SensorFOV'}
        calcParams.cacheFolderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
            'RedIllumination', 'YellowIllumination'};
    case {'StaticPhoton_NM1','StaticPhoton_NM1_MatlabRNG'}
        calcParams.cacheFolderList = {'Standard_NM1', 'BlueIllumination_NM1', 'GreenIllumination_NM1', ...
            'RedIllumination_NM1', 'YellowIllumination_NM1'};
    case {'StaticPhoton_NM2','StaticPhoton_NM2_MatlabRNG'}
        calcParams.cacheFolderList = {'Standard_NM2', 'BlueIllumination_NM2', 'GreenIllumination_NM2', ...
            'RedIllumination_NM2', 'YellowIllumination_NM2'};
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


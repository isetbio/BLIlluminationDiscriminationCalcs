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
    case {'StaticPhoton', 'ThreeFrameEM','BugTests', ...
            'StaticPhoton_5EM_10MS','StaticPhoton_10MS','StaticPhoton_5EM_10MS_SUM',...
            'SensorFOV','StaticPhoton_DiffStandard','StaticPhoton_DiffStandardN',...
            'StaticPhoton_DiffStandardN2', 'StaticPhoton_KxMean', 'StaticPhoton_G' ...
            'SecondOrderModelTest' 'SecondOrderModelTestSum' 'StaticPhoton_10x10'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral'}; % [550 450 40 40]
    case {'StaticPhoton_NM1'}
        calcParams.cacheFolderList = {'NM1', 'NM1'};
    case {'StaticPhoton_NM2'}
        calcParams.cacheFolderList = {'NM2', 'NM2'};
    case {'StaticPhoton_2' ...
            'StaticPhoton_2_UnifNoise' 'StaticPhoton_KxMean2' 'StaticPhoton_G2'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_2'}; % [750 650 40 40]
    case {'PixelNoiseTest'}
        calcParams.cacheFolderList = {'New Images', 'PixelNoise'};
    case {'PixelNoiseAffirm'}
        calcParams.cacheFolderList = {'NewNewImages', 'PixelNoise2'};
    case {'StaticPhoton_3' 'StaticPhoton_KxMean3' 'StaticPhoton_G3'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_3'}; % [550 700 40 40]
    case {'StaticPhoton_4' 'StaticPhoton_KxMean4' 'StaticPhoton_G4'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_4'}; % [500 400 40 40]
    case {'StaticPhoton_5' 'StaticPhoton_KxMean5'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_5'}; % [500 600 40 40]
    case {'StaticPhoton_6'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_6'}; % [700 750 40 40]        
    case {'StaticPhoton_7'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_7'}; % [600 600 40 40]
    case {'StaticPhoton_8'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_8'}; % [615 665 40 40]
    case {'StaticPhoton_9'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_9'}; % [500 675 40 40]
    case {'StaticPhoton_10'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_10'}; % [725 625 40 40]
    case {'StaticPhoton_11'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_11'}; % [550 500 40 40]
    case {'StaticPhoton_12'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_12'}; % [550 550 40 40]
    case {'StaticPhoton_13'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_13'}; % [550 600 40 40]
    case {'StaticPhoton_14'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_14'}; % [650 550 40 40]
    case {'StaticPhoton_15'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_15'}; % [650 750 40 40]

    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


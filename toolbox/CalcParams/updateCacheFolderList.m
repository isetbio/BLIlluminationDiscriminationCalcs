function updatedParams = updateCacheFolderList(calcParams)
% updatedParams = updateCacheFolderList(calcParams)
%
% This function will update the input calcParams so that its
% cacheFolderList appropriate matches its calcIDStr. The use of additional
% calcIDStr's will require editing this file.
%
% Inputs:
%     calcParams  -  A calcParam file with at least the 'calcIDStr' field set
%
% Outputs:
%     updatedParams  -  A calcParam file with the correct 'cacheFolderList' field
%
% 6/4/15   xd  wrote it
% 6/22/17  xd  removed many old and outdated calcIDStr's

% The first folder represents the raw RGB image source.  The second folder
% is the subdirectory in which the scene data and oi data will be stored.
% If the second directory does not exist, it will be created.
switch (calcParams.calcIDStr)
    case {'ValidateFOM'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral'}; % [550 450 40 40]
    case {'Neutral_FullImage'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_FullImage'};
    case {'ConstantFullImage'}
        calcParams.cacheFolderList = {'Constant', 'Constant_FullImage'};
    case {'ShuffledFullImage'}
        calcParams.cacheFolderList = {'Shuffled', 'Shuffled_FullImage'};   
    case {'NM1_FullImage'}
        calcParams.cacheFolderList = {'NM1', 'NM1_FullImage'};   
    case {'NM2_FullImage'}
        calcParams.cacheFolderList = {'NM2', 'NM2_FullImage'};       
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


function updatedParams = updateCropRect(calcParams)
% updatedParams = updateCropRect(calcParams)
%
% This function will update the input calcParams so that its cropRect field
% is assigned appropriately according to its calcID. 
%
% Inputs:
%     calcParams  -  A calcParam file with at least the calcIDStr field set.
%
% Outputs:
%     updatedParams  -  A calcParam file with the correct cropRect field
%
% 7/10/15  xd  wrote it
% 6/22/17  xd  removed old unused calcIDStr

switch (calcParams.calcIDStr)
    case {'ValidateFOM'}
        calcParams.cropRect = [550 450 40 40];
    case {'Neutral_FullImage' 'NM1_FullImage' 'NM2_FullImage'}
        calcParams.cropRect = [489 393 535 480];
    case {'ConstantFullImage' 'ShuffledFullImage'}
        calcParams.cropRect = [560 261 802 667];
    case {'Parallel'}
        calcParams.cropRect = [];
    otherwise
        calcParams.cropRect = [];
end

updatedParams = calcParams;
end


function updatedParams = updateCropRect(calcParams)
% updatedCalcParams = updateCropRect(calcParams)
% 
% This function will update the input calcParams so that its cropRect field
% is assigned appropriately according to its calcID. 
%
% Inputs:
%    calcParams - A calcParam file with at least the calcIDStr field set.
%
% Outputs:
%    updatedParams - A calcParam file with the correct cropRect field
%
% 7/10/15  xd  wrote it

switch (calcParams.calcIDStr)
    case {'StaticPhoton' 'ThreeFrameEM' 'BugTests' ...
            'StaticPhoton_5EM_10MS' 'StaticPhoton_10MS' 'StaticPhoton_5EM_10MS_SUM' ...
            'SensorFOV' 'StaticPhoton_DiffStandard' 'StaticPhoton_DiffStandardN' ...
            'StaticPhoton_DiffStandardN2' 'StaticPhoton_KxMean' 'StaticPhoton_NM1' ...
            'StaticPhoton_NM2' 'PixelNoiseTest' 'PixelNoiseAffirm' 'StaticPhoton_G' ...
            'SecondOrderModelTest' 'SecondOrderModelTestSum' 'StaticPhoton_10x10'...
            'StaticPhoton_CompareToEM' 'SOM_FrozenPosition' 'SOM_FrozenSum'...
            'SOM_moving' 'SOM_movingSum' 'SOM_movingDiffPathSum'}
        calcParams.cropRect = [550 450 40 40];
    case {'StaticPhoton_2' ...
            'StaticPhoton_2_UnifNoise' 'StaticPhoton_KxMean2' 'StaticPhoton_G2'}
        calcParams.cropRect = [750 650 40 40];
    case {'StaticPhoton_3' 'StaticPhoton_KxMean3' 'StaticPhoton_G3'}
        calcParams.cropRect = [550 700 40 40];
    case {'StaticPhoton_4' 'StaticPhoton_KxMean4' 'StaticPhoton_G4'}
        calcParams.cropRect = [500 400 40 40];
    case {'StaticPhoton_5' 'StaticPhoton_KxMean5'}
        calcParams.cropRect = [500 600 40 40];
    case {'StaticPhoton_6'}
        calcParams.cropRect = [700 750 40 40];
    case {'StaticPhoton_7'}
        calcParams.cropRect = [600 600 40 40];
    case {'StaticPhoton_8'}
        calcParams.cropRect = [615 665 40 40];
    case {'StaticPhoton_9'}
        calcParams.cropRect = [500 675 40 40];
    case {'StaticPhoton_10'}
        calcParams.cropRect = [725 625 40 40];
    case {'StaticPhoton_11'}
        calcParams.cropRect = [550 500 40 40];
    case {'StaticPhoton_12'}
        calcParams.cropRect = [550 550 40 40];
    case {'StaticPhoton_13'}
        calcParams.cropRect = [550 600 40 40];
    case {'StaticPhoton_14'}
        calcParams.cropRect = [650 550 40 40];
    case {'StaticPhoton_15'}
        calcParams.cropRect = [650 750 40 40];
        
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;
end


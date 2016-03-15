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
    case {'StaticPhoton' 'BugTests' 'StaticPhoton_NM1' ...
            'StaticPhoton_NM2' 'StaticPhoton_G' ...
            'SecondOrderModelTest' 'SecondOrderModelTestSum' 'StaticPhoton_10x10'...
            'StaticPhoton_CompareToEM' 'SOM_FrozenPosition' 'SOM_FrozenSum'...
            'SOM_moving' 'SOM_movingSum' 'SOM_movingDiffPathSum' 'SOM_sum1'...
            'SOM_sum2' 'SOM_sum4' 'SOM_sum10' 'SOM_sum25' 'SOM_sum100' 'SOM_SNRMulti'...
            'SOM_SNRMultiSum'}
        calcParams.cropRect = [550 450 40 40];
    case {'StaticPhoton_2' 'StaticPhoton_NM1_2' 'StaticPhoton_NM2_2'}
        calcParams.cropRect = [750 650 40 40];
    case {'StaticPhoton_3' 'StaticPhoton_G3' 'StaticPhoton_NM1_3'...
            'StaticPhoton_NM2_3'}
        calcParams.cropRect = [550 700 40 40];
    case {'StaticPhoton_4' 'StaticPhoton_G4' 'StaticPhoton_NM1_4'...
            'StaticPhoton_NM2_4'}
        calcParams.cropRect = [500 400 40 40];
    case {'StaticPhoton_5' 'StaticPhoton_NM1_5' 'StaticPhoton_NM2_5'}
        calcParams.cropRect = [500 600 40 40];
    case {'StaticPhoton_6' 'StaticPhoton_NM1_6' 'StaticPhoton_NM2_6'}
        calcParams.cropRect = [700 750 40 40];
    case {'StaticPhoton_7' 'StaticPhoton_NM1_7' 'StaticPhoton_NM2_7'}
        calcParams.cropRect = [600 600 40 40];
    case {'StaticPhoton_8' 'StaticPhoton_NM1_8' 'StaticPhoton_NM2_8'}
        calcParams.cropRect = [615 665 40 40];
    case {'StaticPhoton_9' 'StaticPhoton_NM1_9' 'StaticPhoton_NM2_9'}
        calcParams.cropRect = [500 675 40 40];
    case {'StaticPhoton_10' 'StaticPhoton_NM1_10' 'StaticPhoton_NM2_10'}
        calcParams.cropRect = [725 625 40 40];
    case {'StaticPhoton_11' 'StaticPhoton_NM1_11' 'StaticPhoton_NM2_11'}
        calcParams.cropRect = [550 500 40 40];
    case {'StaticPhoton_12' 'StaticPhoton_NM1_12' 'StaticPhoton_NM2_12'}
        calcParams.cropRect = [550 550 40 40];
    case {'StaticPhoton_13' 'StaticPhoton_NM1_13' 'StaticPhoton_NM2_13'}
        calcParams.cropRect = [550 600 40 40];
    case {'StaticPhoton_14' 'StaticPhoton_NM1_14' 'StaticPhoton_NM2_14'}
        calcParams.cropRect = [650 550 40 40];
    case {'StaticPhoton_15' 'StaticPhoton_NM1_15' 'StaticPhoton_NM2_15'}
        calcParams.cropRect = [650 750 40 40];
    case {'StaticPhoton_S2_1' 'StaticPhoton_NM1_S2_1' 'StaticPhoton_NM2_S2_1'}
        calcParams.cropRect = [850 800 40 40];
    case {'StaticPhoton_S2_2' 'StaticPhoton_NM1_S2_2' 'StaticPhoton_NM2_S2_2'}
        calcParams.cropRect = [850 750 40 40];
    case {'StaticPhoton_S2_3' 'StaticPhoton_NM1_S2_3' 'StaticPhoton_NM2_S2_3'}
        calcParams.cropRect = [850 700 40 40];
    case {'StaticPhoton_S2_4' 'StaticPhoton_NM1_S2_4' 'StaticPhoton_NM2_S2_4'}
        calcParams.cropRect = [800 800 40 40];
    case {'StaticPhoton_S2_5' 'StaticPhoton_NM1_S2_5' 'StaticPhoton_NM2_S2_5'}
        calcParams.cropRect = [800 750 40 40];
    case {'StaticPhoton_S2_6' 'StaticPhoton_NM1_S2_6' 'StaticPhoton_NM2_S2_6'}
        calcParams.cropRect = [800 700 40 40];
    case {'StaticPhoton_S2_7' 'StaticPhoton_NM1_S2_7' 'StaticPhoton_NM2_S2_7'}
        calcParams.cropRect = [850 500 40 40];
    case {'StaticPhoton_S2_8' 'StaticPhoton_NM1_S2_8' 'StaticPhoton_NM2_S2_8'}
        calcParams.cropRect = [800 500 40 40];
    case {'StaticPhoton_S2_9' 'StaticPhoton_NM1_S2_9' 'StaticPhoton_NM2_S2_9'}
        calcParams.cropRect = [700 500 40 40];
    case {'StaticPhoton_S2_10' 'StaticPhoton_NM1_S2_10' 'StaticPhoton_NM2_S2_10'}
        calcParams.cropRect = [600 700 40 40];
    case {'StaticPhoton_S2_11' 'StaticPhoton_NM1_S2_11' 'StaticPhoton_NM2_S2_11'}
        calcParams.cropRect = [600 750 40 40];
    case {'StaticPhoton_S2_12' 'StaticPhoton_NM1_S2_12' 'StaticPhoton_NM2_S2_12'}
        calcParams.cropRect = [600 800 40 40];
    case {'StaticPhoton_S2_13' 'StaticPhoton_NM1_S2_13' 'StaticPhoton_NM2_S2_13'}
        calcParams.cropRect = [600 400 40 40];
    case {'StaticPhoton_S2_14' 'StaticPhoton_NM1_S2_14' 'StaticPhoton_NM2_S2_14'}
        calcParams.cropRect = [700 400 40 40];
    case {'StaticPhoton_S2_15' 'StaticPhoton_NM1_S2_15' 'StaticPhoton_NM2_S2_15'}
        calcParams.cropRect = [800 400 40 40];
    case {'FullImageTest' 'FullImageTest2' 'FullImageTest3' 'FullImageTest4'...
            'FullImageTest5' 'OS3Step' 'OS3StepConeAbsorb' 'OSWithNoise'...
            'SOM_linear' 'SOM_linear2' 'FullImage'}
        calcParams.cropRect = [489 393 535 480];
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;
end


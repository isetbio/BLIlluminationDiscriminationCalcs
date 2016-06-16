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
    case {'StaticPhoton' 'BugTests' 'StaticPhoton_G' ...
            'SecondOrderModelTest' 'SecondOrderModelTestSum' 'StaticPhoton_10x10'...
            'StaticPhoton_CompareToEM' 'SOM_FrozenPosition' 'SOM_FrozenSum'...
            'SOM_moving' 'SOM_movingSum' 'SOM_movingDiffPathSum' 'SOM_sum1'...
            'SOM_sum2' 'SOM_sum4' 'SOM_sum10' 'SOM_sum25' 'SOM_sum100' 'SOM_SNRMulti'...
            'SOM_SNRMultiSum' 'StaticPhoton_repeat' 'StaticPhoton_newclass'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral'}; % [550 450 40 40]
    case {'StaticPhoton_NM1'}
        calcParams.cacheFolderList = {'NM1', 'NM1'};
    case {'StaticPhoton_NM2'}
        calcParams.cacheFolderList = {'NM2', 'NM2'};
    case {'StaticPhoton_2' 'StaticPhoton_G2'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_2'}; % [750 650 40 40]
    case {'StaticPhoton_3' 'StaticPhoton_G3'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_3'}; % [550 700 40 40]
    case {'StaticPhoton_4' 'StaticPhoton_G4'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_4'}; % [500 400 40 40]
    case {'StaticPhoton_5'}
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
    case {'StaticPhoton_NM1_2'}
        calcParams.cacheFolderList = {'NM1', 'NM1_2'};
    case {'StaticPhoton_NM1_3'}
        calcParams.cacheFolderList = {'NM1', 'NM1_3'};
    case {'StaticPhoton_NM1_4'}
        calcParams.cacheFolderList = {'NM1', 'NM1_4'};
    case {'StaticPhoton_NM1_5'}
        calcParams.cacheFolderList = {'NM1', 'NM1_5'};
    case {'StaticPhoton_NM1_6'}
        calcParams.cacheFolderList = {'NM1', 'NM1_6'};
    case {'StaticPhoton_NM1_7'}
        calcParams.cacheFolderList = {'NM1', 'NM1_7'};
    case {'StaticPhoton_NM1_8'}
        calcParams.cacheFolderList = {'NM1', 'NM1_8'};
    case {'StaticPhoton_NM1_9'}
        calcParams.cacheFolderList = {'NM1', 'NM1_9'};
    case {'StaticPhoton_NM1_10'}
        calcParams.cacheFolderList = {'NM1', 'NM1_10'};
    case {'StaticPhoton_NM1_11'}
        calcParams.cacheFolderList = {'NM1', 'NM1_11'};
    case {'StaticPhoton_NM1_12'}
        calcParams.cacheFolderList = {'NM1', 'NM1_12'};
    case {'StaticPhoton_NM1_13'}
        calcParams.cacheFolderList = {'NM1', 'NM1_13'};
    case {'StaticPhoton_NM1_14'}
        calcParams.cacheFolderList = {'NM1', 'NM1_14'};
    case {'StaticPhoton_NM1_15'}
        calcParams.cacheFolderList = {'NM1', 'NM1_15'};
    case {'StaticPhoton_NM2_2'}
        calcParams.cacheFolderList = {'NM2', 'NM2_2'};
    case {'StaticPhoton_NM2_3'}
        calcParams.cacheFolderList = {'NM2', 'NM2_3'};
    case {'StaticPhoton_NM2_4'}
        calcParams.cacheFolderList = {'NM2', 'NM2_4'};
    case {'StaticPhoton_NM2_5'}
        calcParams.cacheFolderList = {'NM2', 'NM2_5'};
    case {'StaticPhoton_NM2_6'}
        calcParams.cacheFolderList = {'NM2', 'NM2_6'};
    case {'StaticPhoton_NM2_7'}
        calcParams.cacheFolderList = {'NM2', 'NM2_7'};
    case {'StaticPhoton_NM2_8'}
        calcParams.cacheFolderList = {'NM2', 'NM2_8'};
    case {'StaticPhoton_NM2_9'}
        calcParams.cacheFolderList = {'NM2', 'NM2_9'};
    case {'StaticPhoton_NM2_10'}
        calcParams.cacheFolderList = {'NM2', 'NM2_10'};
    case {'StaticPhoton_NM2_11'}
        calcParams.cacheFolderList = {'NM2', 'NM2_11'};
    case {'StaticPhoton_NM2_12'}
        calcParams.cacheFolderList = {'NM2', 'NM2_12'};
    case {'StaticPhoton_NM2_13'}
        calcParams.cacheFolderList = {'NM2', 'NM2_13'};
    case {'StaticPhoton_NM2_14'}
        calcParams.cacheFolderList = {'NM2', 'NM2_14'};
    case {'StaticPhoton_NM2_15'}
        calcParams.cacheFolderList = {'NM2', 'NM2_15'};
    case {'StaticPhoton_S2_1'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_1'};
    case {'StaticPhoton_S2_2'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_2'};
    case {'StaticPhoton_S2_3'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_3'};
    case {'StaticPhoton_S2_4'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_4'};
    case {'StaticPhoton_S2_5'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_5'};
    case {'StaticPhoton_S2_6'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_6'};
    case {'StaticPhoton_S2_7'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_7'};
    case {'StaticPhoton_S2_8'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_8'};
    case {'StaticPhoton_S2_9'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_9'};
    case {'StaticPhoton_S2_10'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_10'};
    case {'StaticPhoton_S2_11'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_11'};
    case {'StaticPhoton_S2_12'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_12'};
    case {'StaticPhoton_S2_13'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_13'};
    case {'StaticPhoton_S2_14'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_14'};
    case {'StaticPhoton_S2_15'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_S2_15'};
    case {'StaticPhoton_NM1_S2_1'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_1'};
    case {'StaticPhoton_NM1_S2_2'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_2'};
    case {'StaticPhoton_NM1_S2_3'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_3'};
    case {'StaticPhoton_NM1_S2_4'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_4'};
    case {'StaticPhoton_NM1_S2_5'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_5'};
    case {'StaticPhoton_NM1_S2_6'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_6'};
    case {'StaticPhoton_NM1_S2_7'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_7'};
    case {'StaticPhoton_NM1_S2_8'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_8'};
    case {'StaticPhoton_NM1_S2_9'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_9'};
    case {'StaticPhoton_NM1_S2_10'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_10'};
    case {'StaticPhoton_NM1_S2_11'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_11'};
    case {'StaticPhoton_NM1_S2_12'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_12'};
    case {'StaticPhoton_NM1_S2_13'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_13'};
    case {'StaticPhoton_NM1_S2_14'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_14'};
    case {'StaticPhoton_NM1_S2_15'}
        calcParams.cacheFolderList = {'NM1', 'Neutral_NM1_S2_15'};
    case {'StaticPhoton_NM2_S2_1'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_1'};
    case {'StaticPhoton_NM2_S2_2'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_2'};
    case {'StaticPhoton_NM2_S2_3'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_3'};
    case {'StaticPhoton_NM2_S2_4'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_4'};
    case {'StaticPhoton_NM2_S2_5'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_5'};
    case {'StaticPhoton_NM2_S2_6'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_6'};
    case {'StaticPhoton_NM2_S2_7'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_7'};
    case {'StaticPhoton_NM2_S2_8'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_8'};
    case {'StaticPhoton_NM2_S2_9'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_9'};
    case {'StaticPhoton_NM2_S2_10'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_10'};
    case {'StaticPhoton_NM2_S2_11'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_11'};
    case {'StaticPhoton_NM2_S2_12'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_12'};
    case {'StaticPhoton_NM2_S2_13'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_13'};
    case {'StaticPhoton_NM2_S2_14'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_14'};
    case {'StaticPhoton_NM2_S2_15'}
        calcParams.cacheFolderList = {'NM2', 'Neutral_NM2_S2_15'};
    case {'FullImageTest' 'FullImageTest2' 'FullImageTest3' 'FullImageTest4'...
            'FullImageTest5' 'OS3Step' 'OS3StepConeAbsorb' 'OSWithNoise'...
            'SOM_linear' 'SOM_linear2' 'OS3StepConeAbsorb2' 'StaticFullImage'...
            'StaticFullImageResizedOI' 'StaticFullImageResizedOI2' 'FullImageDownSampleFixational'...
            'FullImageDownSampleFixational2' 'StaticFullGaussian' ...
            'StaticFullImageResizedOI3' 'StaticFullImageResizedOI4'...
            'StaticFullImageResizedOI5'}
        calcParams.cacheFolderList = {'Neutral', 'Neutral_FullImage'};
    case {'ConstantFullImage'}
        calcParams.cacheFolderList = {'Constant', 'Constant_FullImage'};
    case {'ShuffledFullImage'}
        calcParams.cacheFolderList = {'Shuffled', 'Shuffled_FullImage'};   
    case {'NM1_FullImage' 'StaticFullImageResizedOI8'}
        calcParams.cacheFolderList = {'NM1', 'NM1_FullImage'};   
    case {'NM2_FullImage' 'StaticFullImageResizedOI6' 'StaticFullImageResizedOI7'}
        calcParams.cacheFolderList = {'NM2', 'NM2_FullImage'};       
    otherwise
        error('Unknown calcIDStr set');
end

updatedParams = calcParams;

end


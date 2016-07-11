function [dataset,classes] = df4_EMData(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% [dataset,classes] = df4_EMData(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% 
%
%
%

%% Pre allocate space for data and classes
dataset = cell(n,1);
classes = ones(n,1);
classes(1:n/2) = 0;

%% Generate dataset
%
% This function is rather slow because a new eye movement path has to be
% generated for each training instance.
for ii = 1:n/2

    mosaic.emGenSequence(calcParams.numEMPositions,'em',calcParams.em);
    isomerizations = mosaic.applyEMPath(targetPool{randsample(numel(targetPool),1)},...
        'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        isomerizations = mosaic.os.compute(isomerizations,mosaic.pattern);
    end
    dataset{ii} = isomerizations(:)';
    
    % Generate a new eyemovement path if we are to use different paths
    if ~calcParams.useSameEMPath
        mosaic.emGenSequence(calcParams.numEMPositions,'em',calcParams.em);
    end
    
    
    isomerizations = mosaic.applyEMPath(comparisonPool{1},'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        isomerizations = mosaic.os.compute(isomerizations,mosaic.pattern);
    end
    dataset{ii+n/2} = isomerizations(:)';
end

dataset = cell2mat(dataset);
if ~calcParams.enableOS
    dataset = getNoisySensorImage(calcParams,dataset,kp,kg);
end

end


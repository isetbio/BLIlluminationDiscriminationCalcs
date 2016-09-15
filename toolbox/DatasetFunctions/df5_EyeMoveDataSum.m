function [dataset,classes] = df5_EyeMoveDataSum(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
%DF5_EYEMOVEDATASUM Summary of this function goes here
%   Detailed explanation goes here

%% Pre allocate space for data and classes
dataset = cell(n,1);
classes = ones(n,1);
classes(1:n/2) = 0;

%% Generate dataset
%
% This function is rather slow because a new eye movement path has to be
% generated for each training instance.
for ii = 1:n/2
    
    % Generate data using the target stimulus
    mosaic.emGenSequence(calcParams.numEMPositions,'em',calcParams.em);
    
    % Make sure EM is not out of bounds of our image, maybe this should be
    % the other way around?
    tempEM = mosaic.emPositions;
    outOfBoundsX = abs(tempEM(:,1)) > calcParams.rowPadding;
    outOfBoundsY = abs(tempEM(:,2)) > calcParams.colPadding;
    tempEM(outOfBoundsX,1) = sign(tempEM(outOfBoundsX,1)) * calcParams.rowPadding;
    tempEM(outOfBoundsY,2) = sign(tempEM(outOfBoundsY,2)) * calcParams.colPadding;
    mosaic.emPositions = tempEM;
    
    isomerizations = mosaic.applyEMPath(targetPool{randsample(numel(targetPool),1)},...
        'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        isomerizations = mosaic.os.compute(isomerizations/mosaic.integrationTime,mosaic.pattern);
        calcParams.coneCurrentSize = size(isomerizations);
    end
<<<<<<< HEAD
    isomerizations = sum(isomerizations,3);
=======
>>>>>>> 97ae84bd660df81fefddef0dca356519ec6f8176
    dataset{ii} = isomerizations(:)';
    
    % Generate a new eyemovement path if we are to use different paths
    if ~calcParams.useSameEMPath
        mosaic.emGenSequence(calcParams.numEMPositions,'em',calcParams.em);
        % Make sure EM is not out of bounds of our image, maybe this should be
        % the other way around?
        tempEM = mosaic.emPositions;
        outOfBoundsX = abs(tempEM(:,1)) > calcParams.rowPadding;
        outOfBoundsY = abs(tempEM(:,2)) > calcParams.colPadding;
        tempEM(outOfBoundsX,1) = sign(tempEM(outOfBoundsX,1)) * calcParams.rowPadding;
        tempEM(outOfBoundsY,2) = sign(tempEM(outOfBoundsY,2)) * calcParams.colPadding;
        mosaic.emPositions = tempEM;
    end
    
    % Generate the data using the comparison stimulus
    isomerizations = mosaic.applyEMPath(comparisonPool{1},'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        isomerizations = mosaic.os.compute(isomerizations/mosaic.integrationTime,mosaic.pattern);
    end
<<<<<<< HEAD
    isomerizations = sum(isomerizations,3);
=======
>>>>>>> 97ae84bd660df81fefddef0dca356519ec6f8176
    dataset{ii+n/2} = isomerizations(:)';
end

% Add appropriate noise
dataset = cell2mat(dataset);
if calcParams.enableOS
    dataset = getNoisyConeCurrents(calcParams,dataset,kp,kg);
else
    dataset = getNoisySensorImage(calcParams,dataset,kp,kg);
end

<<<<<<< HEAD
=======
tempDataset = 0;
numOfDataPerSlice = size(dataset,2)/calcParams.numEMPositions;
for ii = 1:calcParams.numEMPositions
    tempDataset = tempDataset + dataset(:,(ii-1)*numOfDataPerSlice+1:ii*numOfDataPerSlice);
end
dataset = tempDataset;

>>>>>>> 97ae84bd660df81fefddef0dca356519ec6f8176
end


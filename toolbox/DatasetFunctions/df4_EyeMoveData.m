function [dataset,classes] = df4_EyeMoveData(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% [dataset,classes] = df4_EMData(calcParams,targetPool,comparisonPool,kp,kg,n,mosaic)
% 
% Generates a data set meant to be used with the second order model.
% Because temporal data quickly inflates the size of a vector, we abandon
% the AB/BA data generation paradigm here. This function will generate eye
% movements as well as do a outer segment calculation if the flags are set.
% Noise will be chosen appropriate to where the calcuation ends (photon for
% isomerizations and osNoise for cone currents)
%
% Inputs:
%     calcParams  -  calcParams struct describing the parameters for this
%                    calculation
%     targetPool  -  cell array of isomerization matrices or matrix
%                    corresponding to the target stimuli
%     comparisonPool  -  cell array of isomerization matrices or matrix
%                        corresponding to the comparison stimuli
%     kp  -  multiplicative factor for Poisson noise
%     kg  -  multiplicative factor for additive zero-mean Gaussian noise
%     n   -  number of samples to generate
%     mosaic - a ISETBIO coneMosaic object set with appropriate parameters
%              for eye movement and outer segment calculations
%
% Outputs:
%     dataset  -  a set of vectorized isomerizations with appropriate noise
%                 added with 50/50 distribution of the two classes. Rows
%                 are observations and columns are features.
%     classes  -  corresponding classes to the dataset output
%
% 7/11/16  xd  wrote it

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
    tempEM = squeeze(mosaic.emPositions);
    outOfBoundsX = abs(tempEM(:,1)) > calcParams.rowPadding;
    outOfBoundsY = abs(tempEM(:,2)) > calcParams.colPadding;
    tempEM(outOfBoundsX,1) = sign(tempEM(outOfBoundsX,1)) * calcParams.rowPadding;
    tempEM(outOfBoundsY,2) = sign(tempEM(outOfBoundsY,2)) * calcParams.colPadding;
    mosaic.emPositions = tempEM;
    isomerizations = mosaic.applyEMPath(targetPool{randsample(numel(targetPool),1)},...
        'emPath', squeeze(mosaic.emPositions), ...
        'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        mosaic.absorptions = isomerizations;
        isomerizations = mosaic.os.compute(mosaic);
        calcParams.coneCurrentSize = size(isomerizations);
    end
    dataset{ii} = isomerizations(:)';
    
    % Generate a new eyemovement path if we are to use different paths
    if ~calcParams.useSameEMPath
        mosaic.emGenSequence(calcParams.numEMPositions,'em',calcParams.em);
        % Make sure EM is not out of bounds of our image, maybe this should be
        % the other way around?
        tempEM = squeeze(mosaic.emPositions);
        outOfBoundsX = abs(tempEM(:,1)) > calcParams.rowPadding;
        outOfBoundsY = abs(tempEM(:,2)) > calcParams.colPadding;
        tempEM(outOfBoundsX,1) = sign(tempEM(outOfBoundsX,1)) * calcParams.rowPadding;
        tempEM(outOfBoundsY,2) = sign(tempEM(outOfBoundsY,2)) * calcParams.colPadding;
        mosaic.emPositions = tempEM;
    end
    
    % Generate the data using the comparison stimulus
    isomerizations = mosaic.applyEMPath(comparisonPool{1},...
        'emPath', squeeze(mosaic.emPositions), ...
        'padRows',calcParams.rowPadding,'padCols',calcParams.colPadding);
    if calcParams.enableOS
        mosaic.absorptions = isomerizations;
        isomerizations = mosaic.os.compute(mosaic);
    end
    dataset{ii+n/2} = isomerizations(:)';
end

% Add appropriate noise
dataset = cell2mat(dataset);
if calcParams.enableOS
    dataset = getNoisyConeCurrents(calcParams,dataset,kp,kg);
else
    dataset = getNoisySensorImage(calcParams,dataset,kp,kg);
end

end


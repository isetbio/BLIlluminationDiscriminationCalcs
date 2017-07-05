function oiArray = sceneArrayToOIArray(oi,sceneArray)
% oiArray = sceneArrayToOIArray(oi,sceneArray)
%  
% Given an OI and a cell array of scenes, this function will perform oi
% compute on all the scenes.
%
% Inputs:
%     oi  -  ISETBIO opticalimage struct for computing the resulting oi's
%            using the input scenes
%     sceneArray  -  cell array of scenes to be used for generating oi's
%
% Outputs:
%     oiArray  -  cell array of opticalimages corresponding to the scenes
%                 in sceneArray
%
% xd  6/30/16  wrote it

oiArray = cellfun(@(X)oiCompute(oi,X),sceneArray,'UniformOutput',false);

end


function oiArray = sceneArrayToOIArray(oi,sceneArray)
% oiArray = sceneArrayToOIArray(oi,sceneArray)
%  
% Given an OI and a cell array of scenes, this function will perform oi
% compute on all the scenes.
%
% xd  6/30/16  wrote it

oiArray = cellfun(@(X)oiCompute(oi,X),sceneArray,'UniformOutput',false);

end


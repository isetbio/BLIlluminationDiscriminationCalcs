function desiredFunction = masterClassifierFunction(functionChoice)
% desiredFunction = masterClassifierFunction(functionChoice)
%  
% This function serves as a wrapper to load the desired classification
% function. 
%
% 6/24/16  xd  wrote it

classifierFunctionPath = fileparts(mfilename('fullpath'));
cfFolder = what(fullfile(classifierFunctionPath));
cfList = cfFolder.m;
desiredFunction = str2func(strrep(cfList{functionChoice},'.m',''));

end


function desiredFunction = masterClassifierFunction(functionChoice)
% desiredFunction = masterClassifierFunction(functionChoice)
%  
% This function serves as a wrapper to load the desired classification
% function. 
%
% Inputs:
%     functionChoice  -  a integer corresponding to the functions located
%                        in the same directory as this function
%
% Outputs:
%     desiredFunction  -  returns a Matlab function object based on the
%                         'functionChoice' input
%
% 6/24/16  xd  wrote it

classifierFunctionPath = fileparts(mfilename('fullpath'));
cfFolder = what(fullfile(classifierFunctionPath));
cfList = cfFolder.m;
desiredFunction = str2func(strrep(cfList{functionChoice},'.m',''));

end


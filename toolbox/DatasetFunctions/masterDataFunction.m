function desiredFunction = masterDataFunction(functionChoice)
% desiredFunction = masterDataFunction(functionChoice)
%  
% This function serves as a wrapper to load the desired data generation
% function. 
%
% Inputs:
%    functionChoice  -  corresponding data function from this folder to load
%
% Outputs:
%    desiredFunction  -  Matlab function object corresponding to
%                        'functionChoice' input 
%
% 6/24/16  xd  wrote it

dataFunctionPath = fileparts(mfilename('fullpath'));
dfFolder = what(fullfile(dataFunctionPath));
dfList = dfFolder.m;
desiredFunction = str2func(strrep(dfList{functionChoice},'.m',''));

end


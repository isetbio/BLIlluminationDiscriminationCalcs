function desiredFunction = masterDataFunction(functionChoice)
% desiredFunction = masterDataFunction(functionChoice)
%  
% This function serves as a wrapper to load the desired data generation
% function. 
%
% xd  6/24/16

dataFunctionPath = fileparts(mfilename('fullpath'));
dfFolder = what(fullfile(dataFunctionPath));
dfList = dfFolder.m;
desiredFunction = str2func(strrep(dfList{functionChoice},'.m',''));

end


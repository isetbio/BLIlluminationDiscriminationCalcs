function desiredFunction = masterDataFunction(functionChoice)
% desiredFunction = masterDataFunction(functionChoice)
%   Detailed explanation goes here

dataFunctionPath = fileparts(mfilename('fullpath'));
dfFolder = what(fullfile(dataFunctionPath));
dfList = dfFolder.m;
desiredFunction = str2func(strrep(dfList{functionChoice},'.m',''));

end


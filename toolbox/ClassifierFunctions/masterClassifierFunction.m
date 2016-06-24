function desiredFunction = masterClassifierFunction(functionChoice)
% desiredFunction = masterClassifierFunction(functionChoice)
%   Detailed explanation goes here

classifierFunctionPath = fileparts(mfilename('fullpath'));
cfFolder = what(fullfile(classifierFunctionPath));
cfList = cfFolder.m;
desiredFunction = str2func(strrep(cfList{functionChoice},'.m',''));

end


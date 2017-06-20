function text = dataFunctionText(functionNumber)
% text = dataFunctionText(functionNumber)
% 
% Gives text associated with data function number. This is for file naming
% purposes.
%
% 9/9/16  xd  wrote it

switch functionNumber
    case 1
        text = 'ABBA';
    case 2
        text = 'ABBAMeanCones';
    case 3
        text = 'noABBA';
    case 4
        text = 'EyeMove';
    otherwise
        error('Invalid data function number!');
end


end


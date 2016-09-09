function text = classifierFunctionText(functionNumber)
% text = classifierFunctionText(functionNumber)
% 
% Returns a string that describes the function. This is for making file
% names.
%
% 9/9/16  xd  wrote it

switch functionNumber
    case 1
        text = 'kNN';
    case 2
        text = 'DiscrimAnalysis';
    case 3
        text = 'SVM';
    case 4
        text = 'distanceBased';
    case 5
        text = '10kFoldSVM';
    otherwise
        error('Invalid function number!');
end



end


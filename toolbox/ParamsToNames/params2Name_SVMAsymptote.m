function name = params2Name_SVMAsymptote(params)
% name = params2Name_SVMAsymptote(params)
%
% Gets name for SVM asymptote script.
%
% 9/15/16  xd  wrote it

name = 'SVMAsymptote';

name = sprintf([name '_FOV-%2.2f_numPCA-%d_IllumStep-%d'],params.sSize,params.numPCA,params.illumStep);

end


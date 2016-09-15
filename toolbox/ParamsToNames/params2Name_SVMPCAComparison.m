function name = params2Name_SVMPCAComparison(params)
% name = params2Name_SVMPCAComparison(params)
%
% Gets name from params.
%
% 9/15/16  xd  wrote it

name = 'SVM_FullVPCA';

name = sprintf([name '_FOV-%2.2f'],params.sSize);

end


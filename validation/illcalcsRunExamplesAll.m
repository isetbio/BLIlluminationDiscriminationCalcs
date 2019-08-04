% Run all the examples in the isetbio tree
%
% Syntax:
%     illcalcsRunExamplesAll
%
% Description:
%     Run all the examples in the isetbio tree,
%     excepthose that contain a line of the form
%     "% ETTBSkip"
%
% See also:
%   ieValidateFullAll, illcalcsRunTutorialsAll

% History:
%   01/17/18  dhb  Wrote it.

ExecuteExamplesInDirectory(fullfile(fileparts(which(mfilename())),'..'),'verbose',false);
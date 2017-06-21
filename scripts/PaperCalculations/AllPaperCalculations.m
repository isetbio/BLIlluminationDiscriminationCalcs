%% AllPaperCalculations
%
% The purpose of this script is to provide a single script through which
% all the main (not necessarily supplemental) calculations are executed.

%% Parameters to set
coresForCreatingOI = 30;
coresPerExecutable = 8;
numExecutables = 5;

%% Get matlab on bash path
PATH = getenv('PATH');
setenv('PATH',[PATH ':' matlabroot '/bin']);

%%
system('matlab -nojvm -nodesktop -r "disp(''hi''); exit;"');

% Generate all the optical images. We assume that the file directory has
% been set up appropriately?
makeAllOISets(coresForCreatingOI);

% Create a list of partial calcParams. This gets looped over to execute all
% the calculations.
calcParamsList = {};
calcParamsList{1} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.62 0.31 0.07]);
calcParamsList{2} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.93 0.00 0.07]);
calcParamsList{3} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.00 0.93 0.07]);
calcParamsList{4} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.66 0.34 0.00]);
calcParamsList{5} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 1.00 0.00 0.00]);
calcParamsList{6} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.00 1.00 0.00]);
calcParamsList{7} = struct('cacheFolderList',{'Constant','Constant_FullImage'},'spatialDensity',[0 0.00 0.00 1.00]);

calcParamsList{8}  = struct('cacheFolderList',{'Neutral','Neutral_FullImage'},'spatialDensity',[0 0.62 0.31 0.07]);
calcParamsList{9}  = struct('cacheFolderList',{'NM1','NM1_FullImage'},'spatialDensity',[0 0.62 0.31 0.07]);
calcParamsList{10} = struct('cacheFolderList',{'NM2','NM2_FullImage'},'spatialDensity',[0 0.62 0.31 0.07]);

% Run number of scripts according to params with number of parallel cores.

for ii = 1:length(calcParamsList)
    for jj = 1:numExecutables
        % Set up strings for vars
        
        % Execute from command line?
        
    end
    
    % Periodically check that the number of result folders is non-zero?
    % There might be a slight possibility that the stars align and all
    % cores finish their current task with finishing the entire
    % calculation, but I think this is not likely to happen.
    
end





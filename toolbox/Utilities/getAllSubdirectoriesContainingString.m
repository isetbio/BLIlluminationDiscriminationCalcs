function subdir = getAllSubdirectoriesContainingString(path,string)
% filenames = getAllFileNamesContainingString(path,string)
% 
% Looks in a directory and returns all subdirectory names that contain a
% given target string.
%
% Inputs:
%     path    -  directory to search in
%     string  -  string to look for
% 
% Outputs:
%     subdir  -  cell array of subdirectories containing the 'string' input
% 
% 7/10/16  xd  wrote it

allsubDir = dir(path);
allsubDir = {allsubDir(:).name};
targetIdx = cell2mat(cellfun(@(X)~isempty(regexp(X,[string '_*\d+'],'once')),allsubDir,'UniformOutput',false));

subdir = allsubDir(targetIdx);

end


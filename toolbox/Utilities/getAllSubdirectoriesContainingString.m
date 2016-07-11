function subdir = getAllSubdirectoriesContainingString(path,string)
% filenames = getAllFileNamesContainingString(path,string)
% 
% Looks in a directory and returns all subdirectory names that contain a
% given target string.
% 
% xd  7/10/16  wrote it

allsubDir = dir(path);
allsubDir = {allsubDir(:).name};
targetIdx = cell2mat(cellfun(@(X)~isempty(strfind(X,string)),allsubDir,'UniformOutput',false));

subdir = allsubDir(targetIdx);

end


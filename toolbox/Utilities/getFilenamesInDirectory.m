function filenames = getFilenamesInDirectory(directory)
% filenames = getFilenamesInDirectory(directory)
% 
% Given an input directory, this function will retrieve all the .mat files
% in that directory. Additionally, it will attempt to sort the filenames
% alphanumerically if possible. This assumes that the filenames follow some 
% sort of pattern as follows: (constant name)[variable #], e.g. ex1.mat.
%
% Inputs: 
%     directory  -  local directory to search
%
% Outputs:
%     filenames  -  cell array of file names found
%
% xd   5/16/16  wrote it

%% Load data and get file names
data = what(directory);
filenames = data.mat;

%% Sort file names
% We first sort it alphanumerically, then sort by number of characters in the
% filename. This puts names with double digits after names with single
% digits.
filenames = sort(filenames);
[~,b] = sort(cellfun(@numel, filenames));
filenames = filenames(b);

end


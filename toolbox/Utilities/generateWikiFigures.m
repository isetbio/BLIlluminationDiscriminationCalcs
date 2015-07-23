function generateWikiFigures(targetDirectory)
% generateWikiFigures(targetDirectory)
%
% This function will convert all the figures located in the targetDirectory
% to PNG images and move them to the wikiFigures directory.  The name of
% the targetDirectory will be the name of the folder created in
% wikiFigures.
%
% Inputs:
%    targetDirectory - The path to the folder with .fig files to convert to
%                      PNG for wikiFigures
%
% 7/23/15  xd  wrote it

%% Get list of figures in target directory
files = dir(targetDirectory);
files = num2cell(files);
theFigureIndex = cellfun(@(X) regexp(X.name, '.fig'), files, 'UniformOutput', false);
theFigureIndex = cellfun('isempty', theFigureIndex);
theFigures = files(~theFigureIndex);

%% Make new folder in wikiFigures
[~, folderName] = fileparts(targetDirectory);
dir = fileparts(fileparts(mfilename('fullfile')));
wikiPath = fullfile(dir, '..', 'wikiFigures',folderName);

if ~exist(wikiPath, 'dir')
    mkdir(wikiPath);
end

%% Save PNG to wikiFigures
for ii = 1:length(theFigures)
    hgload(fullfile(targetDirectory, theFigures{ii}.name));
    FigureSave(fullfile(wikipath, theFigures{ii}.name), gcf, 'png');
    close;
end

end


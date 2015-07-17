function generateWikiFigures
% generateWikiFigures
% 
% This function will pull various figures from this tutorial folder and
% place them in the appropriate folder in WikiFigures.
%
% 7/16/15  xd  wrote it

%% Set up some directory related things
targetTutorialDirectory = 'ClassifiersInHighDimensions';
projectDirectory = fileparts(fileparts(pwd));
tutorialsDirectory = fullfile(projectDirectory, 'tutorials');
targetTutorialPath = fullfile(tutorialsDirectory, targetTutorialDirectory);

%% Get list of folders from the directory
allContents = dir(targetTutorialPath);
isDir = [allContents.isdir];
folders = num2cell(allContents(isDir));

targetDirectories = cellfun(@(X) regexpi(X.name, 'pos|neg|orth'), folders, 'UniformOutput', false);
targetDirectories = cellfun('isempty', targetDirectories);
folders = folders(~targetDirectories);

%% Loop through each folder and get figures
for ii = 1:length(folders)
    theFolderName = folders{ii}.name;
    theFolderContents = dir(fullfile(targetTutorialPath, theFolderName));
    theFolderContents = num2cell(theFolderContents);
    
    theFigureIndex = cellfun(@(X) regexp(X.name, '.fig'), theFolderContents, 'UniformOutput', false);
    theFigureIndex = cellfun('isempty', theFigureIndex);
    theFigures = theFolderContents(~theFigureIndex);
    
    savePath = fullfile(targetTutorialPath, 'WikiFigures', theFolderName);
    for jj = 1:length(theFigures)
        hgload(fullfile(targetTutorialPath, theFolderName, theFigures{jj}.name));
        FigureSave(fullfile(savePath, strtok(theFigures{jj}.name, '.fig')), gcf, 'png');
        close;
    end
end

end


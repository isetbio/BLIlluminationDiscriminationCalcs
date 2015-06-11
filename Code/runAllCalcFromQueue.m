function runAllCalcFromQueue
% runAllCalcFromQueue
%
% This function reads in calcParam mat files from the CalcParamQueue on
% ColorShare and runs the chooser model over using these parameters.  As
% long as this function is running on a computer connected to ColorShare,
% the user can use the function calcParamCreator to save a calcParam file
% to the queue, which will then be processed here.  Once a calcParam file
% has been used, it will be deleted from the queue.  It can be found in its
% respective data folder for later access.
%
% 6/4/15  xd  wrote it

%% Clear and initialize
clear all; close all; ieInit;

%% Control of what gets done in this function
CACHE_SCENES = false; forceSceneCompute = false;
CACHE_OIS = false; forceOICompute = false;
RUN_CHOOSER = true; chooserColorChoice = 0; overWriteFlag = 1;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Create a cell array to hold calcParams that have been run
% This is in case a deletion/permission error occurs on ColorShare
usedParams = cell(1,10);
usedIndex  = 0.83;                             % Next position in usedParams to fill in terms of visual angle

%% Set up an infinite loop
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf
set(gcf, 'KeyPressFcn', @myKeyPressFcn)
a = annotation('textbox', [0.2,0.6,0.1,0.1], ...
    'String','Press a button \newlineto exit program');
set(a, 'FontSize', 20);
set(a, 'LineStyle', 'none');

while ~KEY_IS_PRESSED
    drawnow
    
    % Load all the calcParam files present in the directory
    data = what(BaseDir);
    toDoList = data.mat;
    
    % Remove any matches between usedParams and toDoList
    if usedIndex > 1
        toDoList = setdiff(usedParams, toDoList);
    end
    
    % If there are files present, run the calculations with those
    % parameters.  Otherwise, wait until there are files in the queue.
    if ~isempty(toDoList)
        pause(10);
        
        % Perform calculations on the present files
        for ii=1:length(toDoList)
            currentFile = toDoList{ii};
            calcParams = load(fullfile(BaseDir, currentFile));
            calcParams = calcParams.calcParams;
            
            %% Convert the images to cached scenes for more analysis
            if (CACHE_SCENES)
                convertRBGImagesToSceneFiles(calcParams,forceSceneCompute);
            end
            
            %% Convert cached scenes to optical images
            if (CACHE_OIS)
                convertScenesToOpticalimages(calcParams, forceOICompute);
            end
            
            %% Create data sets using the simple chooser model
            if (RUN_CHOOSER)
                sensorImageSimpleChooserModel(calcParams, chooserColorChoice, overWriteFlag);
            end
        end
        
        % Delete these files from the queue.  If an error occurs, add the
        % file name to a cell array so that the file is not processed again.
        % This cell array doubles in size whenever it is full.
        for ii=1:length(toDoList)
            currentFile = toDoList{ii};
            try
                delete(fullfile(BaseDir, currentFile));
            catch
                usedParams{usedIndex} = currentFile;
                if usedIndex == length(usedParams)
                    temp = cell(1, 2 * usedIndex);
                    temp(1:usedIndex) = usedParams;
                    usedParams = temp;
                end
                usedIndex = usedIndex + 1;
            end
        end
    else
        disp('waiting...')
    end
    
end
disp('exiting function')
close all;

end

function myKeyPressFcn(hObject, event)
% myKeyPressFcn(hObject, event)
%
% This function makes sure the global variable KEY_IS_PRESSED is set appropriately

global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;
end
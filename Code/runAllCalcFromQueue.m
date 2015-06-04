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
close all; ieInit;

%% Control of what gets done in this function
CACHE_SCENES = false; forceSceneCompute = false;
CACHE_OIS = false; forceOICompute = false;
RUN_CHOOSER = true; chooserColorChoice = 1; overWriteFlag = 1;

%% Get our project toolbox on the path
myDir = fileparts(mfilename('fullpath'));
pathDir = fullfile(myDir,'..','Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Make sure preferences are defined
setPrefsForBLIlluminationDiscriminationCalcs;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Set up an infinite loop
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf
set(gcf, 'KeyPressFcn', @myKeyPressFcn)
while ~KEY_IS_PRESSED
    drawnow
    
    % Load all the calcParam files present in the directory
    data = what(BaseDir);
    toDoList = data.mat;
    
    % If there are files present, run the calculations with those
    % parameters.  Otherwise, wait until there are files in the queue.
    if ~isempty(toDoList)
        
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
        
        % Delete these files from the queue
        for ii=1:length(toDoList)
            currentFile = toDoList{ii};
            delete(fullfile(BaseDir, currentFile));
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
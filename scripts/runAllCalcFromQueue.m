function runAllCalcFromQueue
% runAllCalcFromQueue
%
% This function reads in calcParam files from the CalcParamQueue on
% ColorShare and runs the chooser model over using these parameters.  As
% long as this function is running on a computer connected to ColorShare,
% the user can use the function calcParamCreator to save a calcParam file
% to the queue, which will then be processed here.  Once a calcParam file
% has been used, it will be deleted from the queue.  It can be found in its
% respective model data folder for later access.
%
% 6/4/15  xd  wrote it

%% Clear and initialize
ieInit;

%% Get the queue directory
BaseDir = getpref('BLIlluminationDiscriminationCalcs', 'QueueDir');

%% Create a cell array to hold calcParams that have been run
% This is in case a deletion/permission error occurs on ColorShare.
% Currently code associated with these variables are not being used.
usedParams = cell(1,10);
usedIndex  = 1;                             % Next position in usedParams to fill in terms of visual angle

%% Set up an infinite loop
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf;
set(gcf, 'KeyPressFcn', @myKeyPressFcn);
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
        toDoList = toDoList(1);  % Only process one file at a time, this way many computers can draw from the same queue
        pause(5 * rand + 5);     % Pause a random time so that if two computers are running this, file processing conflicts are less likely to occur
        
        % Perform calculations on the current file
        for ii=1:length(toDoList)
            if exist(fullfile(BaseDir, toDoList{ii}), 'file')
                currentFile = toDoList{ii};
                calcParams = load(fullfile(BaseDir, currentFile));
                calcParams = calcParams.calcParams;
                delete(fullfile(BaseDir, currentFile));  % Delete the file so that other computers won't run the same simulation
                try
                    %% Convert the images to cached scenes for more analysis
                    if (calcParams.CACHE_SCENES)
                        convertRBGImagesToSceneFiles(calcParams,calcParams.forceSceneCompute);
                    end
                    
                    %% Convert cached scenes to optical images
                    if (calcParams.CACHE_OIS)
                        convertScenesToOpticalimages(calcParams,calcParams.forceOICompute);
                    end
                    
                    %% Create data sets using the appropriate model
                    if (calcParams.RUN_MODEL)
                        RunModel(calcParams,calcParams.overWriteFlag);
                    end
                    
                    %                 fprintf('This is working fine: %s\n', calcParams.calcIDStr);
                catch
                    err = lasterror;
                    disp(err);
                    disp(err.message);
                    disp(err.stack);
                    disp(err.identifier);
                    save(fullfile(BaseDir, currentFile), 'calcParams'); % Restore the calcParams file if anything occurs
                    error('Something bad happened, but the calcParam has been restored to the queue');
                end
            end
        end
        
        %         % Delete these files from the queue.  If an error occurs, add the
        %         % file name to a cell array so that the file is not processed again.
        %         % This cell array doubles in size whenever it is full.
        %         for ii=1:length(toDoList)
        %             currentFile = toDoList{ii};
        %             try
        %                 delete(fullfile(BaseDir, currentFile));
        %             catch
        %                 usedParams{usedIndex} = currentFile;
        %                 if usedIndex == length(usedParams)
        %                     temp = cell(1, 2 * usedIndex);
        %                     temp(1:usedIndex) = usedParams;
        %                     usedParams = temp;
        %                 end
        %                 usedIndex = usedIndex + 1;
        %             end
        %         end
    else
        disp('waiting...')
    end
    
end
close all;

end

function myKeyPressFcn(hObject, event)
% myKeyPressFcn(hObject, event)
%
% This function makes sure the global variable KEY_IS_PRESSED is set appropriately

global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;
end

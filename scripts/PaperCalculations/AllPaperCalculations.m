%% AllPaperCalculations
%
% The purpose of this script is to provide a single script through which
% all the main (not necessarily supplemental) calculations are executed.
% Note that this script will only execute the model calculations and
% generate the resulting data. It will not execute any of the scripts that
% perform analysis and plotting using the data.
%
% Warning: The entire set of calculations performed by this is script could
% take over a month to finish!
%
% 06/22/17  xd  wrote it

%% Parameters to set
%
% There parameters simply control how many cores (parpool workers) to
% assign to each task.

% Define the number of cores used to generate the optical images. This step
% is fairly quick so even a low number of cores should do the job.
coresForCreatingOI = 30;

% Define the number of times to execute the script and the number of cores
% used on each execution. The product of the two values is the total number
% of cores assigned to a calculation set. The reason that the code is set
% up this way is because the cluster we used is shared with other labs and
% often times other people have set up jobs to run. If we wanted to use 40
% cores, and only 30 are available, splitting up the job like this will
% immediately start 24 cores and the remaining 16 will be queued to run as
% soon as possible.
coresPerExecutable = 8;
numExecutables = 5;

%% Get matlab on bash path
PATH = getenv('PATH');
setenv('PATH',[PATH ':' matlabroot '/bin']);

%% Run the calculation code

% Generate all the optical images. We assume that the file directory has
% been set up appropriately.
% makeAllOISets(coresForCreatingOI);

% Create a list of partial calcParams. This gets looped over to execute all
% the calculations.
calcParamsList = {};
% calcParamsList{1} = setfield(struct('spatialDensity',[0 0.62 0.31 0.07]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{2} = setfield(struct('spatialDensity',[0 0.93 0.00 0.07]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{3} = setfield(struct('spatialDensity',[0 0.00 0.93 0.07]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{4} = setfield(struct('spatialDensity',[0 0.66 0.34 0.00]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{5} = setfield(struct('spatialDensity',[0 1.00 0.00 0.00]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{6} = setfield(struct('spatialDensity',[0 0.00 1.00 0.00]),'cacheFolderList',{'Constant','Constant_FullImage'});
calcParamsList{7} = setfield(struct('spatialDensity',[0 0.00 0.00 1.00]),'cacheFolderList',{'Constant','Constant_FullImage'});

calcParamsList{8}  = setfield(struct('spatialDensity',[0 0.62 0.31 0.07]),'cacheFolderList',{'Neutral','Neutral_FullImage'});
calcParamsList{9}  = setfield(struct('spatialDensity',[0 0.62 0.31 0.07]),'cacheFolderList',{'NM1','NM1_FullImage'});
calcParamsList{10} = setfield(struct('spatialDensity',[0 0.62 0.31 0.07]),'cacheFolderList',{'NM2','NM2_FullImage'});

% Run number of scripts according to params with number of parallel cores.
for ii = 1:length(calcParamsList)
    if isempty(calcParamsList{ii}), continue; end
    
    % Set up strings for vars
    cacheFolderList = calcParamsList{ii}.cacheFolderList;
    oiFolder        = calcParamsList{ii}.cacheFolderList{1};
    sceneFolder     = calcParamsList{ii}.cacheFolderList{2};
    spatialDensity  = mat2str(calcParamsList{ii}.spatialDensity);
    numCores        = num2str(coresPerExecutable);
    
    for jj = 1:numExecutables
        command = ['matlab -nodesktop -nodisplay ' ...
                   '-r "tbUseProject(''BLIlluminationDiscriminationCalcs'',''runLocalHooks'',false);'...
                   'pause(60);'...
                   'cd ~;'...
                   'runAllFirstOrderCalcsParallel(' ...
                   numCores ',''' oiFolder ''',''' sceneFolder ''',' spatialDensity...
                   '); exit;" >output' num2str(jj) '.txt 2>error' num2str(jj) '.txt &'];
        
        % Execute from command line
        system(command);
        disp(command)
        pause(600);
    end
    
    % Periodically check that the number of result folders is non-zero?
    % This indicates that an output folder has been created and no file has
    % been saved there which means the calculation for that folder is still
    % running. When no such folders exist, we move onto the next set of
    % calculations.
    % 
    % There might be a slight possibility that the stars align and all
    % cores finish their current task with finishing the entire
    % calculation, but I think this is not likely to happen.
    analysisPath = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    outputPath = fullfile(analysisPath,'SimpleChooserData');
    
    finish = false;
    while ~finish
        pause(3600);
        hasNotFinishedThisSet = 0;
        folders = dir(outputPath);
        folders = folders(arrayfun(@(x) x.name(1), folders) ~= '.');
        for ff = 1:length(folders)
            individualFolder = dir(fullfile(outputPath,folders(ff).name));
            individualFolder = individualFolder(arrayfun(@(x) x.name(1), individualFolder) ~= '.');
            hasNotFinishedThisSet = hasNotFinishedThisSet + isempty(individualFolder);
        end
        finish = hasNotFinishedThisSet == 0;
    end
end

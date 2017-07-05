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

%% Run the calculation code

% Generate all the optical images. We assume that the file directory has
% been set up appropriately.
% makeAllOISets(coresForCreatingOI);

% Create a list of partial calcParams. This gets looped over to execute all
% the calculations.
calcParamsList = {};
calcParamsList{1} = setfield(struct('spatialDensity',[0 0.62 0.31 0.07]),'cacheFolderList',{'Constant','Constant_FullImage'});
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
    
    % Set up strings for vars
    cacheFolderList = calcParamsList{ii}.cacheFolderList;
    oiFolder        = calcParamsList{ii}.cacheFolderList{1};
    sceneFolder     = calcParamsList{ii}.cacheFolderList{2};
    spatialDensity  = mat2str(calcParamsList{ii}.spatialDensity);
    numCores = num2str(coresPerExecutable);
    
    for jj = 1:numExecutables
        command = ['matlab -nojvm -nodesktop -nodisplay ' ...
                   '-r "tbUseProject(''BLIlluminationDiscriminationCalcs'',''runLocalHooks'',true);'...
                   'runAllFirstOrderCalcsParallel(' ...
                   numCores ',''' oiFolder ''',''' sceneFolder ''',' spatialDensity...
                   '); exit;" >output.txt 2>error.txt &'];
        
        % Execute from command line?
        system(command);
        disp(command)
    end
    
    % Periodically check that the number of result folders is non-zero?
    % There might be a slight possibility that the stars align and all
    % cores finish their current task with finishing the entire
    % calculation, but I think this is not likely to happen.
    analysisPath = getpref('BLIlluminationDiscriminationCalcs','AnalysisDir');
    
    %     thisDir = fileparts(mfilename('fullpath'));
    %     script  = fullfile(thisDir, 'countNonEmptyDirs.sh');
    %     [~,hasFinishedThisSet] = system(['sh ' script ' ''' fullfile(analysisPath,'SimpleChooserData') '''' ]);
    %     while hasFinishedThisSet > 0
    %         pause(3600);
    %         [~,hasFinishedThisSet] = system(['sh ' script ' ''' fullfile(analysisPath,'SimpleChooserData') '''' ]);
    %     end
    
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

%% Run the analysis code
% Maybe this isn't necessary



function convertRBGImagesToSceneFiles
%convertRBGImagesToSceneFiles
%   Function to take in names of folders and convert every RGB image in the
%   target folders to corresponding scene data files in the SceneData
%   folder (currently using temporary local folder)
%
%   3/12/2015   xd  wrote it

    % List of where the images will be stored on ColorShare1
    folderList = {'Standard', 'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};

    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');

    calStructOBJ = loadCalibrationData('StereoLCDLeft');

    % Create the display
    extraData = ExtraCalData;
    extraData.distance = 0.764;
    extraData.subSamplingSvector = [380 8 51];

    % Generate an isetbio display object to model the display used to obtain the calibration data
    saveDisplayObject = true;
    
    tic
    brainardLabDisplay = ptb.GenerateIsetbioDisplayObjectFromPTBCalStruct('BrainardLabStereoLeftDisplay', calStructOBJ.cal, extraData, saveDisplayObject);
    fprintf('Display object generation took %2.1f seconds\n', toc);


    % Loop over each image data folder
    for i = 1:length(folderList)
        imageFilePath = fullfile(dataBaseDir, 'ImageData', folderList{i});
        data = what(imageFilePath);
        fileList = data.mat;

        %   For each image file, load the image and generate a scene from it
        %   using the Brainard Lab Display calibration file
        for s = 1:length(fileList)
            % Create new Scene object if it does not already exist
            imgSize = calStructOBJ.get('screenSizeMM') / 1000;
            imgName = strsplit(fileList{s}, '.');
            sceneCheckPath = fullfile(dataBaseDir, 'SceneData', folderList{i}, strcat(imgName{1}, 'Scene.mat'));
            if (~exist(sceneCheckPath, 'file'))
                getSceneFromRGBImage(folderList{i}, imgName{1}, brainardLabDisplay, imgSize);
            end
            fprintf(imgName{1});
            fprintf('\n');
        end
    end
end


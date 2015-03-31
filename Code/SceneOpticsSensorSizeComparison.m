function SceneOpticsSensorSizeComparison
%SceneOpticsSensorSizeComparison
%This function compares the various pixel sizes of the scene, oi, and
%sensor image to see if any discernable pattern can be attained
%   xd  3/31/15     wrote it

    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);

    s_initISET;
    
    % Load the calibrationData
    calStructOBJ = loadCalibrationData('StereoLCDLeft');
    
    imageData  = loadImageData('Standard/TestImage0');
    
    extraData = ExtraCalData;
    extraData.distance = 0.764;
    dist = 0.764;

    % Generate an isetbio display object to model the display used to obtain the calibration data
    brainardLabDisplay = generateIsetbioDisplayObjectFromCalStructObject('BrainardLabStereoLeftDisplay', calStructOBJ, extraData);
    
    imgSize = calStructOBJ.get('screenSizeMM') / 1000;
    
    scene = sceneFromFile(imageData, 'rgb', [], brainardLabDisplay);  

    % This is h fov
    fov = 2*rad2deg(atan2(imgSize(1)/2,dist));
    scene = sceneSet(scene, 'fov', fov);
    
    y = 40 / 960;
    x = 40 / 1280;
    imgSize2 = [x*imgSize(1), y*imgSize(2)];
    
    fov2 = 2*rad2deg(atan2(imgSize2(1)/2,dist));
    
    
    scene2 = sceneCrop(scene, [550 450 40 40]);
    scene2 = sceneSet(scene2, 'fov', fov2);
    
    vcAddObject(scene2);
    vcAddObject(scene);sceneWindow;
end


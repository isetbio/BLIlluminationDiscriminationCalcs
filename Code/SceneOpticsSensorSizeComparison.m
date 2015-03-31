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
    scene1 = sceneCrop(scene, [550 450 40 40]);
    scene1 = sceneSet(scene1, 'name', 'oldFOV');
    
    
    y = 40 / 960;
    x = 40 / 1280;
    imgSize2 = [x*imgSize(1), y*imgSize(2)];
    
    fov2 = 2*rad2deg(atan2(imgSize2(1)/2,dist));
    
    
    scene2 = sceneCrop(scene, [550 450 40 40]);
    scene2 = sceneSet(scene2, 'fov', fov2);
    scene2 = sceneSet(scene2, 'name', 'oldFOV');
    
    vcAddObject(scene2);
    vcAddObject(scene1);sceneWindow;
    
    optics = oiCreate('human');
    
    oi1 = oiCompute(optics,scene1); 
    oi2 = oiCompute(optics,scene2); 
    
    oi1 = oiSet(oi1, 'name', 'oldFOV');
    oi2 = oiSet(oi2, 'name', 'newFOV');
    
    vcAddObject(oi2); oiWindow;
    vcAddObject(oi1); oiWindow;
    
    
    sensor = sensorCreate;
    sensor = sensorSet(sensor, 'noise flag', 2);
    sensor = sensorSet(sensor,'exp time',0.050);
    sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));

    [sensor1, ~] = sensorSetSizeToFOV(sensor,fov,scene1,oi1);
    [sensor2, ~] = sensorSetSizeToFOV(sensor,fov2,scene2,oi2);
    
    sensor1 = sensorCompute(sensor1,oi1);
    sensor2 = sensorCompute(sensor2,oi2);
    
    sensor1 = sensorSet(sensor1, 'name', 'oldFOV');
    sensor2 = sensorSet(sensor2, 'name', 'newFOV');
    
    vcAddAndSelectObject(sensor1); 
    vcAddAndSelectObject(sensor2); sensorImageWindow;
end


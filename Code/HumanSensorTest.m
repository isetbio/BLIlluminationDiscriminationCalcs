function HumanSensorTest
%HumanSensorTest
%   This function will test the 'human' sensor setting in Isetbio to make
%   sure it is usable for the sensor image chooser model
%   
%   4/17/15     xd     wrote it

    % Clear
    close all; clear global; ieInit;
    
    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);

    % Load the calibrationData
    calStructOBJ = loadCalibrationData('StereoLCDLeft');
    
    imageData  = loadImageData('Standard/TestImage0');
    
    extraData = ptb.ExtraCalData;
    extraData.distance = 0.764;
    % If you want to subsample the primaries, enter a subSamplingVector, otherwise do nothing
    % Here we will subsample with 8 nm subsampling factor
    extraData.subSamplingSvector = [380 8 51];

    % Generate an isetbio display object to model the display used to obtain the calibration data
    saveDisplayObject = true;
    brainardLabDisplay = ptb.GenerateIsetbioDisplayObjectFromPTBCalStruct('BrainardLabStereoLeftDisplay', calStructOBJ.cal, extraData, saveDisplayObject);
    
    imgSize = calStructOBJ.get('screenSizeMM') / 1000;
    
    scene = sceneFromFile(imageData, 'rgb', [], brainardLabDisplay);  
    
    % Generate a scene
    y = 40 / 960;
    x = 40 / 1280;
    imgSize2 = [x*imgSize(1), y*imgSize(2)];
    
    fov2 = 2*rad2deg(atan2(imgSize2(1)/2,extraData.distance));
    
    scene = sceneCrop(scene, [550 450 40 40]);
    scene = sceneSet(scene, 'fov', fov2);
    scene = sceneSet(scene, 'name', 'humanTest');
    
%     vcAddObject(scene);sceneWindow;
    
    % Create a oi
    
    optics = oiCreate('human');
    
    oi = oiCompute(optics,scene); 
    
    oi = oiSet(oi, 'name', 'newFOVHumanTest');
    
%     vcAddObject(oi); oiWindow;

    % Create sensor image    
    sensor = sensorCreate('human');
    sensorRows = sensorGet(sensor,'rows');
    sensor = sensorSet(sensor,'cols',sensorRows);
    sensor = sensorSet(sensor, 'noise flag', 2);
    sensor = sensorSet(sensor,'exp time',0.050);
    sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));

    [sensor, ~] = sensorSetSizeToFOV(sensor,fov2,scene,oi);
    
    sensor = sensorCompute(sensor,oi);
    
    
    data = sensor.data.volts;
    figure; clf;
    imshow(data/max(data(:)));
    
    sensor = sensorSet(sensor, 'name', 'HumanTest');
  
    vcAddAndSelectObject(sensor); 
    sensorWindow('scale',1);
    sensorImageWindow;
    
end


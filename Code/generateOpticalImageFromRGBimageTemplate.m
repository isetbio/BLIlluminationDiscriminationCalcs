function generateOpticalImageFromRGBimageTemplate
% generateOpticalImageFromRGBimageTemplate
%
% Method to generate the optimal image object from the RGB settings data of
% a reference image based on the spectral, gamma, and spatial properties of
% a given display, e.g. 'StereoLCDLeft'.
%
% 2/20/2015    npc  Wrote skeleton script for xiamao ding
% 2/24/2015    xd   Updated to generate isetbio display object and compute
%                   corresponding oi based on said display object
% 2/26/2015    npc  Updated to retrieve image and calibration data from ColorShare1
% 3/2/2015     xd   Updated to generate an additional struct that contains
%                   viewing distance

    % Add project specific toolbox to path dynamically
    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);

    % Load the RGB imageData and generate the calibration object
    % [imageData, calStructOBJ] = loadData();

    % Load the calibrationData
    calStructOBJ = loadCalibrationData('StereoLCDLeft');

    % Load the input image
    imageData  = loadImageData('Standard/TestImage0');

    % the imageData contains an RGB matrix which is
    % sent to the frame buffer for display on a given monitor
    % displayImage(imageData);

    % Initialize ISETBIO
    s_initISET;

    dataBaseDir   = getpref('BLIlluminationDiscriminationCalcs', 'DataBaseDir');
    sceneCheckPath = fullfile(dataBaseDir, 'SceneData', 'Standard', 'TestImage0Scene.mat');
    if (~exist(sceneCheckPath, 'file'))
        extraData = ExtraCalData;
        extraData.distance = 0.764;

        % Generate an isetbio display object to model the display used to obtain the calibration data
        tic
        brainardLabDisplay = generateIsetbioDisplayObjectFromCalStructObject('BrainardLabStereoLeftDisplay', calStructOBJ, extraData);
        fprintf('Display object generation took %2.1f seconds\n', toc);

        % Generate scene using custom display object generated above.
        imgSize = calStructOBJ.get('screenSizeMM') / 1000;

        scene = getSceneFromRGBImage('Standard', 'TestImage0', brainardLabDisplay, imgSize);
    else
        scene = loadSceneData('Standard','TestImage0');
    end
    vcAddObject(scene);
    sceneWindow;

    % Code to generate the optical image

    % Pass in just the name without .mat, let function take care of that,
    % do not pass 'Scene' part of name either, let function append so that it
    % can replace with 'Optics' when saving
    oiCheckPath = fullfile(dataBaseDir, 'OpticalImageData', 'Standard', 'TestImage0OpticalImage.mat');
    if (~exist(oiCheckPath, 'file'))
        oi = getOpticalImageFromSceneData('Standard', 'TestImage0');
    else
        oi = loadOpticalImageData('Standard', 'TestImage0');
    end
    vcAddObject(oi); oiWindow;

    %     oi = loadOpticalImageData('BlueIllumination', 'blue1L-RGB');
    %     vcAddObject(oi); oiWindow;


    imgSize = calStructOBJ.get('screenSizeMM') / 1000;
    fov = rad2deg(atan2(imgSize(1),0.764));

    tic
    sensor = sensorCreate();
    %     sensor = sensorCreate('human');
    sensor = sensorSet(sensor, 'noise flag', 1);
    sensor = sensorSet(sensor,'exp time',0.050);

    [sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);
    sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));


    %     expTimes = [0.005 0.010 0.050 0.100 0.2];
    %     sensor   = sensorSet(sensor,'Exposure Time',expTimes);
    sensorimage   = sensorCompute(sensor,oi);
    %     sensor   = sensorSet(sensor,'ExposurePlane',3);
    fprintf('Sensor image object generation took %2.1f seconds\n', toc);
    vcAddAndSelectObject(sensorimage); sensorImageWindow;

    end


    function displayImage(imageData)
    figure();s
    subplot(2,2,1);
    imshow(imageData);

    componentNames = {'red channel', 'green channel', 'blue channel'};
    for channel = 1:numel(componentNames)
        mask = zeros(size(imageData)); mask(:,:,channel) = 1;
        componentImage = imageData .* mask;
        subplot(2,2,1+channel)
        imshow(componentImage);
        title(componentNames{channel});
    end
end
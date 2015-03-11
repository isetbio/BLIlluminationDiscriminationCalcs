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
    
    extraData = ExtraCalData;
    extraData.distance = 0.764;
    
    % Generate an isetbio display object to model the display used to obtain the calibration data
    tic
    brainardLabDisplay = generateIsetbioDisplayObjectFromCalStructObject('BrainardLabStereoLeftDisplay', calStructOBJ, extraData);
    fprintf('Display object generation took %2.1f seconds\n', toc);
    
    % Generate scene using custom display object generated above.
    tic
    scene = sceneFromFile(imageData, 'rgb', [], brainardLabDisplay);  
    fprintf('Scene object generation took %2.1f seconds\n', toc);
    
    imgSize = calStructOBJ.get('screenSizeMM') / 1000;
    dist = extraData.distance;
    
    fov = rad2deg(atan2(imgSize(1),dist));
    scene = sceneSet(scene, 'fov', fov);
    
    % Comment out the above and uncomment the line below to use the default
    % display
   
    % scene = sceneFromFile(imageData, 'rgb');  
    
    vcAddObject(scene);
    sceneWindow;
    
    % Code to generate the optical image
    oi = oiCreate('human');
    tic
    oi = oiCompute(oi,scene); 
    fprintf('Optical image object generation took %2.1f seconds\n', toc);
    vcAddObject(oi); oiWindow;

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
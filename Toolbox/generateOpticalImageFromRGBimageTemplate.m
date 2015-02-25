function generateOpticalImageFromRGBimageTemplate

    % Load the RGB imageData and generate the calibration object
    [imageData, calStructOBJ] = loadData();

    % the imageData contains an RGB matrix which is
    % sent to the frame buffer for display on a given monitor
%     displayImage(imageData);

    % Initialize ISETBIO
    s_initISET;
    
    % Generate an isetbio display object to model the display used to obtain the calibration data
    brainardLabDisplay = generateIsetbioDisplayObjectFromCalStructObject('BrainardLabStereoLeftDisplay', calStructOBJ);
    
    % Code to generate an isetbio scene from the RGB imageData
    
    % Using the calibration data from the Brainard Lab Display
    % Comment this out and use the default diplay for quicker results
    scene = sceneFromFile(imageData, 'rgb', [], brainardLabDisplay);    
    imgSize = calStructOBJ.get('screenSizeMM') / 1000;
    dist = 0.764;
    
    fov = rad2deg(atan2(imgSize(1),dist));
    scene = sceneSet(scene, 'fov', fov);
    
    % Comment out the above and uncomment the line below to use the default
    % display
   
%     scene = sceneFromFile(imageData, 'rgb');  
    
    vcAddObject(scene);
    sceneWindow;
    
    % Code to generate the optical image
    oi = oiCreate('human');
    oi = oiCompute(oi,scene); 
    vcAddObject(oi); oiWindow;

end

% Method to load the image and the calibration data from the given matfile
function [imageData, calStructOBJ] = loadData()
    % Load the image data and the calibration filename
    data = load('data.mat');
    imageData   = data.sensorImageLeftRGB;
    calFileName = data.calData.calLeftName;
    
    % Load the calibration data from the calibration file
    cal = LoadCalFile(calFileName, Inf);

    % Generate calStructOBJ to access the calibration data
    calStructOBJ = ObjectToHandleCalOrCalStruct(cal);
    clear 'cal'
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



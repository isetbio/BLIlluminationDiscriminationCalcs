function locations = getLocationsUsedInFirstOrderModel
% getLocationsUsedInFirstOrderModel
% 
% This function will return a list of the 30 locations used in the first
% order model.  This can be used in conjunction with getSaccades to create
% eye movement saccadic movements that mimic what the first order model is
% doing (averaging decisions based on multiple locations of focus). 
%
% Outputs:
%   locations  -  A 30x2 matrix where each row represents an (x,y)
%                 coordinate on the whole image, scaled and shifted so that
%                 (0,0) is the center of the image.  These locations should
%                 only be used with the getSaccades function.
% 
% 3/15/16  xd  wrote it

%% Initialize a matrix to store the data
locations = zeros(30, 2);

%% Fill using the raw locations
% Both sets of 15 are numbered 2-15. Set 1 does not have a number for the
% first image, set 2 does, so they will be added separately.

calcParams.calcIDStr = 'StaticPhoton';
calcParams = updateCropRect(calcParams);
locations(1,:) = calcParams.cropRect(1:2);
calcParams.calcIDStr = 'StaticPhoton_S2_1';
calcParams = updateCropRect(calcParams);
locations(16,:) = calcParams.cropRect(1:2);

for ii = 2:15
    calcParams.calcIDStr = ['StaticPhoton_' num2str(ii)];
    calcParams = updateCropRect(calcParams);
    locations(ii,:) = calcParams.cropRect(1:2);
    calcParams.calcIDStr = ['StaticPhoton_S2_' num2str(ii)];
    calcParams = updateCropRect(calcParams);
    locations(ii + 15,:) = calcParams.cropRect(1:2);
end

%% Scale the raw values so that the center of the image is (0,0)
% Get the cropRect of the whole image first
calcParams.calcIDStr = 'FullImage';
calcParams = updateCropRect(calcParams);

fullImageCropRect = calcParams.cropRect;
xOffset = round(fullImageCropRect(1) + 0.5 * fullImageCropRect(3));
yOffset = round(fullImageCropRect(2) + 0.5 * fullImageCropRect(4));
for ii = 1:length(locations)
    locations(ii,:) = [locations(ii,1) - xOffset locations(ii,2) - yOffset];
end

%% Scale location values from scene pos to sensor pos
% Load the scene and oi for the full image to readjust the sensor size
scene = loadSceneData('Neutral_FullImage/Standard', 'TestImage0');
oi = loadOpticalImageData('Neutral_FullImage/Standard', 'TestImage0');
sensor = sensorCreate('human');
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), scene, oi);

% Take the ratio of sensor size to scene size and multiply these by
% locations to get the appropriate sensor location values. Round before
% returning since only integer index values are accepted. The scene
% positions are multiplied by the negative size factor because images are
% flipped when entering eye.
sizeFactor = sensorGet(sensor, 'size') ./ sceneGet(scene, 'size');
locations(:,1) = locations(:,1) * -sizeFactor(1);
locations(:,2) = locations(:,2) * -sizeFactor(2);
locations = round(locations);

end


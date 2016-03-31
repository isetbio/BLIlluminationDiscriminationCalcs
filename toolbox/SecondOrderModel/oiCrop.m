function croppedoi = oiCrop(oi, cropRect)
% croppedoi = oiCrop(oi, cropRect)
% 
% This function takes in an ISETBIO optical image and crops it according to
% the cropRect parameter. 
%
% Inputs:
%   oi        - ISETBIO optical image, refer to the ISETBIO toolbox for more information
%   cropRect  - A vector of form [x y width height] that specifies the top
%               left corner of the desired cropping area with (x,y) and the
%               width and height of the cropping area with the latter two variables
%
% Outputs:
%   croppedoi - An oi that represents the cropped region of the original
%               oi. The only adjusted values are the image data itself and
%               the fov which will be scaled accordingly.
%
% xd   3-31-2016  wrote it

%% Check inputs
if notDefined('oi'), error('Optical Image input missing!'); end
if notDefined('cropRect'), error('Cropping rectangle input missing!'); end

%% Get the old data and take the parts defined by the cropRect
oldData = oiGet(oi, 'data');

% Assign cropRect entries to variables for easier access
x = cropRect(1);
y = cropRect(2);
w = cropRect(3);
h = cropRect(4);

% Crop the old data
newData = oldData(x:x+w, y:y+h, :);

%% Calculate the new fov
oldFOV = oiGet(oi, 'fov');

oldDim = size(oldData);
oldW = oldDim(1);

newFOV = oldFOV * w / oldW;

%% Create cropped oi with newData and newFOV
croppedoi = oi;
croppedoi = oiSet(croppedoi, 'data', newData);
croppedoi = oiSet(croppedoi, 'fov', newFOV);
  
end


function optics = loadOpticalImageData(folderName, imageName)
%loadOpticalImageData
%   Loads the saved optical image data for BLIlluminationCalcs.  Currently using a
%   local temp folder until write access to ColorShare1 is attained.
%
%   3/12/2015   xd  wrote it

    path = strcat(folderName, '/', imageName, 'Optics.mat');

    data = load(path);
    optics = data.optics;

end


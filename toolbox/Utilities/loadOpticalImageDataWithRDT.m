function opticalImage = loadOpticalImageDataWithRDT(folderName,imageName)
% opticalImage = loadOpticalImageDataWithRDT(folderName,imageName)
% 
% Loads an optical image from the archiva server using the Remote Data
% Toolbox. This function is mainly used in validation scripts so that the
% auto-validation for each push can read data from the server instead of
% a local hard disk.
%
% 4/24/17  xd  wrote it

% Path to OI on archiva
opticsPath = fullfile('/resources', 'OpticalImageData', folderName);

% Set up RDT client
rd = RdtClient(getpref('BLIlluminationDiscrimCalcsValidation','remoteDataToolboxConfig'));
rd.crp(opticsPath);

% Load optical image
opticalImage = rd.readArtifact([imageName 'OpticalImage']);
opticalImage = opticalImage.opticalimage;

end


function mosaic = getDefaultBLIllumDiscrMosaic
% mosaic = getDefaultBLIllumDiscrSensor
% 
% This functions returns a default sensor used mainly for testing in
% the BLIlluminationDiscrimination Project.
%
% Outputs:
%     mosaic  -  ISETBIO coneMosaic used for some testing and validation
%                scripts in this project
%
% 6/XX/15  xd  wrote it
% 7/8/16   xd  changed to use coneMosaic

% mosaic = coneMosaic;
% mosaic.fov = 1;
% mosaic.integrationTime = 0.050;
% mosaic.noiseFlag = 'none';
% mosaic.wave = SToWls([380 8 51]);
% mosaic.spatialDensity = [0 0.62 0.31 0.07];

dataDir = getpref('BLIlluminationDiscriminationCalcs','DataBaseDir');
mosaic = load(fullfile(dataDir,'MosaicData','coneMosaic1.1degs.mat'));
mosaic = mosaic.coneMosaic;
mosaic.noiseFlag = 'none';

end


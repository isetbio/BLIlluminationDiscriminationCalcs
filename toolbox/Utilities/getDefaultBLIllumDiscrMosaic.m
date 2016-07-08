function mosaic = getDefaultBLIllumDiscrMosaic
% sensor = getDefaultBLIllumDiscrSensor
% 
% This functions returns a default sensor used mainly for testing in
% the BLIlluminationDiscrimination Project
%
% 6/XX/15  xd  wrote it
% 7/8/16   xd  changed to use coneMosaic

mosaic = coneMosaic;
mosaic.fov = 0.83;
mosaic.integrationTime = 0.050;
mosaic.noiseFlag = false;
mosaic.wave = SToWls([380 8 51]);

end


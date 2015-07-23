function varargout = v_PixelNoise(varargin)
%
%  Validate that the pixel noise across different renderings is roughly equal.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
rng(1);

tolerance = 200;

sensor = getDefaultBLIllumDiscrSensor;

oi1 = loadOpticalImageData('Neutral/Standard', 'TestImage0');
oi2 = loadOpticalImageData('PixelNoise/Standard', 'blue0L1-RGB');
oi3 = loadOpticalImageData('PixelNoise/Standard', 'blue0L2-RGB');
oi4 = loadOpticalImageData('PixelNoise2/Standard', 'blue0L1-RGB');
oi5 = loadOpticalImageData('PixelNoise2/Standard', 'blue0L3-RGB');

s1 = coneAbsorptions(sensor, oi1);
s2 = coneAbsorptions(sensor, oi2);
s3 = coneAbsorptions(sensor, oi3);
s4 = coneAbsorptions(sensor, oi4);
s5 = coneAbsorptions(sensor, oi5);

p1 = sensorGet(s1, 'photons');
p2 = sensorGet(s2, 'photons');
p3 = sensorGet(s3, 'photons');
p4 = sensorGet(s4, 'photons');
p5 = sensorGet(s5, 'photons');

UnitTest.validationRecord('SIMPLE_MESSAGE', '***** Photon Distances *****');

p1p2 = norm(p1(:) - p2(:));
p1p3 = norm(p1(:) - p3(:));
p1p4 = norm(p1(:) - p4(:));
p1p5 = norm(p1(:) - p5(:));

UnitTest.assertIsZero(p1p2 - p1p3,'DISTANCE DIFFERENCE for p1p2 to p1p3',tolerance);
UnitTest.assertIsZero(p1p2 - p1p4,'DISTANCE DIFFERENCE for p1p2 to p1p4',tolerance);
UnitTest.assertIsZero(p1p3 - p1p4,'DISTANCE DIFFERENCE for p1p3 to p1p4',tolerance);
UnitTest.assertIsZero(p1p3 - p1p5,'DISTANCE DIFFERENCE for p1p3 to p1p5',tolerance);

UnitTest.validationData('p1p2', p1p2);

end
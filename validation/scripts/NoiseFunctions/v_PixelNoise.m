function varargout = v_PixelNoise(varargin)
%
%  Validate that the pixel noise across different renderings is roughly equal.
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
close all;

%% Add Toolbox for this project dynamically to Matlab path
myDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
pathDir = fullfile(myDir,'Toolbox','');
AddToMatlabPathDynamically(pathDir);

%% Validation.
%
% Fix random number generator seed 
rng(1);
tolerance = 200;

% Generate a default sensor that will be used in many of the validation
% scripts.
mosaic = getDefaultBLIllumDiscrMosaic;

% Load several different renderings of the target image from the experiment.
try
    oi1 = loadOpticalImageData('Neutral/Standard', 'TestImage0');
    oi2 = loadOpticalImageData('Neutral/Standard', 'TestImage1');
    oi3 = loadOpticalImageData('Neutral/Standard', 'TestImage2');
    oi4 = loadOpticalImageData('Neutral/Standard', 'TestImage4');
    oi5 = loadOpticalImageData('Neutral/Standard', 'TestImage6');
catch
    error('It seems that you do not have the OI required for this validation. Please contact the project developers to obtain it');
end

% Calculate the photon absorptions
p1 = mosaic.compute(oi1);
p2 = mosaic.compute(oi2);
p3 = mosaic.compute(oi3);
p4 = mosaic.compute(oi4);
p5 = mosaic.compute(oi5);

UnitTest.validationRecord('SIMPLE_MESSAGE', '***** Photon Distances *****');

% We want to validate that the Euclidian distance between all of these
% renderings are within a tolerance of each other.  This is to confirm
% that the different renderings are similar to each other.
p1p2 = norm(p1(:) - p2(:));
p1p3 = norm(p1(:) - p3(:));
p1p4 = norm(p1(:) - p4(:));
p1p5 = norm(p1(:) - p5(:));

UnitTest.assertIsZero(p1p2 - p1p3,'DISTANCE DIFFERENCE for p1p2 to p1p3',tolerance);
UnitTest.assertIsZero(p1p2 - p1p4,'DISTANCE DIFFERENCE for p1p2 to p1p4',tolerance);
UnitTest.assertIsZero(p1p3 - p1p4,'DISTANCE DIFFERENCE for p1p3 to p1p4',tolerance);
UnitTest.assertIsZero(p1p3 - p1p5,'DISTANCE DIFFERENCE for p1p3 to p1p5',tolerance);

UnitTest.validationData('p1p2', p1p2);
UnitTest.validationData('p1p3', p1p3);
UnitTest.validationData('p1p4', p1p4);
UnitTest.validationData('p1p5', p1p5);

end

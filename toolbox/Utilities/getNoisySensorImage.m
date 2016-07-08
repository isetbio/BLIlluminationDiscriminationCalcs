function isomerizations = getNoisySensorImage(calcParams,isomerizations,Kp,Kg)
% getNoisySensorImage(calcParams, folderName, imageName, sensor, k)
%
% Generate a single noisy sensor image of the input optical image location
% using the given input sensor.  The noise can be a combination of Poisson
% and Gaussian noise.  If Gaussian noise is desired, be sure to have the
% field meanStandard specified in the calcParams.
%
% Inputs:
%   calcParams - These parameters contains options defining whether or not
%                to use cone adaptation.
%   sensor     - A sensor which already contains a noise free sensor image.
%                This sensor image will be used to compute a noisy image
%                with the desired k-value.
%   Kp         - The k factor for the Poisson noise of this image.
%   Kg         - The k factor for the Gaussian noise in this image.  The
%                standard deviation for this noise will be the sqaure root
%                of the mean of the target image isomerizations.
%
% Outputs:
%   photons - the photon data from the generated sensor image.
%
% 3/18/2015   xd  wrote it
% 4/17/2015   xd  updated to use the human sensor
% 5/18/2015   xd  changed to use photon data instead of volt data
% 6/3/15      xd  now requires a precomputed noise free image

%% Use a default k-values for p and g
if nargin == 3
    Kg = 0;
end
if (nargin < 3)
    Kp = 1;
    Kg = 0;
end

%% Calculate noisy sample

% Get poisson noise, this is in photons
[~,nP] = coneMosaic.photonNoise(isomerizations);

% Get the Gaussian noise
nG = sqrt(calcParams.meanStandard) * randn(size(noiseFree));

% Add noise back with multipliers
isomerizations = isomerizations + Kp * nP + Kg * nG;

% Photons are whole numbers
isomerizations = round(isomerizations);     % Disable rounding for bug testing

end


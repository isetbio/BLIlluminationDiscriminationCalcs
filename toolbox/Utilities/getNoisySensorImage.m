function isomerizations = getNoisySensorImage(calcParams,isomerizations,Kp,Kg)
% isomerizations = getNoisySensorImage(calcParams,isomerizations,Kp,Kg)
%
% Generate a single noisy sensor image of the input optical image location
% using the given input sensor.  The noise can be a combination of Poisson
% and Gaussian noise.  If Gaussian noise is desired, be sure to have the
% field meanStandard specified in the calcParams.
%
% Inputs:
%   calcParams     - These parameters contains options defining whether or 
%                    not to use cone adaptation.
%   isomerizations - A noise free isomerization data matrix obtained from a
%                    coneMosaic object's compute function.
%   Kp             - The k factor for the Poisson noise of this image.
%   Kg             - The k factor for the Gaussian noise in this image. The
%                    standard deviation for this noise will be the sqaure 
%                    root of the mean of the target image isomerizations.
%
% Outputs:
%   isomerizations - isomerization data with added noise
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

% Check if noise flag is set
noiseFlag = 'random';
if isfield(calcParams,'frozen')
    if calcParams.frozen
        noiseFlag = 'frozen';
    end
end

% Get poisson noise, this is in photons
[~,nP] = coneMosaic.photonNoise(isomerizations, 'noiseFlag', noiseFlag);

% Get the Gaussian noise
nG = sqrt(calcParams.meanStandard) * randn(size(isomerizations));

% Add noise back with multipliers
isomerizations = isomerizations + Kp * nP + Kg * nG;

% Photons are whole numbers
isomerizations = round(isomerizations);     % Disable rounding for bug testing

end


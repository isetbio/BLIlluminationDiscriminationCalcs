function currents = getNoisyConeCurrents(calcParams,currents,~,Kg)
% currents = getNoisyConeCurrents(calcParams,isomerizations,~,Kg)
%  
% Multiplies the noise in the outer segment cone currents by a factor of Kg
%
% 7/11/16  xd  wrote it

%% Default values
if (nargin <= 3), Kg = 1; end

%% Add noise with multiplier
for ii = 1:size(currents,1)
    tempCurrent = reshape(currents(ii,:),calcParams.coneCurrentSize);
    noise = zeros(size(tempCurrent));
    noise = osAddNoise(noise,struct('sampTime',calcParams.coneIntegrationTime));
    tempCurrent = tempCurrent + Kg*noise;
    currents(ii,:) = tempCurrent(:);
end


end


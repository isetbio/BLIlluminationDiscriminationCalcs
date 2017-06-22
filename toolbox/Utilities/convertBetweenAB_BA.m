function BAAB = convertBetweenAB_BA(AB_BA)
% function BA_AB = convertBetweenAB_BA(AB_BA)
% 
% This function takes in an AB or BA format vector of cone response data
% and returns the BA or AB version.
%
% Inputs:
%     ABBA   -  isomerization vector in ABBA format
%
% Outputs:
%     BAAB   -  isomerization vector in BAAB format
%
% 5/26/16  xd  wrote it


lengthOfVector = length(AB_BA);
BAAB = [AB_BA(lengthOfVector/2+1:end) AB_BA(1:lengthOfVector/2)];

end


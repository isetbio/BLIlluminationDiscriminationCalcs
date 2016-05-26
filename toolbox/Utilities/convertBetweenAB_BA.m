function BA_AB = convertBetweenAB_BA(AB_BA)
% function BA_AB = convertBetweenAB_BA(AB_BA)
% 
% This function takes in an AB or BA format vector of cone response data
% and returns the BA or AB version.
%
% xd  5/26/16  wrote it


lengthOfVector = length(AB_BA);
BA_AB = [AB_BA(1:lengthOfVector/2) AB_BA(lengthOfVector/2+1:end)];

end


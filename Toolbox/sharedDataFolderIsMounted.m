function status = sharedDataFolderIsMounted
% status = sharedDataFolderIsMounted
%
% Method to check whether the shared data folder is mounted
% If the shared folder is not mounted, it returns false and gives instructions
% on how to mount the folder. Otherwise, it returns true.
%
% 2/25/2015     npc     Wrote it.
% 

    if (isdir('/Volumes/ColorShare1'))
        status = true;
    else
        status = false;
        fprintf(2,'You need to mount the ColorShare1 folder. In Finder do: Go -> Connect to Server and enter the following address: ''afp://scallop.psych.upenn.edu/ColorShare1'' ');
    end
    
end
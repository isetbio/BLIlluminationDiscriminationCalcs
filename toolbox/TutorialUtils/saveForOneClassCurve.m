function saveForOneClassCurve(path,data,trainingSize,testingSize)
% saveForOneClassCurve(path,data,trainingSize,testingSize)
% 
% Used to save data within a parfor for this particular tutorial.
%
% Date unknown   xd  wrote it

save(path,'data','trainingSize','testingSize');

end


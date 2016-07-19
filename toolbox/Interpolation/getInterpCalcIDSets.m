function calcIDList = getInterpCalcIDSets(setNumber)
% calcIDList = getInterpCalcIDSets(setNumber)
%
% Returns a list of calcIDs associated with the interpolation set number.
% These calcIDs will be ordered with the interpolation.
%
% 7/18/16  xd  wrote it

switch (setNumber)
    case 1
        calcIDList = {'SVM_Static_Interp_End_60'...
                      'SVM_Static_Interp1'...
                      'SVM_Static_Interp2'...
                      'SVM_Static_Interp3'...
                      'SVM_Static_Interp_End_71'};
    case 2
        calcIDList = {'SVM_Static_InterpSet2_End_1'...
                      'SVM_Static_InterpSet2_Interp_1'...
                      'SVM_Static_InterpSet2_Interp_2'...
                      'SVM_Static_InterpSet2_Interp_3'...
                      'SVM_Static_InterpSet2_End_12'};
    otherwise
        error('No such interpolation set number!');
end


end


function decision = sensorImageChooser(noisyStandard, noisyTest1, noisyTest2)
% decision = sensorImageChooser(noisyStandard, noisyTest1, noisyTest2)
%
% This function instantiates a near-ideal observer for the for the S - T1 -
% T2 paradigm.
%
% It compares the two tests to the standard, and returns 1 or 2 depending on which one was closer
% in a Euclidean sense.
%
% The inputs are arrays of sensor responses, each of the same dimension.
%
% 3/17/15  xd  Wrote it

%% Get the two relevant differences
delta1 = noisyStandard - noisyTest1;
delta2  = noisyStandard - noisyTest2;

%% Get their Euclidean norms
diff1 = norm(delta1(:));
diff2 = norm(delta2(:));

%% Respond according to which difference was smaller
if diff1 < diff2
    decision = 1;
else
    decision = 2;
end

end


function decision = sensorImageChooser(sensor, noisySensor, testSensor)
%sensorImageChooser
%   This function tests the three input sensor images against each other.
%   It calculates the norm of A = |sensor - noisy| and B = |sensor - test| 
%   and returns '1' if A < B and '2' otherwise.  The inputs are assumed to
%   be the vold data in the sensors
%
%   3/17/15     xd  wrote it

    deltaNoise = sensor - noisySensor;
    deltaTest  = sensor - testSensor;
    
    A = norm(deltaNoise);
    B = norm(deltaTest);
    
    if A < B
        decision = 1;
    else
        decision = 2;
    end

end


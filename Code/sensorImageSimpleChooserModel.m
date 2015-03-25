function sensorImageSimpleChooserModel
%sensorImageSimpleChooserModel 
%   This function will generate several noisy versions of the standard
%   image.  Then it will compare the standard with one of the noisy images
%   and a test image and choose the one closest to the standard image.
%   Success rate will be defined as how many times it chooses the noisy
%   standard image.
%
%   3/17/15     xd  wrote it

    myDir = fileparts(mfilename('fullpath'));
    pathDir = fullfile(myDir,'..','Toolbox','');
    AddToMatlabPathDynamically(pathDir);

    s_initISET;
    
    % Load scene to get FOV
    scene = loadSceneData('Standard', 'TestImage0');
    fov = sceneGet(scene, 'fov');
    scene = sceneSet(scene,'fov',fov/4);
    fov = sceneGet(scene, 'fov');

    % load oi for FOV
    oi = loadOpticalImageData('Standard', 'TestImage0');
    
    % Create a sensor
    sensor = sensorCreate;
%     sensor = sensorSet(sensor, 'noise flag', 1);
    sensor = sensorSet(sensor,'exp time',0.050);
    [sensor, ~] = sensorSetSizeToFOV(sensor,fov,scene,oi);
    sensor = sensorSet(sensor, 'wavelength', SToWls([380 8 51]));
    
    % Simulate trials
    nSimulatedTrials = 100;
    correct = zeros(nSimulatedTrials,1);
    for t = 1:nSimulatedTrials
        if (rem(t,10) == 0)
            fprintf('Finished %d of %d simulated trials\n',t,nSimulatedTrials);
        end
        
        % We need one sample for the initially presented reference standard image
        voltsStandardReference = getNoisySensorImages('Standard','TestImage0',sensor,1);
        
        % We need one sample for the comparison version of the standard image
        voltsStandardComparison = getNoisySensorImages('Standard','TestImage0',sensor,1);
        
        % We need one sample for the presented version of the test image
        %voltsTestComparison = getNoisySensorImages('BlueIllumination','blue1L-RGB',sensor,1);
        voltsTestComparison = getNoisySensorImages('Standard','TestImage0',sensor,1);
        
        if (t == 1)
            figure; clf;
            imshow(voltsStandardReference/max(voltsStandardReference(:)));
            figure; clf;
            imshow(voltsStandardComparison/max(voltsStandardComparison(:)));
            figure; clf;
            imshow(voltsTestComparison/max(voltsTestComparison(:)));
            drawnow;
        end
        
        % Figure out which comparison is closer to standard
        distToStandard = norm(voltsStandardReference(:)-voltsStandardComparison(:));
        distToTest = norm(voltsStandardReference(:)-voltsTestComparison(:));
        
        % Decide if 'subject' was correct on this trial
        if (distToStandard < distToTest)
            correct(t) = 1;
        else
            correct(t) = 0;
        end
    end
    fprintf('Percent correct = %d\n',round(100*sum(correct)/length(correct)));
    
    % Get noisy sensor images
    k = 10;
    volts = getNoisySensorImages('Standard', 'TestImage0', sensor, k);
    
 
    
    folderList = {'BlueIllumination', 'GreenIllumination', ...
        'RedIllumination', 'YellowIllumination'};
    
    suffix = 'L-RGB';
    prefix = {'blue' , 'green', 'red', 'yellow'};
    
    total = 10;
    count = 0;
    for i = 1:total
        tic
        folderNum = floor(4 * rand()) + 1;
        imageNum  = floor(50 * rand()) + 1;
        imageNum  = min(50, imageNum);
        noisyNum  = floor(10 * rand()) + 1;
        
        % Get test image sample
        imageName = strcat(prefix{folderNum}, int2str(imageNum), suffix);
        oi = loadOpticalImageData(folderList{folderNum}, imageName);
        
        % Get sensor image and volt data
        sensorImage = sensorCompute(sensor, oi);
        testVolt = sensorGet(sensorImage, 'volts');
        
        % Get noisy sample to compare against
        noisyVolt = volts(:,:,noisyNum);
        
        A = baseVolt - noisyVolt;
        B = baseVolt - testVolt;
        
        nA = norm(A, 'fro')
        nB = norm(B, 'fro')
        if (nA < nB)
%             fprintf('1\n');
            count = count + 1;
        else
%             fprintf('2\n');
        end
        fprintf('%2.1f\n', toc);
    end
    count
    result = count / total
    
end


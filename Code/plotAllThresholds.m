function plotAllThresholds(calcParams, psychoData, figParams, varargin)
% plotAllThresholds(calcParams, psychoData, figParams, kType, kValue)
%
% This function will plot all the threshold fits.  The specified kType and
% kValue are fixed and the opposing kType will be used as the x-axis.  For
% example, the default values of 'Kg' and 0 will result in a plot of all
% the Kp thresholds for which Kg == 0.
%
% 6/30/15  xd  moved and updated from thresholdCalculation

%% Parse inputs 
p = inputParser;

defaultK = 'Kg';
defaultKValue = 0;

p.addRequired('calcParams', @isstruct);
p.addRequired('psychoData', @isstruct);
p.addRequired('figParams', @isstruct);

p.addOptional('kType', defaultK, @isstr);
p.addOptional('kValue', defaultKValue, @isnumeric);

parse(p, calcParams, psychoData, figParams, varargin{:});

if strcmp(p.Results.kType, 'Kp') && p.Results.kValue == 0
    p.Results.kValue = 1;
end

%% Plot according to kType
switch p.Results.kType
    case {'Kp'}
        % Find index of desired Kp
        startKp = calcParams.startKp;
        KpIndex = (p.Results.kValue - startKp) / calcParams.KpInterval + 1;
       
        % Calculate Kg values
        KInterval = calcParams.KgInterval;
        startKg = calcParams.startKg;
        maxKg = startKg + (calcParams.numKgSamples - 1) * KInterval;
        KValsFine = startKg:(maxKg-1)/1000:maxKg;
        
        % Reorganize data into Kg format.  First Usable Kg is the first
        % index of the UsableData vector in which the entry is less than
        % KpIndex
        usable.blue = find(psychoData.uBlueTotal <= KpIndex, 1);
        usable.red = find(psychoData.uRedTotal <= KpIndex, 1);
        usable.green = find(psychoData.uGreenTotal <= KpIndex, 1);
        usable.yellow = find(psychoData.uYellowTotal <= KpIndex, 1);
        
        % Pad threshold vectors with zeros based on uColorTotal
        psychoData.thresholdBlueTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdBlueTotal, num2cell(psychoData.uBlueTotal), 'Uniform', false);
        psychoData.thresholdRedTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdRedTotal, num2cell(psychoData.uRedTotal), 'Uniform', false);
        psychoData.thresholdGreenTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdGreenTotal, num2cell(psychoData.uGreenTotal), 'Uniform', false);
        psychoData.thresholdYellowTotal = cellfun(@(X,U) [zeros(U-1,1); X],psychoData.thresholdYellowTotal, num2cell(psychoData.uYellowTotal), 'Uniform', false);
     
        % Create the threshold vectors based on the newly calculated usable
        threshold.blue = cellfun(@(X) X(KpIndex), psychoData.thresholdBlueTotal(usable.blue:length(psychoData.thresholdBlueTotal)));
        threshold.red = cellfun(@(X) X(KpIndex), psychoData.thresholdRedTotal(usable.red:length(psychoData.thresholdRedTotal)));
        threshold.green = cellfun(@(X) X(KpIndex), psychoData.thresholdGreenTotal(usable.green:length(psychoData.thresholdGreenTotal)));
        threshold.yellow = cellfun(@(X) X(KpIndex), psychoData.thresholdYellowTotal(usable.yellow:length(psychoData.thresholdYellowTotal)));
        
        theTitle = ['Threshold against k-values for ' calcParams.calcIDStr];
        theXAxis = 'Kg Values';
        theXLim  = [0 maxKg];
    case {'Kg'}
        % Find index for desired Kg
        startKg = calcParams.startKg;
        KgIndex = (p.Results.kValue - startKg) / calcParams.KgInterval + 1;
        
        % Calculate Kp Values
        KInterval = calcParams.KpInterval;
        startKp = calcParams.startKp;
        maxKp = startKp + (calcParams.numKpSamples - 1) * KInterval;
        KValsFine = startKp:(maxKp-1)/1000:maxKp;
        
        usable.blue = psychoData.uBlueTotal(KgIndex);
        usable.red = psychoData.uRedTotal(KgIndex);
        usable.green = psychoData.uGreenTotal(KgIndex);
        usable.yellow = psychoData.uYellowTotal(KgIndex);
        
        % Create the threshold vectors based on the newly calculated usable
        threshold.blue = psychoData.thresholdBlueTotal{KgIndex};
        threshold.red = psychoData.thresholdRedTotal{KgIndex};
        threshold.green = psychoData.thresholdGreenTotal{KgIndex};
        threshold.yellow = psychoData.thresholdYellowTotal{KgIndex}; 
        
        theTitle = ['Threshold against k-values for ' calcParams.calcIDStr];
        theXAxis = 'Kp Values';
        theXLim  = [0 maxKp];
    otherwise
        error('kType was not specified as Kg or Kp');
end

% Plot using parameters defined in switch statement
figure;
set(gcf, 'position', [0 0 1000 500]);
subplot(1,2,1);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);

fitAndPlotToThreshold(usable.blue, threshold.blue, 'b', KInterval, KValsFine, figParams);
fitAndPlotToThreshold(usable.red, threshold.red, 'r', KInterval, KValsFine, figParams);
fitAndPlotToThreshold(usable.green, threshold.green, 'g', KInterval, KValsFine, figParams);
fitAndPlotToThreshold(usable.yellow, threshold.yellow, 'y', KInterval, KValsFine, figParams);

title(theTitle, 'interpreter', 'none');
xlabel(theXAxis);
ylabel('Threshold (E*)');
ylim([0 50]);
xlim(theXLim);

% Load associated crop image
img = loadImageData(fullfile(calcParams.cacheFolderList{1}, 'Standard', 'TestImage0'));
img = imcrop(img, calcParams.cropRect);
subplot(1,2,2);
subimage(img);
end


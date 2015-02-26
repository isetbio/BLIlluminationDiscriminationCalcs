function [subSampledWavelengthSampling, subSampledSPDs] = subSampleSPDs(originalWavelengthSampling, originalSPDs, subSamplingFactor, lowPassSigma, maintainTotalEnergy)
% [subSampledWavelengthSampling, subSampledSPDs] = subSampleSPDs(wavelengthSampling, originalSPDs, subSamplingFactor, lowPassSigma, maintainTotalEnergy)
%
% Method to subsample the SPDs by a given subSamplingFactor after first
% low-passing them with a Gaussian kernel with sigma = lowPassSigma.
% If maintainTotalEnergy is set to true, the sub-sampled SPDs have equal
% total power as the original SPDs.
%
% 2/26/2015     npc     Wrote it.
% 

    % get number of SPD channels
    channelsNum = size(originalSPDs,2);
    
    % generate subsampling vector containing the indices of the samples to keep
    subSamplingVector = (1:subSamplingFactor:numel(originalWavelengthSampling));
    subSampledWavelengthSampling = originalWavelengthSampling(subSamplingVector);
    
    % preallocate memory for the subsampled SPDs
    subSampledSPDs = zeros(numel(subSampledWavelengthSampling), channelsNum);
    lowpassedSPDs = zeros(numel(originalWavelengthSampling), channelsNum);
    
    % generate the lowpass kernel
    lowPassKernel = generateGaussianLowPassKernel(subSamplingFactor, lowPassSigma, originalWavelengthSampling, maintainTotalEnergy);
        
    % zero pad lowpass kernel
    FFTsize = 1024;
    paddedLowPassKernel = zeroPad(lowPassKernel, FFTsize);
    
    hFig = figure(1);
    set(hFig, 'Position', [200 200 1731 1064]);
    clf;

    for channelIndex = 1:channelsNum
        % zero pad SPD
        paddedSPD = zeroPad(squeeze(originalSPDs(:, channelIndex)), FFTsize);
        
        % filter SPD with kernel
        FFTkernel = fft(paddedLowPassKernel);
        FFTspd    = fft(paddedSPD);
        tmp       = FFTspd .* FFTkernel;
            
        % back in original domain
        tmp = ifftshift(ifft(tmp));
        lowpassedSPDs(:, channelIndex) = extractSignalFromZeroPaddedSignal(tmp, numel(originalWavelengthSampling));
        
        % subsample the lowpassed SPD
        subSampledSPDs(:,channelIndex) = lowpassedSPDs(subSamplingVector,channelIndex);
    end
    
    maxY = max([max(subSampledSPDs(:)) max(originalSPDs(:)) max(lowpassedSPDs(:))]);
    originalSPDpower   = sum(originalSPDs,1);
    subSampledSPDpower = sum(subSampledSPDs,1);
        
    for channelIndex = 1:channelsNum 
        % plot results
        subplot(3, 7, [1 2 3 4 5 6]+(channelIndex-1)*7);
        hold on;
        % plot the lowpass kernel as a stem plot
        hStem = stem(originalWavelengthSampling, maxY/2 + lowPassKernel*maxY/3, 'Color', [0.5 0.5 0.90], 'LineWidth', 1, 'MarkerFaceColor', [0.7 0.7 0.9]);
        hStem.BaseValue = maxY/2;
        % plot the subSampledSPD in red
        plot(subSampledWavelengthSampling, subSampledSPDs(:,channelIndex), 'ro-', 'MarkerFaceColor', [1.0 0.7 0.7], 'MarkerSize', 14);
        % plot the lowpass version of the original SPD in gray
        plot(originalWavelengthSampling, lowpassedSPDs(:, channelIndex), 'ks:', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 8);
        % plot the the original SPD in black
        plot(originalWavelengthSampling, originalSPDs(:, channelIndex), 'ks-', 'MarkerFaceColor', [0.1 0.1 0.1], 'MarkerSize', 6); 
        hold off;
        set(gca, 'YLim', [0 maxY], 'XLim', [min(originalWavelengthSampling) max(originalWavelengthSampling)]);
        h_legend = legend('lowpass kernel','subsampled SPD', 'lowpassedSPD', 'originalSPD');
        box on;
        xlabel('wavelength (nm)'); ylabel('energy');
        title(sprintf('power: %2.4f (original SPD) vs. %2.4f (subsampled SPD)', originalSPDpower(channelIndex), subSampledSPDpower(channelIndex)));
    end
       
    setFigureFontSizes(hFig, 'fontName', 'helvetica', 'FontSize', 14);
    drawnow;
end

% Method to zero pad a vector to desired size
function paddedF = zeroPad(F, padSize)
    ix = floor(numel(F)/2);
    paddedF = zeros(1,padSize);
    paddedF(padSize/2+(-ix:ix)) = F;
end

% Method to extract a signal from a zero-padded version of it
function F = extractSignalFromZeroPaddedSignal(paddedF, desiredSize)
    ix = floor(desiredSize/2);
    xo = numel(paddedF)/2-1;
    F = paddedF(xo+(-ix:-ix+desiredSize-1));
end

% Method to generate a Gaussian LowPass kernel
function gaussF = generateGaussianLowPassKernel(subSamplingFactor, sigma, samplingAxis, maintainTotalEnergy) 

    samplingAxis = (0:(numel(samplingAxis)-1))-(numel(samplingAxis)/2)+0.5;
    
    if (subSamplingFactor <= 1)
        gaussF = zeros(size(samplingAxis));
        gaussF(samplingAxis == 0) = 1;
    else
        gaussF = exp(-0.5*(samplingAxis/sigma).^2);
        if (maintainTotalEnergy)
            gain = subSamplingFactor;
        else
            gain = 1;
        end
        gaussF = gain * gaussF / sum(gaussF);
    end
end


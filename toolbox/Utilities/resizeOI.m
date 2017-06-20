function newoi = resizeOI(oi,fov)
% newoi = resizeOI(oi,fov)
% 
% Script to resize an OI object to a new target fov size. This function
% downsamples by averaging the signal within equally spaced blocks in the old
% OI.
%
% Inputs:
%   oi - original OI
%   fov - target fov. This should be less than the original fov of the OI.
%
% xd  4/22/2016 wrote it
% xd  5/19/2016 added comments and formatting

%% Use 0 to leave OI unmodified
if fov == 0, newoi = oi; return; end;

%% Average the OI differently from resizing it



%% Calculation if fov not 0
% Get the old fov to calculate how many data points to average for the new oi
oldfov = oiGet(oi,'fov');
oldSize = size(oiGet(oi, 'photons'));

newSize = repmat(floor(oldSize(2) * fov / oldfov),1,2);

sizeStep = floor(oldSize(1:2) ./ newSize(1:2));

% Pre-allocate new data matrices
newData = zeros([newSize, oldSize(3)]);
newIllum = zeros(newSize);

oldData = oiGet(oi, 'photons');
oldIllum = oiGet(oi, 'illuminance');

% Average old data
for ii = 1:newSize(1)
    for jj = 1:newSize(2)
        for kk = 1:oldSize(3)
            newData(ii,jj,kk) = mean2(oldData(1 + sizeStep(1)*(ii-1):min(sizeStep(1)*(ii),oldSize(1)),...
                1 + sizeStep(2)*(jj-1):min(sizeStep(2)*(jj),oldSize(2)),kk));
        end
        newIllum(ii,jj) = mean2(oldIllum(1 + sizeStep(1)*(ii-1):min(sizeStep(1)*(ii),oldSize(1)),...
            1 + sizeStep(2)*(jj-1):min(sizeStep(2)*(jj),oldSize(2))));
    end
end

% Set appropriate variables in new oi
newoi = oiSet(oi, 'photons', newData);
newoi = oiSet(newoi, 'illuminance', newIllum);
newoi = oiSet(newoi, 'fov', fov);
newoi = oiSet(newoi, 'depthmap', zeros(newSize-1));

end



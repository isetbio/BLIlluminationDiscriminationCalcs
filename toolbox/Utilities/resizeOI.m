function newoi = resizeOI(oi, fov)
%RESIZEOITOSENSOR Summary of this function goes here
%   Detailed explanation goes here

oldfov = oiGet(oi,'fov');
oldSize = size(oiGet(oi, 'photons'));

newSize(1:2) = floor(oldSize(1:2) * fov / oldfov);

sizeStep = floor(oldSize(1:2) ./ newSize(1:2));

newData = zeros([newSize-1, oldSize(3)]);
newIllum = zeros(newSize-1);

oldData = oiGet(oi, 'photons');
oldIllum = oiGet(oi, 'illuminance');

for ii = 1:newSize(1)-1
    for jj = 1:newSize(2)-1
        for kk = 1:oldSize(3)
            newData(ii,jj,kk) = mean2(oldData(1 + sizeStep(1)*(ii-1):min(sizeStep(1)*(ii),oldSize(1)),...
                1 + sizeStep(2)*(jj-1):min(sizeStep(2)*(jj),oldSize(2)),kk));
        end
        newIllum(ii,jj) = mean2(oldIllum(1 + sizeStep(1)*(ii-1):min(sizeStep(1)*(ii),oldSize(1)),...
            1 + sizeStep(2)*(jj-1):min(sizeStep(2)*(jj),oldSize(2))));
    end
end

newoi = oiSet(oi, 'photons', newData);
newoi = oiSet(newoi, 'illuminance', newIllum);
newoi = oiSet(newoi, 'fov', fov);
newoi = oiSet(newoi, 'depthmap', zeros(newSize-1));

end



function cropRect = convertPatchToOICropRect(patchNum,p,oiPadding,oiSize,patchFov)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
% cropRect is [posx posy width height]


patchH = floor(patchNum / p.vNum);
patchV = mod(patchNum, p.vNum);

% Patch number. Subtract 1 since it is 1-indexed and then subtract 0.5 to
% center in the patch as the mosaic computes from the center. We the resize
% using the patchFov input to get it into units of dva and the resize into
% units of OI "pixels"
oiPatch = [patchH patchV] - 1 - 0.5;
oiPatch = oiPatch * patchFov + oiPadding;
hw = 2 * patchFov; 

% The crop rectangle starts at the location calculated above and is 2 patch
% sizes wide and high. This gives enough padding for the mosaic
% computations to not cause an error.
cropRect = round([oiPatch(1) oiPatch(2) hw hw] * oiSize); 

end


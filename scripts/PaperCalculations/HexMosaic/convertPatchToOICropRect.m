function cropRect = convertPatchToOICropRect(patchNum,p,oiPadding,oiSize)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
% cropRect is [posx posy width height]


patchH = floor(patchNum / p.vNum);
patchV = mod(patchNum, p.vNum);

oiPatch = oiPadding + [patchH patchV] - 0.5;

cropRect = round([oiPatch(1) - 1 oiPatch(2) - 1 2 2] * oiSize); 

end


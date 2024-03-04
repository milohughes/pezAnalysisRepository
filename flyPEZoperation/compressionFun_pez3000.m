function compressionFun_pez3000(vidDest,movWrite)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

vidObj = VideoWriter(vidDest,'MPEG-4');
open(vidObj)
frmCount = size(movWrite,3);
for iterFrm = 1:frmCount
    writeVideo(vidObj,movWrite(:,:,iterFrm))
end
close(vidObj)
end


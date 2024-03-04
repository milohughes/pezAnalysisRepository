function [roiPos,prismW] = roi2crop(roiPos,vidWidth,vidHeight,offset)
%roi2crop returns crop values for bottom view from roiPos
%   roiPos comes from assessTable.  vidWidth and vidHeight can be obtained
%   from the experimentSummary
if ~exist('offset','var')
    offset = 0;
end
if ~exist('vidWidth','var')
    vidWidth = 384;
end
if ~exist('vidHeight','var')
    vidHeight = 832;
end
roiPos = [roiPos(2:3,1) roiPos(1:2,2)-(vidHeight-vidWidth+1)];
%%% adjusts by 15, all sides because of 'roiSwell' in pezControl_v9+
roiContract = 15+offset;%%% contracts the roi to the original position
roiPos = roiPos+[roiContract roiContract
    -roiContract -roiContract];
% accounts for the fact that some people don't make sure it's right
while true
    roiPos(roiPos < 1) = 1;
    roiPos(roiPos > vidWidth) = vidWidth;
    prismW = diff(roiPos(:,1));
    if prismW < 185-offset*2
        roiPos(2) = roiPos(2)-offset;
        roiPos(1) = roiPos(2)-240+offset*2;
        roiPos(3) = roiPos(3)+offset;
        roiPos(4) = roiPos(3)+240-offset*2;
    else
        break
    end
end

end


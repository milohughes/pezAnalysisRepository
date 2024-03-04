function dirDataOut = centerDegs(dirDataIn,mode)
%centerDegs Takes vector or scalar or cell
%   Retrurn same class, values from -179 to 180
if ~exist('mode','var')
    mode = 1;
end
if mode == 1
    halfVal = 180;
else
    halfVal = pi;
end
if isa(dirDataIn,'cell')
    if min(size(dirDataIn)) > 1
        error('wrong size')
    end
    for iterC = 1:numel(dirDataIn)
        dirData = dirDataIn{iterC};
        while nansum(dirData >= halfVal) > 0,dirData(dirData >= halfVal) = dirData(dirData >= halfVal)-halfVal*2;end
        while nansum(dirData < -halfVal) > 0,dirData(dirData < -halfVal) = dirData(dirData < -halfVal)+halfVal*2;end
        dirDataIn{iterC} = dirData;
    end
elseif isa(dirDataIn,'double')
    dirData = dirDataIn;
    while nansum(dirData >= halfVal) > 0,dirData(dirData >= halfVal) = dirData(dirData >= halfVal)-halfVal*2;end
    while nansum(dirData < -halfVal) > 0,dirData(dirData < -halfVal) = dirData(dirData < -halfVal)+halfVal*2;end
    dirDataIn = dirData;
else
    error('wrong data type')
end
dirDataOut = dirDataIn;

function [outputIm,I_source] = flyRotate_and_center(inputIm,origPos,origTheta,destTheta,objSize,sizeRange,fillFlag)
%flyRotate_and_center Rotates and centers an object in an image, fast
%   flyIm is the original image.  origTheta is the angle of the object with
%   respect to vector 0,0 - Inf,0.  destTheta is the desired output angle
%   of the object.  destSize is a scalar representing the equal width
%   and height of the output image.  dwnSample is a scalar greater than 0
%   and less than or equal to 2 which is a resampling factor.  No
%   interpolation will be done.  origPos is the x,y location of the object.
%   The x,y origin is pixels from top, left.  Thetas are in degrees.

persistent indexer_bounds indexer_struct
%%
if isempty(mfilename) || nargin == 0
    vidObj = VideoReader('Y:\Data_pez3000\20140210\run001_pez3001_20140210\run001_pez3001_20140210_expt0005000000810040_vid0009.mp4');
    inputIm = read(vidObj,1);
    inputIm = inputIm(:,:,1);
    origPos = [167 662];
    origTheta = -90;
    destTheta = 0;
    objSize = 149;
    sizeRange = [150 200];
    fillFlag = 3;
    indexer_bounds = [];
    indexer_struct = [];
end
sizeRange = round(sizeRange/2)*2;
newSizeTest = true;
if ~isempty(indexer_bounds)
    if sum(sizeRange-indexer_bounds) == 0
        newSizeTest = false;
    end
end
indexer_bounds = sizeRange;
destSize = indexer_bounds(2);
spoke_count = 1440; %720 or 1080 or 1440
target_spoke_length = destSize*2;
size_factor = 1.2;%changes resolution and size
coverage = 3;%increase to make dot smaller, decreases size slightly
if newSizeTest
    indexer_struct = resize_and_rotate_Indexer(spoke_count,target_spoke_length,...
        indexer_bounds,size_factor,coverage);
end
indexer = indexer_struct.average_indexer;
avg_spoke_length = indexer_struct.avg_spoke_length;
trg_spoke_length = indexer_struct.trg_spoke_length;
source_dim = indexer_struct.image_dim;
source_leg = (source_dim-1)/2;
size_iters = avg_spoke_length-trg_spoke_length+1;
outputIm = uint8(zeros(source_dim,source_dim));

I_pad = padarray(inputIm,[source_leg source_leg]);
origPos = floor(origPos);
origPos(origPos < 1) = 1;
crop_dims = [origPos source_dim-1 source_dim-1];
I_source = imcrop(I_pad,crop_dims);
if isempty(I_source)
    outputIm = repmat(outputIm,[1 1 3]);
    return
end
if max(indexer(:)) > numel(I_source) || min(indexer(:)) < 1
    outputIm = repmat(outputIm,[1 1 3]);
    return
end
ndxtIm = I_source(indexer);
thetaShift = round((destTheta-origTheta)*(spoke_count/360));
ndxtIm = circshift(ndxtIm,[0 thetaShift]);
if indexer_bounds(1) > indexer_bounds(2)
    size_options = linspace(indexer_bounds(2),indexer_bounds(1),size_iters);
else
    size_options = linspace(indexer_bounds(1),indexer_bounds(2),size_iters);
end
[~,rendxVal] = min(size_options-objSize);

outputIm(indexer(size_iters-rendxVal+1:end-rendxVal+1,:)) = ndxtIm(rendxVal:rendxVal+trg_spoke_length-1,:);
outputIm_filled = outputIm;
outputIm_filled(indexer_struct.center_indexer) = 150;
if fillFlag == 1
    outputIm = cat(3,outputIm_filled,outputIm,outputIm);
elseif fillFlag == 2
    outputIm = cat(3,outputIm,outputIm_filled,outputIm);
elseif fillFlag == 3
    outputIm = cat(3,outputIm,outputIm,outputIm_filled);
else
    outputIm_filled(indexer_struct.center_indexer) = mean(ndxtIm(rendxVal,:));
    outputIm = cat(3,outputIm_filled,outputIm_filled,outputIm_filled);
end

if isempty(mfilename) || nargin == 0
    figure
%     close all
    imshowpair(repmat(I_source,[1 1 3]),outputIm,'montage')
    outputIm = [];
end
end


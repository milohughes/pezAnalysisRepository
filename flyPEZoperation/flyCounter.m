function [observed_fly,markt_I] = flyCounter(frmOne)

frm_adjust = imadjust(frmOne);
level_init = graythresh(frm_adjust);
BW1 = im2bw(frm_adjust,level_init);

se3 = strel('disk',3);
BW2 = imdilate(BW1,se3);
BW2 = imfill(BW2,'holes');

se12 = strel('disk',12);
BW2 = imerode(BW2,se12);

se7 = strel('disk',7);
BWfin = imdilate(BW2,se7);

%%% Eliminates small blobs in the BW image
stats = regionprops(BWfin,'ConvexArea','PixelIdxList');
if isempty(stats) == 0
    pixel_count = [stats.ConvexArea]';
    BWfin(vertcat(stats(pixel_count < 2000).PixelIdxList)) = 0;
end

%%% Analyzes the remaining blobs in the BW image
stats = regionprops(BWfin,'Centroid','ConvexArea');
pixel_val = 0;
point_count = 0;
pixel_count = 0;
if isempty(stats) == 0
    pixel_count = [stats.ConvexArea]';
    pixel_val = max(pixel_count);
    top_points = [stats.Centroid];
    top_points = reshape(top_points,2,length(stats))';
    point_count = size(top_points,1);    
end

%%% Generates final output
if pixel_count == 0
    observed_fly = 0;
    counter_string = 'Empty';
elseif point_count == 0
    observed_fly = 0;
    counter_string = 'Empty';
elseif point_count > 1
    observed_fly = 2;
    counter_string = 'Multi';
elseif pixel_val > 10000
    if pixel_val > 30000
        observed_fly = 0;
        counter_string = 'Empty';
    else
        observed_fly = 2;
        counter_string = 'Multi';
    end
else
    observed_fly = 1;
    counter_string = 'Single';
end

% fly_count = pixel_val ~= 0;
% fly_count(2) = point_count == 1;
% fly_count(3) = pixel_val < 10000;
% observed_fly = prod(double(fly_count));
% counter_string_ops = {'Empty','Multi','Single'};
% 
% counter_string = counter_string_ops{fly_count+1};
txt_cell = {'FLY COUNTER RESULTS'
    ['pixel count: ' num2str(pixel_val)]
    ['region count: ' num2str(point_count)]
    ['decision: ' counter_string]};
txt_im = textN2im(BWfin,txt_cell,10,[0.05 0.05]);
I = uint8(txt_im.*255);
markt_I = repmat(I,[1 1 3]);


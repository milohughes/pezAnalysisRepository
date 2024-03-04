function [observed_fly,markt_I] = flyCounter_3000(frmOne)

% vidDir = 'Y:\Data_pez3000\20130809\run012_pez3001_20130809';
% backgrDir = fullfile(vidDir,'backgroundFrames');
% vidNames = dir(fullfile(vidDir,'*.mp4'));
% backNames = dir(fullfile(backgrDir,'*.tif'));
% vidNames = {vidNames(:).name};
% backNames = {backNames(:).name};
% vidObj = VideoReader(fullfile(vidDir,vidNames{1}));
% vidWidth = vidObj.width;
% frmOne = read(vidObj,1);
% backFrm = imread(fullfile(backgrDir,backNames{1}));

frmAdj = imadjust(double(frmOne)./255);

level_init = graythresh(frmAdj);
BW1 = im2bw(frmAdj,level_init);

se3 = strel('disk',3);
BW2 = imdilate(BW1,se3);
BW2 = imfill(BW2,'holes');

se12 = strel('disk',12);
BW2 = imerode(BW2,se12);

se7 = strel('disk',7);
BWfin = imdilate(BW2,se7);

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

txt_cell = {'FLY COUNTER RESULTS'
    ['pixel count: ' num2str(pixel_val)]
    ['region count: ' num2str(point_count)]
    ['decision: ' counter_string]};
txt_im = textN2im(BWfin,txt_cell,10,[0.05 0.05]);

I = uint8(([frmAdj,BW1;BW2,txt_im]).*255);
markt_I = repmat(I,[1 1 3]);

% imshow(markt_I)
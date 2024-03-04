function [ im_points ] = points2colorMask( points,im_RGB,point_size,color_specs )
%points2colorMask Generate a mask to plot colored points on an image
%   'points' is an n-by-2 array of x-y coordinates. 'point_size' is how big
%   the points will be in pixels.  'color_specs' is a 1x3 vector
%   representing the color in RGB format.  The 'color_mask' output is the
%   same size of 'im_size' in the first two dimensions, but is a
%   3-dimensional array of class 'double' which can be combined with an
%   image of the same size and class.  The composite image should then be
%   multiplied by 255 elementwise and converted to class 'uint8'.

points = round(points);
im_size = size(im_RGB);
points_blank = zeros(im_size(1:2));
blank_dim1 = im_size(1);
X_vec = points(:,1).*blank_dim1-blank_dim1;
Y_vec = points(:,2);
linear_ndcs = X_vec+Y_vec;
se_pts = strel('disk',point_size);
mask_2D = points_blank;
mask_2D(linear_ndcs) = 1;
mask_2D = imdilate(mask_2D,se_pts);
mask_2D_logical = logical(mask_2D);
im_points = im_RGB;
for i = 1:3
    points_mask = im_points(:,:,i);
    points_mask(mask_2D_logical) = uint8(color_specs(i)*255);
    im_points(:,:,i) = points_mask;
end
%generates a linear-indexing-based resampling matrix for both resampling
%image blocks for locating a fly and for generating an average composite.
%The average composite must have representative flies reduced to the
%average small fly (empirically determined to be 140 pixels) while the
%image block to be indexed must equal the average big fly (180 pixels).
%Spoke_count will set the accuracy of the established heading and will
%affect processing times, ultimately.

function [indexer_struct] = hotIndexer2(spoke_count,spoke_length,...
    indexer_bounds,resize_factor,coverage)

% clear all
% close all
% % clc
% spoke_count = 48;
% spoke_length = 16;
% resize_factor = 0.6;
% indexer_bounds = [120 172];

% coverage = 1.5;%higher number means more of the fly is covered with indexer

pixel_last_of_small = indexer_bounds(1)/2;%mid-point to end of smallest flies
head_half_small = round(resize_factor*pixel_last_of_small);
half_large = indexer_bounds(2)/2;%mid-point to end of largest flies, defines image block dim!!!!
head_half_large = round(resize_factor*half_large);
pixel_last_of_large = head_half_large;%adjusted for indexing vector
pts_of_origin_count = spoke_length;
pts_including_boundaries_count = pts_of_origin_count*2+1;
factor = 1+(1/pts_including_boundaries_count)*coverage;
pts_max_last = round(log(pixel_last_of_large)/log(factor));
pts_distr = factor.^(1:pts_max_last);%redistribute points based on factor
%find the point index closest to end of small fly
pts_min_last = find(max(pts_distr(pts_distr < head_half_small))== pts_distr);
%find the point index 'pts_searcher' inward from 'pts_min_last_ind'
pts_min_first = pts_min_last-pts_including_boundaries_count;
%generate vector for indexing average flies
pix_avg_ind_mids = fliplr(pts_distr(pts_min_first:pts_max_last));
pix_avg_ind_vec = fliplr(pix_avg_ind_mids(2:2:end-1))
%generate vector for indexing target flies
pix_trg_ind_mids = fliplr(pts_distr(end-pts_including_boundaries_count:pts_max_last));
pix_trg_ind_vec = fliplr(pix_trg_ind_mids(2:2:end-1))

%determining boundaries around points for sampling the image block
out_diffs_avg = floor(diff([pix_avg_ind_mids(end) pix_avg_ind_vec])/2);
out_diffs_trg = floor(diff([pix_trg_ind_mids(end) pix_trg_ind_vec])/2);
rot_diffs_avg = floor((2*pi/spoke_count).*(pix_avg_ind_vec)/2);
rot_diffs_trg = floor((2*pi/spoke_count).*(pix_trg_ind_vec)/2);
max_out_diff_avg = max(out_diffs_avg)
max_out_diff_trg = max(out_diffs_trg)
max_rot_diff_avg = max(rot_diffs_avg)
max_rot_diff_trg = max(rot_diffs_trg)
% 
% avg_count = length(out_diffs_avg);
% trg_count = length(out_diffs_trg);
% 
% %number of points on 'out' associated with each vector point
% out_pts_avg = out_diffs_avg*2+1;
% out_pts_trg = out_diffs_trg*2+1;

% avg_sub_index = [];
% 
% for i = 1:avg_count
%     
%     rot_diff = rot_diffs_avg(i);
%     rot_span = (-rot_diff:rot_diff);
%     rot_frag = repmat(rot_span,1,out_pts_avg(i));
%     vec_pt = round(pix_avg_ind_vec(i));
%     out_diff = out_diffs_avg(i);
%     out_frag = repmat((vec_pt-out_diff:vec_pt+out_diff),length(rot_span),1);
%     index_frag = [rot_frag;out_frag(:)'];
%     avg_sub_index = [avg_sub_index index_frag];
% 
% end
% 
% 
% 
% trg_sub_index = [];
% 
% for i = 1:trg_count
%     
%     rot_diff = rot_diffs_trg(i);
%     rot_span = (-rot_diff:rot_diff);
%     rot_frag = repmat(rot_span,1,out_pts_trg(i));
%     vec_pt = round(pix_trg_ind_vec(i));
%     out_diff = out_diffs_trg(i);
%     out_frag = repmat((vec_pt-out_diff:vec_pt+out_diff),length(rot_span),1);
%     index_frag = [rot_frag;out_frag(:)'];
%     trg_sub_index = [trg_sub_index index_frag]
% 
% end
% avg_sample_dims = (out_diffs_avg*2+1).*(rot_diffs_avg*2+1);
% trg_sample_dims = (out_diffs_trg*2+1).*(rot_diffs_trg*2+1);
% if sum(avg_sample_dims) ~= length(avg_sub_index)
%     error('dims dont add up');
% end
% if sum(trg_sample_dims) ~= length(trg_sub_index)
%     error('dims dont add up');
% end
% 
% if max(rot_diffs_avg) ~= max(rot_diffs_trg)
%     error('2nd dim of average and target sampling blocks unequal')
% end
% 

avg_sub_index = [zeros(1,length(pix_avg_ind_vec));round(pix_avg_ind_vec)];
trg_sub_index = [zeros(1,length(pix_trg_ind_vec));round(pix_trg_ind_vec)];

% length of each side of image to be indexed
block_dim = pixel_last_of_large*2+1;
center = pixel_last_of_large+1;
indexer_line = 1:block_dim^2;
indexer_box = reshape(indexer_line',block_dim,block_dim);
resampler = makeresampler('nearest','fill');

pts_init = [center 1
    center center
    center block_dim];

avg_sub_index = avg_sub_index+center;
trg_sub_index = trg_sub_index+center;
avg_index_vec = (avg_sub_index(2,:).*block_dim)-block_dim+avg_sub_index(1,:);
[avg_test_r,avg_test_c] = ind2sub([block_dim,block_dim],avg_index_vec);
avg_test = [avg_test_r;avg_test_c];
if isequal(avg_test,avg_sub_index) ~= 1
    error('sub to index conversion fail'), end
trg_index_vec = (trg_sub_index(2,:).*block_dim)-block_dim+trg_sub_index(1,:);
[trg_test_r,trg_test_c] = ind2sub([block_dim,block_dim],trg_index_vec);
trg_test = [trg_test_r;trg_test_c];
if isequal(trg_test,trg_sub_index) ~= 1
    error('sub to index conversion fail'), end

avg_ind = zeros(length(avg_index_vec),spoke_count);
trg_ind = zeros(length(trg_index_vec),spoke_count);

for j = 1:spoke_count
    
    theta = (2*pi/spoke_count)*(j-1);
    rot_matrix = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0;0 0 1];
    rot_tform = maketform('affine', rot_matrix);
    pts_dest = tformfwd(rot_tform, pts_init-center)+center;
    box_tform = cp2tform(pts_init,pts_dest,'nonreflective similarity');
    box_rot = tformarray(indexer_box,box_tform,resampler,[2 1],[2 1],...
        [block_dim block_dim],[],0);
    avg_ind(:,j) = box_rot(avg_index_vec);
    trg_ind(:,j) = box_rot(trg_index_vec);

end

indexer_struct = struct('half_sml',pixel_last_of_small,'half_lrg',half_large,...
    'image_dim',block_dim,'target_indexer',trg_ind,'average_indexer',avg_ind,...
    'avg_spoke_length',length(pix_avg_ind_vec),'trg_spoke_length',...
    length(pix_trg_ind_vec));

% sample_length = length(avg_sample_dims);
% avg_crop1 = indexer_box./range(indexer_box(:));
% avg_crop2 = rot90(avg_crop1);
% avg_crop3 = rot90(avg_crop2);
% avg_spoked1 = avg_crop1(avg_ind);
% avg_cells = mat2cell(avg_spoked1,avg_sample_dims);
% avg_mean = cellfun(@(x) mean(x,1),avg_cells,'UniformOutput',false);
% avg_mat1 = reshape(cell2mat(avg_mean),sample_length,spoke_count);
% avg_spoked2 = avg_crop2(avg_ind);
% avg_cells = mat2cell(avg_spoked2,avg_sample_dims);
% avg_mean = cellfun(@(x) mean(x,1),avg_cells,'UniformOutput',false);
% avg_mat2 = reshape(cell2mat(avg_mean),sample_length,spoke_count);
% avg_spoked3 = avg_crop3(avg_ind);
% avg_cells = mat2cell(avg_spoked3,avg_sample_dims);
% avg_mean = cellfun(@(x) mean(x,1),avg_cells,'UniformOutput',false);
% avg_mat3 = reshape(cell2mat(avg_mean),sample_length,spoke_count);
% 
% test(:,:,1) = avg_mat1;
% test(:,:,2) = avg_mat2;
% test(:,:,3) = avg_mat3;
% test = uint8(test.*255);
% init_im(:,:,1) = avg_crop1;
% init_im(:,:,2) = avg_crop2;
% init_im(:,:,3) = avg_crop3;
% 
% figure,imshow(init_im);
% figure, imshow(test)
% figure, imshow(avg_ind,[])














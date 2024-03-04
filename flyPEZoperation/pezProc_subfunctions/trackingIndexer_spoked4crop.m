function [ndxr_struct] = trackingIndexer_spoked4crop(src_leg,trk_hort_ref)
% trackingIndexer_spoked_LR Generates linear indexing variables for
% tracking flies in pez videos
%   Inputs required: radius of resample (src_leg) which will be reduced by
%   one-third, removing the inner-most third, and head versus tail
%   reference (trk_hort_ref).  Outputs include variables needed for tracking
%   and visualization, condensed in a structure class variable.  IMPORTANT:
%   THE TOP HALF OF THE REINDEXED OUTPUT IS A SYMMETRIC MIRROR OF THE BOTTOM.

theta_leg = 2;
pos_leg = 3;
pos_ops = ([-7 -3 -1 0 2 4 8]);
im_leg = max(pos_ops)+src_leg;
im_dim = im_leg*2+1;
col_indexer = ((1:im_dim)-1).*im_dim;
heading_factor = 3;
spoke_count = 360/heading_factor;
% spoke_span_factor = 1/2;% fraction of coverage on either side of center
% spoke_span_factor = 2/3;% fraction of coverage on either side of center
spoke_span_factor = 1;% fraction of coverage on either side of center
pos_count = pos_leg*2+1;
theta_count = theta_leg*2+1;
theta_ops = ([-3 -2 0 1 2]);
spoke_leg = round(spoke_count*spoke_span_factor/2);
spoke_span = spoke_leg*2+1;

% spoke_span_ops = [spoke_count/2-spoke_leg+1:spoke_count/2+spoke_leg+1;
%     spoke_count-spoke_leg+1:spoke_count,1:spoke_leg+1];%points toward fly center
spoke_span_ops = [spoke_count-spoke_leg+1:spoke_count,1:spoke_leg+1;
    spoke_count/2-spoke_leg+1:spoke_count/2+spoke_leg+1];%points away from center

y_ops = repmat(pos_ops',[1 pos_count theta_count]);
x_ops = repmat(pos_ops,[pos_count 1 theta_count]);
theta_findr = repmat(theta_ops,pos_count^2,1);
mastr_findr = [x_ops(:) y_ops(:) theta_findr(:)];

rho_min = src_leg*(0.1);
rho_span = src_leg-rho_min;
spoke_length = round(rho_span/pi);
rho_adj = linspace(0,1,spoke_length).^(0.7);
ndx_rhos = round(rho_adj.*rho_span+rho_min);
deg2rad = 2*pi/spoke_count;
rhos_array = repmat(ndx_rhos(:),1,spoke_count);
thetas_array = repmat((1:spoke_count)-1,spoke_length,1).*deg2rad;
rot_ndx_x = round(rhos_array.*cos(thetas_array));
rot_ndx_y = -round(rhos_array.*sin(thetas_array));

sampl_ndx_r1 = repmat(pos_ops,1,pos_count);
sampl_ndx_c1 = repmat(pos_ops,pos_count,1);
sampl_ndx_r2 = repmat(sampl_ndx_r1(:),[1 spoke_length spoke_count]);
sampl_ndx_r3 = permute(sampl_ndx_r2,[2 3 1]);
sampl_ndx_c2 = repmat(sampl_ndx_c1(:),[1 spoke_length spoke_count]);
sampl_ndx_c3 = permute(sampl_ndx_c2,[2 3 1]);
sampl_ndx_r4 = repmat(rot_ndx_y,[1 1 pos_count^2])+sampl_ndx_r3+im_leg+1;
sampl_ndx_c4 = repmat(rot_ndx_x,[1 1 pos_count^2])+sampl_ndx_c3+im_leg+1;
sampl_ndx_m1 = sampl_ndx_r4+col_indexer(sampl_ndx_c4);
sampl_ndx_m2 = reshape(sampl_ndx_m1,spoke_length*spoke_count,pos_count^2);
shift_ops = (-theta_leg:theta_leg);
sampl_ndx_m3 = zeros(spoke_length*spoke_count,pos_count^2,theta_count);
for j = 1:theta_count
    shift_val = shift_ops(j)*spoke_length;
    sampl_ndx_m3(:,:,j) = circshift(sampl_ndx_m2,-shift_val);
end
sampl_ndxr_mastr = reshape(sampl_ndx_m3,spoke_length*spoke_count,pos_count^2*theta_count);
templ_ref = median(1:pos_count^2*theta_count);
% templ_ndxr_mastr = repmat(sampl_ndxr_mastr(:,templ_ref),1,pos_count^2*theta_count);
templ_ndxr_mastr = sampl_ndxr_mastr(:,templ_ref);
templ_rendxr = repmat((1:spoke_length*spoke_span)',1,pos_count^2*theta_count);

spoke_ndxr1 = spoke_span_ops(trk_hort_ref,:);
spoke_ndxr2a = repmat(spoke_ndxr1(:),1,spoke_count);
spoke_ndxr2b = repmat((1:spoke_count)-1,spoke_span,1);
spoke_ndxr3 = spoke_ndxr2a+spoke_ndxr2b;
spoke_adj = zeros(spoke_span,spoke_count);
spoke_adj(spoke_ndxr3 > spoke_count) = -spoke_count;
spoke_ndxr4 = spoke_ndxr3+spoke_adj;
spoke_ndxr5 = reshape((1:spoke_length*spoke_count),...
    spoke_length,spoke_count);
spoke_ndxr_mastr = zeros(spoke_span*spoke_length,spoke_count);
for  iter = 1:spoke_count
    spoke_ndxr6 = spoke_ndxr5(:,spoke_ndxr4(:,iter)');
    spoke_ndxr_mastr(:,iter) = spoke_ndxr6(:);
end

ndxr_struct = struct('mastr_findr',mastr_findr,'spoke_length',...
    spoke_length,'spoke_leg',spoke_leg,'pos_leg',pos_leg,'theta_leg',...
    theta_leg,'spoke_count',spoke_count,'templ_mastr',templ_ndxr_mastr,...
    'sampl_mastr',sampl_ndxr_mastr,'im_leg',im_leg,...
    'spoke_mastr',spoke_ndxr_mastr,'templ_rendxr',templ_rendxr);

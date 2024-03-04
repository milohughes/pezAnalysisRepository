function [ level_gray,frm_remap,background ] = frame_var_generator( frame_in,L_fly,cntr_pt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
frm_centr = round(size(frame_in,2)/2);
lim_leg = L_fly/2;
if cntr_pt(1) < frm_centr(1)
    lim_boundA = round(cntr_pt(1));
    lim_boundB = round(cntr_pt(1)+lim_leg);
else
    lim_boundA = round(cntr_pt(1)-lim_leg);
    lim_boundB = round(cntr_pt(1));
end
limit_frm = frame_in(:,lim_boundA:lim_boundB);
tol = [0.01 0.99];

[frm_indxt,frm_graymap] = gray2ind(limit_frm,256);
lowhigh_in = stretchlim(limit_frm,tol);
frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],1);

frm_indxt = gray2ind(frame_in,256);
frm_reindxt = ind2gray(frm_indxt,frm_remap);
background = imopen(frm_reindxt,strel('disk',64));
frm_part = frm_reindxt-background;

level_gray = graythresh(frm_part(:,lim_boundA:lim_boundB));%^(1/2);
end


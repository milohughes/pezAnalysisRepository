repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))

test_exp_id = '0108000024880730';
vid_name = 'run014_pez3002_20171208_expt0108000024880730_vid0004';

martin_file = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\filtered_chr_vids_for_annotation_v2.mat');
martin_file = martin_file.(cell2mat(fieldnames(martin_file)));

all_save_data = load('Z:\Leg_Tracking_Data\Martin_leg_tracking_filter_v1.mat');
all_save_data = all_save_data.(cell2mat(fieldnames(all_save_data)));

%Convert Struct to Table
all_save_data = struct2table(all_save_data);

%Filter data for 'Good' analyzed videos
vid_quality_filter = cellfun(@(x) strcmp(x,'Good'),all_save_data.VidQuality);
filtered_save_data = all_save_data(vid_quality_filter,:);

filt_file = martin_file(cellfun(@(x) contains(x,test_exp_id),martin_file));
complete_matching = filtered_save_data(ismember(filtered_save_data.VideoName,filt_file),:);
complete_matching = complete_matching(ismember(complete_matching.VideoName,vid_name),:);

click_points = complete_matching.Track_Points{1};
click_points = table2cell(click_points);
click_points = click_points(:,2:end);
click_points = cell2mat(click_points);

leg_mid_point = [(click_points(:,1)+click_points(:,3))/2,(click_points(:,2)+click_points(:,4))/2];

leg_lineseg_angle = atan2d((click_points(:,4) - click_points(:,2)),(click_points(:,3) - click_points(:,1)));
leg_lineseg_angle(leg_lineseg_angle<0) = leg_lineseg_angle(leg_lineseg_angle<0)+360;
rotate_angle = leg_lineseg_angle-180;

array_idx = 1:1:length(leg_lineseg_angle);
left_leg_rotate = arrayfun(@(x) rotation([click_points(x,1) click_points(x,2)] - [leg_mid_point(x,1) leg_mid_point(x,2)] ,[0 0],-rotate_angle(x),'degrees'),array_idx,'UniformOutput',false);
right_leg_rotate = arrayfun(@(x) rotation([click_points(x,3) click_points(x,4)] - [leg_mid_point(x,1) leg_mid_point(x,2)] ,[0 0],-rotate_angle(x),'degrees'),array_idx,'UniformOutput',false);
center_pos_rotate = arrayfun(@(x) rotation([click_points(x,5) click_points(x,6)] - [leg_mid_point(x,1) leg_mid_point(x,2)] ,[0 0],-rotate_angle(x),'degrees'),array_idx,'UniformOutput',false);
center_leg_rotate = arrayfun(@(x) rotation([leg_mid_point(x,1) leg_mid_point(x,2)] - [leg_mid_point(x,1) leg_mid_point(x,2)] ,[0 0],-rotate_angle(x),'degrees'),array_idx,'UniformOutput',false);

P_center = cell2mat(center_pos_rotate');
P_left = cell2mat(left_leg_rotate');
P_right = cell2mat(right_leg_rotate');

center_perp_pt = [P_center(1),0];

Left_leg_InDegrees = abs(atand(((P_left(:,1)-center_perp_pt(:,1)) ./ P_center(:,2))));
Right_leg_InDegrees = abs(atand(((P_right(:,1)-center_perp_pt(:,1)) ./ P_center(:,2))));

Left_leg_InDegrees(P_center(1,2) < 0) = 180 - Left_leg_InDegrees(P_center(1,2) < 0);
Right_leg_InDegrees(P_center(1,2) < 0) = 180 - Right_leg_InDegrees(P_center(1,2) < 0);

Alpha_angle = Left_leg_InDegrees + Right_leg_InDegrees;

figure
index = 1;
for iterZ = linspace(1,size(click_points,1),9)
    subplot(3,3,index)
    set(gca,'nextplot','add')
    plot(P_left(iterZ,1),P_left(iterZ,2),'bo')
    plot(P_right(iterZ,1),P_right(iterZ,2),'go')
    plot(P_center(iterZ,1),P_center(iterZ,2),'ro')

    line([P_left(iterZ,1) P_right(iterZ,1)],[P_left(iterZ,2) P_right(iterZ,2)],'color',rgb('black')); %left to right
    line([P_left(iterZ,1) P_center(iterZ,1)],[P_left(iterZ,2) P_center(iterZ,2)],'color',rgb('black')); %left to center
    line([P_right(iterZ,1) P_center(iterZ,1)],[P_right(iterZ,2) P_center(iterZ,2)],'color',rgb('black')); %right to center
    set(gca,'Ylim',[-30 30],'Xlim',[-100 100],'ydir','reverse');
    index = index + 1;
end


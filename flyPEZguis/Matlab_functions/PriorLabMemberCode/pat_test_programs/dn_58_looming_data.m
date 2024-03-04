%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load in groups infor
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))

    file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';    
    saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);            saved_groups = saved_groups.Saved_Group_IDs;        
    sample_group = saved_groups(cellfun(@(x) contains(x,'Martin DN058 Data'),saved_groups.Properties.RowNames),:);
%    sample_group = saved_groups(cellfun(@(x) contains(x,'Pat Data :: Control Compare'),saved_groups.Properties.RowNames),:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get experiment ids of interest
    sample_ids = sample_group.Experiment_IDs{1};
    sample_ids = cellfun(@(x) strtrim(x),sample_ids,'UniformOutput',false);
    steps = length(sample_ids);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% default filtering paramaters
    temp_range = [22.5,24.0];
    humidity_cut_off = 40;
    azi_off = 22.5;
    remove_low = false;
    low_count = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vairables to store the data
    combine_data = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%set_up_iosr(~,~)
    cd('C:\Users\breadsp\Documents\Pez3000_Gui_Folder\Matlab_functions\IoSR-Surrey-MatlabToolbox-4bff1bb');
    addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);
    
    %% start SOFA    
    SOFAstart(0);    
    cd(currdir); % return to original directory          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load in the data using object class
    for iterZ = 1:steps

        test_data =  Experiment_ID(sample_ids{iterZ});
        test_data.temp_range = temp_range;
        test_data.humidity_cut_off = humidity_cut_off;
        test_data.remove_low = remove_low;
        test_data.low_count = low_count;
        test_data.azi_off = azi_off;
        try
            test_data.load_data;
            test_data.make_tables;
            combine_data = [combine_data;test_data];   %#ok<*AGROW>
        catch
            warning('id with no graph table');
        end
    end

    steps = length(combine_data);
    ids_usuable_data = arrayfun(@(x) height(combine_data(x).Complete_usuable_data),1:1:steps)';
    combine_data(ids_usuable_data == 0,:) = [];

    steps = length(combine_data);
        
    for iterZ = 1:steps
        combine_data(iterZ).get_tracking_data;
    end 
    for iterZ = 1:steps
        combine_data(iterZ).display_data
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get dn58, looming lv 40, azi 180 data only
    filt_combine_data = combine_data;
    parsed_info = vertcat(combine_data(:).parsed_data);
    
    remove_dl = cellfun(@(x) contains(x,'1500090'),parsed_info.ParentB_ID);
%    remove_dl = cellfun(@(x) contains(x,'3015823'),parsed_info.ParentB_ID);
    filt_combine_data(remove_dl) = [];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     dn058_looming_data = vertcat(filt_combine_data(:).Complete_usuable_data);
%     geno_ids = cellfun(@(x) x(33:40),dn058_looming_data.Properties.RowNames,'UniformOutput',false);
%     stim_pos = dn058_looming_data.Stim_Pos_At_Trigger;
%     stim_pos(stim_pos == -0) = 0; 
%     stim_pos(stim_pos == -180) = 180; 
%     combo_list = cellfun(@(x,y) sprintf('%s_%03f',x,y),geno_ids,num2cell(stim_pos),'UniformOutput',false);
%     uni_combo = unique(combo_list);
%     all_save_data = [];
%     for iterZ = 1:length(uni_combo)
%         matching_list = dn058_looming_data(ismember(combo_list,uni_combo{iterZ}),:);
%         random_index = unique(randi([1,height(matching_list)],20,1),'stable');
%         all_save_data = [all_save_data;matching_list.Properties.RowNames(random_index)];
%     end
%     save('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\filtered_loom_vids_for_annotation_v2.mat','all_save_data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    
    
    all_videos = vertcat(filt_combine_data(:).Complete_usuable_data);
    last_frame = all_videos.frame_of_leg_push;
    last_frame(cellfun(@(x) isempty(x),last_frame)) = num2cell(all_videos.autoFot(cellfun(@(x) isempty(x),last_frame)));
    last_frame(cellfun(@(x) isnan(x),last_frame)) = num2cell(all_videos.trkEnd(cellfun(@(x) isnan(x),last_frame))-50);
        
    short_tracking = cellfun(@(x,y) length(x(:,1)) < y,all_videos.bot_points_and_thetas,last_frame);
    all_videos(short_tracking,:) = [];        last_frame(short_tracking,:) = [];    
     
    bad_start = cell2mat(all_videos.Start_Frame) < 0;
    all_videos(bad_start,:) = [];        last_frame(bad_start,:) = [];
     
    motion_interval = cellfun(@(x,y,z) x(y:z,:),all_videos.bot_points_and_thetas,all_videos.Start_Frame,last_frame,'UniformOutput',false);
    to_early = cellfun(@(x) length(x) <= 50, motion_interval);
    all_videos(to_early,:) = [];        last_frame(to_early,:) = [];       motion_interval(to_early,:) = [];
     
    stim_fly_saw = cellfun(@(x,y) -(x(:,3) - (y+2*pi)).*180/pi, motion_interval,num2cell(all_videos.VidStat_Stim_Azi),'UniformOutput',false);
     
    index = 1;
    figure
    stim_pos = all_videos.Stim_Pos_At_Trigger;
    stim_pos(stim_pos == -0) = 0; 
    stim_pos(stim_pos == -180) = 180;      
    for iterA = -90:90:180
        subplot(2,2,index)
        time_index = [];
        all_fly_angle = [];
        stim_logic = ismember(stim_pos,iterA);
        for iterZ = round(linspace(1,2745,10))
            filt_stim = stim_fly_saw((cellfun(@(x) length(x) >= iterZ, stim_fly_saw) & stim_logic),:);             

            fly_angle = cellfun(@(x) x(iterZ),filt_stim);
            fly_angle = rem(rem(fly_angle,360)+360,360);
            
            switch iterA 
                case -90
                    fly_angle(fly_angle < 90) =  fly_angle(fly_angle < 90) + 360;       %90 to 450
                    fly_angle(fly_angle > 450) =  fly_angle(fly_angle > 450) - 360;       
                case 0
                    fly_angle(fly_angle > 180) =  fly_angle(fly_angle > 180) - 360;     %-180 to 180
                    fly_angle(fly_angle < -180) =  fly_angle(fly_angle < -180) + 360;   
                case 90
                    fly_angle(fly_angle < -90) =  fly_angle(fly_angle < -90) + 360;     %-90 to 270
                    fly_angle(fly_angle > 270) =  fly_angle(fly_angle > 270) - 360;    
                case 180
                    fly_angle(fly_angle < 0) =  fly_angle(fly_angle < 0) + 360;         %0 to 360
                    fly_angle(fly_angle > 360) =  fly_angle(fly_angle > 360) - 360;
            end
             
            all_fly_angle = [all_fly_angle;fly_angle];
            time_index = [time_index;repmat(iterZ,length(fly_angle),1)];
        end
        [y_data,x_data] = iosr.statistics.tab2box(time_index,all_fly_angle);
        remove_data = sum(~isnan(y_data)) < 5;
        x_data(remove_data) = [];
        y_data(:,remove_data) = [];
        
        y_data = y_data - y_data(:,1);
        
        index = index + 1;
%        iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
%               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

        set(gca,'nextplot','add');
        plot(x_data',y_data);
           
           
         angle_ticks = atan(40 ./ (40/tan(10*pi/360) - (x_data - 1)/6)) .* 360/pi;
         set(gca,'Xtick',x_data,'XTickLabel',angle_ticks);
    end
%%     
     change_pos = cellfun(@(x) x(end,:) - x(1,:),motion_interval ,'UniformOutput',false);
     change_pos = cell2mat(change_pos);
% 
%     stay_logic = cellfun(@(x) isnan(x) ,last_frame);
% %    all_videos(stay_logic,:) = [];        last_frame(stay_logic,:) = [];    
% 
     azi_used = all_videos.Stim_Pos_At_Trigger;
     azi_used(azi_used == -0) = 0;           azi_used(azi_used == -180) = 180;
% 
%     combo_stim = cellfun(@(x,y) sprintf('%s_%03f',x,y),all_videos.Stimuli_Used,num2cell(azi_used),'UniformOutput',false);
%     uni_azi = unique(combo_stim);

    jump_group = cell(height(all_videos),1);
    jump_group(cellfun(@(x) isnan(x), all_videos.frame_of_leg_push)) = repmat({'Fly Stayed'},sum(cellfun(@(x) isnan(x), all_videos.frame_of_leg_push)),1);
    jump_group(cellfun(@(x) ~isnan(x), all_videos.frame_of_leg_push)) = repmat({'Fly Jumped'},sum(cellfun(@(x) ~isnan(x), all_videos.frame_of_leg_push)),1);
    
    [y_data,x_data,group_labels] = iosr.statistics.tab2box(azi_used,change_pos(:,3),jump_group);
    y_data(y_data > 2*pi) = NaN;
    
    figure
    iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    
    testing_data = all_videos(azi_used == -90,:);
    start_frame = testing_data.Start_Frame;
    
    filtered_pos_vector = cellfun(@(x,y) x(y:end,:),testing_data.bot_points_and_thetas,start_frame,'UniformOutput',false);
    norm_pos_vector = cellfun(@(x) [(x(:,1) - x(1,1)),(x(:,2) - x(1,2)),x(:,3)],filtered_pos_vector,'UniformOutput',false);

    rotated_norm_pos = cellfun(@(x) rotation([x(:,1) x(:,2)],[0 0],-x(1,3),'radians'),norm_pos_vector,'UniformOutput',false);
    figure;
    index = 1;
    for iterZ = (0:50:450)*6
        subplot(4,4,index)
        
        filt_data = rotated_norm_pos(cellfun(@(x) length(x),rotated_norm_pos) > iterZ);
        if isempty(filt_data)
            continue
        end
        plot_data = cell2mat(cellfun(@(x) x((iterZ+1),1:2),filt_data,'UniformOutput',false));
        scatter(plot_data(:,1), plot_data(:,2));
        
        line([-150 150],[0 0],'color',rgb('gray'),'linewidth',.5);
        line([0 0],[-150 150],'color',rgb('gray'),'linewidth',.5);
        index = index + 1;
        title(sprintf('%4.0f milliseconds after stim start',iterZ/6),'Interpreter','none','HorizontalAlignment','center');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    jump_count = zeros(length(uni_azi),1);
    total_count = zeros(length(uni_azi),1);
    filt_azi_used = zeros(length(uni_azi),1);
    for iterZ = 1:length(uni_azi)
        stimuli_logic = ismember(combo_stim,uni_azi{iterZ});
        filt_videos = all_videos(stimuli_logic,:);
        jump_count(iterZ) = sum(cellfun(@(x) ~isnan(x), filt_videos.frame_of_leg_push));
        total_count(iterZ) = height(filt_videos);
        filt_azi_used(iterZ) = unique(azi_used(stimuli_logic));
    end
    jump_rate = jump_count ./ total_count;
    
    
    p = polyfit([0;90;180],jump_rate([2,4,3]),2);
    pos_y = polyval(p,0:30:180);
    p = polyfit([0;-90;-180],jump_rate([2,1,3]),2);
    neg_y = polyval(p,0:-30:-180);

%    p = polyfit([0;90;180],jump_rate([3,6,4]),2);
%    pos_y = polyval(p,0:30:180);
%    p = polyfit([0;-90;-180],jump_rate([3,2,4]),2);
%    neg_y = polyval(p,0:-30:-180);

    
    estimate_jump_rate = [pos_y,neg_y(2:(end-1))].*100;
    estimate_azi = [0:30:180,-30:-30:-150];
    
    azi_list = arrayfun(@(x,y) repmat(x,round(y*1000),1),estimate_azi,estimate_jump_rate,'UniformOutput',false);
    %azi_list = arrayfun(@(x,y) repmat(x,round(y*1000),1),filt_azi_used(1:(end-1)),jump_rate(1:(end-1)),'UniformOutput',false);
    azi_list = vertcat(azi_list{:});
    
    bin_count = 30;
    [t,r] = rose(azi_list.*pi/180,360/30);
    r = r ./10;
    t(t>0) = t(t>0)-15*pi/180;   %rotate 5 degrees since using 10 degree bins
    %r((end-3):end) = r(1:4);
    t(2) = t(end-1);
    
    index = 1;
    for iterR = 2:4:length(r)
        r(iterR)   = estimate_jump_rate(index);
        r(iterR+1) = estimate_jump_rate(index);
        index = index +1;
    end
    
    figure; 
    polar(t,r,'r-',100)

    
    curr_child = get(gca,'Children');
    x_data = get(curr_child,'XData');
    y_data = get(curr_child,'YData');
    for iterP = 4:4:length(t)
        patch_x = x_data((iterP-3):iterP);
        patch_y = y_data((iterP-3):iterP);

        patch(patch_x,patch_y,rgb('light blue'),'facealpha',.5,'Edgealpha',.5);
    end    
    
%%
    fig_size = 350;
    quiv_size = fig_size*.5;
    for iterZ = 1:1:9
        subplot(3,3,iterZ)
        switch iterZ
            case 3
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (45-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (45+22.5);                
                x_cord = fig_size;     y_cord = -fig_size;           u = -quiv_size;  v = quiv_size;
            case 1
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (135-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (135+22.5);
                x_cord = -fig_size;     y_cord = -fig_size;           u = quiv_size;  v = quiv_size;            
            case 7
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (-45-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (-45+22.5);
                x_cord = -fig_size;     y_cord = fig_size;           u = quiv_size;  v = -quiv_size;
            case 8
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (-90-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (-90+22.5);
                x_cord = 0;     y_cord = fig_size;           u = 0;  v = -quiv_size;
            case 2
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (90-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (90+22.5);
                x_cord = 0;     y_cord = -fig_size;           u = 0;  v = quiv_size;
            case 6
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (0-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (0+22.5);
                x_cord = fig_size;     y_cord = 0;           u = -quiv_size;  v = 0;
            case 4
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (180-22.5) | all_videos.Stim_Fly_Saw_At_Trigger <= (-180+22.5);
                x_cord = -fig_size;     y_cord = 0;           u = quiv_size;  v = 0;
            case 9
                azi_logic = all_videos.Stim_Fly_Saw_At_Trigger >= (-45-22.5) & all_videos.Stim_Fly_Saw_At_Trigger <= (-45+22.5);
                x_cord = fig_size;     y_cord = fig_size;           u = -quiv_size;  v = -quiv_size;
            otherwise
                continue
        end
        filt_azi_vids = all_videos(azi_logic,:);        filt_last_frame = last_frame(azi_logic);
        stay_logic = cellfun(@(x) isnan(x) ,filt_last_frame);
        filt_azi_vids(stay_logic,:) = [];        filt_last_frame(stay_logic,:) = [];    
        
        if isempty(filt_azi_vids)
            continue
        end


        fly_pos_start = cell2mat(cellfun(@(x,y) x(y,:),filt_azi_vids.bot_points_and_thetas,filt_azi_vids.Start_Frame,'UniformOutput',false));
        fly_pos_end = cell2mat(cellfun(@(x,y) x(y,:),filt_azi_vids.bot_points_and_thetas,filt_last_frame,'UniformOutput',false));

        org_azi_pos = fly_pos_start(:,3);
        new_azi_pos = fly_pos_end(:,3) - fly_pos_start(:,3);
        pos_change = [(fly_pos_end(:,1) - fly_pos_start(:,1)),(fly_pos_end(:,2) - fly_pos_start(:,2))];
        rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'radians'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));

        full_diff = cellfun(@(x,y) (x-y)/6, filt_azi_vids.frame_of_take_off,filt_azi_vids.frame_of_wing_movement,'UniformOutput',false);
        full_diff(cellfun(@(x) isempty(x), full_diff)) = {NaN};
        full_diff = cell2mat(full_diff);
        
        color_scat = repmat(rgb('light blue'),length(rot_pos(:,1)),1);
        color_scat(isnan(full_diff),:) = repmat(rgb('dark green'),sum(isnan(full_diff)),1);

%         scatter(rot_pos(:,1),rot_pos(:,2));
        axis equal
        set(gca,'xlim',[-fig_size fig_size],'Ylim',[-fig_size fig_size],'nextplot','add','Ydir','reverse')    
        line([-fig_size fig_size],[0 0],'color',rgb('black'),'linewidth',.8)
        line([0 0],[-fig_size fig_size],'color',rgb('black'),'linewidth',.8)
        
        quiver(x_cord,y_cord,u,v,'MaxHeadSize',5,'linewidth',1.2,'color',rgb('red'));
        
        for iterQ = 1:length(new_azi_pos)
            u = cos(new_azi_pos(iterQ))*50;        v = -sin(new_azi_pos(iterQ))*50;
            quiver(rot_pos(iterQ,1),rot_pos(iterQ,2),u,v,0,'MaxHeadSize',3,'linewidth',.5,'color',color_scat(iterQ,:));
        end
        jump_pct = (sum(~stay_logic)/length(stay_logic))*100;
        title(sprintf('jump rate :: %4.4f%%',jump_pct),'Interpreter','none','HorizontalAlignment','center')
        
        
% %        figure; 
%         set(gca,'nextplot','add');
%         hist_counts = hist3(rot_pos(~isnan(full_diff),:),{-150:30:150 -150:30:150});
%         hist_counts(hist_counts > 0) = 2;
%         
%         [conplot,~] = contour(hist_counts,1);
%         break_points = find(conplot(1,:) == 1);
%         for iterB = 1:(length(break_points))
%             if iterB == length(break_points)
%                 patch_data = conplot(:,(break_points(iterB)+1) : end);
%             else
%                 patch_data = conplot(:,(break_points(iterB)+1) : (break_points(iterB+1)-1));
%             end
%             patch(patch_data(1,:),patch_data(2,:),rgb('light red'),'facealpha',.5);
%         end
%         
%         hist_counts = hist3(rot_pos(isnan(full_diff),:),{-150:30:150 -150:30:150});
%         hist_counts(hist_counts > 0) = 2;        
%         
%         [conplot,~] = contour(hist_counts,1);
%         break_points = find(conplot(1,:) == 1);
%         for iterB = 1:(length(break_points))
%             if iterB == length(break_points)
%                 patch_data = conplot(:,(break_points(iterB)+1) : end);
%             else
%                 patch_data = conplot(:,(break_points(iterB)+1) : (break_points(iterB+1)-1));
%             end
%             patch(patch_data(1,:),patch_data(2,:),rgb('light blue'),'facealpha',.5);
%         end
        

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
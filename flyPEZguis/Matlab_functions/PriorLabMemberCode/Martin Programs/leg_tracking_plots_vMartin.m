%This script plots the leg tracking data collected in the leg_tracking_gui.
%For generating COM shift over time plots.
function leg_tracking_plots_vMartin
    %----------------------------------------------------------------------
    %Setup
    
    %Pathing Info
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    
    %Load toolbox for statistics and plotting
    set_up_iosr;
    
    %----------------------------------------------------------------------
    %Load data for analysis and plotting

    %Load list of videos for location, motion and manually exclusion
    %(other behaviors ongoing and focus). Filter the annotations because
    %this list may have been updated to exclude annotated videos.
    filtered_chr_vids = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\filtered_chr_vids_for_annotation_v2.mat');
%    filtered_chr_vids = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\chr_vids_for_annotation_v3.mat');
    filtered_chr_vids = filtered_chr_vids.(cell2mat(fieldnames(filtered_chr_vids))); %cell
    
    %Load all data with leg annotations and make table.
%     all_save_data = load('Z:\Leg_Tracking_Data\Martin_leg_tracking_filter_v1.mat');
    all_save_data = load('Z:\Leg_Tracking_Data\Martin_leg_tracking_filter_v2.mat');
    all_save_data = all_save_data.(cell2mat(fieldnames(all_save_data)));
    if isstruct(all_save_data)
        all_save_data = struct2table(all_save_data);
    end
    
    %----------------------------------------------------------------------
    %Filter the data to determine subset to analyze and plot
    
    %Filter annotation data for 'Good' annnotated videos
    annotation_quality_filter = cellfun(@(x) strcmp(x,'Good'),all_save_data.VidQuality);
    good_anno_table = all_save_data(annotation_quality_filter,:);
    
    %Filter all save data to include only those in martin_file
    vid_quality_filter_idx = ismember(good_anno_table.Properties.RowNames,filtered_chr_vids);
    filtered_save_data = good_anno_table(vid_quality_filter_idx,:);
    
    %Filter for tracking and annotations complete in each frame.
%     filled_in_filter = false(height(filtered_save_data),1);
%     for iter1 = 1:height(filtered_save_data)
%         filled_in_check_table = varfun(@(x) iscell(x),filtered_save_data.Track_Points{iter1});
%         filled_in_filter(iter1) = ~any(filled_in_check_table{1,:});
%     end
%     
%     %Report back videos with spotty tracking
%     fprintf('Videos With Incomplete Tracking or Annotations:\n')
%     track_fail_idx = find(~filled_in_filter);
%     if isempty(track_fail_idx)
%         fprintf('None');
%     else
%         for iter2 = 1:length(track_fail_idx)
%             fprintf('%i ',track_fail_idx(iter2));
%         end
%     end
%     fprintf('\n');
%     
%     filtered_save_data = filtered_save_data(filled_in_filter,:);
    
    %----------------------------------------------------------------------
    %Find genotype labels for each of the video names according to their Experiment ID
    geno_list = cellfun(@(x) x(29:44),filtered_save_data.Properties.RowNames,'UniformOutput',false);
    new_labels = convert_labels(geno_list);
%    [~,new_labels,~] = make_sort_order(new_labels);

    %----------------------------------------------------------------------
    %Calculate statistics on annotations completed to date
    martin_labels = convert_labels(cellfun(@(x) x(29:44),filtered_chr_vids,'UniformOutput',false));
    tracked_file = convert_labels(cellfun(@(x) x(29:44),all_save_data.Properties.RowNames,'UniformOutput',false));
    martin_table = tabulate(martin_labels);         %all videos to work
    complete_table = tabulate(tracked_file);        %all completed videos
    tracked_table = tabulate(new_labels);           %all complete videos with good quality
    
    %includes some bad experiments that need to be filtered
    make_summary_table(martin_table,complete_table,tracked_table);
%    angle_results = find_inital_angle(filtered_save_data);      %inital angle between COM and legs
%    angle_results(angle_results(:,1) < 60 | angle_results(:,2) < 60,:) = [];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    plot_type = 'angle_box_plot';
%   plot_type = 'center_movement';
%    plot_type = 'movement_tracker';
%    plot_type = 'leg_angle_vs_leg_dist';
%    plot_type = 'center_pos_start';
%    plot_type = 'mass_change_100ms';
%    plot_type = 'center_of_mass_rel_leg_line';
%    plot_type = 'distance_between_legs';
%    plot_type = 'boxplot_total_movement';
%    plot_type =  'movement_over_time';
%    plot_type =  'plot_tiles';
    plot_type =  'GF_jump_dir';
%    plot_type = 'center_of_leg_movement';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch plot_type
        case 'movement_tracker'
            movement_tracker(filtered_save_data,new_labels)
        case 'leg_angle_vs_leg_dist'
%            leg_angle_vs_leg_dist('DNp02',filtered_save_data,new_labels);
%            leg_angle_vs_leg_dist('DNp11',filtered_save_data,new_labels);
            leg_angle_vs_leg_dist('ESC',filtered_save_data,new_labels);
        case 'angle_box_plot'
            figure; 
            hb = boxplot(angle_results(:,1:2),'notch','on');
            set(hb,'linewidth',1.2);
            set(gca,'Ylim',[30 150],'Ytick',30:30:150,'Ygrid','on','Xticklabel',[{'Left Leg'},{'Right Leg'}],'fontsize',20)
            figure;
            hist((angle_results(:,1) - angle_results(:,2)),-10:1:10);
            set(gca,'fontsize',20)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        case 'center_pos_start'
            center_pos_start(filtered_save_data)
        case 'center_movement'                        
%           center_movement('all',filtered_save_data,new_labels,'single');
%            center_movement('ESC',filtered_save_data,new_labels,'single');
%             center_movement('DNp11',filtered_save_data,new_labels,'single');
%            center_movement('DNp02',filtered_save_data,new_labels,'single');
%            center_movement('DNp02, DNp04',filtered_save_data,new_labels,'single');
           center_movement('DNp02, DNp04, DNp06',filtered_save_data,new_labels,'single');


            figure
            [sort_order,~,trimmed_labels] = make_sort_order(new_labels);
            label_logic = cellfun(@(x) contains(x,'('),trimmed_labels);
            new_trim_labels = cellfun(@(x) x(1:strfind(x,'(')-1),trimmed_labels,'UniformOutput',false);
            new_trim_labels(cellfun(@(x) isempty(x),new_trim_labels)) = [];
            trimmed_labels(label_logic) = new_trim_labels;
            
%            uni_labels = unique(new_labels);       %use this for genotype 
            uni_labels = unique(trimmed_labels);    %use this for cell type
            for iterZ = 1:length(uni_labels)
%                subplot(4,6,iterZ)                 %use this for genotype 
                subplot(3,5,iterZ)                   %use this for cell type
                center_movement(uni_labels{iterZ},filtered_save_data(sort_order,:),trimmed_labels,'multi');
%                center_movement(uni_labels{iterZ},filtered_save_data,new_labels,'multi');
                set(gca,'Ytick',-100:25:100,'Ygrid','on','Xlim',[0 100]);
                h_patch = patch([0 50 50 0],[-100 -100 100 100],rgb('very light red'));
                set(h_patch,'FaceAlpha',.25,'edgealpha',0);
            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'mass_change_100ms'
            figure
            uni_labels = unique(new_labels);
            for iterZ = 1:length(uni_labels)
                [front,back,none] = mass_change_100ms(filtered_save_data(cellfun(@(x) contains(x,uni_labels{iterZ}),new_labels),:),subplot(4,6,iterZ)); 
                title(sprintf('%s\n forward: %4.0f, backward: %4.0f, no move: %4.0f',uni_labels{iterZ},front,back,none),'Interpreter','none','HorizontalAlignment','center');
            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'center_of_mass_rel_leg_line'
            center_of_mass_rel_leg_line(filtered_save_data(cellfun(@(x) contains(x,'DNp11'),new_labels),:));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'distance_between_legs'
    %    distance_between_legs(filtered_save_data(cellfun(@(x) contains(x,'ESC'),new_labels),:));
    %    distance_between_legs(filtered_save_data(cellfun(@(x) contains(x,'DNp11'),new_labels),:));
            figure
            uni_labels = unique(new_labels);
            for iterZ = 1:length(uni_labels)

                angle_results = distance_between_legs(filtered_save_data(cellfun(@(x) contains(x,uni_labels{iterZ}),new_labels),:));
                angle_results(cellfun(@(x) isempty(x), angle_results)) = {NaN};
                angle_results = cell2mat(angle_results);
                subplot(6,4,iterZ)
                boxplot(angle_results);
                set(gca,'Ylim',[100 275],'Xlim',[0 10],'Xtick',1:1:9,'Xticklabel',0:25:200);
                title(sprintf('%s',uni_labels{iterZ}),'Interpreter','none','HorizontalAlignment','center');
                line([0 10],[180 180],'color',rgb('light gray'),'linewidth',.7);
            end
        case 'boxplot_total_movement'
             boxplot_total_movement(filtered_save_data);
        case 'movement_over_time'
            movement_over_time(filtered_save_data);
        case 'plot_tiles'
            for iterZ = 1:length(uni_geno)
                test_table = filtered_save_data(cellfun(@(x) contains(x,uni_geno(iterZ)),new_labels),:);
                plot_tiles(test_table,uni_geno(iterZ))
                if cellfun(@(x) contains(x,'ESC'),uni_geno(iterZ))
                    [ESC_center_line_x,ESC_center_line_y] = center_movement(uni_geno(iterZ),test_table,0,0);
                else
                    center_movement(uni_geno(iterZ),test_table,ESC_center_line_x,ESC_center_line_y);
                end
            end
        case 'GF_jump_dir'
            GF_jump_dir(filtered_save_data(cellfun(@(x) contains(x,'DNp01'),new_labels),:));
        case 'center_of_leg_movement'
            center_of_leg_movement(filtered_save_data);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot functions
function plot_tiles(line_data_table,line_name)
    %Selected plots to generate
    
    
    plot_type = 'plot_raw_annotation_tiles_flag';
%    plot_type = 'plot_leg_lineseg_rotated_tiles_flag';
%    plot_type = 'plot_center_rotated_tiles_flag';
    
    switch plot_type
        case {'plot_raw_annotation_tiles_flag'}
            figure
            [x_plot,y_plot] = split_fig(height(line_data_table));

            for iterZ = 1:height(line_data_table)

                subplot(x_plot,y_plot,iterZ)
                set(gca,'nextplot','add','ydir','reverse')

                plot_data = line_data_table.Track_Points{iterZ}{:,2:7};
                fly_orintation = line_data_table.Fly_Orientation{iterZ};

                color_count = size(plot_data,1);
                start_color = rgb('extremely light red');    stop_color = rgb('red');
                left_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,1),plot_data(:,2),12,left_leg_color,'filled')

                start_color = rgb('extremely light blue');    stop_color = rgb('blue');%[160 82 45]/255; %brown;
                right_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,3),plot_data(:,4),12,right_leg_color,'filled')

                start_color = rgb('extremely light gray');    stop_color = rgb('black');
                center_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,5),plot_data(:,6),12,center_leg_color,'filled')

                line([plot_data(1,5), plot_data(1,1)],[plot_data(1,6),plot_data(1,2)],'color',rgb('red'),'linewidth',.8);
                line([plot_data(1,5), plot_data(1,3)],[plot_data(1,6),plot_data(1,4)],'color',rgb('blue'),'linewidth',.8);

                if line_data_table.Jump_Flag(iterZ) == 0
                    jump_status = {'Non-Jump'};
                elseif line_data_table.Jump_Flag(iterZ) == 1
                    jump_status = {'Jump'};
                end
    %             title_str = cellfun(@(w,x,y) sprintf('%s_%s_%s\n%s',w,x(1:27),x(46:end),y),line_name,line_data_table.VideoName(iterZ),jump_status,'UniformOutput',false);
    %             title(sprintf('%s',title_str{1}),'Interpreter','none','HorizontalAlignment','center','fontsize',8);
                title_str = sprintf('RawAnno %s %s\n%s',cell2mat(line_name),cell2mat(jump_status),cell2mat(line_data_table.VideoName(iterZ)));
                title(title_str,'Interpreter','none','HorizontalAlignment','center','fontsize',8);
                set(gca,'Xlim',[0 384],'Ylim',[0 384]);
                
                u = cos(fly_orintation)*50;
                v = -sin(fly_orintation)*50;
                hQuiv = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',gca,'Visible','off');
                set(hQuiv,'XData',plot_data(1,5),'YData',plot_data(1,6),...
                    'MaxHeadSize',5,'LineWidth',2,'AutoScaleFactor',1,'color',rgb('green'),'UData',u,'VData',v,'visible','on')
                
                axis equal;
            end
    
        
        case 'plot_leg_lineseg_rotated_tiles_flag'

    %        rot_angle = 270*pi/180; %rad      

            %Find the midpoint of the line segement between the two legs.
            %Determine the angle of the line segment to offset rotate into this
            %coordinate system.
            %
            figure
            track_data = line_data_table.Track_Points;
            leg_midpoint = cellfun(@(x) [(x.Left_Leg_x+x.Right_Leg_x)/2,(x.Left_Leg_y+x.Right_Leg_y)/2],track_data,'UniformOutput',false);
            leg_lineseg_angle = cellfun(@(x) atan2d((x.Left_Leg_y-x.Right_Leg_y),(x.Left_Leg_x-x.Right_Leg_x))*pi/180,line_data_table.Track_Points,'UniformOutput',false);

            normalized_position = cellfun(@(x,y) [x.Left_Leg_x - y(:,1),x.Left_Leg_y - y(:,2) ...
                                                x.Right_Leg_x - y(:,1),x.Right_Leg_y - y(:,2) ...
                                                x.Center_x - y(:,1),x.Center_y - y(:,2)], line_data_table.Track_Points,leg_midpoint,'UniformOutput',false);

            rotate_output = cellfun(@(x,y) new_rotate_fun(x,y),normalized_position,leg_lineseg_angle,'UniformOutput',false);

            [x_plot,y_plot] = split_fig(height(line_data_table));
            for iterZ = 1:height(line_data_table)
                subplot(x_plot,y_plot,iterZ);
    %             rotated_norm_cords = cellfun(@(x,y) [rotation([x(:,1) x(:,2)*-1],[0,0],y-rot_angle,'radians'),...
    %                                                  rotation([x(:,3) x(:,4)*-1],[0,0],y-rot_angle,'radians'),...
    %                                                  rotation([x(:,5) x(:,6)*-1],[0,0],y-rot_angle,'radians')],normalized_position,leg_lineseg_angle,'UniformOutput',false);

                plot_data = rotate_output{iterZ};

                color_count = size(plot_data,1);
    %             start_color = rgb('extremely light red');    stop_color = rgb('red');
    %             left_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
    %             scatter(plot_data(:,1),plot_data(:,2),12,left_leg_color,'filled')
    %             set(gca,'nextplot','add');
    %             
    %             start_color = rgb('extremely light blue');    stop_color = rgb('blue');%[160 82 45]/255; %brown;
    %             right_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
    %             scatter(plot_data(:,3),plot_data(:,4),12,right_leg_color,'filled')

                start_color = rgb('extremely light gray');    stop_color = rgb('black');
                center_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,5),plot_data(:,6),12,center_leg_color,'filled')

    %            ellipse(5,2,rot_angle,0,0,rgb('black'));
     %           line([0, plot_data(1,1)],[0,plot_data(1,2)],'color',rgb('red'),'linewidth',.8);
     %           line([0, plot_data(1,3)],[0,plot_data(1,4)],'color',rgb('blue'),'linewidth',.8);

                if line_data_table.Jump_Flag(iterZ) == 0
                    jump_status = {'Non-Jump'};
                elseif line_data_table.Jump_Flag(iterZ) == 1
                    jump_status = {'Jumped'};
                end
    %             title_str = cellfun(@(w,x,y) sprintf('%s_%s_%s\n%s',w,x(1:27),x(46:end),y),line_name,line_data_table.VideoName(iterZ),jump_status,'UniformOutput',false);
    %             title(sprintf('%s',title_str{1}),'Interpreter','none','HorizontalAlignment','center','fontsize',8);
                title_str = sprintf('CenterRot %s %s\n%s',cell2mat(line_name),cell2mat(jump_status),cell2mat(line_data_table.VideoName(iterZ)));
                title(title_str,'Interpreter','none','HorizontalAlignment','center','fontsize',8);

                set(gca,'Xlim',[-50 50],'Ylim',[-50 50]);
                line([-50 50],[0 0],'color',rgb('red'),'linewidth',.8);
                line([0 0],[-50 50],'color',rgb('red'),'linewidth',.8);
    %            set(gca,'Xlim',[-200 200],'Ylim',[-200 200]);
    %             axis equal;        
            end
   
        case 'plot_center_rotated_tiles_flag'
            figure
            [x_plot,y_plot] = split_fig(height(line_data_table));

            for iterZ = 1:height(line_data_table)

                subplot(x_plot,y_plot,iterZ)
                set(gca,'nextplot','add','ydir','reverse')

                rot_angle = 270*pi/180; %rad        

                normalized_position = cellfun(@(x) [x.Left_Leg_x - x.Center_x(1),x.Left_Leg_y - x.Center_y(1) ...
                                                    x.Right_Leg_x - x.Center_x(1),x.Right_Leg_y - x.Center_y(1) ...
                                                    x.Center_x - x.Center_x(1),x.Center_y - x.Center_y(1)], line_data_table.Track_Points,'UniformOutput',false);
                rotated_norm_cords = cellfun(@(x,y) [rotation([x(:,1) x(:,2)*-1],[0,0],y-rot_angle,'radians'),...
                                                     rotation([x(:,3) x(:,4)*-1],[0,0],y-rot_angle,'radians'),...
                                                     rotation([x(:,5) x(:,6)*-1],[0,0],y-rot_angle,'radians')],normalized_position,line_data_table.Fly_Orientation,'UniformOutput',false);

                plot_data = rotated_norm_cords{iterZ};

                color_count = size(plot_data,1);
                start_color = rgb('extremely light red');    stop_color = rgb('red');
                left_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,1),plot_data(:,2),12,left_leg_color,'filled')

                start_color = rgb('extremely light blue');    stop_color = rgb('blue');%[160 82 45]/255; %brown;
                right_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,3),plot_data(:,4),12,right_leg_color,'filled')

                start_color = rgb('extremely light gray');    stop_color = rgb('black');
                center_leg_color = [linspace(start_color(1),stop_color(1),color_count)',linspace(start_color(2),stop_color(2),color_count)',linspace(start_color(3),stop_color(3),color_count)'];
                scatter(plot_data(:,5),plot_data(:,6),12,center_leg_color,'filled')

                ellipse(5,2,rot_angle,0,0,rgb('black'));
                line([plot_data(1,5), plot_data(1,1)],[plot_data(1,6),plot_data(1,2)],'color',rgb('red'),'linewidth',.8);
                line([plot_data(1,5), plot_data(1,3)],[plot_data(1,6),plot_data(1,4)],'color',rgb('blue'),'linewidth',.8);

                if line_data_table.Jump_Flag(iterZ) == 0
                    jump_status = {'Non-Jump'};
                elseif line_data_table.Jump_Flag(iterZ) == 1
                    jump_status = {'Jumped'};
                end
    %             title_str = cellfun(@(w,x,y) sprintf('%s_%s_%s\n%s',w,x(1:27),x(46:end),y),line_name,line_data_table.VideoName(iterZ),jump_status,'UniformOutput',false);
    %             title(sprintf('%s',title_str{1}),'Interpreter','none','HorizontalAlignment','center','fontsize',8);
                title_str = sprintf('CenterRot %s %s\n%s',cell2mat(line_name),cell2mat(jump_status),cell2mat(line_data_table.VideoName(iterZ)));
                title(title_str,'Interpreter','none','HorizontalAlignment','center','fontsize',8);

                set(gca,'Xlim',[-200 200],'Ylim',[-200 200]);
    %             axis equal;
            end
    end    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% support functions
function rotate_output = new_rotate_fun(click_points,rotate_angle)

   new_index = (1:1:length(click_points(:,1)))';
   rotate_output_leg_left = arrayfun(@(x) rotation([click_points(x,1) click_points(x,2)],[0 0],-1*rotate_angle(x),'radians'),new_index,'UniformOutput',false)';
   rotate_output_leg_right = arrayfun(@(x) rotation([click_points(x,3) click_points(x,4)],[0 0],-1*rotate_angle(x),'radians'),new_index,'UniformOutput',false)';
   rotate_output_leg_center = arrayfun(@(x) rotation([click_points(x,5) click_points(x,6)],[0 0],-1*rotate_angle(x),'radians'),new_index,'UniformOutput',false)';

   rotate_output = [cell2mat(rotate_output_leg_left'),cell2mat(rotate_output_leg_right'),cell2mat(rotate_output_leg_center')];
end

function set_up_iosr(~,~)
    currdir = cd;
    cd([fileparts(which(mfilename('fullpath'))) filesep '..']);
    directory = pwd;
    directory = [directory filesep 'IoSR-Surrey-MatlabToolbox-4bff1bb'];
    
    cd(directory);
    addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);
    
    %% start SOFA    
    SOFAstart(0);    
    cd(currdir); % return to original directory
end

function new_labels = convert_labels(old_labels)
    parsed_data = [];
    [uni_labels,~,uni_pos] = unique(old_labels);
    for iterZ = 1:length(uni_labels)
        test_data = Experiment_ID(uni_labels{iterZ});
        test_data.parse_data
        parsed_data = [parsed_data;test_data.parsed_data];
    end
    exp_info = correct_exp_info(parsed_data);
    exp_info = exp_info(uni_pos,:);
   
    not_in_sheet_id = [    {'1500090'};     {'2502522'};   {'3020007'}; {'2135398'};{'2135420'}; {'3026909'}];
    not_in_sheet_conv = [{'DL Wildtype'};      {'LC4'};      {'LC6'};    {'LPLC1'};  {'LPLC2'};  {' L1, L2'}];

    [~,~,raw] = xlsread('Z:\Pez3000_Gui_folder\DN_name_conversion.xlsx','Hiros List');
    header_list = raw(1,1:end);
    header_list = regexprep(header_list,' ','_');
    dn_table = cell2table(raw(2:end,1:end));
    dn_table.Properties.VariableNames = header_list;

    [locA,locB] = ismember(str2double(exp_info.ParentA_ID),dn_table.robot_ID);
    
    new_labels = old_labels;
    new_labels(locA) = dn_table(locB(locA),:).import_name;
        
    [locA,locB] = ismember(str2double(exp_info.ParentA_ID),str2double(not_in_sheet_id));
    new_labels(locA) = not_in_sheet_conv(locB(locA),:);
end

function exp_info = correct_exp_info(exp_info)
    flip_logic = cellfun(@(x) contains(x,'1150416') | contains(x,'1117481'),exp_info.ParentA_ID);
    temp_par_b_id = exp_info.ParentB_ID(flip_logic);
    temp_par_b_name = exp_info.ParentB_name(flip_logic);

    exp_info.ParentB_ID(flip_logic) = exp_info.ParentA_ID(flip_logic);        exp_info.ParentA_ID(flip_logic) = temp_par_b_id;
    exp_info.ParentB_name(flip_logic) = exp_info.ParentA_name(flip_logic);    exp_info.ParentA_name(flip_logic) = temp_par_b_name;

    exp_info.ParentB_name(cellfun(@(x) contains(x,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'),exp_info.ParentB_name)) = {'DL_UAS_Kir21_3_0090'};
    exp_info.ParentB_name(cellfun(@(x) contains(x,'UAS_Chrimson_Venus_X_0070VZJ_K_45195'),exp_info.ParentB_name)) = {'UAS_Chrimson_Venus_X_0070'};                
    exp_info.ParentB_name(cellfun(@(x) contains(x,'CTRL_DL_1500090_0028FCF_DL_1500090'),exp_info.ParentB_name)) = {'CTRL_DL_1500090'};
end

function [x_plot,y_plot] = split_fig(proto_used)     %how many subplots to make
    if proto_used == 1;                x_plot = 1; y_plot = 1;
    elseif proto_used == 2;            x_plot = 1; y_plot = 2;
    elseif proto_used <= 4;            x_plot = 2; y_plot = 2;
    elseif proto_used <= 6;            x_plot = 2; y_plot = 3;
    elseif proto_used <= 9;            x_plot = 3; y_plot = 3;
    elseif proto_used <= 12;           x_plot = 3; y_plot = 4;
    elseif proto_used <= 16;           x_plot = 4; y_plot = 4;
    elseif proto_used <= 20;           x_plot = 5; y_plot = 4;
    elseif proto_used <= 25;           x_plot = 5; y_plot = 5;
    elseif proto_used <= 30;           x_plot = 5; y_plot = 6;
    elseif proto_used <= 36;           x_plot = 6; y_plot = 6;            
    elseif proto_used <= 42;           x_plot = 7; y_plot = 6;            
    elseif proto_used <= 49;           x_plot = 7; y_plot = 7;
    elseif proto_used <= 56;           x_plot = 8; y_plot = 7;
    elseif proto_used <= 64;           x_plot = 8; y_plot = 8;
    end        
end

function summary_table = make_summary_table(martin_table,complete_table,tracked_table)
    locA = ~ismember(martin_table(:,1),complete_table(:,1));
    complete_table = [complete_table;[martin_table(locA,1),num2cell(zeros(sum(locA),2))]];
    
    locA = ~ismember(martin_table(:,1),tracked_table(:,1));
    tracked_table = [tracked_table;[martin_table(locA,1),num2cell(zeros(sum(locA),2))]];
    
    [~,locB_1] = ismember(martin_table(:,1),complete_table(:,1));
    [~,locB_2] = ismember(martin_table(:,1),tracked_table(:,1));

    summary_table = [martin_table(:,[1,2]),complete_table(locB_1,2),tracked_table(locB_2,2)];    
end

function boxplot_total_movement(filtered_save_data)
    track_data = filtered_save_data.Track_Points;
%    left_leg_move = cellfun(@(x) sqrt((x.Left_Leg_x(end) - x.Left_Leg_x(1)).^2 + (x.Left_Leg_y(end) - x.Left_Leg_y(1)).^2),track_data,'UniformOutput',false);
%    right_leg_move = cellfun(@(x) sqrt((x.Right_Leg_x(end) - x.Right_Leg_x(1)).^2 + (x.Right_Leg_y(end) - x.Right_Leg_y(1)).^2),track_data,'UniformOutput',false);
%    center_move = cellfun(@(x) sqrt((x.Center_x(end) - x.Center_x(1)).^2 + (x.Center_y(end) - x.Center_y(1)).^2),track_data,'UniformOutput',false);
    
    left_leg_move = cellfun(@(x) (sqrt((x.Left_Leg_x(2:end) - x.Left_Leg_x(1:(end-1))).^2 + (x.Left_Leg_y(2:end) - x.Left_Leg_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
    left_leg_move = cellfun(@(x) sum(x),left_leg_move);
    
    right_leg_move = cellfun(@(x) (sqrt((x.Right_Leg_x(2:end) - x.Right_Leg_x(1:(end-1))).^2 + (x.Right_Leg_y(2:end) - x.Right_Leg_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
    right_leg_move = cellfun(@(x) sum(x),right_leg_move);

    
    center_move = cellfun(@(x) (sqrt((x.Center_x(2:end) - x.Center_x(1:(end-1))).^2 + (x.Center_y(2:end) - x.Center_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
    center_move = cellfun(@(x) sum(x),center_move);
    
    
    new_labels = convert_labels(cellfun(@(x) x(29:44),filtered_save_data.VideoName,'UniformOutput',false));
    uni_labels = unique(new_labels);
    figure;
    [x_plot,y_plot] = split_fig(length(uni_labels));
    for iterZ = 1:length(uni_labels)
        geno_logic = ismember(new_labels,uni_labels{iterZ});
        plot_data = [left_leg_move(geno_logic),center_move(geno_logic),right_leg_move(geno_logic)];
        subplot(x_plot,y_plot,iterZ)
        y_data = plot_data;
        
        iosr.statistics.boxPlot(1:1:3,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));            
        
        title(sprintf('%s\n Count :: %4.0f',uni_labels{iterZ},sum(geno_logic)),'Interpreter','none','HorizontalAlignment','center');
        set(gca,'Ylim',[0 200]); 
    end
end

function movement_over_time(filtered_save_data)
    track_data = filtered_save_data.Track_Points;
    left_leg_move = cellfun(@(x) (sqrt((x.Left_Leg_x(2:end) - x.Left_Leg_x(1:(end-1))).^2 + (x.Left_Leg_y(2:end) - x.Left_Leg_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
    right_leg_move = cellfun(@(x) (sqrt((x.Right_Leg_x(2:end) - x.Right_Leg_x(1:(end-1))).^2 + (x.Right_Leg_y(2:end) - x.Right_Leg_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
    center_move = cellfun(@(x) (sqrt((x.Center_x(2:end) - x.Center_x(1:(end-1))).^2 + (x.Center_y(2:end) - x.Center_y(1:(end-1))).^2)),track_data,'UniformOutput',false);
        
    new_labels = convert_labels(cellfun(@(x) x(29:44),filtered_save_data.VideoName,'UniformOutput',false));
    uni_labels = unique(new_labels);
    figure;
   
    row_index = 0;
    for iterZ = 1:length(uni_labels)
        geno_logic = ismember(new_labels,uni_labels{iterZ});
        left_leg_data = left_leg_move(geno_logic);
        right_leg_data = right_leg_move(geno_logic);
        center_data = center_move(geno_logic);
        
        try
        right_plot = subplot(12,4,(mod(iterZ,4)+8)+1+row_index);       right_pos = get(right_plot,'Position');     right_pos(4) = 0.05;    set(right_plot,'nextplot','add','Position',right_pos);
        center_plot = subplot(12,4,(mod(iterZ,4)+4)+1+row_index);      center_pos = get(center_plot,'Position');   center_pos(2) =  right_pos(2) + .05;   center_pos(4) = 0.05;    set(center_plot,'nextplot','add','Position',center_pos,'Xtick',[]);
        left_plot = subplot(12,4,mod(iterZ,4)+1+row_index);            left_pos = get(left_plot,'Position');       left_pos(2) = center_pos(2) +  0.05;   left_pos(4) = 0.05;    set(left_plot,'nextplot','add','Position',left_pos,'Xtick',[]);
        
        catch
            warning('plot size')
        end
        
        for iterR = 1:length(center_data)       
           x_data = 0:1:(length(left_leg_data{iterR})-1);           
           plot(left_plot,x_data,cumsum(cell2mat(left_leg_data(iterR))),'-');
           plot(center_plot,x_data,cumsum(cell2mat(center_data(iterR))),'-');        %200
           plot(right_plot,x_data,cumsum(cell2mat(right_leg_data(iterR))),'-');      %400
        end

        title(sprintf('%s\n Count :: %4.0f',uni_labels{iterZ},sum(geno_logic)),'Interpreter','none','HorizontalAlignment','center','parent',left_plot);
        set(left_plot,'Xlim',[0 40],'Xtick',[],'Ylim',[0 40],'Ytick',40);        set(center_plot,'Xlim',[0 40],'Xtick',[],'Ylim',[0 15],'Ytick',15);        set(right_plot,'Xlim',[0 40],'Ylim',[0 40],'Ytick',40);
        set(right_plot,'Xtick',0:10:40,'Xticklabel',(0:10:40)*5);     %600        

%        set(left_plot,'Xlim',[0 40],'Ylim',[0 200],'Ytick',200);        set(center_plot,'Xlim',[0 40],'Ylim',[0 200],'Ytick',200);        set(right_plot,'Xlim',[0 40],'Ylim',[0 200],'Ytick',200);
%        set(right_plot,'Xtick',0:10:40,'Xticklabel',(0:10:40)*5);     %600        

        if mod(iterZ,4) == 0
            row_index = row_index + 12;  
        end
    end
end

function center_of_mass_rel_leg_line(test_table)
    figure
    [x_plot,y_plot] = split_fig(height(test_table));
    for iterT = 1:height(test_table)
        subplot(x_plot,y_plot,iterT)
        vid_points = table2cell(test_table.Track_Points{iterT})';

        x_cords = [vid_points(2,:);vid_points(6,:);vid_points(4,:)];        %left_x, center_x, right_x
        y_cords = [vid_points(3,:);vid_points(7,:);vid_points(5,:)];        %left_y, center_y, right_y
        
        x_cords = cell2mat(x_cords);
        y_cords = cell2mat(y_cords);

        dist_traveled =  sqrt((x_cords(:,1:(end-1)) - x_cords(:,2:(end))).^2  +(y_cords(:,1:(end-1)) - y_cords(:,2:(end))).^2);
        Left_leg_InDegrees = zeros(size(x_cords,2),1);
        Right_leg_InDegrees = zeros(size(x_cords,2),1);
        for iterZ = 1:size(x_cords,2)
            leg_lineseg_angle = atan2d((y_cords(3,iterZ) - y_cords(1,iterZ)),(x_cords(3,iterZ) - x_cords(1,iterZ)));
            if leg_lineseg_angle < 0
                leg_lineseg_angle = leg_lineseg_angle + 360;
            end
            leg_lineseg_angle = rem(leg_lineseg_angle,360);
            
            leg_midpoint = [(x_cords(1,iterZ) + x_cords(3,iterZ))/2,(y_cords(1,iterZ) + y_cords(3,iterZ))/2];
            rotate_angle = leg_lineseg_angle.*pi/180;
            
            rotate_cords = rotation([x_cords(:,iterZ)-leg_midpoint(1),y_cords(:,iterZ)-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
            
            P_left = rotate_cords(1,:);
            P_center = rotate_cords(2,:);
            P_right = rotate_cords(3,:);
            
            center_perp_pt = [P_center(1),0];
            
            Left_leg_InDegrees(iterZ) = abs(atand(((P_left(1)-center_perp_pt(1)) / P_center(2))));
            Right_leg_InDegrees(iterZ) = abs(atand(((P_right(1)-center_perp_pt(1)) / P_center(2))));
            if rotate_cords(2,2) < 0 %com is behind legs take outside angle
                Left_leg_InDegrees(iterZ) = 180 - Left_leg_InDegrees(iterZ);
                Right_leg_InDegrees(iterZ) = 180 - Right_leg_InDegrees(iterZ);
            end
            
        end
%       figure;
        x_points = 0:1:(length(Left_leg_InDegrees)-1);
        try
       [AX,H1,H2] = plotyy(x_points,[0,dist_traveled(1,:)],x_points,Left_leg_InDegrees); 
        catch
            warning('error?')
        end
       set(H1,'color',rgb('blue'));       set(H2,'color',rgb('blue'));
       set(AX(1),'nextplot','add'); set(AX(2),'nextplot','add');
       plot(AX(1),x_points,[0,dist_traveled(3,:)],'-g');
       plot(AX(2),x_points,Right_leg_InDegrees,'-go');
       set(AX(1),'Ylim',[0 30],'Ytick',0:5:30,'Ycolor',rgb('black'));
       set(AX(2),'Ylim',[60 150],'Ytick',60:15:150,'Ycolor',rgb('black'));
    end
end

function angle_results = distance_between_legs(test_table)
%     all_vids = [];
%     all_theta = [];
    figure
    time_cut_offs = 0:25:200;
    [x_plot,y_plot] = split_fig(height(test_table));
    angle_results = cell(height(test_table),length(time_cut_offs));
    for iterT = 1:height(test_table)
        subplot(x_plot,y_plot,iterT)
        vid_points = table2cell(test_table.Track_Points{iterT})';

        x_cords = [vid_points(2,:);vid_points(6,:);vid_points(4,:)];        %left_x, center_x, right_x
        y_cords = [vid_points(3,:);vid_points(7,:);vid_points(5,:)];        %left_y, center_y, right_y
        
        x_cords = cell2mat(x_cords);
        y_cords = cell2mat(y_cords);
%         if length(x_cords) > 15
%             x_cords = x_cords(:,5:15);
%             y_cords = y_cords(:,5:15);        
%         else
%             x_cords = x_cords(:,5:end);
%             y_cords = y_cords(:,5:end);                    
%         end       
        
        Full_ThetaInDegrees = zeros(length(x_cords),1);
        Left_leg_InDegrees = zeros(length(x_cords),1);
        Right_leg_InDegrees = zeros(length(x_cords),1);
%        curr_vid = repmat(test_table.VideoName(iterT),length(x_cords),1);

        try
        for iterZ = 1:size(x_cords,2)
            leg_lineseg_angle = atan2d((y_cords(3,iterZ) - y_cords(1,iterZ)),(x_cords(3,iterZ) - x_cords(1,iterZ)));
            if leg_lineseg_angle < 0
                leg_lineseg_angle = leg_lineseg_angle + 360;
            end
            leg_lineseg_angle = rem(leg_lineseg_angle,360);
            
            leg_midpoint = [(x_cords(1,iterZ) + x_cords(3,iterZ))/2,(y_cords(1,iterZ) + y_cords(3,iterZ))/2];
            rotate_angle = leg_lineseg_angle.*pi/180;
            
            rotate_cords = rotation([x_cords(:,iterZ)-leg_midpoint(1),y_cords(:,iterZ)-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
            
            P_left = rotate_cords(1,:);
            P_center = rotate_cords(2,:);
            P_right = rotate_cords(3,:);
            
            center_perp_pt = [P_center(1),0];
            Left_leg_InDegrees(iterZ) = abs(atand(((P_left(1)-center_perp_pt(1)) / P_center(2))));
            Right_leg_InDegrees(iterZ) = abs(atand(((P_right(1)-center_perp_pt(1)) / P_center(2))));
            Full_ThetaInDegrees(iterZ) = Left_leg_InDegrees(iterZ) + Right_leg_InDegrees(iterZ);
            
%             P_left = [x_cords(1,iterZ),y_cords(1,iterZ)];
%             P_center = [x_cords(2,iterZ),y_cords(2,iterZ)];
%             P_right = [x_cords(3,iterZ),y_cords(3,iterZ)];
            
%            new_p1 = [x_cords(2,iterZ),y_cords(1,iterZ)];
%            new_p2 = [x_cords(2,iterZ),y_cords(3,iterZ)];

            Full_ThetaInDegrees(iterZ) = atan2(abs(det([P_right-P_center;P_left-P_center])),dot(P_right-P_center,P_left-P_center)).*180/pi;
            
%            Left_leg_InDegrees(iterZ) = atan2(abs(det([new_p1-P_center;P_left-P_center])),dot(new_p1-P_center,P_left-P_center)).*180/pi;
%            Right_leg_InDegrees(iterZ) = atan2(abs(det([P_right-P_center;new_p2-P_center])),dot(P_right-P_center,new_p2-P_center)).*180/pi;
            if rotate_cords(2,2) > 0    %y center point in behind mid line
                Full_ThetaInDegrees(iterZ) = 360 - Full_ThetaInDegrees(iterZ);
            end
            
        end
        dist_traveled =  sqrt((x_cords(:,1:(end-1)) - x_cords(:,2:(end))).^2  +(y_cords(:,1:(end-1)) - y_cords(:,2:(end))).^2);
        both_leg_distance = [0,(dist_traveled(1,:) + dist_traveled(3,:))];
        x_cords = (1:1:length(both_leg_distance))*5 - 5;
        angle_results(iterT,1:1:sum(ismember(x_cords,time_cut_offs))) = num2cell(Full_ThetaInDegrees(ismember(x_cords,time_cut_offs))');
        
        
%        set(gca,'nextplot','add');
%        [AX,H1,H2] = plotyy(x_cords,Full_ThetaInDegrees,x_cords,both_leg_distance);
%        title(sprintf('%s',test_table.VideoName{iterT}),'Interpreter','none','fontsize',6);
        catch
            warning('empty?')
        end
        
%        all_vids = [all_vids;curr_vid];
%        all_theta = [all_theta;[Full_ThetaInDegrees,Left_leg_InDegrees,Right_leg_InDegrees]];

%         set(gca,'Xlim',[0 40],'Xtick',0:10:40,'Xticklabel',0:50:200,'Ylim',[90 270],'Ytick',90:45:270);
%         line([0 40],[180 180]);
%         new_ylim = [round(Full_ThetaInDegrees(1))-100 ,round(Full_ThetaInDegrees(1))+100];
%         set(AX(1),'Ylim',new_ylim,'Ytick',min(new_ylim):30:max(new_ylim),'Ycolor',rgb('red'))
%         set(AX(2),'Ylim',[0 40],'Ytick',0:10:40,'Ycolor',rgb('orange'))
%         set(H1,'color',rgb('red'));
%         set(H2,'color',rgb('orange'));
%         %line([0 200],[round(Full_ThetaInDegrees(1)) round(Full_ThetaInDegrees(1))],'color',rgb('black'),'parent',AX(1));
%         line([0 200],[180 180],'color',rgb('black'),'parent',AX(1));
    end
%     figure;    
%     set(gca,'nextplot','add')
%     y_data = iosr.statistics.tab2box(all_vids,all_theta);
% %    scatter_data = cumsum(y_data)';
%     scatter_data = y_data';
%     
%     for iterZ = 1:size(scatter_data,1)
%         plot(scatter_data(iterZ,:),'-o');
%     end
end

function [forward_move,back_move,no_move] = mass_change_100ms(test_table,curr_plot)
    all_left_legs = [];
    all_center_legs = [];
    all_right_legs = [];
    for iterT = 1:height(test_table)
        vid_points = table2cell(test_table.Track_Points{iterT})';

        x_cords = [vid_points(2,:);vid_points(6,:);vid_points(4,:)];        %left_x, center_x, right_x
        y_cords = [vid_points(3,:);vid_points(7,:);vid_points(5,:)];        %left_y, center_y, right_y
        
        x_cords = cell2mat(x_cords);
        y_cords = cell2mat(y_cords);
        if length(x_cords) < 5
            continue
        end
                
        leg_lineseg_angle = atan2d((y_cords(3,5) - y_cords(1,5)),(x_cords(3,5) - x_cords(1,5)));
        if leg_lineseg_angle < 0
            leg_lineseg_angle = leg_lineseg_angle + 360;
        end
        leg_lineseg_angle = rem(leg_lineseg_angle,360);

        leg_midpoint = [(x_cords(1,5) + x_cords(3,5))/2,(y_cords(1,5) + y_cords(3,5))/2];
        rotate_angle = leg_lineseg_angle.*pi/180;

        rotate_left_cords = rotation([x_cords(1,:)'-leg_midpoint(1),y_cords(1,:)'-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
        rotate_center_cords = rotation([x_cords(2,:)'-leg_midpoint(1),y_cords(2,:)'-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
        rotate_right_cords = rotation([x_cords(3,:)'-leg_midpoint(1),y_cords(3,:)'-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
        
        if size(rotate_left_cords,1) < 20
            all_left_legs = [all_left_legs; [rotate_left_cords(5,:),rotate_left_cords(end,:)]]; %#ok<*AGROW>
            all_center_legs = [all_center_legs; [rotate_center_cords(5,:),rotate_center_cords(end,:)]];
            all_right_legs = [all_right_legs; [rotate_right_cords(5,:),rotate_right_cords(end,:)]];
        else
            all_left_legs = [all_left_legs; [rotate_left_cords(5,:),rotate_left_cords(20,:)]];
            all_center_legs = [all_center_legs; [rotate_center_cords(5,:),rotate_center_cords(20,:)]];
            all_right_legs = [all_right_legs; [rotate_right_cords(5,:),rotate_right_cords(20,:)]];
        end
    end
    
    set(curr_plot,'nextplot','add')
    
    for iterZ = 1:size(all_center_legs,1)
        line([all_left_legs(iterZ,1),all_left_legs(iterZ,3)],[all_left_legs(iterZ,2),all_left_legs(iterZ,4)],'color',rgb('orange'),'parent',curr_plot);
        line([all_right_legs(iterZ,1),all_right_legs(iterZ,3)],[all_right_legs(iterZ,2),all_right_legs(iterZ,4)],'color',rgb('red'),'parent',curr_plot);
        line([all_center_legs(iterZ,1),all_center_legs(iterZ,3)],[all_center_legs(iterZ,2),all_center_legs(iterZ,4)],'color',rgb('dark green'),'parent',curr_plot);
    end
    line([-200 200],[0 0],'color',rgb('gray'),'linewidth',.8,'parent',curr_plot);
    line([0,0],[-80 80],'color',rgb('gray'),'linewidth',.8,'parent',curr_plot);
    forward_move = sum(all_center_legs(:,4) > 5);
    back_move = sum(all_center_legs(:,4) < -5);
    no_move = length(all_center_legs(:,4)) - forward_move - back_move;
end

function angle_results = find_inital_angle(test_table)
    angle_results = zeros(height(test_table),3);   
    for iterT = 1:height(test_table)
        vid_points = test_table.Click_Points(iterT);

        x_cords = [vid_points.Left_Leg_Mid(:,1),vid_points.Center_of_Mass(:,1),vid_points.Right_Leg_Mid(:,1)];
        y_cords = [vid_points.Left_Leg_Mid(:,2),vid_points.Center_of_Mass(:,2),vid_points.Right_Leg_Mid(:,2)];
                
        try
            leg_lineseg_angle = atan2d((y_cords(1,3) - y_cords(1,1)),(x_cords(1,3) - x_cords(1,1)));
        catch
            warning('end')
        end
        if leg_lineseg_angle < 0
            leg_lineseg_angle = leg_lineseg_angle + 360;
        end
        leg_lineseg_angle = rem(leg_lineseg_angle,360);
            
        leg_midpoint = [(x_cords(1,1) + x_cords(1,3))/2,(y_cords(1,1) + y_cords(1,3))/2];
        rotate_angle = leg_lineseg_angle.*pi/180;
            
        rotate_cords = rotation([x_cords(:,1)-leg_midpoint(1),y_cords(:,1)-leg_midpoint(2)],[0 0],-rotate_angle,'radians');
            
        P_left = rotate_cords(1,:);
        P_center = rotate_cords(2,:);
        P_right = rotate_cords(3,:);
        center_perp_pt = [P_center(1),0];

        Left_leg_InDegrees = abs(atand(((P_left(1)-center_perp_pt(1)) / P_center(2))));
        Right_leg_InDegrees = abs(atand(((P_right(1)-center_perp_pt(1)) / P_center(2))));
        if rotate_cords(2,2) < 0 %com is behind legs take outside angle
            Left_leg_InDegrees = 180 - Left_leg_InDegrees;
            Right_leg_InDegrees = 180 - Right_leg_InDegrees;
        end
        
        Full_ThetaInDegrees = Left_leg_InDegrees + Right_leg_InDegrees;
        
        angle_results(iterT,1) = Left_leg_InDegrees;
        angle_results(iterT,2) = Right_leg_InDegrees;
        angle_results(iterT,3) = Full_ThetaInDegrees;
    end

end

function center_pos_start(line_data_table)
    leg_mid_point = cellfun(@(x) [(x.Left_Leg_x + x.Right_Leg_x)/2,(x.Left_Leg_y + x.Right_Leg_y)/2], line_data_table.Track_Points,'UniformOutput',false);
    left_leg_norm = cellfun(@(x,y) [x.Left_Leg_x - y(:,1),x.Left_Leg_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
    right_leg_norm = cellfun(@(x,y) [x.Right_Leg_x - y(:,1),x.Right_Leg_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
    center_pos_norm = cellfun(@(x,y) [x.Center_x - y(:,1),x.Center_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
    
    all_center_start = [];
    for iterZ = 1:length(left_leg_norm)
        left_open_cell = left_leg_norm{iterZ};
        right_open_cell = right_leg_norm{iterZ};
        center_open_cell = center_pos_norm{iterZ};
        
        leg_lineseg_angle = atan2d((right_open_cell(:,2) - left_open_cell(:,2)),(right_open_cell(:,1) - left_open_cell(:,1)));
        leg_lineseg_angle = leg_lineseg_angle + 360;
        rotate_angle = leg_lineseg_angle-180;
        
        center_pos_rotate = arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),center_open_cell(:,1),center_open_cell(:,2),rotate_angle,'UniformOutput',false);
        center_pos_rotate = cell2mat(center_pos_rotate);        
        all_center_start = [all_center_start;center_pos_rotate(1,:)];
    end
%     new_labels = convert_labels(cellfun(@(x) x(29:44),line_data_table.VideoName,'UniformOutput',false));
%     trimmed_labels = new_labels;
%     label_logic = cellfun(@(x) contains(x,'('),new_labels);
    
%     new_trim_labels = cellfun(@(x) x(1:strfind(x,'(')-1),new_labels,'UniformOutput',false);
%     new_trim_labels(cellfun(@(x) isempty(x),new_trim_labels)) = [];
%     trimmed_labels(label_logic) = new_trim_labels;
    
    
    figure; 
    plot(all_center_start(:,1),all_center_start(:,2),'.b','MarkerSize',15);
    view([90 90])
    set(gca,'Xlim',[-60 60],'Ylim',[-60 60],'fontsize',15,'Xtick',-60:30:60,'Ytick',-60:30:30);
    grid on
    line([-60 60],[0 0],'color',rgb('black'),'linewidth',.8);
    line([0 0],[-60 60],'color',rgb('black'),'linewidth',.8);
end

function center_movement(line_name,line_data_table,label_names,fig_choice,metric_choice)
    %Process label strings
    trimmed_labels = label_names;
    label_logic = cellfun(@(x) contains(x,'('),trimmed_labels);
    new_trim_labels = cellfun(@(x) x(1:strfind(x,'(')-1),trimmed_labels,'UniformOutput',false);
    new_trim_labels(cellfun(@(x) isempty(x),new_trim_labels)) = [];
    trimmed_labels(label_logic) = new_trim_labels;
    trimmed_labels = cellfun(@(x) strtrim(x),trimmed_labels,'UniformOutput',false);

    line_name = strtrim(line_name);
    all_center_start = [];
    
    %Plot angle or COM over time for only all lines
    if strcmp(line_name,'all')
    else
        line_data_table = line_data_table(cellfun(@(x) strcmp(x,line_name),trimmed_labels),:);
        label_names = label_names(cellfun(@(x) strcmp(x,line_name),trimmed_labels));
    end
    
    %Plot angle or COM over time for only one line
    
    %Filter out to get correct data for plotting. 
    if strcmp(fig_choice,'single') && ~strcmp(line_name,'all')
        line_data_table(cellfun(@(x) contains(x,'49024'),label_names),:) = [];      %bad dnp11 line
        label_names(cellfun(@(x) contains(x,'49024'),label_names),:) = [];

        if strcmp(line_name,'DNp02')
            line_data_table(cellfun(@(x) contains(x,'1544'),label_names),:) = [];       %double line
            label_names(cellfun(@(x) contains(x,'1544'),label_names),:) = [];
            
            line_data_table(cellfun(@(x) contains(x,'2292'),label_names),:) = [];       %triple line    
            label_names(cellfun(@(x) contains(x,'2292'),label_names),:) = [];
        end
    end
    
    %Data structure v1
%     leg_lineseg_angle = cellfun(@(x) atan2d((x.Right_Leg_y - x.Left_Leg_y),(x.Right_Leg_x - x.Left_Leg_x)), line_data_table.Track_Points,'UniformOutput',false);
    %Data structure v2
    RLM = arrayfun(@(x) line_data_table.Click_Points(x).Right_Leg_Mid,1:1:height(line_data_table),'UniformOutput',false);
    LLM = arrayfun(@(x) line_data_table.Click_Points(x).Left_Leg_Mid,1:1:height(line_data_table),'UniformOutput',false);
    COM = arrayfun(@(x) line_data_table.Click_Points(x).Center_of_Mass,1:1:height(line_data_table),'UniformOutput',false);
    leg_lineseg_angle = cellfun(@(x,y) atan2d(x(:,2) - y(:,2),(x(:,1) - y(:,1))),RLM,LLM,'UniformOutput',false);

%     new_labels = cellfun(@(x) x(29:44),line_data_table.VideoName,'UniformOutput',false);
%     new_labels = convert_labels(new_labels);
    
%    dn_logic = cellfun(@(x) contains(x, 'DNp11'),new_labels);
    
    samp_angle = leg_lineseg_angle;
    %Data structure v1
%     label_list = cellfun(@(a,b) repmat({a},b,1),line_data_table.VideoName,cellfun(@(x) size(x,1),samp_angle,'UniformOutput',false),'UniformOutput',false); % 
    %Data structure v2
    label_list = cellfun(@(a,b) repmat({a},b,1),line_data_table.Properties.RowNames,cellfun(@(x) size(x,1),samp_angle','UniformOutput',false),'UniformOutput',false);

    samp_angle = vertcat(samp_angle{:});
    label_list = vertcat(label_list{:});
    
    %Data Filter Step for Leg Angle Movement
    x_pos_data = iosr.statistics.tab2box(label_list,samp_angle(:,1));       x_pos_data = x_pos_data';
    x_pos_data(x_pos_data<0) = x_pos_data(x_pos_data<0)+360;
    x_pos_data = x_pos_data(:,(1:(end-1))) - x_pos_data(:,2:end);
    x_pos_data = cumsum((x_pos_data),2); 
    remove_data_logic = abs(x_pos_data(:,1)) > 1 |  abs(x_pos_data(:,2)) > 2 | abs(x_pos_data(:,3)) > 3;     
    
    %remove videos where leg angle changes more then 3 degree in first 10 milliseconds
    line_data_table(remove_data_logic,:) = [];
    label_names(remove_data_logic,:) = [];    
    LLM(remove_data_logic) = [];
    RLM(remove_data_logic) = [];
    COM(remove_data_logic) = [];
    
    %Data structure v1
%     leg_mid_point = cellfun(@(x) [(x.Left_Leg_x + x.Right_Leg_x)/2,(x.Left_Leg_y + x.Right_Leg_y)/2], line_data_table.Track_Points,'UniformOutput',false);
%     left_leg_norm = cellfun(@(x,y) [x.Left_Leg_x - y(:,1),x.Left_Leg_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
%     right_leg_norm = cellfun(@(x,y) [x.Right_Leg_x - y(:,1),x.Right_Leg_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
%     center_pos_norm = cellfun(@(x,y) [x.Center_x - y(:,1),x.Center_y - y(:,2)] , line_data_table.Track_Points,leg_mid_point,'UniformOutput',false);
    %Data structure v2
    leg_mid_point = cellfun(@(x,y) [(x(:,1) + y(:,1))/2,(x(:,2) + y(:,2))/2],LLM,RLM,'UniformOutput',false);
    left_leg_norm = cellfun(@(x,y) [x(:,1) - y(:,1),x(:,2) - y(:,2)],LLM,leg_mid_point,'UniformOutput',false);
    right_leg_norm = cellfun(@(x,y) [x(:,1) - y(:,1),x(:,2) - y(:,2)],RLM,leg_mid_point,'UniformOutput',false);
    center_pos_norm = cellfun(@(x,y) [x(:,1) - y(:,1),x(:,2) - y(:,2)],COM,leg_mid_point,'UniformOutput',false);

    summary_data = [];

    %Rotate to angle between two middle legs
    for iterZ = 1:length(left_leg_norm)
        left_open_cell = left_leg_norm{iterZ};
        right_open_cell = right_leg_norm{iterZ};
        center_open_cell = center_pos_norm{iterZ};
        
        leg_lineseg_angle = atan2d((right_open_cell(:,2) - left_open_cell(:,2)),(right_open_cell(:,1) - left_open_cell(:,1)));
        leg_lineseg_angle = leg_lineseg_angle + 360;
        rotate_angle = leg_lineseg_angle-180;
        
        left_leg_rotate = arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),left_open_cell(:,1),left_open_cell(:,2),rotate_angle,'UniformOutput',false);
        right_leg_rotate = arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),right_open_cell(:,1),right_open_cell(:,2),rotate_angle,'UniformOutput',false);
        center_pos_rotate = arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),center_open_cell(:,1),center_open_cell(:,2),rotate_angle,'UniformOutput',false);        
                
        left_leg_rotate = cell2mat(left_leg_rotate);
        right_leg_rotate = cell2mat(right_leg_rotate);
        center_pos_rotate = cell2mat(center_pos_rotate);
                    
        Left_leg_InDegrees = abs(atand(((left_leg_rotate(:,1)-center_pos_rotate(:,1)) ./ center_pos_rotate(:,2))));
        Right_leg_InDegrees = abs(atand(((right_leg_rotate(:,1)-center_pos_rotate(:,1)) ./ center_pos_rotate(:,2))));
       
        Left_leg_InDegrees(center_pos_rotate(:,2) <0) = 180 - Left_leg_InDegrees(center_pos_rotate(:,2) <0);
        Right_leg_InDegrees(center_pos_rotate(:,2) <0) = 180 - Right_leg_InDegrees(center_pos_rotate(:,2) <0);
        
        Total_Angle = Left_leg_InDegrees + Right_leg_InDegrees;

        center_mass_dist = [0;(sqrt((center_pos_rotate(1:(end-1),1) - center_pos_rotate(2:(end),1)).^2 + (center_pos_rotate(1:(end-1),2) - center_pos_rotate(2:(end),2)).^2))];
        summary_data = [summary_data;[repmat(line_data_table.Properties.RowNames(iterZ),length(Total_Angle),1),repmat(label_names(iterZ),length(Total_Angle),1),num2cell(Total_Angle),num2cell(center_mass_dist)],num2cell(center_pos_rotate(:,1)),num2cell(center_pos_rotate(:,2))];
        all_center_start = [all_center_start;center_pos_rotate(1,:)];
    end
    angle_data = iosr.statistics.tab2box(summary_data(:,1),cell2mat(summary_data(:,3)));
    angle_data = angle_data';
    com_dist = iosr.statistics.tab2box(summary_data(:,1),cell2mat(summary_data(:,4)));
    com_dist = com_dist';
    com_x_pos = iosr.statistics.tab2box(summary_data(:,1),cell2mat(summary_data(:,5)));
    com_x_pos = com_x_pos';
    com_y_pos = iosr.statistics.tab2box(summary_data(:,1),cell2mat(summary_data(:,6)));
    com_y_pos = com_y_pos';

    
    %More filtering: %remove flies where Center of Mass moved more then 1.5 pixels in first 10 milliseconds
    remove_data_logic = com_dist(:,2) > 5 | com_dist(:,3) > 5;
    angle_data(remove_data_logic,:) = [];
        
    angle_dims =  size(angle_data);
    angle_diff = angle_data - angle_data(:,1);
    angle_mean = mean(angle_diff,'omitnan');          angle_std = std(angle_diff,'omitnan');
    
    if strcmp(fig_choice,'single')
        figure; 
        subplot(2,2,1)
        set(gca,'nextplot','add')

        for iterZ = 1:angle_dims(1)
            plot((0:1:(angle_dims(2))-1)*5,angle_data(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title(sprintf('Angle Position over time\n for every fly'));
        
        subplot(2,2,3)
        boxplot(angle_diff);
        set(gca,'Ylim',[-80 80]);
        set(gca,'Xlim',[0 21.5],'Xtick',1:5:21,'Xticklabel',0:25:100);
        title('Box plot of Zeroed out Angle Position')
    
        subplot(2,2,2)
        set(gca,'nextplot','add')        

        angle_dims =  size(angle_data);
        for iterZ = 1:angle_dims(1)
            plot((0:1:(angle_dims(2))-1)*5,angle_diff(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Ylim',[-80 80]);
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title('Zeroed out for Orgional Position');
    
        subplot(2,2,4)
    end
%     figure
    x_cord = (0:1:(angle_dims(2))-1)*5;
%     iosr.statistics.boxPlot(x_cord,diff(angle_diff,[],2),'symbolColor','k','medianColor','k','symbolMarker','+',...
%                'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
                   
    set(gca,'nextplot','add');

    plot(x_cord,angle_mean,'-b');
    for iterZ = 1:angle_dims(2)
        plot(x_cord(iterZ),angle_mean(iterZ),'b.','MarkerSize',20);
        line([x_cord(iterZ) x_cord(iterZ)],[(angle_mean(iterZ) - angle_std(iterZ)) (angle_mean(iterZ) + angle_std(iterZ))],'color',rgb('black'),'linewidth',1);
    end
    set(gca,'Ylim',[-100 100],'Ytick',-100:25:100,'ygrid','on');
    set(gca,'Xlim',[0 100],'Xtick',0:25:100);
    title('Mean and Standard Deviation')
    if strcmp(fig_choice,'multi')
        title(sprintf('%s (count :: %4.0f)',line_name,angle_dims(1)),'HorizontalAlignment','center','Interpreter','none','fontsize',13);
    end
    
    %Figure for COM movement along the X (side-to-side) and Y (back-front)-------------------------------------------------------------------------------------
    com_dims =  size(com_x_pos);
    com_x_pos_diff = com_x_pos - com_x_pos(:,1);
    com_x_pos_mean = mean(com_x_pos_diff,'omitnan');          
    com_x_pos_std = std(com_x_pos_diff,'omitnan');
    com_y_pos_diff = com_y_pos - com_y_pos(:,1);
    com_y_pos_mean = mean(com_y_pos_diff,'omitnan');          
    com_y_pos_std = std(com_y_pos_diff,'omitnan');
    
    if strcmp(fig_choice,'single')
        figure; 
        subplot(2,2,1)
        set(gca,'nextplot','add')
        for iterZ = 1:com_dims(1)
            plot((0:1:(com_dims(2))-1)*5,com_x_pos(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title(sprintf('COM X Position'));
        
        subplot(2,2,2)
        set(gca,'nextplot','add')        
        for iterZ = 1:com_dims(1)
            plot((0:1:(com_dims(2))-1)*5,com_x_pos_diff(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Ylim',[-80 80]);
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title('COM X Position Zeroed Out');
    
        subplot(2,2,3)
        set(gca,'nextplot','add')        
        for iterZ = 1:com_dims(1)
            plot((0:1:(com_dims(2))-1)*5,com_y_pos(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title(sprintf('COM Y Position'));
        
        subplot(2,2,4)
        set(gca,'nextplot','add')
        
        for iterZ = 1:com_dims(1)
            plot((0:1:(com_dims(2))-1)*5,com_y_pos_diff(iterZ,:),'-','MarkerSize',7,'Marker','.');
        end
        set(gca,'Xlim',[0 100],'Xtick',0:25:100);
        title(sprintf('COM Y Position Zeroed Out'));
        
    end    
    
    
end

function [sort_order,new_labels,sort_labels] = make_sort_order(new_labels)
    dl_logic = cellfun(@(x) (contains(x,'DL Wildtype')),new_labels);                
    new_labels(dl_logic) = cellfun(@(x) sprintf('    %s',x),new_labels(dl_logic),'uniformoutput',false);

    dl_logic = cellfun(@(x) (contains(x,'SS01062')),new_labels);                
    new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);        

    gf_logic = cellfun(@(x) (contains(x,'Giant Fiber')),new_labels);                
    new_labels(gf_logic) = cellfun(@(x) sprintf('  %s',x),new_labels(gf_logic),'uniformoutput',false);                

    single_logic = cellfun(@(x) ~contains(x,','),new_labels);
    new_labels(single_logic) = cellfun(@(x) sprintf(' %s',x),new_labels(single_logic),'uniformoutput',false);                                

    dl_logic = cellfun(@(x) (contains(x,'L1, L2')),new_labels);
    new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);

    [sort_labels,sort_order] = sort(new_labels);
end

function GF_jump_dir(test_table)
    all_track_data = [];
    all_manual = [];
    last_geno = [];
    
    [~,sort_idx] = sort(cellfun(@(x) x(29:44),test_table.VideoName,'UniformOutput',false));
    test_table = test_table(sort_idx,:);
    
    for iterZ = 1:height(test_table)
        geno_ids = cellfun(@(x) x(29:44),test_table.VideoName(iterZ),'UniformOutput',false);
        geno_ids = geno_ids{1};
        if isempty(last_geno) || ~strcmp(last_geno,geno_ids)
            manual_data = load(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_manualAnnotations']);
            all_manual = [all_manual;manual_data.(cell2mat(fieldnames(manual_data)))];
        end
        last_geno = geno_ids;
        try
            track_data = load(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_flyAnalyzer3000_v14' filesep test_table.VideoName{iterZ} '_flyAnalyzer3000_v14_data']);
        catch
            warning('no track')
        end
        all_track_data = [all_track_data;track_data.(cell2mat(fieldnames(track_data)))];
    end
    manual_matching = all_manual(all_track_data.Properties.RowNames,:);
    
    jump_logic = cellfun(@(x) isempty(x), manual_matching.frame_of_leg_push);
    all_track_data(jump_logic,:) = [];      manual_matching(jump_logic,:) = [];
    
    jump_logic = cellfun(@(x) isnan(x), manual_matching.frame_of_leg_push);
    all_track_data(jump_logic,:) = [];      manual_matching(jump_logic,:) = [];    
    
    fly_bot_pos = cellfun(@(x,y,z) x(y:z,:),all_track_data.bot_points_and_thetas,manual_matching.frame_of_leg_push,manual_matching.frame_of_take_off,'UniformOutput',false);
    fly_top_pos = cellfun(@(x,y,z) x(y:z,:),all_track_data.top_points_and_thetas,manual_matching.frame_of_leg_push,manual_matching.frame_of_take_off,'UniformOutput',false);
    
    azi_angle = cell2mat(cellfun(@(x) polyfit(x(:,1),x(:,2),1),fly_bot_pos,'UniformOutput',false));
    ele_angle = cell2mat(cellfun(@(x) polyfit(x(:,1),x(:,2),1),fly_top_pos,'UniformOutput',false));
end

function center_of_leg_movement(line_data_table)
%    leg_mid_point = cellfun(@(x) [(x.Left_Leg_x + x.Right_Leg_x)/2,(x.Left_Leg_y + x.Right_Leg_y)/2], line_data_table.Track_Points,'UniformOutput',false);
    leg_lineseg_angle = cellfun(@(x) atan2d((x.Right_Leg_y - x.Left_Leg_y),(x.Right_Leg_x - x.Left_Leg_x)), line_data_table.Track_Points,'UniformOutput',false);

    new_labels = cellfun(@(x) x(29:44),line_data_table.VideoName,'UniformOutput',false);
    new_labels = convert_labels(new_labels);
    
%    dn_logic = cellfun(@(x) contains(x, 'DNp11'),new_labels);
    
 %   samp_angle = leg_lineseg_angle(dn_logic);
 %   label_list = cellfun(@(a,b) repmat({a},b,1), line_data_table(dn_logic,:).VideoName,cellfun(@(x) size(x,1),samp_angle,'UniformOutput',false),'UniformOutput',false);
    samp_angle = leg_lineseg_angle;
    label_list = cellfun(@(a,b) repmat({a},b,1), line_data_table.VideoName,cellfun(@(x) size(x,1),samp_angle,'UniformOutput',false),'UniformOutput',false);
    
    samp_angle = vertcat(samp_angle{:});
    label_list = vertcat(label_list{:});
    
    x_pos_data = iosr.statistics.tab2box(label_list,samp_angle(:,1));       x_pos_data = x_pos_data';
    x_pos_data(x_pos_data<0) = x_pos_data(x_pos_data<0)+360;
    x_pos_data = x_pos_data(:,(1:(end-1))) - x_pos_data(:,2:end);
    x_pos_data = cumsum((x_pos_data),2); 
    x_pos_data(abs(x_pos_data(:,3)) > 3.5,:) = [];
%    x_pos_data(abs(x_pos_data(:,3)) > 3,:) = [];
    
    if size(x_pos_data,2) > 21
        x_pos_data = x_pos_data(:,1:21);
    end    

    
    figure; boxplot(x_pos_data);
    
    max_dist = max(x_pos_data,[],2,'omitnan');
    figure
    
    no_move_sample = x_pos_data(max_dist < 5,:);
    med_move_sample = x_pos_data(max_dist >= 5 & max_dist < 15,:);
    large_move_sample = x_pos_data(max_dist >= 15 & max_dist < 25,:);
    massive_move_sample = x_pos_data(max_dist >= 25,:);
    
    subplot(2,2,1)
    boxplot(no_move_sample);    set(gca,'Ylim',[0 50]);        title(sprintf('Flies that moved less than 5 degrees total\n count :: %4.0f',size(no_move_sample,1)));
    subplot(2,2,2)
    boxplot(med_move_sample);   set(gca,'Ylim',[0 50]);        title(sprintf('Flies that moved between 5 and 15 degrees total\n count :: %4.0f',size(med_move_sample,1)));
    subplot(2,2,3)
    boxplot(large_move_sample); set(gca,'Ylim',[0 50]);        title(sprintf('Flies that moved between 15 and 25 degrees total\n count :: %4.0f',size(large_move_sample,1)));
    subplot(2,2,4)
    boxplot(massive_move_sample);   set(gca,'Ylim',[0 50]);    title(sprintf('Flies that moved over 25 degrees total\n count :: %4.0f',size(massive_move_sample,1)));
    
    
    uni_labels = unique(new_labels);
    [x_plot,y_plot] = split_fig(length(uni_labels));
    figure
    for iterZ = 1:length(uni_labels)
        subplot(x_plot,y_plot,iterZ)
        label_logic = ismember(new_labels,uni_labels{iterZ});
%        test_mid_leg = leg_mid_point(label_logic);
        samp_angle = leg_lineseg_angle(label_logic);
        
        
%        leg_dist_trvl = cellfun(@(x)  sqrt(((x(1,1) - x(:,1)).^2) + ((x(1,2) - x(:,2)).^2)),test_mid_leg,'UniformOutput',false);
        
        
%        label_list = cellfun(@(a,b) repmat({a},b,1), line_data_table.VideoName(label_logic),cellfun(@(x) size(x,1),leg_dist_trvl,'UniformOutput',false),'UniformOutput',false);
        label_list = cellfun(@(a,b) repmat({a},b,1), line_data_table.VideoName(label_logic),cellfun(@(x) size(x,1),samp_angle,'UniformOutput',false),'UniformOutput',false);
        label_list = vertcat(label_list{:});
 %       leg_dist_trvl = vertcat( leg_dist_trvl{:});
        samp_angle = vertcat(samp_angle{:});
        x_pos_data = iosr.statistics.tab2box(label_list,samp_angle(:,1));       x_pos_data = x_pos_data';
        x_pos_data(x_pos_data<0) = x_pos_data(x_pos_data<0)+360;
        
        
        x_pos_data = (x_pos_data - x_pos_data(:,1));
        x_pos_data(x_pos_data>180) = x_pos_data(x_pos_data>180)-360;
        x_pos_data(x_pos_data<-180) = x_pos_data(x_pos_data<-180)+360;
        
        if size(x_pos_data,2) > 21
            x_pos_data = x_pos_data(:,1:21);
        end
        boxplot(x_pos_data);        
        set(gca,'Xlim',[0 22],'Xtick',1:5:21,'Xticklabel',0:25:100);
        title(sprintf('%s',uni_labels{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
    end

end
function movement_tracker(line_data,line_labels)
    trimmed_labels = line_labels;
    label_logic = cellfun(@(x) contains(x,'('),trimmed_labels);
    new_trim_labels = cellfun(@(x) x(1:strfind(x,'(')-1),trimmed_labels,'UniformOutput',false);
    new_trim_labels(cellfun(@(x) isempty(x),new_trim_labels)) = [];
    trimmed_labels(label_logic) = new_trim_labels;


%    uni_labels = unique(line_labels);
    uni_labels = unique(trimmed_labels);
    [x_plot,y_plot] = split_fig(length(uni_labels));    
    all_errors = [];
    for iterP = 15
        figure
        for iterZ = 1:length(uni_labels)        

            subplot(x_plot,y_plot,iterZ);
%            testing_data = line_data(ismember(line_labels,uni_labels{iterZ}),:);
            testing_data = line_data(ismember(trimmed_labels,uni_labels{iterZ}),:);
            leg_mid_points = arrayfun(@(x) (testing_data.Click_Points(x).Right_Leg_Mid(1,:) + testing_data.Click_Points(x).Left_Leg_Mid(1,:))./2,1:1:height(testing_data),'UniformOutput',false);
            leg_mid_points = leg_mid_points';
            leg_mid_points = cell2mat(leg_mid_points);
            leg_rotate_angle = arrayfun(@(x) atand((testing_data.Click_Points(x).Right_Leg_Mid(1,2) - testing_data.Click_Points(x).Left_Leg_Mid(1,2))./ ...
                (testing_data.Click_Points(x).Right_Leg_Mid(1,1) - testing_data.Click_Points(x).Left_Leg_Mid(1,1))),1:1:height(testing_data),'UniformOutput',false)';
            leg_rotate_angle = (cell2mat(leg_rotate_angle) + 360) - 180;

            leg_rotate_angle(leg_rotate_angle > 360) = leg_rotate_angle(leg_rotate_angle > 360) - 360;

            left_leg_rotate = arrayfun(@(x)  rotation((testing_data.Click_Points(x).Left_Leg_Mid - leg_mid_points(x,:)),[0 0],-leg_rotate_angle(x),'degrees'),1:1:height(testing_data),'UniformOutput',false);
            right_leg_rotate = arrayfun(@(x)  rotation((testing_data.Click_Points(x).Right_Leg_Mid - leg_mid_points(x,:)),[0 0],-leg_rotate_angle(x),'degrees'),1:1:height(testing_data),'UniformOutput',false);
            center_mass_rotate = arrayfun(@(x)  rotation((testing_data.Click_Points(x).Center_of_Mass - leg_mid_points(x,:)),[0 0],-leg_rotate_angle(x),'degrees'),1:1:height(testing_data),'UniformOutput',false);
            
            if sum(cellfun(@(x) length(x),left_leg_rotate) > iterP) == 0
                continue
            end

            left_mid_leg_dist = cell2mat(cellfun(@(x)[(x(iterP,1) - x(1,1)),(x(iterP,2) - x(1,2))],left_leg_rotate(cellfun(@(x) length(x),left_leg_rotate) > iterP),'UniformOutput',false)');
%            left_mid_leg_dist = mean(left_mid_leg_dist);

            right_mid_leg_dist = cell2mat(cellfun(@(x)[(x(iterP,1) - x(1,1)),(x(iterP,2) - x(1,2))],right_leg_rotate(cellfun(@(x) length(x),left_leg_rotate) > iterP),'UniformOutput',false)');
%            right_mid_leg_dist = mean(right_mid_leg_dist);

            center_mass_dist = cell2mat(cellfun(@(x)[(x(iterP,1) - x(1,1)),(x(iterP,2) - x(1,2))],center_mass_rotate(cellfun(@(x) length(x),left_leg_rotate) > iterP),'UniformOutput',false)');
%            center_mass_dist = mean(center_mass_dist);

            error_checking = testing_data(cellfun(@(x) length(x),left_leg_rotate) > iterP,:);
            extreme_movers = (sum(abs(left_mid_leg_dist) > 25,2)+sum(abs(right_mid_leg_dist) > 25,2)) > 0;
            error_checking = error_checking(extreme_movers,:);
%              center_mass_dist(extreme_movers,:) = [];
%              left_mid_leg_dist(extreme_movers,:) = [];
%              right_mid_leg_dist(extreme_movers,:) = [];

            set(gca,'nextplot','add');     
            %Plot Raw Arrows
%             plot(0, 0,'r.','markersize',25); 
%             plot(60, 0,'b.','markersize',25);      
%             plot(-60, 0,'g.','markersize',25);      
%             for iterC = 1:length(center_mass_dist)
%                 quiver(0,0,center_mass_dist(iterC,1),center_mass_dist(iterC,2),'color',rgb('red'));
%                 quiver(60,0,right_mid_leg_dist(iterC,1),right_mid_leg_dist(iterC,2),'color',rgb('blue'));
%                 quiver(-60,0,left_mid_leg_dist(iterC,1),left_mid_leg_dist(iterC,2),'color',rgb('green'));
%             end

            %Plot circular mean
            plot(0, 0,'r.','markersize',25); 
            plot(20, 0,'b.','markersize',25);      
            plot(-20, 0,'g.','markersize',25);      

            [theta,rho] = cart2pol(center_mass_dist(:,1),center_mass_dist(:,2));
             u = cos(circ_mean(theta))*mean(rho);        v = -sin(circ_mean(theta))*mean(rho);             quiver(0,0,u,v,0,'color',rgb('red'));

            [theta,rho] = cart2pol(right_mid_leg_dist(:,1),right_mid_leg_dist(:,2));
             u = cos(circ_mean(theta))*mean(rho);        v = -sin(circ_mean(theta))*mean(rho);             quiver(20,0,u,v,0,'color',rgb('blue'));

            [theta,rho] = cart2pol(left_mid_leg_dist(:,1),left_mid_leg_dist(:,2));
            u = cos(circ_mean(theta))*mean(rho);        v = -sin(circ_mean(theta))*mean(rho);             quiver(-20,0,u,v,0,'color',rgb('green'));

             
            
            title(sprintf('%s\ncount:: %4.0f',uni_labels{iterZ},length(center_mass_dist)));
            set(gca,'ydir','reverse');
%            set(gca,'Ylim',[-100 100],'Ytick',-100:25:100,'Ygrid','on','Xlim',[-100 100],'Xtick',-100:25:100); %raw
            set(gca,'Ylim',[-30 30],'Ytick',-30:15:30,'Ygrid','on','Xlim',[-30 30],'Xtick',-30:15:30);
            all_errors = [all_errors;error_checking];
            axis equal
        end
    end
end

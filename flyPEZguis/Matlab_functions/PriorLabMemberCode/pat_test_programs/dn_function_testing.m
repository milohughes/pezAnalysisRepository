%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load in groups infor
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))

    file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';    
    saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);            saved_groups = saved_groups.Saved_Group_IDs;        
    sample_group = saved_groups(cellfun(@(x) contains(x,'Pat Data :: Martin DN Data'),saved_groups.Properties.RowNames),:);
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
    for iterZ = 1:steps
        combine_data(iterZ).get_tracking_data;
    end 
    for iterZ = 1:steps
        combine_data(iterZ).display_data
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% caulate video percent information
    steps = length(combine_data);
    video_information = zeros(steps,10);
    
    for iterZ = 1:steps
        good_data = height(combine_data(iterZ).Complete_usuable_data)+height(combine_data(iterZ).Videos_Need_To_Work);
        pez_data = height(combine_data(iterZ).Multi_Blank) + height(combine_data(iterZ).Pez_Issues) + height(combine_data(iterZ).Balancer_Wings);
        track_data = height(combine_data(iterZ).Failed_Location) + height(combine_data(iterZ).Vid_Not_Tracked) + height(combine_data(iterZ).Bad_Tracking);
        
        video_information(iterZ,1) = good_data + pez_data + track_data;                         %total videos
        video_information(iterZ,2) = height(combine_data(iterZ).Videos_Need_To_Work);           %not annotated
        video_information(iterZ,3) = height(combine_data(iterZ).Complete_usuable_data);         %good and passing
        
        jump_delay = cellfun(@(x,y) (x-y)/6, combine_data(iterZ).Complete_usuable_data.frame_of_leg_push,combine_data(iterZ).Complete_usuable_data.Start_Frame);
        
        video_information(iterZ,4) = sum(jump_delay > 0 & jump_delay <= 50);        %jumped during light cycle
        video_information(iterZ,5) = sum(jump_delay > 50 & jump_delay <= 100);       %jumped 25 ms after lights off
        video_information(iterZ,6) = sum(jump_delay > 100 & jump_delay <= 150);      %jumped betwen 25 and 75 ms after lights off
        video_information(iterZ,7) = sum(jump_delay > 150 & jump_delay <= 200);      
        video_information(iterZ,8) = sum(jump_delay > 200 & jump_delay <= 300);
        video_information(iterZ,9) = sum(jump_delay > 300);
        video_information(iterZ,10) = sum(isnan(jump_delay));                        %flies didn't jump
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert expids into cell type names
    parsed_info = vertcat(combine_data(:).parsed_data);

    [~,~,raw] = xlsread('Z:\Pez3000_Gui_folder\DN_name_conversion.xlsx','Hiros List');
    header_list = raw(1,:);
    header_list = regexprep(header_list,' ','_');
    dn_table = cell2table(raw(2:end,:));
    dn_table.Properties.VariableNames = header_list;

    [locA,locB] = ismember(str2double(parsed_info.ParentA_ID),dn_table.robot_ID);
    matching_data = dn_table(locB(locA),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    dn_logic = cellfun(@(x) contains(x,'P4, P2'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P4, P6'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P1'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P11'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P2') & ~contains(x,'P4'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P4') & ~contains(x,'P2') & ~contains(x,'P6'),matching_data.new_name);    
    test_data = vertcat(combine_data(dn_logic).Complete_usuable_data);
    test_data(cell2mat(test_data.Start_Frame) < 100,:) = [];   
    
    jump_logic = ~isnan(cell2mat(test_data.frame_of_leg_push));     %filters to jumpers only
    test_data = test_data(jump_logic,:);
    jump_delay = cellfun(@(x,y) (x-y)/6, test_data.frame_of_leg_push,test_data.Start_Frame);
    %time_window_logic = (jump_delay > 50 & jump_delay <= 100);
    time_window_logic = (jump_delay > 25 & jump_delay <= 75);
    
    test_data = test_data(time_window_logic,:);     %filters jumpers to only between 50 and 100 ms 
    
    
    last_frame = cell2mat(test_data.frame_of_leg_push);
    time_cut_off = cell2mat(test_data.Start_Frame)+ ((50+100)*6);
    last_frame(last_frame > time_cut_off) = time_cut_off(last_frame > time_cut_off);
    last_frame(isnan(last_frame)) = time_cut_off(isnan(last_frame));
    
    short_tracking = cellfun(@(x,y) length(x(:,1)) < y,test_data.bot_points_and_thetas,test_data.frame_of_take_off);
    test_data(short_tracking,:) = [];
%     has_enough_tracking = cellfun(@(x) length(x(:,1)),test_data.bot_points_and_thetas) > last_frame;
%     
%     last_frame = last_frame(has_enough_tracking);
%     test_data = test_data(has_enough_tracking,:);
    
%     tracked_data_points = cellfun(@(x,y,z) x(y:z,:),test_data.bot_points_and_thetas,test_data.Start_Frame,num2cell(last_frame),'UniformOutput',false);
%     com_move = cellfun(@(x) [x(end,1) - x(1,1), x(end,2) - x(1,2)],tracked_data_points,'UniformOutput',false);
%     rotate_angle = cellfun(@(x) x(1,3),tracked_data_points,'UniformOutput',false);
%     rotated_movement = cell2mat(cellfun(@(x,y) rotation(x,[0 0],y,'radians'),com_move,rotate_angle,'UniformOutput',false));

    figure
    data_path = '\\DM11\cardlab\Data_pez3000'; 
    for iterZ = 1:46
        subplottight(5,10,iterZ)
        vid_name = test_data.Properties.RowNames{iterZ};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);

        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vid_name,'.mp4']);
        vidObj_partail = VideoReader(fullPath_parital); %#ok<TNMLP>
  
        frmData = read(vidObj_partail,1); %#ok<VIDREAD>
        
        tI = log(double(frmData)+15);
        frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
        [~,frm_graymap] = gray2ind(frmAdj,256);
        tol = [0 0.9999];
        gammaAdj = 0.75;
        lowhigh_in = stretchlim(frmAdj,tol);
        lowhigh_in(1) = 0.01;
        frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
        frm_remap = uint8(frm_remap(:,1).*255);
        frmData = intlut(frmAdj,frm_remap);

        frmData = frmData(449:end,:,:);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zero pads image
        rotate_angle = cellfun(@(x) x(1,3),test_data.bot_points_and_thetas(iterZ));
        rotate_angle = 360-(rotate_angle .* 180/pi);
        
        zero_pad = 300;

        frmData = padarray(frmData, zero_pad,'pre');              %pads zeros on neg x to make - 300 in length
        frmData = padarray(frmData, zero_pad,'post');              %pads zeros on pos x to make 300 in length
                        
        frmData = [frmData,uint8(zeros(size(frmData,1),zero_pad,3))];          %pads zeros on neg y to make - 300 in length
        frmData = [uint8(zeros(size(frmData,1),zero_pad,3)),frmData];     %#ok<*AGROW> %pads zeros on neg y to make  300 in length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rotate image
        rotData = imrotate(frmData, rotate_angle,'bilinear', 'crop');
        center_point = (384+(2*zero_pad))/2;
        com_frame_1 = cell2mat(cellfun(@(x) x(1,1:2),test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
        rot_com_x_y = cell2mat(arrayfun(@(x,y,z) rotation([x+zero_pad y+zero_pad],[center_point center_point],-z,'degrees'),com_frame_1(:,1),com_frame_1(:,2),rotate_angle,'UniformOutput',false));
        rot_com_x_y = rot_com_x_y - zero_pad;

        rotData(:,1:zero_pad,:) = [];        rotData(:,(end-(zero_pad+1)):end,:) = [];
        rotData(1:zero_pad,:,:) = [];        rotData(end-(zero_pad+1):end,:,:) = [];
                    
        axis equal
        hIm = image('Parent',gca,'CData',rotData);
        set(gca,'Xlim',[0 384],'Ylim',[0 384],'ydir','reverse','nextplot','add');
        set(gca,'Xtick', [],'Ytick', []);                
                
        plot(rot_com_x_y(1),rot_com_x_y(2),'r.','markersize',10);
        fly_size = test_data.fly_length{iterZ}/2;
        
        plot(rot_com_x_y(1)-fly_size,rot_com_x_y(2),'.','markersize',10,'color',rgb('orange'));     %tail point
        plot(rot_com_x_y(1)+fly_size,rot_com_x_y(2),'.','markersize',10,'color',rgb('green'));      %head point
                    
        try
            head_area = sum(rotData((round(rot_com_x_y(2))-5):1:(round(rot_com_x_y(2))+5),round(rot_com_x_y(1)+fly_size)-5:1:(round(rot_com_x_y(1)+fly_size)+5),:),3);
        catch
            head_area = 0;
        end
        try
            tail_area = sum(rotData((round(rot_com_x_y(2))-5):1:(round(rot_com_x_y(2))+5),round(rot_com_x_y(1)-fly_size)-5:1:(round(rot_com_x_y(1)-fly_size)+5),:),3);
        catch
            tail_area = 0;
        end
        
       drawnow(); 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%

    
    bot_pos_shift_pos = cellfun(@(x,y,z) x(y:z,:),test_data.bot_points_and_thetas,test_data.Start_Frame,test_data.frame_of_leg_push,'UniformOutput',false);
    bot_pos_jump_pos = cellfun(@(x,y,z)  x(y:z,:),test_data.bot_points_and_thetas,test_data.frame_of_leg_push,test_data.frame_of_take_off,'UniformOutput',false);

    leg_pos_shift_change = cell2mat(cellfun(@(x,y) [(x(end,1) - x(1,1)) ,(x(end,2) - x(1,2))]  ,bot_pos_shift_pos,'UniformOutput',false));
    leg_pos_jump_change = cell2mat(cellfun(@(x,y) [(y(end,1) - x(1,1)) ,(y(end,2) - x(1,2))]  ,bot_pos_shift_pos,bot_pos_jump_pos,'UniformOutput',false));
    org_azi_pos = cellfun(@(x) x(1,3).*180/pi ,bot_pos_shift_pos);
    
    rot_pos_leg_shift = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'degrees'),leg_pos_shift_change(:,1),leg_pos_shift_change(:,2),org_azi_pos,'UniformOutput',false));
    rot_pos_leg_jump = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'degrees'),leg_pos_jump_change(:,1),leg_pos_jump_change(:,2),org_azi_pos,'UniformOutput',false));
    
    figure
    set(gca,'nextplot','add');
    for iterZ = 1:length(leg_pos_shift_change)
        line([0 rot_pos_leg_shift(iterZ,1)],[0 rot_pos_leg_shift(iterZ,2)],'color',rgb('red'),'linewidth',.8);
        line([rot_pos_leg_shift(iterZ,1) rot_pos_leg_jump(iterZ,1)],[rot_pos_leg_shift(iterZ,2), rot_pos_leg_jump(iterZ,2)],'color',rgb('green'),'linewidth',.8);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    
    org_azi_pos = cellfun(@(x) x(1,3).*180/pi ,fly_bot_leg);
    leg_pos_change = cell2mat(cellfun(@(x,y) [(x(end,1) - x(1,1)) ,(x(end,2) - x(1,2))]  ,fly_bot_leg,'UniformOutput',false));
    leg_dir_change = cell2mat(cellfun(@(x,y) (x(end,3) - x(1,3))  ,fly_bot_leg,'UniformOutput',false));
    rot_pos_x_y = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'degrees'),leg_pos_change(:,1),leg_pos_change(:,2),org_azi_pos,'UniformOutput',false));
    
    figure; 
    set(gca,'nextplot','add')   
    scatter(rot_pos_x_y(:,1),rot_pos_x_y(:,2));
    set(gca,'ydir','reverse','Xlim',[-50 50],'Ylim',[-50 50])
    line([-50 50],[0 0],'color',rgb('black'),'linewidth',.5); 
    line([0 0],[-50 50],'color',rgb('black'),'linewidth',.5); 
    for iterZ = 1:length(leg_dir_change)
        u = cos(leg_dir_change(iterZ))*5;           v = -sin(leg_dir_change(iterZ))*5;
        quiver(rot_pos_x_y(iterZ,1),rot_pos_x_y(iterZ,2),u,v,0,'color',rgb('red'),'MaxHeadSize',2);
    end


    
    fly_bot_pos = cellfun(@(x,y,z) x(y:z,:),test_data.bot_points_and_thetas,test_data.frame_of_leg_push,test_data.frame_of_take_off,'UniformOutput',false);
    fly_top_pos = cellfun(@(x,y,z) x(y:z,:),test_data.top_points_and_thetas,test_data.frame_of_leg_push,test_data.frame_of_take_off,'UniformOutput',false);
    
    
    ele_angle = cellfun(@(x) (x(end,2) - x(1,2)) /(x(end,1) - x(1,1))  ,fly_top_pos);
    org_azi_pos = cellfun(@(x) x(1,3).*180/pi ,fly_bot_pos);
    pos_change = cell2mat(cellfun(@(x,y) [(x(end,1) - x(1,1)) ,(x(end,2) - x(1,2)) ,(y(end,2) - y(1,2))]  ,fly_bot_pos,fly_top_pos,'UniformOutput',false));      
    rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'degrees'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));
    rot_pos(:,2) = rot_pos(:,2) *-1;
    normalized_azi_esc = atan2(rot_pos(:,2),rot_pos(:,1));
    
    for iterZ = 1:length(leg_dir_change)
        u = cos(normalized_azi_esc(iterZ))*5;           v = -sin(normalized_azi_esc(iterZ))*5;
        quiver(rot_pos_x_y(iterZ,1),rot_pos_x_y(iterZ,2),u,v,0,'color',rgb('dark green'),'MaxHeadSize',2);
    end    
    


    


    leg_bot_pos = cellfun(@(x,y,z) x(y:z,:),test_data.bot_points_and_thetas,test_data.Start_Frame,test_data.frame_of_leg_push,'UniformOutput',false);
    leg_rot_pos = cellfun(@(x,y) rotation([x(:,1) x(:,2)],[0 0],y,'degrees'),leg_bot_pos,num2cell(org_azi_pos),'UniformOutput',false);
    leg_rot_pos = cellfun(@(x) x - x(1,:),leg_rot_pos,'UniformOutput',false);
    leg_rot_pos = cell2mat(cellfun(@(x) x(end,:),leg_rot_pos,'UniformOutput',false));
    
    figure; 
    subplot(2,2,1)
    scatter(leg_rot_pos(:,1),leg_rot_pos(:,2)); 
    line([-60 60],[0 0],'color',rgb('black'),'linewidth',.5); 
    line([0 0],[-60 60],'color',rgb('black'),'linewidth',.5);
    title(sprintf('Scatter distrubtion of center of mass movement\n between start frame and leg push frame'));
    
    curr_plot = subplot(2,2,2);
    [leg_alpha,leg_theta] = cart2pol(leg_rot_pos(:,1),leg_rot_pos(:,2));    
    leg_theta = leg_theta ./ 60;        %scales 0 to 1
    circle_scatter(leg_alpha,leg_theta,curr_plot);
    
%    circ_plot(leg_polar,'pat_special',[],(360/20),true,true,'linewidth',2,'color','r',.5);
    title(sprintf('Radial distrubtion of center of mass movement\n between start frame and leg push frame'));
    
%    subplot(2,2,3)
%    circ_plot(normalized_azi_esc,'pat_special',[],(360/20),true,true,'linewidth',2,'color','r');
%    title(sprintf('Radial distrubtion of take off direction (Azimuth)'));
    
        
    
    escape_ele = atan(abs(ele_angle(:,1)));         
    escape_ele = ((pi/2) - escape_ele) ./ (pi/2);  

    curr_plot = subplot(2,2,3);
    circle_scatter(normalized_azi_esc,escape_ele,curr_plot)
    
%    curr_plot = subplot(2,2,4);
%    circle_scatter((leg_alpha - normalized_azi_esc),(leg_theta - escape_ele),curr_plot);

    x_data = leg_rot_pos(:,1);
    y_data = leg_rot_pos(:,2);
    z_data = zeros(length(leg_rot_pos(:,1)),1);
    
    u = cos(normalized_azi_esc)*5;
    v = -sin(normalized_azi_esc)*5;
    w = sin(atan(abs(ele_angle(:,1)))) * 5;      % 50 is 90 deg
    
    figure
    set(gca,'nextplot','add');
    quiver3(x_data,y_data,z_data,u,v,w,1,'MaxHeadSize',1);
    quiver3(mean(x_data),mean(y_data),mean(z_data),mean(u)*25,mean(v)*25,mean(w),0,'MaxHeadSize',5,'color',rgb('red'),'linewidth',1.2);
    set(gca,'xlim',[-100 100],'Ylim',[-100 100],'Zlim',[0 10]);
    line([0 0],[-100 100],[0 0],'color',rgb('black'),'linewidth',.8);
    line([0 0],[0 0],[0 10],'color',rgb('black'),'linewidth',.8);
    line([-100 100],[0 0],[0 0],'color',rgb('black'),'linewidth',.8);
function dn_function_testing_video
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
    view = 'full';
%    view = 'top';
%    view = 'bottom';
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
%    dn_logic = cellfun(@(x) contains(x,'P4, P2'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P4, P6'),matching_data.new_name);
    dn_logic = cellfun(@(x) contains(x,'P1'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P11'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P2') & ~contains(x,'P4'),matching_data.new_name);
%    dn_logic = cellfun(@(x) contains(x,'P4') & ~contains(x,'P2') & ~contains(x,'P6'),matching_data.new_name);    
    test_data = vertcat(combine_data(dn_logic).Complete_usuable_data);
    test_data(cell2mat(test_data.Start_Frame) < 100,:) = [];   
    
    jump_logic = ~isnan(cell2mat(test_data.frame_of_leg_push));     %filters to jumpers only
    test_data = test_data(jump_logic,:);
    jump_delay = cellfun(@(x,y) (x-y)/6, test_data.frame_of_leg_push,test_data.Start_Frame);

    time_window_logic = (jump_delay > 25 & jump_delay <= 75);
    
    test_data = test_data(time_window_logic,:);     %filters jumpers to only between 50 and 100 ms 
           
    short_tracking = cellfun(@(x,y) length(x(:,1)) < y,test_data.bot_points_and_thetas,test_data.frame_of_take_off);
    test_data(short_tracking,:) = [];
    

%    figure    
    full_pathway =  cellfun(@(x,y) (x-y) / 6, test_data.frame_of_take_off, test_data.frame_of_wing_movement);
%    [full_pathway,sort_idx] = sort(full_pathway);
%    test_data = test_data(sort_idx,:);
    bot_orientation = cellfun(@(x,y) x(y,3), test_data.bot_points_and_thetas,test_data.Start_Frame);    
    [~,sort_idx] = sort(bot_orientation);
    test_data = test_data(sort_idx,:);
     
    
    color_map = [rgb('light red');rgb('light green');rgb('light blue')];
%    com_pos_movement = zeros(length(full_pathway),1);
    for iterZ = 1:length(full_pathway)
        subplottight(4,13,iterZ)
        
        [vidObjCell,frameReferenceMesh] = get_ref_mesh(test_data(iterZ,:));
        start_frame = test_data.Start_Frame{iterZ};
        leg_frame = test_data.frame_of_leg_push{iterZ};
        jump_frame = test_data.frame_of_take_off{iterZ};
        frame_offset = test_data.Adjusted_ROI{iterZ};
        frame_offset = frame_offset(7,2);

        start_frmData = read(vidObjCell{frameReferenceMesh(start_frame,3)},frameReferenceMesh(start_frame,2));
        start_frmData = enhance_img(start_frmData,frame_offset,view);
        
        leg_frmData = read(vidObjCell{frameReferenceMesh(leg_frame,3)},frameReferenceMesh(leg_frame,2));
        leg_frmData = enhance_img(leg_frmData,frame_offset,view);        
        
        jump_frmData = read(vidObjCell{frameReferenceMesh(jump_frame,3)},frameReferenceMesh(jump_frame,2));
        jump_frmData = enhance_img(jump_frmData,frame_offset,view);
        
        C = imfuse(start_frmData,leg_frmData,'montage');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   get angle and pad size
        rotate_angle = cellfun(@(x) x(start_frame ,3),test_data.bot_points_and_thetas(iterZ));
        rotate_angle = 360-(rotate_angle .* 180/pi);
        
        zero_pad = 300;
        center_point = (384+(2*zero_pad))/2;
        
        start_com_pos = cell2mat(cellfun(@(x) x(start_frame ,1:2),test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
        leg_push_com_pos = cell2mat(cellfun(@(x) x(leg_frame ,1:2),test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
        
        rot_com_s = cell2mat(arrayfun(@(x,y,z) rotation([x+zero_pad y+zero_pad],[center_point center_point],-z,'degrees'),start_com_pos(:,1),start_com_pos(:,2),rotate_angle,'UniformOutput',false));
        rot_com_s = rot_com_s - zero_pad;        
        
        rot_com_l = cell2mat(arrayfun(@(x,y,z) rotation([x+zero_pad y+zero_pad],[center_point center_point],-z,'degrees'),leg_push_com_pos(:,1),leg_push_com_pos(:,2),rotate_angle,'UniformOutput',false));
        rot_com_l = rot_com_l - zero_pad;        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pad the data
%zero padding for bottem view if rotating
    if strcmp(view,'bottom')
        zero_pad = 300;
%zero padding for top view (no rotation)
    else
        zero_pad = 400;
    end
    start_frmData = pad_image(start_frmData,zero_pad,view);
    leg_frmData = pad_image(leg_frmData,zero_pad,view);
    jump_frmData = pad_image(jump_frmData,zero_pad,view);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rotate image
        if strcmp(view,'bottom')
            rot_Start_Data = rotate_image(start_frmData, rotate_angle,zero_pad);
            rot_Leg_Data = rotate_image(leg_frmData, rotate_angle,zero_pad);
            rot_Jump_Data = rotate_image(jump_frmData, rotate_angle,zero_pad);

            display_data = rot_Start_Data;                 %red
            display_data(:,:,2) = rot_Leg_Data(:,:,2);     %green
            display_data(:,:,3) = rot_Jump_Data(:,:,3);    %blue
            image_lim = 384;
        else
            display_data = start_frmData;                 %red
            display_data(:,:,2) = leg_frmData(:,:,2);     %green
            display_data(:,:,3) = jump_frmData(:,:,3);    %blue
            image_lim = 400; 
        end
        
%        axis equal        
                 
%        image('Parent',gca,'CData',display_data);
        
%        set(gca,'Xlim',[0 image_lim],'Ylim',[0 image_lim],'ydir','reverse');
%        set(gca,'Xtick', [],'Ytick', [],'nextplot','add');
                  
        if strcmp(view,'top')
            line([0 image_lim],[300 300],'color',rgb('orange'),'linewidth',.8);     %top of prism
            bot_orientation = cell2mat(cellfun(@(x) x( [start_frame,leg_frame,jump_frame],:), test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
%            bot_orientation(:,1) = (bot_orientation(:,1) - bot_orientation(1,1)) + (image_lim/2);
            bot_orientation(:,2) = (bot_orientation(:,2) - bot_orientation(1,2)) + (image_lim - 50);
%            scatter(bot_orientation(:,1),bot_orientation(:,2))
            for iterL = 1:3
                u = cos(bot_orientation(iterL,3)).*50;              v = -sin(bot_orientation(iterL,3)).*50;
                quiver(bot_orientation(iterL,1),bot_orientation(iterL,2),u,v,0,'color',color_map(iterL,:),'MaxHeadSize',5);
            end
        end
%        com_pos_movement(iterZ) = sqrt(sum((rot_com_l - rot_com_s).^2));
%        text(15,325,sprintf('pathway :: %4.2f ms \n  COM move :: %4.4f pixels',full_pathway(iterZ),com_pos_movement(iterZ)),'color',rgb('white'));
%        text(15,325,sprintf('top orientation :: %4.4f pixels',bot_orientation(iterZ).*180/pi),'color',rgb('white'));
        drawnow(); 
        if strcmp(view,'full')
%            figure
            image('Parent',gca,'CData',display_data);
            set(gca,'Ydir','reverse','Xlim',[0 384],'ylim',[0 832],'nextplot','add');
            set(gca,'Xtick', [],'Ytick', []);
            bot_points = cell2mat(cellfun(@(x) x( [start_frame,leg_frame,jump_frame],:), test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
            scatter(bot_points(:,1),bot_points(:,2)+832-384);
            top_points = cell2mat(cellfun(@(x) x( [start_frame,leg_frame,jump_frame],:), test_data.top_points_and_thetas(iterZ),'UniformOutput',false));
            scatter(top_points(:,1),top_points(:,2));
            for iterL = 1:3
                line([top_points(iterL,1) bot_points(iterL,1)],[top_points(iterL,2) bot_points(iterL,2)+832-384]);
            end
        end
        axis equal
    end
end
function [vidObjCell,frameReferenceMesh] = get_ref_mesh(temp_data)
    video_name = temp_data.Properties.RowNames{1};
    vid_date = video_name(16:23);
    vid_run = video_name(1:23);
    data_path = '\\DM11\cardlab\Data_pez3000'; 
    
    fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[video_name,'.mp4']);
    fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[video_name,'_supplement.mp4']);
    

    vidObj_partail = VideoReader(fullPath_parital);
    try
        vidObj_supplement = VideoReader(fullPath_supplement);
        vidObjCell{1} = vidObj_partail;
        vidObjCell{2} = vidObj_supplement;
    catch
        vidObjCell{1} = vidObj_partail;
        vidObjCell{2} =  vidObj_partail;

    end
    vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>

    frameRefcutrate = double(temp_data.cutrate10th_frame_reference{1});
    frameReffullrate = double(temp_data.supplement_frame_reference{1});
    Y = (1:numel(frameRefcutrate));

    xi = (1:(vidFrames_partial*10));
    yi = repmat(Y,10,1);
    yi = yi(:);
    [~,xSuppl] = ismember(frameReffullrate,xi);
    objRefVec = ones(1,(vidFrames_partial*10));
    objRefVec(xSuppl) = 2;
    yi(xSuppl) = (1:length(frameReffullrate));

    frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
end
        
function frmData = enhance_img(frmData,offset,view)
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

    if strcmp(view,'bottom')      
        frmData = frmData(449:end,:,:);
    elseif strcmp(view,'top')
        frmData = frmData(1:offset,:,:);
    end
end
function frmData = pad_image(frmData,zero_pad,view)
    if strcmp(view,'bottom')
        frmData = padarray(frmData, zero_pad,'pre');                        %pads zeros on neg x to make - 300 in length
        frmData = padarray(frmData, zero_pad,'post');                       %pads zeros on pos x to make 300 in length

        frmData = [frmData,uint8(zeros(size(frmData,1),zero_pad,3))];       %pads zeros on neg y to make - 300 in length
        frmData = [uint8(zeros(size(frmData,1),zero_pad,3)),frmData];       %#ok<*AGROW> %pads zeros on neg y to make  300 in length
    elseif strcmp(view,'top')
        try
            frmData = padarray(frmData, 100,'post');                            %adds 100 pixels underneath        
            if size(frmData(:,:,1),1) > zero_pad                
                frmData = frmData((size(frmData(:,:,1),1)-(zero_pad-1)):end,:,:);   %trims to 400 pixels in y direction
            else
                pad_space = zero_pad - size(frmData(:,:,1),1);
                frmData = padarray(frmData, pad_space,'pre');                            %adds 100 pixels underneath        
            end
        catch
            warning('size mismatch')
        end
        
        x_pad_size = (zero_pad-size(frmData(:,:,1),2))/2;
        frmData = [frmData,uint8(zeros(size(frmData,1),x_pad_size,3))];       %pads right side of image
        frmData = [uint8(zeros(size(frmData,1),x_pad_size,3)),frmData];       %pads left side of image        
    end
end
function rotData = rotate_image(frmData, rotate_angle,zero_pad)
    rotData = imrotate(frmData, rotate_angle,'bilinear', 'crop');
%    center_point = (384+(2*zero_pad))/2;
%    com_frame_1 = cell2mat(cellfun(@(x) x(1,1:2),test_data.bot_points_and_thetas(iterZ),'UniformOutput',false));
%    rot_com_x_y = cell2mat(arrayfun(@(x,y,z) rotation([x+zero_pad y+zero_pad],[center_point center_point],-z,'degrees'),com_frame_1(:,1),com_frame_1(:,2),rotate_angle,'UniformOutput',false));
%    rot_com_x_y = rot_com_x_y - zero_pad;

    rotData(:,1:zero_pad,:) = [];        rotData(:,(end-(zero_pad+1)):end,:) = [];
    rotData(1:zero_pad,:,:) = [];        rotData(end-(zero_pad+1):end,:,:) = [];
end
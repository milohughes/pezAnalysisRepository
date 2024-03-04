repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))


test_exp_id = '0108000024880730';
vid_idx = 5;
data_path = '\\DM11\cardlab\Data_pez3000'; 
analysis_path = '\\DM11\cardlab\Data_pez3000_analyzed';
stimuli_info = load([analysis_path filesep test_exp_id filesep test_exp_id '_videoStatisticsMerged']);
stimuli_info = stimuli_info.(cell2mat(fieldnames(stimuli_info)));
assess_table = load([analysis_path filesep test_exp_id filesep test_exp_id '_rawDataAssessment']);
assess_table = assess_table.(cell2mat(fieldnames(assess_table)));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vidName = complete_matching.VideoName{vid_idx};
vid_date = vidName(16:23);
vid_run = vidName(1:23);
curr_stats = stimuli_info(vidName,:);
tracked_table = complete_matching.Track_Points{1};
adj_roi = assess_table(vidName,:).Adjusted_ROI{1};
adj_roi(:,2)  = adj_roi(:,2) - 449;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vidName,'.mp4']);
fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[vidName,'_supplement.mp4']);

vidObj_partail = VideoReader(fullPath_parital);
try
    vidObj_supplement = VideoReader(fullPath_supplement);
    vidObjCell{1} = vidObj_partail;
    vidObjCell{2} = vidObj_supplement;
catch
    vidObjCell{1} = vidObj_partail;
    vidObjCell{2} =  vidObj_partail;
end
vidWidth = vidObj_partail.Width;
vidHeight = vidObj_partail.Height;
vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>

frameRefcutrate = double(curr_stats.cutrate10th_frame_reference{1});
frameReffullrate = double(curr_stats.supplement_frame_reference{1});
Y = (1:numel(frameRefcutrate));
x = frameRefcutrate;
xi = (1:(vidFrames_partial*10));
yi = repmat(Y,10,1);
yi = yi(:);
[~,xSuppl] = ismember(frameReffullrate,xi);
objRefVec = ones(1,(vidFrames_partial*10));
objRefVec(xSuppl) = 2;
yi(xSuppl) = (1:length(frameReffullrate));

if length(xi) ~= length(yi)
    setnextvid
end
frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matching_images = frameReferenceMesh(ismember(frameReferenceMesh(:,1),tracked_table.Frame_Number),:);

vidObj_p = VideoReader(fullPath_parital);
vidObj_s = VideoReader(fullPath_supplement);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_index = round(linspace(1,length(matching_images),9));
figure
Left_leg_InDegrees = zeros(length(test_index),1);
Right_leg_InDegrees = zeros(length(test_index),1);

for iterI = 1:9
    leg_points = zeros(size(matching_images,1),4);
    left_leg = [complete_matching.Track_Points{vid_idx}.Left_Leg_x(test_index(iterI)),complete_matching.Track_Points{vid_idx}.Left_Leg_y(test_index(iterI))]; 
    right_leg = [complete_matching.Track_Points{vid_idx}.Right_Leg_x(test_index(iterI)),complete_matching.Track_Points{vid_idx}.Right_Leg_y(test_index(iterI))]; 
    center_pos = [complete_matching.Track_Points{vid_idx}.Center_x(test_index(iterI)),complete_matching.Track_Points{vid_idx}.Center_y(test_index(iterI))]; 
    
    frame_data = matching_images(test_index(iterI),:);
    frmData = read(vidObjCell{frame_data(:,3)},frame_data(:,2));    
    frmData = frmData(449:end,:,:);

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

    leg_midpoint = [(left_leg(1) + right_leg(1))/2,(left_leg(2) + right_leg(2))/2];        
    leg_lineseg_angle = atan2d((right_leg(2) - left_leg(2)),(right_leg(1) - left_leg(1)));
    if leg_lineseg_angle < 0
        leg_lineseg_angle = leg_lineseg_angle + 360;
    end
    subplottight(3,3,iterI)
    display_str = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iterZ = 1:4
        set(gca,'nextplot','add');
        hIm = image('Parent',gca,'CData',frmData);
        
        if iterZ == 1
            
%            x_lim = get(hIm,'Xdata');        y_lim = get(hIm,'Ydata');
%            line([x_lim(1) x_lim(2)],[(y_lim(1) + y_lim(2))/2 (y_lim(1) + y_lim(2))/2],'color',rgb('white'),'linewidth',.8);
%            line([(x_lim(1) + x_lim(2))/2 (y_lim(1) + y_lim(2))/2],[y_lim(1) y_lim(2)],'color',rgb('white'),'linewidth',.8);
        elseif iterZ == 2
            set(hIm,'Xdata',[x_lim(1)-leg_midpoint(1) x_lim(2)-leg_midpoint(1)]);
            set(hIm,'Ydata',[y_lim(1)-leg_midpoint(2) y_lim(2)-leg_midpoint(2)]);
            
            left_leg = left_leg - leg_midpoint;
            right_leg = right_leg - leg_midpoint;
            center_pos = center_pos - leg_midpoint;
            leg_midpoint = leg_midpoint - leg_midpoint;
            
            x_lim = get(hIm,'Xdata');        y_lim = get(hIm,'Ydata');
 %           line([x_lim(1) x_lim(2)],[0 0],'color',rgb('white'),'linewidth',.8);
 %           line([0 0],[y_lim(1) y_lim(2)],'color',rgb('white'),'linewidth',.8);
            save_x = x_lim;
            save_y = y_lim;
        elseif iterZ == 3
            rotate_angle = (leg_lineseg_angle-180)+90;

            y_top =  round(abs(-300-y_lim(1)));
            y_bot =   round(abs(300-y_lim(2)));
            frmData = padarray(frmData, round(abs(-300-y_lim(1))),'pre');              %pads zeros on neg x to make - 300 in length
            frmData = padarray(frmData, round(abs(300-y_lim(2))),'post');              %pads zeros on pos x to make 300 in length
            
            x_front = round(abs(-300-x_lim(1)));
            x_back = round(300-x_lim(2));
            
            frmData = [frmData,uint8(zeros(size(frmData,1),round(300-x_lim(2)),3))];          %pads zeros on neg y to make - 300 in length
            frmData = [uint8(zeros(size(frmData,1),round(abs(-300-x_lim(1))),3)),frmData];     %#ok<*AGROW> %pads zeros on neg y to make  300 in length
            
            
            left_leg(1) = (left_leg(1) - x_lim(1)) + x_front;               right_leg(1) = (right_leg(1) - x_lim(1)) + x_front;
            center_pos(1) = (center_pos(1) - x_lim(1)) + x_front;           leg_midpoint(1) = (leg_midpoint(1) - x_lim(1)) + x_front;
            
            left_leg(2) = (left_leg(2) + y_lim(2) +  y_bot);               right_leg(2) = (right_leg(2) + y_lim(2) +  y_bot);
            center_pos(2) = (center_pos(2) + y_lim(2) +  y_bot);           leg_midpoint(2) = (leg_midpoint(2) + y_lim(2) +  y_bot);
            
            %frmData is 601 X 601, padded so that 0,0 is rotated point of
            %interest
            
            hIm = image('Parent',gca,'CData',frmData);
%            line([0 600],[300 300],'color',rgb('white'),'linewidth',.8);
%            line([300 300],[00 600],'color',rgb('white'),'linewidth',.8);
        elseif iterZ == 4
            
            rotData = imrotate(frmData, rotate_angle,'bilinear', 'crop');

            rotData(:,1:x_front,:) = [];        rotData(:,(end-(x_back+1)):end,:) = [];
            rotData(1:y_top,:,:) = [];          rotData(end-(y_bot+1):end,:,:) = [];
            
            
            hIm = image('Parent',gca,'CData',rotData);                        
            set(hIm,'Xdata',save_x,'Ydata',save_y);
            
            
            
%             x_lim = xlim - mean(x_lim);
%             y_lim = ylim - mean(y_lim);
%             set(hIm,'Xdata',x_lim,'Ydata',y_lim);
%             left_leg(1) = left_leg(1) - leg_midpoint(1) - x_front;
%             right_leg(1) = right_leg(1) - leg_midpoint(1) - x_front;
%             center_pos(1) = center_pos(1) - leg_midpoint(1) - x_front;
%             leg_midpoint(1) = leg_midpoint(1) - leg_midpoint(1) - x_front;
            
            
            
            left_leg = rotation(left_leg-300,[0 0],-rotate_angle,'degrees');
            right_leg = rotation(right_leg-300,[0 0],-rotate_angle,'degrees');
            center_pos = rotation(center_pos-300,[0 0],-rotate_angle,'degrees');
            leg_midpoint = rotation(leg_midpoint-300,[0 0],-rotate_angle,'degrees');
            
            x_lim = get(hIm,'Xdata');        y_lim = get(hIm,'Ydata');            
            
            
            line([x_lim(1) x_lim(2)],[0 0],'color',rgb('white'),'linewidth',.8,'parent',gca);
            line([0 0],[y_lim(1) y_lim(2)],'color',rgb('white'),'linewidth',.8,'parent',gca);            
            center_perp_pt = [center_pos,0];
            
            Left_leg_InDegrees(iterI) = abs(atand(((left_leg(1)-center_perp_pt(1)) / center_pos(2))));
            Right_leg_InDegrees(iterI) = abs(atand(((right_leg(1)-center_perp_pt(1)) / center_pos(2))));
            if center_pos(1,2) < 0 %com is behind legs take outside angle
                Left_leg_InDegrees(iterI) = 180 - Left_leg_InDegrees(iterI);
                Right_leg_InDegrees(iterI) = 180 - Right_leg_InDegrees(iterI);
            end
%            display_str = sprintf('Time :: %4.0fms\nLeft Leg Angle :: %4.4f degrees\nRight Leg Angle :: %4.4f degrees \nTotal Angle %4.4f degrees',...
%                (test_index(iterI)-1)*5,Left_leg_InDegrees(iterI),Right_leg_InDegrees(iterI),Left_leg_InDegrees(iterI)+Right_leg_InDegrees(iterI));
            
        elseif iterZ > 3
            continue
        end
        plot(left_leg(1),left_leg(2),'b.','MarkerSize',25,'color',rgb('light blue'));
        plot(right_leg(1),right_leg(2),'g.','MarkerSize',25);
        plot(center_pos(1),center_pos(2),'r.','MarkerSize',25);
        plot(leg_midpoint(1),leg_midpoint(2),'color',rgb('orange'),'Marker','*','MarkerSize',10);
%        line([left_leg(1) right_leg(1)],[left_leg(2) right_leg(2)],'color',rgb('purple'),'linewidth',.8)
        
        line([left_leg(1) center_pos(1)],[left_leg(2) center_pos(2)],'color',rgb('light blue'),'linewidth',.8)
        line([right_leg(1) center_pos(1)],[right_leg(2) center_pos(2)],'color',rgb('green'),'linewidth',.8)

        x_lim = get(hIm,'Xdata');        y_lim = get(hIm,'Ydata');
        set(gca,'Ydir','reverse','Xlim',x_lim,'Ylim',y_lim,'nextplot','add','Xtick',[],'Ytick',[]);
        line([x_lim(1) x_lim(1)],y_lim,'color',rgb('orange'),'linewidth',2)
        line([x_lim(2) x_lim(2)],y_lim,'color',rgb('orange'),'linewidth',2)
        line(x_lim,[y_lim(1) y_lim(1)],'color',rgb('orange'),'linewidth',2)
        line(x_lim,[y_lim(2) y_lim(2)],'color',rgb('orange'),'linewidth',2)
        if ~isempty(display_str)
            text(x_lim(1)+10,y_lim(1)+50,display_str,'HorizontalAlignment','left','Interpreter','none','color',rgb('light red'),'fontsize',15);
        end
    end
end
function h = subplottight(n,m,i)
    [c,r] = ind2sub([m n], i);
    ax = subplot('Position', [(c-1)/m, 1-(r)/n, 1/m, 1/n]);
    if(nargout > 0)
      h = ax;
    end
end
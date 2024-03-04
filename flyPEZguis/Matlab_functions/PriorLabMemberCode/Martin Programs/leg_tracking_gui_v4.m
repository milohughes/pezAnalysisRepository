function leg_tracking_gui_v4
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gets pathing info
repositoryDir_1 = fileparts(fileparts(fileparts(mfilename('fullpath'))));
repositoryDir_2 = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir_1,'Support_Programs'))
addpath(fullfile(repositoryDir_2,'Analysis Programs'))


%filter_martin_data = true;
filter_martin_data = false;

analysis_path = '\\DM11\cardlab\Data_pez3000_analyzed';
data_path = '\\DM11\cardlab\Data_pez3000';

old_leg_path = '\\DM11\cardlab\Leg_Tracking_Data\Martin_leg_tracking_filter_v2.mat';
%new_leg_path = '\\DM11\cardlab\Leg_Tracking_Data\Martin_leg_tracking_filter_v3.mat';
new_leg_path = '\\DM11\cardlab\Leg_Tracking_Data\Martin_leg_tracking_looming.mat';
if filter_martin_data == true
%    martin_file = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\chr_vids_for_annotation_v3.mat');
    martin_file = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\filtered_loom_vids_for_annotation_v2.mat');
else
    martin_file = load('Z:\Martin\flypez_analysis\old_analysis\LC4DN_manuscript_grid_videos\filtered_chr_vids_for_annotation_v2.mat');
end
martin_file = martin_file.(cell2mat(fieldnames(martin_file))); %cell


save_leg_path = old_leg_path;    
if exist(new_leg_path,'file') && filter_martin_data == true
    all_save_data = load(new_leg_path);
    all_save_data = all_save_data.all_save_data;
    save_leg_path = new_leg_path;
elseif ~exist(new_leg_path,'file') && filter_martin_data == true
    all_save_data = load(old_leg_path);
    all_save_data = all_save_data.all_save_data;
    save_leg_path = new_leg_path;
elseif exist(old_leg_path,'file') && filter_martin_data == false
    all_save_data = load(old_leg_path);
    all_save_data = all_save_data.all_save_data;
else
    all_save_data = [];
end

%filters all save data file to same size as martins list;
all_save_data = all_save_data(ismember(all_save_data.Properties.RowNames,martin_file),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets background
screen2use = 1;         % in multi screen setup, this determines which screen to be used
screen2cvr = 0.8;       % portion of the screen to cover

monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);

%%%%% Figure and children %%%%%
backColor = [0 0 0.2];
FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
    (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
hFigA = figure('NumberTitle','off','Name','Leg Tracker Gui - by PMB',...
    'menubar','none','units','pix','Color',backColor,...
    'pos',FigPos,'colormap',gray(256));
set(hFigA,'WindowButtonDownFcn',@FigClickCallback);
set(hFigA,'WindowButtonUpFcn',@FigReleaseCallback);
set(hFigA,'WindowScrollWheelFcn',@FigWheelCallback);
% control panel
hPanA = uipanel('Position',[.05 .8 .9 .185],'Visible','On');
hPanB = uipanel('Position',[.55 .075 .40 .7],'Visible','On');
hPanC = uipanel('Position',[.05 .01 .45 .06],'Visible','On');
hTextD = uicontrol(hFigA,'Style','text','string','Frame :: ','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'units','normalized','Position',[.05 .75 .45 .025],'Visible','On','fontsize',15);

set(hFigA,'CloseRequestFcn',@myCloseFun)
hTable = uitable('Parent',hPanB,'units','normalized',...
    'position',[0 .5 1 .5],'backgroundcolor',rgb('light gray'));
set(hTable,'CellSelectionCallback',@change_frame_entry);
% jScroll = findjobj(hTable);
% jTable = jScroll.getViewport.getView;
hAxesP = axes('Parent',hPanB,'Position',[.0 .0 1 .5],...
    'color',rgb('white'),'tickdir','in','nextplot','replacechildren','visible','on','YDir','reverse');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m_display = uimenu(hFigA,'Label','Display Options');
    m_display_opts_1 = uimenu(m_display,'Label','Show All Data','checked','on','Callback',@change_display);           %default
    m_display_opts_2 = uimenu(m_display,'Label','Hide Tracked Data','checked','off','Callback',@change_display);
    m_display_opts_3 = uimenu(m_display,'Label','Show Tracked Data Only','checked','off','Callback',@change_display);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame and graph axes
hAxesA = axes('Parent',hFigA,'Position',[.05 .025 .45 .75],...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
set(hAxesA,'DataAspectRatio',[1 1 1])
set(hAxesA,'DrawMode','fast')
set(hAxesA,'units','pix')
axesApos = get(hAxesA,'position');
set(hAxesA,'units','normalized')

button_width = (1- (.01*4))/3;
start_right_front = uicontrol(hPanC,'Style','pushbutton','string','Front Right Leg Position ::','Units','normalized','position',[.01 .5 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on');
start_right_mid = uicontrol(hPanC,'Style','pushbutton','string','Mid Right Leg Position ::','Units','normalized','position',[(.02+ button_width) .5 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on');
start_right_hind = uicontrol(hPanC,'Style','pushbutton','string','Hind Right Leg Position ::','Units','normalized','position',[(.03+button_width*2) .5 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on');
 
start_left_front = uicontrol(hPanC,'Style','pushbutton','string','Front Left Leg Position ::','Units','normalized','position',[.01 .01 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on'); 
start_left_mid = uicontrol(hPanC,'Style','pushbutton','string','Mid Left Leg Position ::','Units','normalized','position',[(.02+ button_width) .01 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on');   
start_left_hind = uicontrol(hPanC,'Style','pushbutton','string','Hind Left Leg Position ::','Units','normalized','position',[(.03+button_width*2) .01 button_width .45],...
     'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'callback',@select_leg,'enable','on'); 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame reset button
frmResetPos = get(hAxesA,'Position');
frmResetPos = frmResetPos.*[1.3 1.1 0.5 0.02];
hCreset = uicontrol('style','pushbutton','units','normalized',...
    'string','Reset Frame','Position',frmResetPos,'fontunits','normalized','fontsize',.4638,...
    'parent',hPanA,'callback',@resetFigCallback,'visible','on','Enable','on');

set(hCreset,'position',[.65,.01,.34,.15]) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Labels
 guiStrCell = {'Select User','','','',''};
 guiStrCt = numel(guiStrCell);
 compoStrCell = cat(1,guiStrCell(:));
 hTlabels = zeros(guiStrCt,1);
 hTedit = zeros(guiStrCt,1);
% 
 for iterS = 1:guiStrCt
     hTlabels(iterS) = uicontrol(hPanA,'Style','text','string',[compoStrCell{iterS} ':'],'Units','normalized',...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000);
     hTedit(iterS) = uicontrol(hPanA,'Style','popup','string','...','Units','normalized','HorizontalAlignment','left',...
         'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000);
 end
 set(hTlabels(1),'position',[.01 .8 .2 .15])
 set(hTedit(1),'position',[.22 .77 .4 .18])
 for iterPA = 1:guiStrCt
    set(hTlabels(iterPA),'position',[.01 1-(.2*iterPA) .2 .15])
    set(hTedit(iterPA),'position',[.22 1-(.2*iterPA)-.03 .4 .18])

 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% prev/next video pushbuttons
prevFilePos = [.65 .8 .125 .15];
nextFilePos = [.85 .8 .125 .15];
hCprevVid = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Prev Video',...
    'Position',prevFilePos - [0 .2 0 0],'fontunits','normalized','fontsize', 0.4598,'callback',@setprevvid,'Enable','off');
hCnextVid = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Next Video','Position',nextFilePos - [0 .2 0 0],'fontunits','normalized','fontsize', 0.4598,'callback',@setnextvid,'Enable','off');
hCprevFile = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Prev Dataset','Position',prevFilePos,'fontunits','normalized','fontsize', 0.4598,'callback',@pfileCallback,'Enable','off');
hCnextFile = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Next Dataset','Position',nextFilePos,'fontunits','normalized','fontsize', 0.4598,'callback',@nfileCallback,'Enable','off');
iconshade = 0.1;
makeFolderIcon(hCnextFile,0.8,'next',iconshade)
makeFolderIcon(hCnextVid,0.8,'next',iconshade)
makeFolderIcon(hCprevFile,0.8,'prev',iconshade)
makeFolderIcon(hCprevVid,0.8,'prev',iconshade)

hStim_pos = uicontrol(hPanA,'style','text','units','normalized','HorizontalAlignment','left',...
    'string','Stimuli Position Relative to Fly ::  ','Position',[.65 .4 .250 .15],'fontunits','normalized','fontsize', 0.4598);

hPartial = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Partial Fly Shown','Position',[.65 .2 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@toggle_quality);

hBadTrack = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Tracking Wrong','Position',[.77 .2 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@toggle_quality);

hLegVis = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Legs Not Visable','Position',[.89 .2 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@toggle_quality);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables
hIm_1 = [];  
stim_start_frame = [];         leg_push_frame = [];
disp_hdl = [];          display_toggle = 'All';
stim_range = [0 180];

exp_list = [];              vid_list = [];              exp_id = [];                vidName = [];                   vidOps = [];
vidHeight = [];             vidWidth = [];              vidFrames_partial = [];     

zoomMag = 1;                clickPos = [];              centerIm = [];              video_index = 1;
vidOff = 0;                 vidObjCell = cell(2,1);     frameReferenceMesh = [];    
frameRefcutrate = [];       frameReffullrate = [];      
track_data = [];            Video_Quality = {'Good'};
frm_remap = [];             saved_data = [];            test_data = [];             
filt_table_list = [];
master_table = [];


frame_index = [];           duration_seconds = 200;         time_index = 0:5:duration_seconds;
%frame_index = [];           duration_seconds = 500;          time_index = 0:10:duration_seconds;
frame_count = length(time_index);
vid_pos_vect = 1:1:frame_count;

btnC = [.8 .8 .8];
%click_count = (6*2)+1;
htmlcolor = sprintf('rgb(%d,%d,%d)', round(btnC*255));
%tableData = repmat(cell(1,click_count),frame_count,1);
tableData = struct();
current_video = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selct video options
    function load_options(~,~)
        reset_video
        turn_flags_off
        set(hTedit,'Value',1);
        set(hCnextFile,'string','Next Experiment');
        set(hCprevFile,'string','Prev Experiment');
        set(hTedit(1),'String', 'Martin');
        set(hTedit(2),'String','Multiple Collections');
        set(hTlabels(2),'String','Select Collection:');
        
        set(hTedit(3),'String','In Focus And Center');
        set(hTlabels(3),'String','Select  Group:');
        set(hCnextFile,'enable','on');
        set(hCprevFile,'enable','on');
        load_files = martin_file;
        load_files = cellfun(@(x) x(29:44),load_files,'UniformOutput',false);
        load_files = unique(load_files);
        set(hTlabels(4),'String','Select Experiment_ID:');
        set(hTedit(4),'String',['...';load_files],'Callback', @populate_vid_list);
    end
    function populate_vid_list(hObj,~)
        reset_video
        set(hTedit(5),'value',1);
        vid_val = get(hObj,'Value');
        exp_list = get(hObj,'String');
        exp_id = exp_list{vid_val};

        test_data =  Experiment_ID(exp_id);
        test_data.temp_range = [22.5,24.0];
        test_data.humidity_cut_off = 40;
        test_data.remove_low = false;
        test_data.low_count = 0;
        test_data.azi_off = 180;

        test_data.load_data;
        test_data.make_tables;
        master_table = [test_data.Complete_usuable_data;test_data.Failed_Location;test_data.Pez_Issues;test_data.Multi_Blank];
        filt_table_list = master_table;
                
        vid_list = master_table.Properties.RowNames;
        
        set(hTlabels(5),'String','Select Video:');

        filter_vid_list
    end
    function filter_vid_list(~,~)
        master_table = filt_table_list;       %restore master list for filtering
        if isempty(vid_list)
            set(hTedit(5),'value',1,'String','...','enable','off')
            nfileCallback
        end
        martin_list = martin_file;
        vid_list = vid_list(ismember(vid_list,martin_list));        
            
        switch display_toggle 
            case 'All'
                %no filtering
            case 'Hide_Track'
                vid_list(ismember(vid_list,leg_data.Properties.RowNames)) = [];
            case 'Show_Track'
                vid_list = vid_list(ismember(vid_list,leg_data.Properties.RowNames));
        end
        master_table = master_table(vid_list,:);

        org_list_index = cellfun(@(y) sprintf('%04s',num2str(y)),num2cell(1:1:height(master_table))','UniformOutput',false);
        org_list_index = org_list_index(ismember(master_table.Properties.RowNames,vid_list));
        
        index = cellfun(@(x) strfind(x,'expt'),vid_list);
        if ~isempty(vid_list)
            short_list = cellfun(@(x,y,z) sprintf('%s%04s_orgvid%04s',x(index:(index+23)),num2str(y),num2str(z)),vid_list,num2cell(1:1:length(index))',org_list_index,'UniformOutput',false);        
%            set(hTedit(5),'value',1,'String',vid_list,'Callback',@select_video,'enable','on');            
            set(hTedit(5),'value',1,'String',short_list,'Callback',@select_video,'enable','on');
            select_video(hTedit(5))
        else
            set(hTedit(5),'value',1,'String','...','enable','off')
            nfileCallback
        end
    end
    function select_video(hObj,~)
        video_index = get(hObj,'Value');
        set(hCnextVid,'Enable','on');
        set(hCprevVid,'Enable','on');
        set(hLegVis,'Enable','on');
        set(hBadTrack,'Enable','on');
        set(hPartial,'Enable','on');
        set(hCreset,'Enable','on');
        delete(get(hAxesP,'Children'));
        
        vidOps = vid_list;
        vidOps = circshift(vidOps,-vidOff+1);
        vidOff = 1;
        vidName = vid_list(video_index,:);
        videoLoad
    end
    function change_display(hObj,~)
        set(m_display_opts_1,'checked','off')
        set(m_display_opts_2,'checked','off')
        set(m_display_opts_3,'checked','off')
        switch hObj
            case m_display_opts_1 
                display_toggle = 'All';
                set(m_display_opts_1,'checked','on')
            case m_display_opts_2
                display_toggle = 'Hide_Track';
                set(m_display_opts_2,'checked','on')
            case m_display_opts_3             
                display_toggle = 'Show_Track';
                set(m_display_opts_3,'checked','on')
        end
        filter_vid_list;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load and parsing functions
    function videoLoad
        delete(get(hAxesA,'Children'));
        set(hAxesA,'NextPlot','Add');
        vid_name = vidName{1};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);
        
        vid_pos_vect = 1:1:frame_count;

        current_video = master_table(vidName,:);
        leg_push_frame = cell2mat(current_video.frame_of_leg_push);
        leg_push_frame(arrayfun(@(x) isnan(x) ,leg_push_frame)) = current_video(arrayfun(@(x) isnan(x) ,leg_push_frame),:).trkEnd;

        if ~isempty(all_save_data)
            saved_logic = ismember(cellstr(vertcat(all_save_data.Properties.RowNames)),current_video.Properties.RowNames);
            if sum(saved_logic) == 0
%                tableData = repmat(cell(1,click_count),frame_count,1);
                tableData = struct();
            else            
                matching_data = all_save_data(saved_logic,:); 
                matching_data = fix_cell_error(matching_data);
                tableData = matching_data.Click_Points;
                switch matching_data.VidQuality{1}
                    case {'Partial Fly Shown'}
                         toggle_quality(hPartial);
                    case  {'Tracking Off'}
                         toggle_quality(hBadTrack);
                    case  {'Legs Hidden From View'}
                         toggle_quality(hLegVis);
                end
            end
        end
        
        stim_start_frame = cell2mat(current_video.Start_Frame);
        try
            track_data = load([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v13' filesep vidName{1} '_flyAnalyzer3000_v13_data']);
            track_data = track_data.saveobj;            
                        
            vid_stats = load([analysis_path filesep exp_id filesep exp_id '_videoStatisticsMerged']);
            vid_stats = dataset2table(vid_stats.videoStatisticsMerged(track_data.Properties.RowNames,:));
            track_data = [track_data,vid_stats];                        
        catch
            track_data = [];
        end
        frame_index = stim_start_frame:(5*6):(stim_start_frame+(duration_seconds*6));      %every 100 ms after start in 5 ms interval
        frame_index = frame_index(frame_index <= leg_push_frame);
        vid_pos_vect = 1:1:length(frame_index);
        if isempty(fieldnames(tableData))
            tableData.Frame_Index = frame_index;
            tableData.Left_Leg_Front = nan(length(frame_index),2);
            tableData.Left_Leg_Mid = nan(length(frame_index),2);
            tableData.Left_Leg_Hind = nan(length(frame_index),2);
            tableData.Right_Leg_Front = nan(length(frame_index),2);
            tableData.Right_Leg_Mid = nan(length(frame_index),2);
            tableData.Right_Leg_Hind = nan(length(frame_index),2);
            tableData.Center_of_Mass = nan(length(frame_index),2);
        end
        
        if size(tableData.Frame_Index,1) > length(frame_index)
            tableData.Frame_Index = frame_index;
        end
%         if size(tableData.Left_Leg_Front,1) > length(frame_index)
%             tableData.Left_Leg_Front = nan(length(frame_index),2);
%         end
%         if size(tableData.Left_Leg_Mid,1) > length(frame_index)
%             tableData.Left_Leg_Mid = nan(length(frame_index),2);
%         end
%         if size(tableData.Left_Leg_Hind,1) > length(frame_index)
%             tableData.Left_Leg_Hind = nan(length(frame_index),2);
%         end
%         if size(tableData.Right_Leg_Front,1) > length(frame_index)
%             tableData.Right_Leg_Front = nan(length(frame_index),2);
%         end
%         if size(tableData.Right_Leg_Mid,1) > length(frame_index)
%             tableData.Right_Leg_Mid = nan(length(frame_index),2);
%         end
%         if size(tableData.Right_Leg_Hind,1) > length(frame_index)
%             tableData.Right_Leg_Hind = nan(length(frame_index),2);
%         end
%         if size(tableData.Center_of_Mass,1) > length(frame_index)
%             tableData.Center_of_Mass = nan(length(frame_index),2);
%         end
        
%        tableData.Frame_Index = frame_index;
                        
        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vidName{1},'.mp4']);
        fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[vidName{1},'_supplement.mp4']);
        
        if ~exist(fullPath_parital,'file')
            setnextvid
        end
        
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
        vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>
        vidHeight = 384;
        
        frameRefcutrate = double(current_video.cutrate10th_frame_reference{1});
        frameReffullrate = double(current_video.supplement_frame_reference{1});
        Y = (1:numel(frameRefcutrate));
        xi = (1:(vidFrames_partial*10));
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*10));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
        show_video(1);
        summary_table;
    end
    function matching_data = fix_cell_error(matching_data)
        if iscell(matching_data.Click_Points.Left_Leg_Mid)
            matching_data.Click_Points.Left_Leg_Mid(sum(cellfun(@(x) isempty(x), matching_data.Click_Points.Left_Leg_Mid),2) > 0,:) = {nan};
            matching_data.Click_Points.Left_Leg_Mid = cell2mat(matching_data.Click_Points.Left_Leg_Mid);
        end
        if iscell(matching_data.Click_Points.Right_Leg_Mid)
            matching_data.Click_Points.Right_Leg_Mid(sum(cellfun(@(x) isempty(x), matching_data.Click_Points.Right_Leg_Mid),2) > 0,:) = {nan};
            matching_data.Click_Points.Right_Leg_Mid = cell2mat(matching_data.Click_Points.Right_Leg_Mid);
        end        
        if iscell(matching_data.Click_Points.Center_of_Mass)
            matching_data.Click_Points.Center_of_Mass(sum(cellfun(@(x) isempty(x), matching_data.Click_Points.Center_of_Mass),2) > 0,:) = {nan};
            matching_data.Click_Points.Center_of_Mass = cell2mat(matching_data.Click_Points.Center_of_Mass);
        end
    end
        
    function draw_roi(~,~)
        adj_roi = current_video.Adjusted_ROI;
        if isempty(adj_roi)
            roi = cell2mat(track_data.roi);
        else
            roi = cell2mat(adj_roi);
        end
        line([roi(1,1) roi(2,1)],[roi(1,2)-449 roi(2,2)-449],'parent',hAxesA,'Tag','roi line');
        line([roi(3,1) roi(3,1)],[roi(1,2)-449 roi(2,2)-449],'parent',hAxesA,'Tag','roi line');
        line([roi(1,1) roi(3,1)],[roi(1,2)-449 roi(1,2)-449],'parent',hAxesA,'Tag','roi line');
        line([roi(1,1) roi(3,1)],[roi(2,2)-449 roi(2,2)-449],'parent',hAxesA,'Tag','roi line');
    end
    function show_video(~,~)
        frame_data = frameReferenceMesh(frameReferenceMesh(:,1) == frame_index(vid_pos_vect(1)),:);       
        frmData = read(vidObjCell{frame_data(:,3)},frame_data(:,2));
        
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
        frmData = frmData(448:end,:,:);
        hIm_1 = image('Parent',hAxesA,'CData',frmData);
        set(hIm_1,'ButtonDownFcn',@ImageClickCallback);
        
        for iterD = 1:6
            disp_hdl(iterD) = plot(0,0,'parent',hAxesA);
        end
        
        
        draw_roi;
           
        videoDisp(hAxesA,frame_index(vid_pos_vect(1)))
        plot_tracking_data(hAxesA)
%        resetFigCallback
    end
    function plot_tracking_data(curr_axis)
        error_flag = 0;
        bot_vector = track_data.bot_points_and_thetas{1};
        fly_len = track_data.fly_length{1};
        
        try
            pos_vect = bot_vector(frame_index(vid_pos_vect(1)),:);
        catch
            error_flag = 1;
        end
        if error_flag == 0
            set(curr_axis,'nextplot','add')
            plot(pos_vect(1),pos_vect(2),'r.','parent',curr_axis,'markersize',20);

            h_quiv = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',curr_axis,'Visible','off');
            u = cos(pos_vect(:,3))*fly_len/2;
            v = -sin(pos_vect(:,3))*fly_len/2;
            set(h_quiv,'XData',pos_vect(1),'YData',pos_vect(2),'MaxHeadSize',5,'LineWidth',.8,'AutoScaleFactor',1,'color',rgb('red'),'UData',u,'VData',v,'visible','on');

            plot(pos_vect(1)+u,pos_vect(2)+v,'g.','parent',curr_axis,'markersize',20);
            plot(pos_vect(1)-u,pos_vect(2)-v,'.','parent',curr_axis,'markersize',20,'color',rgb('orange'));

            fly_pos = bot_vector(stim_start_frame,3)*180/pi;
            stim_pos = (track_data.stimulus_azimuth{1}*180/pi)+360;

            offset = stim_pos - fly_pos;
            if offset > 180
                offset = 360-offset;
            elseif offset < -180
                offset = offset + 360;
            end

            set(hStim_pos,'string',sprintf('Stimuli Position Relative to Fly :: %4.2f degrees',offset));
            saved_data.Stimuli_Position = {offset};
            if abs(offset) < stim_range(1) || abs(offset) > stim_range(2)
                setnextvid  %skip_video
            end
        end
        if error_flag == 1                              %if no tracking use Nans
            tableData.Center_of_Mass(vid_pos_vect(1),:) = nan(1,2);
        else
            tableData.Center_of_Mass(vid_pos_vect(1),:) = pos_vect(1:2);
        end
        summary_table;
    end
    function toggle_quality(hObj,~)
        switch hObj
            case hPartial
                if strcmp(Video_Quality,{'Partial Fly Shown'})
                    Video_Quality = {'Good'};
                else
                    Video_Quality = {'Partial Fly Shown'};
                end
            case hBadTrack
                if strcmp(Video_Quality,{'Tracking Off'})
                    Video_Quality = {'Good'};
                else
                    Video_Quality = {'Tracking Off'};
                end                
            case hLegVis
                if strcmp(Video_Quality,{'Legs Hidden From View'})
                    Video_Quality = {'Good'};
                else
                    Video_Quality = {'Legs Hidden From View'};
                end
        end

        set(hPartial,'backgroundcolor',[0.9400    0.9400    0.9400]);
        set(hBadTrack,'backgroundcolor',[0.9400    0.9400    0.9400]);
        set(hLegVis,'backgroundcolor',[0.9400    0.9400    0.9400]);                                    
        
        switch Video_Quality{1}
            case 'Partial Fly Shown'
                set(hPartial,'backgroundcolor',rgb('very light blue'));
            case  'Tracking Off'  
                set(hBadTrack,'backgroundcolor',rgb('very light blue'));
            case  'Legs Hidden From View'
                set(hLegVis,'backgroundcolor',rgb('very light blue'));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% show the video
    function videoDisp(curr_axis,curr_frame)
        if isempty(frameReferenceMesh)
            return
        end
        frmData = read(vidObjCell{frameReferenceMesh(curr_frame,3)},frameReferenceMesh(curr_frame,2));
        frmData = frmData(449:end,:,:);

        backoff = 15;
        tI = log(double(frmData(:,:,1))+backoff);
        frmAdj = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
        frmAdj = intlut(frmAdj,frm_remap);

        frmData = frmAdj;
        set(hIm_1,'CData',frmData,'parent',curr_axis);
        drawnow
        set(hTextD,'string',sprintf('Frame :: %4.0f',frameReferenceMesh(curr_frame,1)),'HorizontalAlignment','center');
        display_points
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% button toggle functions
    function turn_flags_off(~,~)
        set(hCreset,'Enable','off');
        set(hCnextVid,'Enable','off');
        set(hCprevVid,'Enable','off');
        set(hCnextFile,'Enable','off');
        set(hCprevFile,'Enable','off');
        set(hLegVis,'Enable','off');
        set(hBadTrack,'Enable','off');
        set(hPartial,'Enable','off');
    end
%% next and last experiment
    function pfileCallback(~,~)
        reset_video
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        
        last_value = get(hTedit(4),'value');
        if last_value == 2
            set(hTedit(4),'value',length(get(hTedit(4),'string')));
        else
            set(hTedit(4),'value',last_value - 1);
        end
        set(hTedit(5),'Value',1,'String','....');
        populate_vid_list(hTedit(4));        
    end
    function nfileCallback(~,~)
        reset_video
        last_value = get(hTedit(4),'value');
        if last_value == length(get(hTedit(4),'string'))
            set(hTedit(4),'value',2);
        else
            set(hTedit(4),'value',last_value + 1);
        end
        set(hTedit(5),'Value',1,'String','....');
        populate_vid_list(hTedit(4));
    end
    function setprevvid(~,~)
        if length(vidOps) == 1
            return
        end
        reset_video
                
        if video_index > 1
            video_index = video_index - 1;
        else
            video_index = length(vidOps);
        end
        vidName = vid_list(video_index,:);
        
        set(hTedit(5),'Value',video_index+1)
        
        videoLoad
    end
    function setnextvid(~,~)
        if length(vidOps) == 1
            return
        end
        reset_video
        
        if video_index < length(vidOps)
            video_index = video_index + 1;
        else
            video_index = 1;
        end
        
        vidName = vid_list(video_index,:);
        set(hTedit(5),'Value',video_index)
        
        videoLoad
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function select_leg(hObj,~)
        set(start_left_front,'backgroundcolor',[.94 .94 .94]);
        set(start_left_mid,'backgroundcolor',[.94 .94 .94]);
        set(start_left_hind,'backgroundcolor',[.94 .94 .94]);
        
        
        set(start_right_front,'backgroundcolor',[.94 .94 .94]);
        set(start_right_mid,'backgroundcolor',[.94 .94 .94]);
        set(start_right_hind,'backgroundcolor',[.94 .94 .94]);

        set(hObj,'backgroundcolor',rgb('very light green'),'UserData',[0,0]);
            
        set(hFigA,'WindowButtonDownFcn',[]);
        set(hFigA,'WindowButtonUpFcn',[]);
        set(hFigA,'WindowScrollWheelFcn',[]);        
    end
    function ImageClickCallback (objectHandle , ~ )
        button_select = 0;
        if objectHandle == hIm_1 && length(get(start_right_front,'UserData')) == 2 && sum(get(start_right_front,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 1;
        elseif objectHandle == hIm_1 && length(get(start_right_mid,'UserData')) == 2 && sum(get(start_right_mid,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 2;
        elseif objectHandle == hIm_1 && length(get(start_right_hind,'UserData')) == 2 && sum(get(start_right_hind,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 3;
                        
        elseif objectHandle == hIm_1 && length(get(start_left_front,'UserData')) == 2 && sum(get(start_left_front,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 4;
        elseif objectHandle == hIm_1 && length(get(start_left_mid,'UserData')) == 2 && sum(get(start_left_mid,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 5;
        elseif objectHandle == hIm_1 && length(get(start_left_hind,'UserData')) == 2 && sum(get(start_left_hind,'backgroundcolor') == rgb('very light green')) == 3
            button_select = 6;
        end
        
        if button_select == 0
            return
        else
            axesHandle  = get(objectHandle,'Parent');
            coordinates = get(axesHandle,'CurrentPoint'); 
            coordinates = coordinates(1,1:2);
        end
        switch button_select
            case 1
                tableData.Right_Leg_Front(vid_pos_vect(1),:) = coordinates;
            case 2
                tableData.Right_Leg_Mid(vid_pos_vect(1),:) = coordinates;
            case 3
                tableData.Right_Leg_Hind(vid_pos_vect(1),:) = coordinates;                
            case 4
                tableData.Left_Leg_Front(vid_pos_vect(1),:) = coordinates;
            case 5
                tableData.Left_Leg_Mid(vid_pos_vect(1),:) = coordinates;
            case 6
                tableData.Left_Leg_Hind(vid_pos_vect(1),:) = coordinates;                 
        end
        summary_table;
        vid_pos_vect = circshift(vid_pos_vect,-1);
        show_video        
    end
    function display_points(~,~)                
        left_leg_front = tableData.Left_Leg_Front(vid_pos_vect(1),:);
        left_leg_mid = tableData.Left_Leg_Mid(vid_pos_vect(1),:);
        left_leg_hind = tableData.Left_Leg_Hind(vid_pos_vect(1),:);
        
        right_leg_front = tableData.Right_Leg_Front(vid_pos_vect(1),:);
        right_leg_mid = tableData.Right_Leg_Mid(vid_pos_vect(1),:);
        right_leg_hind = tableData.Right_Leg_Hind(vid_pos_vect(1),:);
                
        show_points(left_leg_front,rgb('light green'),1);
        show_points(left_leg_mid,rgb('light blue'),2);
        show_points(left_leg_hind,rgb('light orange'),3);
        
        show_points(right_leg_front,rgb('light cyan'),4);
        show_points(right_leg_mid,rgb('light magenta'),5);
        show_points(right_leg_hind,rgb('light purple'),6);        
    end
    function show_points(plot_cords,plot_color,index)
        if sum(isnan(plot_cords)) == 0
            if ishandle(disp_hdl(index))
                set(disp_hdl(index),'Xdata',plot_cords(1),'YData',plot_cords(2),'Marker','*','color',plot_color,'markersize',15,'parent',hAxesA);
            else
                disp_hdl(index) = plot(plot_cords(1),plot_cords(2),'Marker','*','color',plot_color,'markersize',15,'parent',hAxesA);
            end
        end
    end
    function make_scatter_disp(~,~)
        delete(get(hAxesP,'Children'));
        set(hAxesP,'nextplot','add');
        
        plot(hAxesP,tableData.Left_Leg_Front(:,1),tableData.Left_Leg_Front(:,2),'o','color',rgb('light green'));
        plot(hAxesP,tableData.Left_Leg_Mid(:,1),tableData.Left_Leg_Mid(:,2),'o','color',rgb('light blue'));  
        plot(hAxesP,tableData.Left_Leg_Hind(:,1),tableData.Left_Leg_Hind(:,2),'o','color',rgb('light orange')); 
        
        plot(hAxesP,tableData.Right_Leg_Front(:,1),tableData.Right_Leg_Front(:,2),'o','color',rgb('light cyan'))
        plot(hAxesP,tableData.Right_Leg_Mid(:,1),tableData.Right_Leg_Mid(:,2),'o','color',rgb('light magenta')); 
        plot(hAxesP,tableData.Right_Leg_Hind(:,1),tableData.Right_Leg_Hind(:,2),'o','color',rgb('light purple'));
        
        plot(hAxesP,tableData.Center_of_Mass(:,1),tableData.Center_of_Mass(:,2),'o','color',rgb('light red'));
        
        set(hAxesP,'Xlim',[0 vidWidth],'Ylim',[0 vidHeight]);
        set(hAxesP,'color',rgb('black'))
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% figure click functions
    function FigClickCallback(~,~)
        clickPos = get(0,'PointerLocation');
        set(hCreset,'Visible','on')
    end
    function resetFigCallback(~,~)
        if isempty(vidWidth)
            return
        end
        centerIm = [vidWidth/2 vidHeight/2];
        zoomMag = 1;
        clickPos = get(0,'PointerLocation');
        timerFigFun([],[])
%        set(hCreset,'Visible','off')
        set(hFigA,'CurrentAxes',[])
        set(hFigA,'WindowButtonDownFcn',@FigClickCallback);
        set(hFigA,'WindowButtonUpFcn',@FigReleaseCallback);
        set(hFigA,'WindowScrollWheelFcn',@FigWheelCallback);
    end
    function FigReleaseCallback(~,~)
        dragDist = clickPos-get(0,'PointerLocation');
        if isempty(centerIm)
            centerIm = [dragDist(1) -dragDist(2)];
        else
            centerIm = centerIm+[dragDist(1) -dragDist(2)];
        end
    end
    function FigWheelCallback(~,event)
        clickPos = get(0,'PointerLocation');
        minPos = clickPos-FigPos(1:2)-axesApos(1:2);
        maxPos = axesApos(3:4)-minPos;
        if min([minPos maxPos]) > 0
            zoomMag = zoomMag+(event.VerticalScrollCount/100)*3;
            timerFigFun([],[])
            set(hCreset,'Visible','on')
        end
    end
    function timerFigFun(~,~)
        dragDist = clickPos-get(0,'PointerLocation');
        hWidth = vidWidth*zoomMag/2;
        hHeight = vidHeight*zoomMag/2;
        set(hAxesA,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth]+dragDist(1),...
            'ylim',[centerIm(2)-hHeight centerIm(2)+hHeight]-dragDist(2))
                
        videoDisp(hAxesA,1)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reset/clear and save functions
    function reset_video
        make_save_struct
        resetbuttons
        hIm_1 = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
        set(hIm_1,'CData',(zeros(vidHeight,vidWidth,1)))
%        tableData = repmat(cell(1,7),frame_count,1);
        tableData = struct();
        Video_Quality = {'Good'};
        delete(get(hAxesP,'Children'));
    end
    function resetbuttons
        resetFigCallback       
        set(hPartial,'backgroundcolor',[.94 .94 .94]);
        set(hBadTrack,'backgroundcolor',[.94 .94 .94]);
        set(hLegVis,'backgroundcolor',[.94 .94 .94]);        
    end
    function summary_table(~,~)
        widthList = {100,100,100,100,100,100,100,100};
        colName = {'Frame Number','Left Leg Front','Left Leg Middle','Left Leg Hind','Right Leg Front','Right Leg Middle','Right Leg Hind','Center Of Mass'};
        frame_number = num2cell(tableData.Frame_Index');
        left_leg_front = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Left_Leg_Front(:,1),tableData.Left_Leg_Front(:,2),'UniformOutput',false);
        left_leg_mid = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Left_Leg_Mid(:,1),tableData.Left_Leg_Mid(:,2),'UniformOutput',false);
        left_leg_hind = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Left_Leg_Hind(:,1),tableData.Left_Leg_Hind(:,2),'UniformOutput',false);
        
        right_leg_front = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Right_Leg_Front(:,1),tableData.Right_Leg_Front(:,2),'UniformOutput',false);
        right_leg_mid = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Right_Leg_Mid(:,1),tableData.Right_Leg_Mid(:,2),'UniformOutput',false);
        right_leg_hind = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Right_Leg_Hind(:,1),tableData.Right_Leg_Hind(:,2),'UniformOutput',false);
        
        center_pos = arrayfun(@(x,y) sprintf('(%4.2f,%4.2f)',x,y),tableData.Center_of_Mass(:,1),tableData.Center_of_Mass(:,2),'UniformOutput',false);
        
        display_data = [frame_number,left_leg_front,left_leg_mid,left_leg_hind,right_leg_front,right_leg_mid,right_leg_hind,center_pos];
        colName = cellfun(@(x,y) strcat('<html><body bgcolor="',htmlcolor,...
            '" width="',num2str(x),'px">',y),widthList,colName,'uniformoutput',false);
        set(hTable,'RowName',[],'ColumnName',colName,'ColumnWidth',widthList,'Data',display_data);
        make_scatter_disp
        drawnow
    end
    function change_frame_entry(~, eventdata, ~)
        try
            frame_clicked = eventdata.Indices(1);
        catch
            return   %didn't click
        end
        vid_pos_vect = 1:1:length(frame_index);
        vid_pos_vect = circshift(vid_pos_vect,(frame_clicked-1)*-1);
        show_video
    end
    function make_save_struct(~,~)
        if ~isempty(vidName)             
            new_dataset = dataset();
            new_dataset.VidQuality = Video_Quality;
            new_dataset.Jump_Flag = current_video.autoJumpTest;
            new_dataset.Fly_Orientation = cellfun(@(x,y) x(y,3),track_data.bot_points_and_thetas,num2cell(tableData.Frame_Index(1)),'UniformOutput',false);       %fly pos at start in radians
            new_table = dataset2table(new_dataset);
            new_table.Properties.RowNames  = vidName;
            
            new_table.Click_Points = tableData;

            if ~isempty(all_save_data)
                matcing_old_data = ismember(all_save_data.Properties.RowNames,vidName);
                if sum(matcing_old_data) > 0        %replace old points with new points
                    all_save_data(matcing_old_data,:) = new_table;
                else
                    all_save_data = [all_save_data;curr_struct];                    
                end
            end        
        end
    end
    function myCloseFun(~,~)
        make_save_struct
        save(save_leg_path,'all_save_data');        
        delete(hFigA)
    end
end
function Escape_tracking_gui_v1
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gets pathing info
repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))

op_sys = system_dependent('getos');
if contains(op_sys,'Microsoft Windows')
    file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
    analysis_path = '\\DM11\cardlab\Data_pez3000_analyzed';
    data_path = '\\DM11\cardlab\Data_pez3000'; 
    save_path = '\\DM11\cardlab\Jump_Angle_Tracking';
else
    file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
    analysis_path = '/Volumes/cardlab/Data_pez3000_analyzed';
    data_path = '/Volumes/cardlab/Data_pez3000';    
    save_path = '/Volumes/cardlab/Jump_Angle_Tracking';
end

if exist(fullfile(save_path,'Escape_Angle_Data.mat'),'file') == 2
    all_save_data = load(fullfile(save_path,'Escape_Angle_Data'));
    all_save_data = all_save_data.all_save_data;
else
    all_save_data = [];
end

try
    poolobj = parpool;
catch
    poolobj = gcp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp_range = [22.0,25.0];           humidity_cut_off = 40;
azi_off = 22.5;
remove_low = false;                  low_count = 5;
exp_cut = 100;                      ignore_graph_table = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables
exp_dir = [];
saved_groups = [];          saved_collections = [];              curr_collection = [];          curr_group = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
leg_push_frame = [];        take_off_frame = [];                Video_Quality = [];

elip_handle_leg_top = [];        elip_handle_leg_bot = [];
elip_handle_jump_top = [];       elip_handle_jump_bot = [];

vid_list = [];              vidName = [];               vidOps = [];       
vidFrames_partial = [];     video_index = 1;
vidOff = 0;                 vidObjCell = cell(2,1);     frameReferenceMesh = [];    
frameRefcutrate = [];       frameReffullrate = [];      
frm_remap = [];             master_table = [];          graphTable = [];

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
% control panel
hPanA = uipanel('Position',[.05 .8 .9 .185],'Visible','On');
figure_size = .3;

hTextD = uicontrol(hFigA,'Style','text','string','Frame :: ','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'units','normalized','Position',[.01 .75 figure_size .025],'Visible','On','fontsize',15);

hTextE = uicontrol(hFigA,'Style','text','string','Frame :: ','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'units','normalized','Position',[.33 .75 figure_size .025],'Visible','On','fontsize',15);

set(hFigA,'CloseRequestFcn',@myCloseFun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame and graph axes
hAxesA_top = axes('Parent',hFigA,'Position',[.01 .43 figure_size figure_size],...             %.375
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
%set(hAxesA_top,'DataAspectRatio',[1 1 1],'units','pix')
set(hAxesA_top,'units','normalized')

hAxesA_bot = axes('Parent',hFigA,'Position',[.01 .05 figure_size figure_size],...             %.375
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
%set(hAxesA_bot,'DataAspectRatio',[1 1 1],'units','pix')
set(hAxesA_bot,'units','normalized')

hAxesB_top = axes('Parent',hFigA,'Position',[.33 .43 figure_size figure_size],...             %.375
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
%set(hAxesB_top,'DataAspectRatio',[1 1 1],'units','pix')
set(hAxesB_top,'units','normalized')

hAxesB_bot = axes('Parent',hFigA,'Position',[.33 .05 figure_size figure_size],...             %.375
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
%set(hAxesB_bot,'DataAspectRatio',[1 1 1],'units','pix')
set(hAxesB_bot,'units','normalized')

hAxesC_raw = axes('Parent',hFigA,'Position',[.66 .27 figure_size figure_size],...             %.375
    'color','w','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse','Xlim',[-125 125],'Ylim',[-125 125]);
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

current_video = [];

hGood_Data = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Good Video','Position',[.70 .025 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@toggle_quality);

hPartial = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Partial Fly Shown','Position',[.85 .025 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@toggle_quality);

hTrack_Full = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Videos With T/O Track','Position',[.63 .225 .125 .15],'fontunits','normalized','fontsize', 0.4000,'callback',@filter_list);

hTrack_Leg = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Videos without T/O track','Position',[.757 .225 .125 .15],'fontunits','normalized','fontsize', 0.4000,'callback',@filter_list);

hTrack_none = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Videos With No Tracking Only','Position',[.885 .225 .125 .15],'fontunits','normalized','fontsize', 0.4000,'callback',@filter_list);

hHide_Annotate = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off','BackgroundColor',rgb('light cyan'),...
    'string','Videos Need to Check','Position',[.70 .40 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@filter_list_v2,'UserData',1);

hShow_Annotate = uicontrol(hPanA,'style','pushbutton','units','normalized','Enable','off',...
    'string','Annotated Videos Only','Position',[.85 .40 .100 .15],'fontunits','normalized','fontsize', 0.4598,'callback',@filter_list_v2,'UserData',0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_user_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selct video options
    function load_user_data(~,~)
        new_file_path = struct2dataset(dir(analysis_path));        
        saved_collections = load([file_dir filesep 'Saved_Collection.mat']);            saved_collections = saved_collections.Saved_Collection;   
        saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);            saved_groups = saved_groups.Saved_Group_IDs;        
        exp_dir =  new_file_path.name;                                                  exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));       
        exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= exp_cut,exp_dir));

        saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:);
        [~,sort_idx] = sort(lower(regexprep(saved_groups.Properties.RowNames,' ','')));
        saved_groups = saved_groups(sort_idx,:);
        saved_users   = unique(saved_collections.User_ID); 
        set(hTedit(1),'String',[' ';unique(saved_users)],'horizontalalignment','center','fontunits','normalized','fontsize',0.5000,'enable','on','callback',@populatecollect);
    end
    function populatecollect(hObj,~)                        % select User
        curr_collection = ' ';
        index = get(hObj,'value');
        list = get(hObj,'string');                           %selected User
        
        collect_list = saved_collections(strcmp(saved_collections.User_ID,list(index)),:).Collection_Name;
        collect_ids = get(saved_collections(strcmp(saved_collections.User_ID,list(index)),:),'ObsNames');
        new_collect_list = cellfun(@(x,y) [x,'  ::  ',y],collect_ids,collect_list,'UniformOutput',false);
        set(hTlabels(2),'string','Select Collection');
        set(hTlabels(3),'string','Select Group');
        
        set(hTedit(2),'string',[' ';new_collect_list],'value',1,'enable','on','callback',@populatelist);
        group_data = saved_groups(strcmp(list{index},saved_groups.User_ID),:);
        if ~isempty(group_data)
            set(hTedit(3),'string',[' ';unique(group_data.Properties.RowNames,'stable')],'value',1,'enable','on','callback',@parse_group_list);
        else
            set(hTedit(3),'string','No Groups Found for this User','value',1,'enable','off');
        end
    end
    function parse_group_list(hObj,~)                       % called if Collection
        set(hTedit(2),'value',1);            index = get(hObj,'value');              list = get(hObj,'string');
        curr_group  = saved_groups(strcmp(list{index},saved_groups.Properties.RowNames),:).Experiment_IDs{1};
        curr_group = strtrim(curr_group);
        if ~iscell(curr_group)
            curr_group =  cellstr(curr_group);           
        end
        curr_collection = cellfun(@(x) x(1:4), curr_group,'uniformoutput',false);
        curr_collection = unique(curr_collection);
        
        get_list_of_vids
    end
    function populatelist(hObj,~)                           % called if Group
        set(hTedit(3),'value',1);             index = get(hObj,'value');             list = get(hObj,'string');
        list = cellfun(@(x) x(strfind(x,'::')+4:end),list(index),'uniformoutput',false);
        curr_collection = get(saved_collections(ismember(saved_collections.Collection_Name,list),:),'ObsName');
        
        get_list_of_vids
    end
    function get_list_of_vids(~,~)
        if ~isempty(curr_group)
            load_files = curr_group;
        else
            if iscell(curr_collection)
                collect_match = curr_collection;
            else
                collect_match = {curr_collection};
            end
            load_files = exp_dir(cellfun(@(x) strcmp(x(1:4),collect_match),exp_dir),:);
        end
        set(hTlabels(4),'string','Select Experiment ID');
        set(hTedit(4),'String',['...';load_files],'Callback', @populate_vid_list);
        
    end
    function filter_list_v2(hObj,~)
        set(hHide_Annotate,  'BackgroundColor',[.8 .8 .8],'UserData',0);
        set(hShow_Annotate,'BackgroundColor',[.8 .8 .8],'UserData',0);
        
        set(hObj,'BackgroundColor',rgb('light cyan'),'UserData',1);
        vid_list = master_table.Properties.RowNames;
        filter_vid_list
    end
    function filter_list(hObj,~)
        if isempty(master_table)
            return
        end
        vid_list = master_table.Properties.RowNames;
        set(hTrack_Full,  'BackgroundColor',[.8 .8 .8],'UserData',0);
        set(hTrack_Leg,'BackgroundColor',[.8 .8 .8],'UserData',0);
        set(hTrack_none , 'BackgroundColor',[.8 .8 .8],'UserData',0);

        set(hObj,'BackgroundColor',rgb('light cyan'),'UserData',1);
        
        no_tracking = cellfun(@(x) isempty(x), master_table.bot_points_and_thetas);
        filt_table = master_table(~no_tracking,:);
        
        auto_jump_azi = cell2mat(master_table.zeroFly_Jump);
        auto_jump_azi = auto_jump_azi(:,1);
        switch hObj
            case hTrack_Full
                filt_table = filt_table(~isnan(auto_jump_azi),:);
            case hTrack_Leg
                filt_table = filt_table(isnan(auto_jump_azi),:);                
            case hTrack_none
                filt_table = master_table(no_tracking,:);
        end 
        vid_list = filt_table.Properties.RowNames;
        
        filter_vid_list
    end
    function populate_vid_list(hObj,~)
        set(hTedit(5),'value',1);
        vid_val = get(hObj,'Value');
        curr_exp_list = get(hObj,'String');
        curr_exp_id = curr_exp_list{vid_val};

        test_data =  Experiment_ID(curr_exp_id);
        test_data.temp_range = temp_range;
        test_data.humidity_cut_off = humidity_cut_off;
        test_data.remove_low = remove_low;
        test_data.low_count = low_count;
        test_data.azi_off = azi_off;
        test_data.ignore_graph_table = ignore_graph_table;
            
        test_data.load_data;
        test_data.make_tables;
        test_data.get_tracking_data;
                       
        set(hTlabels(5),'String','Select Video:');
        
        master_table = test_data.Complete_usuable_data;
        
        jump_logic = find_jump_data(master_table);
        master_table = master_table(jump_logic,:);

        
        vid_list = master_table.Properties.RowNames;

        filter_vid_list
        
        load(fullfile(analysis_path,curr_exp_id,[curr_exp_id,'_dataForVisualization.mat']))
        if strcmp('manualJumpDir',graphTable.Properties.VariableNames) == 0
            graphTable.manualJumpDir(1:height(graphTable)) = NaN;
        end
    end
    function jump_logic = find_jump_data(summary_table)
        try
            jump_logic = summary_table.autoJumpTest;
            jump_logic(summary_table.autoFot == 0) = cell2mat(summary_table(summary_table.autoFot == 0,:).jumpTest);
        catch
            jump_logic = summary_table.jumpTest;
        end
        if iscell(jump_logic)
            jump_logic = cell2mat(jump_logic);
        end
        
        done_logic = cellfun(@(x) ~isempty(x), summary_table.frame_of_leg_push);
        done_table = summary_table(done_logic,:);
        frame_logic = cellfun(@(x) ~isnan(x), done_table.frame_of_leg_push);
        jump_logic(done_logic) = frame_logic;
        if isnumeric(jump_logic)
            jump_logic = logical(jump_logic);
        end        
    end
    function filter_vid_list(~,~)
%         if isempty(vid_list)
%             set(hTedit(5),'value',1,'String','...','enable','off')
%             nfileCallback
%         end
        if get(hHide_Annotate,'UserData') == 1
            if ~isempty(all_save_data)
                vid_list = vid_list(~ismember(vid_list,all_save_data.Properties.RowNames));
            end
        elseif get(hShow_Annotate,'UserData') == 1
            vid_list = vid_list(ismember(vid_list,all_save_data.Properties.RowNames));
        end
        
        org_list_index = cellfun(@(y) sprintf('%04s',num2str(y)),num2cell(1:1:height(master_table))','UniformOutput',false);
        org_list_index = org_list_index(ismember(master_table.Properties.RowNames,vid_list));
        
        index = cellfun(@(x) strfind(x,'expt'),vid_list);
        if ~isempty(vid_list)
            short_list = cellfun(@(x,y,z) sprintf('%s%04s_orgvid%04s',x(index:(index+23)),num2str(y),num2str(z)),vid_list,num2cell(1:1:length(index))',org_list_index,'UniformOutput',false);        
%            set(hTedit(5),'value',1,'String',short_list,'Callback',@select_video,'enable','on');
            set(hTedit(5),'value',1,'String',vid_list,'Callback',@select_video,'enable','on');
            select_video(hTedit(5))
        else
        set(hShow_Annotate,'Enable','on');
        set(hHide_Annotate,'Enable','on');
%             set(hTedit(5),'value',1,'String','...','enable','off')
%             nfileCallback
        end
    end
    function load_options(~,~)
        set(hCnextFile,'string','Next Experiment');
        set(hCprevFile,'string','Prev Experiment');        
        set(hCnextFile,'enable','on');
        set(hCprevFile,'enable','on');
        set(hCnextVid,'Enable','on');
        set(hCprevVid,'Enable','on');
        
        set(hTrack_Full,'Enable','on');
        set(hTrack_Leg,'Enable','on');
        set(hTrack_none,'Enable','on');
        
        set(hShow_Annotate,'Enable','on');
        set(hHide_Annotate,'Enable','on');
        
        set(hGood_Data,'Enable','on');
        set(hPartial,'Enable','on');
    end
    function select_video(hObj,~)
        load_options
        video_index = get(hObj,'Value');
        
        vidOps = vid_list;
        vidOps = circshift(vidOps,-vidOff+1);
        vidOff = 1;
        vidName = vid_list(video_index,:);
        videoLoad
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load and parsing functions
    function videoLoad
        reset_video
        
        vid_name = vidName{1};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);
        
        current_video = master_table(vidName,:);
                
        if isempty(current_video.frame_of_take_off{1})
            take_off_frame = cell2mat(current_video.autoFrameOfTakeoff);
        else
            take_off_frame = cell2mat(current_video.frame_of_take_off);
        end
        
%         if isempty(current_video.frame_of_leg_push{1})
%             leg_push_frame =  take_off_frame - 30;
%         else
%             leg_push_frame = cell2mat(current_video.frame_of_leg_push);
%         end
%                                 
        leg_push_frame =  take_off_frame - 30;
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
        vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>
        
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
        show_video(leg_push_frame,'top',hAxesA_top);
        show_video(leg_push_frame,'bot',hAxesA_bot);
        set(hTextD,'string',sprintf('Leg Push Frame :: %4.0f',leg_push_frame));
        
        show_video(take_off_frame,'top',hAxesB_top);
        show_video(take_off_frame,'bot',hAxesB_bot);
        set(hTextE,'string',sprintf('Take Off Frame :: %4.0f',take_off_frame));
        
        set(hAxesA_top,'Xlim',[0 384],'Ylim',[0 384]);
        set(hAxesA_bot,'Xlim',[0 384],'Ylim',[0 384]);
        set(hAxesB_top,'Xlim',[0 384],'Ylim',[0 384]);
        set(hAxesB_bot,'Xlim',[0 384],'Ylim',[0 384]);
        
        plot_tracking_data(hAxesA_top)
        plot_tracking_data(hAxesA_bot)
        show_stimuli_plot
        
        plot_tracking_data(hAxesB_top)
        plot_tracking_data(hAxesB_bot)
        
        toggle_quality(hGood_Data)
        
    end
    function show_video(samp_frame,view,parent_axis)
        leg_frame_data = frameReferenceMesh(frameReferenceMesh(:,1) == samp_frame,:);       
        frmData = read(vidObjCell{leg_frame_data(:,3)},leg_frame_data(:,2));
        
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
        if strcmp(view,'bot')
            frmData = frmData(448:end,:,:);
            image('Parent',parent_axis,'CData',frmData);
        elseif strcmp(view,'top')
            frmData = frmData(1:384,:,:);
            image('Parent',parent_axis,'CData',frmData);
        end            
        
    %    set(hIm_1,'ButtonDownFcn',@ImageClickCallback);                   
    end
    function plot_tracking_data(curr_axis)
        if ~isempty(all_save_data)            
            check_if_exists = ismember(all_save_data.Properties.RowNames,vidName);
        else
            check_if_exists = 0;
        end
        
        if check_if_exists == 0     %if data not in saved file then use tracking or estimate data
            top_track = current_video.top_points_and_thetas{1};
            bot_track = current_video.bot_points_and_thetas{1};
            if ~isempty(bot_track)
                switch curr_axis
                    case hAxesA_top
                        if length(top_track) >= leg_push_frame
                            plot_pts = top_track(leg_push_frame,:);
                            elip_handle_leg_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'r-.',curr_axis);                    
                         else
    %                        [rho,phi,obj,max_idx] = estimate_center_of_image(curr_axis);
    %                        elip_handle_leg_top = ellipseselect('init',rho,phi,obj.mu(max_idx,1),obj.mu(max_idx,2),2*pi,'b-.',curr_axis);
                           plot_pts = top_track(end,:);
                           elip_handle_leg_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);
                        end                    
                    case hAxesA_bot
                        if length(bot_track) >= leg_push_frame
                            plot_pts = bot_track(leg_push_frame,:);
                            elip_handle_leg_bot = ellipseselect('init',(cell2mat(current_video.fly_length)/2),20,plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'r-.',curr_axis);
                        else
                            %[rho,phi,obj,max_idx] = estimate_center_of_image(curr_axis);
                            %elip_handle_leg_bot = ellipseselect('init',rho,phi,obj.mu(max_idx,1),obj.mu(max_idx,2),2*pi,'b-.',curr_axis);                    
                            plot_pts = bot_track(end,:);
                            elip_handle_leg_bot = ellipseselect('init',(cell2mat(current_video.fly_length)/2),20,plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);
                        end
                    case hAxesB_top
                        if length(top_track) >= take_off_frame
                            plot_pts = top_track(take_off_frame,:);
                            elip_handle_jump_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'r-.',curr_axis);
                        else
    %                        [rho,phi,obj,max_idx] = estimate_center_of_image(curr_axis);
    %                        elip_handle_jump_top = ellipseselect('init',rho,phi,obj.mu(max_idx,1),obj.mu(max_idx,2),2*pi,'b-.',curr_axis);                                        
                            plot_pts = top_track(end,:);
                            elip_handle_jump_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);
                        end
                    case hAxesB_bot
                        if length(bot_track) >= take_off_frame
                            plot_pts = bot_track(take_off_frame,:);
                            elip_handle_jump_bot = ellipseselect('init',(cell2mat(current_video.fly_length)/2),20,plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'r-.',curr_axis);
                        else
    %                        [rho,phi,obj,max_idx] = estimate_center_of_image(curr_axis);
    %                        elip_handle_jump_bot = ellipseselect('init',rho,phi,obj.mu(max_idx,1),obj.mu(max_idx,2),2*pi,'b-.',curr_axis);                                                            
                            plot_pts = bot_track(end,:);
                            elip_handle_jump_bot = ellipseselect('init',(cell2mat(current_video.fly_length)/2),20,plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);
                        end
                end
            else
                plot_pts = [192,192,pi,50,50];
                switch curr_axis
                    case hAxesA_top
                        elip_handle_leg_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);                    
                    case hAxesA_bot
                        elip_handle_leg_bot = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);                    
                    case hAxesB_top
                        elip_handle_jump_top = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);                    
                    case hAxesB_bot
                        elip_handle_jump_bot = ellipseselect('init',plot_pts(:,4),plot_pts(:,5),plot_pts(:,1),plot_pts(:,2),2*pi-plot_pts(:,3),'b-.',curr_axis);                    
                end
            end            
        else
            curr_vid = all_save_data(vidName,:);
            switch curr_axis                
                case hAxesA_top
                     elip_handle_leg_top = ellipseselect('init',curr_vid.Leg_Push_Top_View.a,curr_vid.Leg_Push_Top_View.b,curr_vid.Leg_Push_Top_View.x0,curr_vid.Leg_Push_Top_View.y0,curr_vid.Leg_Push_Top_View.phi,'r-.',curr_axis);
                case hAxesA_bot
                    elip_handle_leg_bot = ellipseselect('init',curr_vid.Leg_Push_Bot_View.a,curr_vid.Leg_Push_Bot_View.b,curr_vid.Leg_Push_Bot_View.x0,curr_vid.Leg_Push_Bot_View.y0,curr_vid.Leg_Push_Bot_View.phi,'r-.',curr_axis);
                case hAxesB_top
                    elip_handle_jump_top = ellipseselect('init',curr_vid.Jump_Frame_Top_View.a,curr_vid.Jump_Frame_Top_View.b,curr_vid.Jump_Frame_Top_View.x0,curr_vid.Jump_Frame_Top_View.y0,curr_vid.Jump_Frame_Top_View.phi,'r-.',curr_axis);                        
                case hAxesB_bot
                    elip_handle_jump_bot = ellipseselect('init',curr_vid.Jump_Frame_Bot_View.a,curr_vid.Jump_Frame_Bot_View.b,curr_vid.Jump_Frame_Bot_View.x0,curr_vid.Jump_Frame_Bot_View.y0,curr_vid.Jump_Frame_Bot_View.phi,'r-.',curr_axis);                        
            end            
        end
        set(hAxesC_raw,'Xlim',[-125 125],'ylim',[-125 125])
    end
    function wall_position = get_wall_pos(test_data)
        test_string = test_data.Stimuli_Used;
        wall_width_loc = ones(length(test_string),1) .*360;
        wall_logic = cellfun(@(x) contains(x,'wall'),test_string);
        
%        width_index = cellfun(@(x) strfind(x,'_w'),test_string(wall_logic));
        height_index = cellfun(@(x) strfind(x,'_h'),test_string(wall_logic));
        at_index = cellfun(@(x) strfind(x,'at'),test_string(wall_logic),'UniformOutput',false);

        wall_width = cellfun(@(x,y,z) x((z(1)+2):(y-1)),test_string(wall_logic),num2cell(height_index ),at_index,'UniformOutput',false);
        wall_width_loc(wall_logic) = str2double(wall_width);
        copy_wall_pos = wall_width_loc;
        copy_wall_pos(wall_width_loc == 180) = 0;        copy_wall_pos(wall_width_loc == 0) = 180;
        wall_position = copy_wall_pos;
    end
    function show_stimuli_plot(~,~)
        delete(get(hAxesC_raw,'Children'));
%         bot_track = current_video.bot_points_and_thetas{1};
%         if length(bot_track) >= leg_push_frame
%             plot_pts = bot_track(leg_push_frame,:);
%         else
%             return
%         end
        plot_pts = get(elip_handle_leg_bot,'UserData');
        plot_pts = [plot_pts.x0,plot_pts.y0,(2*pi-plot_pts.phi)];
        
        x_data = -100:.1:100;       y_data = sqrt(100*100 - x_data.^2);
        set(hAxesC_raw,'nextplot','add')
        plot(hAxesC_raw,x_data,y_data,'-k','linewidth',2);
        plot(hAxesC_raw,x_data,-y_data,'-k','linewidth',2);
        set(hAxesC_raw,'Xlim',[-125 125],'Ylim',[-125 125]);
        
        line([-100 100],[0 0],'linewidth',.8,'color',rgb('gray'),'parent',hAxesC_raw)
        line([0 0],[-100 100],'linewidth',.8,'color',rgb('gray'),'parent',hAxesC_raw)
        
        u = cos(plot_pts(:,3))*50;
        v = -sin(plot_pts(:,3))*50;
        quiver(0,0,u,v,'color',rgb('orange'),'LineWidth',1,'MaxHeadSize',5,'AutoScaleFactor',1,'parent',hAxesC_raw)
        
        stim_pos = cell2mat(current_video.stimulus_azimuth).*180/pi + 360;
        if isempty(stim_pos)
            stim_pos = current_video.VidStat_Stim_Azi.*180/pi+360;
        end
        u = cos(stim_pos.*pi/180)*50;
        v = -sin(stim_pos.*pi/180)*50;
        quiver(0,0,u,v,'color',rgb('blue'),'LineWidth',1,'MaxHeadSize',5,'AutoScaleFactor',1,'parent',hAxesC_raw)

        stim_pos = (stim_pos-15):(stim_pos+15);
        stim_pos = stim_pos .* (pi / 180);
        [stim_x,stim_y] = pol2cart(stim_pos,125);
        plot(hAxesC_raw,stim_x,-stim_y,'-b','linewidth',2)

        
        wall_position = get_wall_pos(current_video);
        wall_size = 25;
        if wall_position == 270
            wall_x = -wall_size:1:wall_size;  wall_y = ones((2*wall_size+1),1) .* 120;
        elseif wall_position == 90
            wall_x = -wall_size:1:wall_size;  wall_y = ones((2*wall_size+1),1) .* -120;
        elseif wall_position == 0 
            wall_y = -wall_size:1:wall_size;  wall_x = ones((2*wall_size+1),1) .* 120;
        elseif wall_position == 180 
            wall_y = -wall_size:1:wall_size;  wall_x = ones((2*wall_size+1),1) .* -120;
        end
        
        if exist(fullfile(save_path,'Escape_Angle_Data.mat'),'file') == 2
            if ismember(vidName,all_save_data.Properties.RowNames)      %if has jump angle in save file then show
                if master_table(vidName,:).flipBool == 0
                    escape_azimuth = all_save_data(vidName,:).Manual_Jump_Azi + plot_pts(:,3);
                else
                    escape_azimuth = -all_save_data(vidName,:).Manual_Jump_Azi + plot_pts(:,3);
                end
                u = cos(escape_azimuth)*50;
                v = -sin(escape_azimuth)*50;
                quiver(0,0,u,v,'color',rgb('red'),'LineWidth',1,'MaxHeadSize',5,'AutoScaleFactor',1,'parent',hAxesC_raw)
            end
        end
        try
        plot(hAxesC_raw,wall_x,wall_y,'-r','linewidth',2)
        end
        set(hAxesC_raw,'Xlim',[-125 125],'Ylim',[-125 125]);        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% next and last experiment
    function pfileCallback(~,~)
        update_save_file
        write_save_file
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
        if ~isempty(vidName)
        update_save_file
        write_save_file
        end
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
        update_save_file
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
        update_save_file
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
    function toggle_quality(hObj,~)
        set(hPartial,'backgroundcolor',[0.9400    0.9400    0.9400]);
        set(hGood_Data,'backgroundcolor',[0.9400    0.9400    0.9400]);
        
        switch hObj
            case hPartial
                Video_Quality = {'Partial Fly Shown'};
            case hGood_Data
                Video_Quality = {'Good'};
        end
        set(hObj,'backgroundcolor',rgb('very light blue'));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function output_pts = check_elipse(input_elipse)
        if ishandle(input_elipse)
            output_pts = get(input_elipse,'UserData');
            if sum((cellfun(@(x) contains(x,'oldpt'),fieldnames(output_pts)))) == 1
                output_pts = rmfield(output_pts,'oldpt');               
            end
        else
            output_pts = struct('a',[],'b',[],'x0',[],'y0',[],'phi',[],'style','r-.','axis',[0,384,0,384],'he',[],'hc',[],'ha',[],'hb',[]);
        end
            
    end
    function update_save_file(~,~)        
        leg_top_pts = check_elipse(elip_handle_leg_top);
        leg_bot_pts = check_elipse(elip_handle_leg_bot);
        jmp_top_pts = check_elipse(elip_handle_jump_top);
        jmp_bot_pts = check_elipse(elip_handle_jump_bot);
        
        try
            auto_azi = master_table(vidName,:).zeroFly_Jump{1};
            auto_azi = auto_azi(1);
        catch
            auto_azi = NaN;
        end
        flip_stim = master_table(vidName,:).flipBool;
        
%         if strcmp(Video_Quality,{'Partial Fly Shown'})
%             man_theta = NaN;
%             man_rho = NaN;        
%         elseif ~isempty(leg_bot_pts.phi) && ~isempty(jmp_bot_pts.phi)
%             fly_leg = get(elip_handle_leg_bot,'UserData');
%             fly_jump = get(elip_handle_jump_bot,'UserData');
%             fly_leg_azi = 2*pi - fly_leg.phi;        
%             fly_norm_rot = rotation([fly_jump.x0 - fly_leg.x0,(fly_jump.y0 - fly_leg.y0)*-1],[0,0],2*pi-fly_leg_azi,'radians');        
%             [man_theta,man_rho] = cart2pol(fly_norm_rot(:,1),fly_norm_rot(:,2));
%             if flip_stim == 1
%                 man_theta = -1*man_theta;
%             end
%         else
%             man_theta = NaN;
%             man_rho = NaN;
%         end
%         manual_azi = man_theta;
%         manual_ele = man_rho;
        
        if strcmp(Video_Quality,{'Partial Fly Shown'})
            theta = NaN;
%             rho = NaN;            
%         elseif size(master_table(vidName,:).bot_points_and_thetas{1},1) > take_off_frame
%             [theta,rho] = get_angle_of_jump_from_tracking(master_table(vidName,:));
        elseif ~isempty(leg_bot_pts.phi) && ~isempty(jmp_bot_pts.phi)
            fly_leg = get(elip_handle_leg_bot,'UserData');               fly_jump = get(elip_handle_jump_bot,'UserData'); 
            frame_of_leg_xy = [fly_leg.x0,fly_leg.y0];                   frame_of_take_off_xy = [fly_jump.x0,fly_jump.y0];           
            [theta,~] = get_angle_of_jump_from_tracking_v2(frame_of_take_off_xy,frame_of_leg_xy,-fly_leg.phi);
        else 
            theta = NaN;
        end
        man_theta = theta;
            if flip_stim == 1
                man_theta = -1*man_theta;
            end
                
        output_save_table = cell2table([Video_Quality,{leg_top_pts},{leg_bot_pts},{jmp_top_pts},{jmp_bot_pts},{flip_stim},{auto_azi},{man_theta}]);
        output_save_table.Properties.RowNames = vidName;
        output_save_table.Properties.VariableNames = [{'Video_Quality'},{'Leg_Push_Top_View'},{'Leg_Push_Bot_View'},{'Jump_Frame_Top_View'},{'Jump_Frame_Bot_View'},{'Flip_Angle_Logic'},{'Auto_Jump_Azi'},{'Manual_Jump_Azi'}]; 
        
        graphTable.manualJumpDir(vidName) = man_theta;
        vidNamestr = cell2mat(vidName);
        expID = vidNamestr(29:44);
        save(fullfile(analysis_path,expID,[expID,'_dataForVisualization.mat']),'graphTable')
        
        if ~isempty(all_save_data)            
            check_if_exists = ismember(all_save_data.Properties.RowNames,vidName);
        else
            check_if_exists = 0;
        end
        if sum(check_if_exists) == 1
            all_save_data(vidName,:) = output_save_table;
        else
            all_save_data = [all_save_data;output_save_table];
        end
    end
%     function [theta,rho] = get_angle_of_jump_from_tracking(sample_vid)
%         jump_theta = sample_vid.bot_points_and_thetas{1};
%         jump_theta = jump_theta(leg_push_frame,3);
%         XYZ_3D_filt = sample_vid.XYZ_3D_filt{1};
%         zero_netXYZ = XYZ_3D_filt-repmat(XYZ_3D_filt(1,:),size(XYZ_3D_filt,1),1);
% 
%         xyzDiffPre = zero_netXYZ(take_off_frame,:)-zero_netXYZ(leg_push_frame,:);
%         [az_jump,~,rho_jump] = cart2sph(xyzDiffPre(1),-xyzDiffPre(2),-xyzDiffPre(3));
%         uv_zeroFlyJump = [cos(az_jump-jump_theta) -sin(az_jump-jump_theta)].*rho_jump;
%         [theta,rho] = cart2pol(uv_zeroFlyJump(1),-uv_zeroFlyJump(2));
%     end
    function [theta,rho] = get_angle_of_jump_from_tracking_v2(frame_of_take_off_xy,frame_of_leg_xy,jump_theta)
        xyzDiffPre = frame_of_take_off_xy - frame_of_leg_xy;
        az_jump = cart2pol(xyzDiffPre(1),-xyzDiffPre(2));
        uv_zeroFlyJump = [cos(az_jump-jump_theta) -sin(az_jump-jump_theta)];
        [theta,rho] = cart2pol(uv_zeroFlyJump(1),-uv_zeroFlyJump(2));
    end
    function write_save_file(~,~)
        save(fullfile(save_path,'Escape_Angle_Data'),'all_save_data');     
    end
    function reset_video(~,~)
        delete(get(hAxesA_bot,'Children'));             delete(get(hAxesB_bot,'Children'));             %remove all old info
        set(hAxesA_bot,'NextPlot','Add');               set(hAxesB_bot,'NextPlot','Add');
        delete(get(hAxesA_top,'Children'));             delete(get(hAxesB_top,'Children'));             %remove all old info
        set(hAxesA_top,'NextPlot','Add');               set(hAxesB_top,'NextPlot','Add');
    end
    function myCloseFun(~,~)
        if ~isempty(vidName)        %only save if a video was selected
            update_save_file
            write_save_file
        end
        try
            delete(poolobj);
        catch
        end
        delete(hFigA)
    end
end
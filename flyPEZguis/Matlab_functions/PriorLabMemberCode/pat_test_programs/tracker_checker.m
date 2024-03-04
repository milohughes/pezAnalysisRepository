function tracker_checker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gets pathing info
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))

    op_sys = system_dependent('getos');
    if ~isempty(strfind(op_sys,'Microsoft Windows'))
        file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
        analysis_path = '\\tier2\card\Data_pez3000_analyzed';
        data_path = '\\tier2\card\Data_pez3000';
    else
        file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
        analysis_path = [filesep 'Volumes' filesep 'card' filesep 'Data_pez3000_analyzed'];
        data_path = [filesep 'Volumes' filesep 'card' filesep 'Data_pez3000'];
        if ~exist(data_path,'file')
            data_path = [filesep 'Volumes' filesep 'card-1' filesep 'Data_pez3000'];
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saved_collections = load([file_dir filesep 'Saved_Collection.mat']);
    saved_collections = saved_collections.Saved_Collection;

    saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);
    saved_groups = saved_groups.Saved_Group_IDs;

    exp_dir =  struct2dataset(dir(analysis_path));
    exp_dir = exp_dir.name;
    exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));

    saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:);
    %saved_groups = saved_groups(ismember(saved_groups.Experiment_ID, exp_dir),:);

    [~,sort_idx] = sort(lower(regexprep(saved_groups.Properties.RowNames,' ','')));
    saved_groups = saved_groups(sort_idx,:);

    saved_users   = unique([saved_collections.User_ID;saved_groups.User_ID]);
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
%    hPanB = uipanel('Position',[.05 .05 .925 .05],'Visible','On');
%    hPanC = uipanel('Position',[.05 .01 .925 .04],'Visible','On');
    set(hFigA,'CloseRequestFcn',@myCloseFun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame and graph axes
    hAxesA = axes('Parent',hFigA,'Position',[.05 .05 .42 .8],...
        'color','k','tickdir','in','nextplot','replacechildren',...
        'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
    set(hAxesA,'DataAspectRatio',[1 1 1])
    set(hAxesA,'DrawMode','fast')
    set(hAxesA,'units','pix')
    axesApos = get(hAxesA,'position');
    set(hAxesA,'units','normalized')

    hAxesB = axes('Parent',hFigA,'Position',[.55 .05 .42 .8],...
        'color','k','tickdir','in','nextplot','replacechildren',...
        'xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
    set(hAxesB,'DataAspectRatio',[1 1 1])
    set(hAxesB,'DrawMode','fast')
    set(hAxesB,'units','pix')
    set(hAxesB,'units','normalized')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame reset button
    frmResetPos = get(hAxesA,'Position');
    frmResetPos = frmResetPos.*[1.3 1.1 0.5 0.02];
    hCreset = uicontrol('style','pushbutton','units','normalized',...
        'string','Reset Frame','Position',frmResetPos,'fontunits','normalized','fontsize',.4638,...
        'parent',hPanA,'callback',@resetFigCallback,'visible','on','Enable','on');
    %set(hCreset,'position',[.4,.01,.2,.03])
    set(hCreset,'position',[.65,.01,.34,.15]) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Labels
    guiStrCell = {'Select User','','','',''};
    guiStrCt = numel(guiStrCell);
    compoStrCell = cat(1,guiStrCell(:));
    hTlabels = zeros(guiStrCt,1);
    hTedit = zeros(guiStrCt,1);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables
hIm_1 = [];                 hIm_2 = [];                 stim_start_frame = [];    
collect_list = [];          exp_list = [];              vid_list = [];              exp_id = [];                vidName = [];                   vidOps = [];
vidHeight = [];             vidWidth = [];              vidFrames_partial = [];     
frmNum = [];                frmOps = [];                zoomMag = 1;                clickPos = [];              centerIm = [];              video_index = 1;
vidOff = 0;                 vidObjCell = cell(2,1);     collect_select = [];        frameReferenceMesh = [];    
frameRefcutrate = [];       frameReffullrate = [];      group_list = [];           
auto_annotations = [];      stimuli_info = [];          assess_table = [];          man_annotations = [];       track_data = [];
frm_remap = [];             saved_data = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% timmers used
tFig  = timer('TimerFcn',@timerFigFun, 'ExecutionMode','fixedRate','Period',0.1);
tZoom = timer('TimerFcn',@timerZoomFun,'ExecutionMode','fixedRate','Period',0.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% starting functions
load_options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selct video options
    function load_options(~,~)
        reset_video
        turn_flags_off
        set(hTedit,'Value',1);
        set(hCnextFile,'string','Next Experiment');
        set(hCprevFile,'string','Prev Experiment');
        set(hTedit(1),'String', ['...';saved_users],'Callback', @select_user);
    end
    function select_user(hObj,~)
        reset_video
        turn_flags_off
        
        set(hTedit(2),'Value',1,'String','....');
        set(hTedit(3),'Value',1,'String','....');
        set(hTedit(4),'Value',1,'String','....');
        set(hTedit(5),'Value',1,'String','....');
        user_val = get(hObj,'Value');
        user_select = saved_users(user_val-1);
        
        if strcmp(user_select,'All Users')
            collect_list = [saved_collections.Collection_Name;'All Collections'];
            group_list = [unique(saved_groups.Properties.RowNames);'All Groups'];
            num_list =[get(saved_collections,'ObsNames');{'0000'}];
            num_list = cellfun(@(x,y) [x ' :: ' y],num_list,collect_list,'uniformoutput',false);
        else
            logic_match = strcmp(saved_collections.User_ID,user_select);
            num_list = get(saved_collections(logic_match,:),'ObsNames');
            collect_list = saved_collections(logic_match,:).Collection_Name;
            num_list = cellfun(@(x,y) [x ' :: ' y],num_list,collect_list,'uniformoutput',false);
            group_list = saved_groups(strcmp(saved_groups.User_ID,user_select),:);
            group_list = unique(group_list.Properties.RowNames,'stable');
        end
        
        set(hTedit(2),'String',[{'...'};num_list],'Callback', @select_list);
        set(hTlabels(2),'String','Select Collection:');
        
        set(hTedit(3),'String',[{'...'};group_list],'Callback', @select_list);
        set(hTlabels(3),'String','Select  Group:');
    end
    function select_list(hObj,~)
        reset_video
        collect_val = get(hObj,'Value') - 1;
        
        set(hTlabels(4),'String','Select Experiment_ID:');
        if hObj == hTedit(2)
            set(hTedit(3),'value',1);
            collect_select = collect_list(collect_val);
            if strcmp(collect_select,'All Collections')
                load_files = exp_dir;
            else
                Collect_index = get(saved_collections(strcmp(saved_collections.Collection_Name,collect_select),:),'ObsName');
                load_files = exp_dir(cellfun(@(x) strcmp(x(1:4),Collect_index{1}),exp_dir));
            end
        elseif hObj == hTedit(3)
            set(hTedit(2),'value',1);
            collect_select = group_list(collect_val);
            if strcmp(collect_select,'All Groups')
                load_files = exp_dir;
            else
                load_files = (saved_groups(strcmp(saved_groups.Properties.RowNames,collect_select),:).Experiment_IDs);
                load_files = unique(load_files{1});
                load_files = cellfun(@(x) strtrim(x),load_files,'uniformoutput',false);
            end
        end
        exp_list = regexprep(load_files,'.mat','');
        [~,si] = sort(cellfun(@(x) x(13:16),exp_list,'uniformoutput',false));
        load_files = exp_list(si);
        
        set(hTedit(4),'String',['...';load_files],'Callback', @populate_vid_list);
        set(hCnextFile,'enable','on');
        set(hCprevFile,'enable','on');
    end
    function populate_vid_list(hObj,~)
        reset_video
        set(hTedit(5),'value',1);
        vid_val = get(hObj,'Value');
        exp_list = get(hObj,'String');
        exp_id = exp_list{vid_val};

        try
            man_annotations = load([analysis_path filesep exp_id filesep exp_id '_manualAnnotations']);
        catch
            nfileCallback
        end
        autoPath = [analysis_path filesep exp_id filesep exp_id '_automatedAnnotations.mat'];
        if exist(autoPath,'file') ==2
            auto_annotations = load([analysis_path filesep exp_id filesep exp_id '_automatedAnnotations']);
            auto_annotations = auto_annotations.automatedAnnotations;
        else
            auto_annotations = [];
        end
        stimuli_info = load([analysis_path filesep exp_id filesep exp_id '_videoStatisticsMerged']);
        assess_table = load([analysis_path filesep exp_id filesep exp_id '_rawDataAssessment']);
        
        man_annotations = man_annotations.manualAnnotations;
        stimuli_info = stimuli_info.videoStatisticsMerged;
        assess_table = assess_table.assessTable;
        
%        vid_list = man_annotations.Properties.RowNames;
        tracked_list = struct2dataset(dir(fullfile([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v13'],'*.mat')));
        tracked_list = regexprep(tracked_list.name,'_flyAnalyzer3000_v13_data.mat','');
        
        vid_list = tracked_list;
        
        set(hTlabels(5),'String','Select Video:');

        filter_vid_list
    end
    function filter_vid_list(~,~)
        
        if isempty(vid_list)
            set(hTedit(5),'value',1,'String','...','enable','off')
            nfileCallback
        end
        if ~isempty(assess_table)
            single_logic = cellfun(@(x) strcmp(x,'Single'),assess_table.Fly_Count);
            balance_logic = cellfun(@(x) strcmp(x,'None'),assess_table.Balancer);
            condition_logic = cellfun(@(x) strcmp(x,'Good'),assess_table.Physical_Condition);
            accuracy_logic = cellfun(@(x) strcmp(x,'Good'),assess_table.Fly_Detect_Accuracy);
            decision_logic = cellfun(@(x) strcmp(x,'Pass'),assess_table.Raw_Data_Decision);
            nidaq_logic = cellfun(@(x) strcmp(x,'Good'),assess_table.NIDAQ);
            
            usuable_logic = single_logic & balance_logic & condition_logic & accuracy_logic & decision_logic & nidaq_logic;
        end        
  
        if ~isempty(man_annotations)
            man_annotations = man_annotations(assess_table(usuable_logic,:).Properties.RowNames,:);
            vid_list = man_annotations.Properties.RowNames;            
            
            done = cellfun(@(x) ~isempty(x),man_annotations.frame_of_take_off);
            vid_list(~done) = [];
            temp_annotate = man_annotations(done,:);
            temp_auto = auto_annotations(done,:);
            jump_logic = cellfun(@(x,y) ~isnan(x) & x > y,temp_annotate.frame_of_take_off,temp_auto.visStimFrameStart);
            
            vid_list(~jump_logic) = [];
        end        
        org_list_index = cellfun(@(y) sprintf('%04s',num2str(y)),num2cell(1:1:height(man_annotations))','UniformOutput',false);
        org_list_index = org_list_index(ismember(man_annotations.Properties.RowNames,vid_list));
        
        index = cellfun(@(x) strfind(x,'expt'),vid_list);
        if ~isempty(vid_list)
            short_list = cellfun(@(x,y,z) sprintf('%s%04s_orgvid%04s',x(index:(index+23)),num2str(y),num2str(z)),vid_list,num2cell(1:1:length(index))',org_list_index,'UniformOutput',false);        
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
        set(hCreset,'Enable','on');
        
        vidOps = vid_list;
        vidOps = circshift(vidOps,-vidOff+1);
        vidOff = 1;
        vidName = vid_list(video_index,:);
%        create_save_data
        videoLoad
    end
    function create_save_data(~,~)
        table_headers = [{'Video_Quality'},{'Stimuli_Position'},{'Stim_Frame_head_pos'},{'Stim_Frame_center_pos'},{'Stim_Frame_tail_pos'},{'Leg_push_head_pos'},{'Leg_push_center_pos'},{'Leg_push_tail_pos'},...
            {'Start_leg_left'},{'Start_leg_right'},{'Push_leg_left'},{'Push_leg_right'}];
        saved_data = cell(1,length(table_headers));
        saved_data = cell2table(saved_data);
        saved_data.Properties.RowNames = vidName;
        saved_data.Properties.VariableNames = table_headers;        
        saved_data.Video_Quality = {'Good'};
        
%         if isempty(leg_data)
%             set_saved_data_defaults
%         elseif ismember(vidName,leg_data.Properties.RowNames);
%             saved_data = leg_data(vidName,:);
%             set_saved_toggle
%         else
%             set_saved_data_defaults
%         end
    end
    function set_saved_data_defaults(~,~)
        saved_data.Stimuli_Position = {nan};
        saved_data.Stim_Frame_head_pos = {nan,nan};
        saved_data.Stim_Frame_center_pos = {nan,nan};
        saved_data.Stim_Frame_tail_pos = {nan,nan};
        saved_data.Leg_push_head_pos = {nan,nan};
        saved_data.Leg_push_center_pos = {nan,nan};
        saved_data.Leg_push_tail_pos = {nan,nan};  
        
        saved_data.Start_leg_left = [nan,nan];
        saved_data.Start_leg_right = [nan,nan];
        saved_data.Push_leg_left = [nan,nan];
        saved_data.Push_leg_right = [nan,nan];
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load and parsing functions
    function videoLoad
        delete(get(hAxesA,'Children'));
        delete(get(hAxesB,'Children'));
        set(hAxesA,'NextPlot','Add');
        set(hAxesB,'NextPlot','Add');
        vid_name = vidName{1};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);
        
        try
             temp_vidStats = stimuli_info(vidName,:);
        catch
             stimuli_info = stimuli_info.videoStatisticsMerged;
             temp_vidStats = stimuli_info(vidName,:);
        end
        try
            track_data = load([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v13' filesep vidName{1} '_flyAnalyzer3000_v13_data']);
            track_data = track_data.saveobj;            
            annotation_data = load([analysis_path filesep exp_id filesep exp_id '_automatedAnnotations']);
            annotation_data  = annotation_data.automatedAnnotations;
            annotation_data = annotation_data(track_data.Properties.RowNames,:);
            
%            man_data = load([analysis_path filesep exp_id filesep exp_id '_manualAnnotations']);
%            man_data = man_data.manualAnnotations;
%            man_data = man_data(track_data.Properties.RowNames,:);
%            leg_push_frame = cell2mat(man_data.frame_of_leg_push);
            
            stim_start_frame = annotation_data.visStimFrameStart;
            stim_start_frame = cell2mat(stim_start_frame);
            vid_stats = load([analysis_path filesep exp_id filesep exp_id '_videoStatisticsMerged']);
            vid_stats = dataset2table(vid_stats.videoStatisticsMerged(track_data.Properties.RowNames,:));
            track_data = [track_data,vid_stats];                        
        catch           %no track data
            track_data = [];
        end
        if isempty(cell2mat(track_data.final_frame_tracked))                         %empty tracking
            setnextvid
        elseif cell2mat(track_data.final_frame_tracked) < (stim_start_frame+200)     %short tracking
            setnextvid
        end
                
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
        vidHeight = vidObj_partail.Height;
        vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>
        vidHeight = 384;
        
        frameRefcutrate = double(temp_vidStats.cutrate10th_frame_reference{1});
        frameReffullrate = double(temp_vidStats.supplement_frame_reference{1});
        Y = (1:numel(frameRefcutrate));
%        x = frameRefcutrate;
        xi = (1:(vidFrames_partial*10));
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*10));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
        
        frmOps = 1:1:(vidFrames_partial*10);
        frmOps = frmOps';
                
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
        frmData = frmData(448:end,:,:);
        hIm_1 = image('Parent',hAxesA,'CData',frmData);
        hIm_2 = image('Parent',hAxesB,'CData',frmData);   
                   
        videoDisp(hAxesA)
        videoDisp(hAxesB)
        plot_tracking_data(hAxesA)
        plot_tracking_data(hAxesB)

        resetFigCallback
    end
    function plot_tracking_data(curr_axis)
        error_flag = 0;
        bot_vector = track_data.bot_points_and_thetas{1};
        fly_len = track_data.fly_length{1};
%        set(hStim_pos,'string',sprintf('Stimuli Position Relative to Fly ::  %4.2f',));                
        if curr_axis == hAxesA
            try
                pos_vect = bot_vector(stim_start_frame,:);
            catch
                error_flag = 1;
            end
        elseif curr_axis == hAxesB
            try
                last_track = cell2mat(track_data.final_frame_tracked);
                pos_vect = bot_vector((last_track - 100),:);
            catch
                error_flag = 1;
            end
        end
        if error_flag == 0;
            set(curr_axis,'nextplot','add')
            plot(pos_vect(1),pos_vect(2),'r.','parent',curr_axis,'markersize',20);

            h_quiv = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',curr_axis,'Visible','off');
            u = cos(pos_vect(:,3))*fly_len/2;
            v = -sin(pos_vect(:,3))*fly_len/2;
            set(h_quiv,'XData',pos_vect(1),'YData',pos_vect(2),...
                    'MaxHeadSize',5,'LineWidth',1.5,'AutoScaleFactor',1,'color',rgb('red'),'UData',u,'VData',v,'visible','on')            
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% show the video
    function videoDisp(curr_axis,~)
        last_track = cell2mat(track_data.final_frame_tracked);        
        if isempty(last_track)
            return
        elseif last_track <  (stim_start_frame + 200)
            return
        end
        
        if nargin == 0
            frmNum = 1;
            curr_axis = gca;
        elseif curr_axis == hAxesA
            frmNum = stim_start_frame;
        elseif curr_axis == hAxesB
            frmNum = last_track - 100;
        end
        if isempty(frameReferenceMesh)
            return
        end
        if isnan(frameReferenceMesh(frmNum,2))
            frmNum = find(~isnan(frameReferenceMesh(:,2)),1,'last');
        end
        frmData = read(vidObjCell{frameReferenceMesh(frmNum,3)},frameReferenceMesh(frmNum,2));
        frmData = frmData(448:end,:,:);

        backoff = 15;
        tI = log(double(frmData(:,:,1))+backoff);
        frmAdj = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
        frmAdj = intlut(frmAdj,frm_remap);

        frmData = frmAdj;
        if curr_axis == hAxesA
            set(hIm_1,'CData',frmData,'parent',curr_axis);
        elseif curr_axis == hAxesB
            set(hIm_2,'CData',frmData,'parent',curr_axis);
        end        
        drawnow
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% button toggle functions
    function turn_flags_off(~,~)
        set(hCreset,'Enable','off');
        set(hCnextVid,'Enable','off');
        set(hCprevVid,'Enable','off');
        set(hCnextFile,'Enable','off');
        set(hCprevFile,'Enable','off');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% next and last experiment
    function pfileCallback(~,~)
        save_clicked_points        
        resetbuttons
        create_save_data
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        timerZoomFun([],[])
        
        gammaResetCallback
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
        save_clicked_points        
        resetbuttons
        create_save_data
        timerZoomFun([],[])
        
        gammaResetCallback
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
%        save_clicked_points        
        resetbuttons
        
        timerZoomFun([],[])
        
        if video_index > 1
            video_index = video_index - 1;
        else
            video_index = length(vidOps);
        end
        vidName = vid_list(video_index,:);
        
        set(hTedit(5),'Value',video_index+1)
        
        create_save_data
        videoLoad
    end
    function setnextvid(~,~)
        if length(vidOps) == 1
            return
        end
%        save_clicked_points        
        resetbuttons
        timerZoomFun([],[])
        
        if video_index < length(vidOps)
            video_index = video_index + 1;
        else
            video_index = 1;
        end
        
        vidName = vid_list(video_index,:);
        set(hTedit(5),'Value',video_index)
        
%        create_save_data
        videoLoad
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% figure click functions
    function FigClickCallback(~,~)
        clickPos = get(0,'PointerLocation');
        set(hCreset,'Visible','on')
        minPos = clickPos-FigPos(1:2)-axesApos(1:2);
        maxPos = axesApos(3:4)-minPos;
        if min([minPos maxPos]) > 0 && strcmp(get(hCreset,'Enable'),'on')
            start(tFig)
        end
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
        stop(tFig)
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
        
        set(hAxesB,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth]+dragDist(1),...
            'ylim',[centerIm(2)-hHeight centerIm(2)+hHeight]-dragDist(2))
        
        videoDisp(hAxesA)
        videoDisp(hAxesB)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% zoom function
    function timerZoomFun(~,~)
%         if ~isempty(diodeData)
%             zoomVal = 1-get(hCzoom,'Value');
%             tarSpan = length(frmOps)*zoomVal/2;
%             xlimGrph = [-tarSpan tarSpan]+frmNum;
%             minXlim = min(xlimGrph);
%             maxXlim = length(frmOps)-max(xlimGrph);
%             if minXlim < 1
%                 xlimGrph = xlimGrph-minXlim+1;
%             elseif maxXlim < 0
%                 xlimGrph = xlimGrph+maxXlim;
%             end
%             set(hAxesB,'XLim',xlimGrph)
%         end
        %         get(hAxesB)
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reset/clear and save functions
    function reset_video
        resetbuttons
        hIm_1 = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
        set(hIm_1,'CData',(zeros(vidHeight,vidWidth,1)))
        
        hIm_2 = image('Parent',hAxesB,'CData',zeros(vidHeight,vidWidth,1));
        set(hIm_2,'CData',(zeros(vidHeight,vidWidth,1)))
    end
    function resetbuttons
        resetFigCallback
    end
    function myCloseFun(~,~)
        delete(tZoom)
        delete(hFigA)
    end

end


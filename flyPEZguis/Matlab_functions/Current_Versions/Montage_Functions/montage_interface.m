function montage_interface
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir));
    addpath(fullfile(fileparts(repositoryDir),'Support_Programs'));
    addpath(fullfile(repositoryDir,'Analysis Programs'));
    
    
    op_sys = system_dependent('getos');
    if contains(op_sys,'Microsoft Windows')
        file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
    else
        file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
    end

    Collection = load([file_dir filesep 'Saved_Collection.mat']);
    Genotypes = load([file_dir filesep 'Saved_Genotypes.mat']);
    Protocols = load([file_dir filesep 'Saved_Protocols_new_version.mat']);


    backColor = [0 0 0.2];
    %%%%% Figure and children %%%%%
    FigPos =  [78  113  2022  789];
    %FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),(scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
    hFigA = figure('NumberTitle','off','menubar','none','units','pix','Color',backColor,'pos',FigPos,'colormap',gray(256));
    
    m_filter = uimenu(hFigA,'Label','Filter ID By User');
    m_select = uimenu(hFigA,'Label','Select Exp ID','callback',@toggle_view);
    m_display = uimenu(hFigA,'Label','Display Summary Frame','callback',@toggle_view);
    
    userNames = unique(Collection.Saved_Collection.User_ID);
    userStrings = [{'No user selected'};userNames(:)];
    hUserMenu = zeros(1,numel(userStrings));
    for iterUser = 1:numel(userStrings)
        hUserMenu(iterUser) = uimenu(m_filter,'Label',userStrings{iterUser},...
            'Callback',@filter_id_list);
    end    
    

    % control panel
    hPanA = uipanel('Position',[0 .0 .2 1],'Visible','Off');
    hPanB = uipanel('Position',[0 .0 .5 1],'Visible','On');
    
    collect_table = uicontrol(hPanB,'Style','listbox','units','normalized','position',[0 .5 1 .5]);
    geno_table = uicontrol(hPanB,'Style','listbox','string','','units','normalized','position',[0 0 .5 .5]);
    proto_table = uicontrol(hPanB,'Style','listbox','string','','units','normalized','position',[0.5 0 .5 .5]);

    valid_id_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
    valid_id_list = valid_id_list(cellfun(@(x) length(x) == 16,valid_id_list.name),:).name;
    valid_id_list = valid_id_list(cellfun(@(x) ~isnan(str2double(x)),valid_id_list));
    valid_id_list = valid_id_list(cellfun(@(x) str2double(x(1:4)) >= 40,valid_id_list));
    Collection.Saved_Collection(str2double(get(Collection.Saved_Collection,'ObsNames')) < 40,:) = [];
        

    collect_ids = (cellfun(@(x) x(1:4),valid_id_list,'UniformOutput',false));
    uni_collect = unique(collect_ids);      collect_select = [];
    collectionNames = get(Collection.Saved_Collection,'ObsName');
    [locA,locB] = ismember(uni_collect,collectionNames);
    collection_info = Collection.Saved_Collection(locB(locA),:);
    
    uni_geno = [];                          geno_select = [];
    uni_proto = [];                         proto_select = [];    
    
    new_string = cellfun(@(x,y) sprintf('%s :: %s',x,y),uni_collect,collection_info.Collection_Name,'UniformOutput',false);
    set(collect_table,'string',['Select Collection';new_string],'callback',@filter_geno_list);


    expIDlist = [];     fly_image = [];     hImageAxis = [];        frmFullD = []; 
    all_markers = [];   all_stimuli = [];   sample_data= [];   
    

    Frame_Input = [];
    center_disp = false;                stimuli_disp = false;
    border_disp = false;                fly_logic = 'all';
    sort_order = 'none';                download_frames = 'all';
    download_rate = 10;                 center_mass_opts = 'none';
    
    size_choice_c = 3;                  color_choice_c = 'red';
    size_choice_s = 3;                  color_choice_s = 'red';
    
    color_border = 'red';
    fly_view = 'top';
    fly_rot = 'none';
    fly_align = 90;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% center of mass options
    show_center = uicontrol(hPanA,'Style','pushbutton','string','Center Of Mass','Units','normalized','Position',[.05 .940 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_center);
    center_color = uicontrol(hPanA,'Style','popup','string',[{'Color'};{'blue'};{'green'};{'red'};{'cyan'};{'magenta'};{'yellow'};{'black'};{'white'}],...
                'Units','normalized','Position',[.375 .920 .3 .0750],'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits',...
                'normalized','fontsize',.2000,'FontWeight','bold','UserData',0,'callback',@add_markers,'enable','off');
    center_size = uicontrol(hPanA,'Style','popup','string',[{'Size'};{'3'};{'4'};{'5'};{'6'};{'7'};{'8'};{'9'};{'10'}],'Units','normalized','Position',[.375 .875 .3 .0750],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.200,'FontWeight','bold','UserData',0,'callback',@add_markers,'enable','off');
     
    uicontrol(hPanA,'Style','text','string','Points to Plot','Units','normalized','Position',[.7 .965 .3 .030],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'FontWeight','bold');
     
    center_plot_opts = uicontrol(hPanA,'Style','popup','string',[{'Continious'};{'Per Frame'}],'Units','normalized','Position',[.7 .90 .4 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','Value',1,'enable','off','callback',@center_opts);     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% stimuli options
    show_stimuli = uicontrol(hPanA,'Style','pushbutton','string','Show Stimuli','Units','normalized','Position',[.05 .840 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_stim);
    stimuli_color = uicontrol(hPanA,'Style','popup','string',[{'Color'};{'blue'};{'green'};{'red'};{'cyan'};{'magenta'};{'yellow'};{'black'};{'white'}],...
                'Units','normalized','Position',[.375 .825 .3 .0750],'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits',...
                'normalized','fontsize',.2000,'FontWeight','bold','UserData',0,'callback',@add_markers,'enable','off');
    stimuli_size = uicontrol(hPanA,'Style','popup','string',[{'Size'};{'3'};{'4'};{'5'};{'6'};{'7'};{'8'};{'9'};{'10'}],'Units','normalized','Position',[.375 .78 .3 .0750],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.200,'FontWeight','bold','UserData',0,'callback',@add_markers,'enable','off');
     
    uicontrol(hPanA,'Style','text','string','Stimuli Orientation','Units','normalized','Position',[.7 .872 .3 .030],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'FontWeight','bold');     
     
    stimuli_plot_opts = uicontrol(hPanA,'Style','popup','string',[{'Normal Position'};{'Aligned to same side'}],'Units','normalized','Position',[.7 .805 .4 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','Value',1,'enable','off','callback',@flip_stim);     
     
     
    show_grid = uicontrol(hPanA,'Style','pushbutton','string','Show Borders','Units','normalized','Position',[.05 .765 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_border);     
    border_color = uicontrol(hPanA,'Style','popup','string',[{'Color'};{'blue'};{'green'};{'red'};{'cyan'};{'magenta'};{'yellow'};{'black'};{'white'}],...
                'Units','normalized','Position',[.375 .73 .3 .0750],'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits',...
                'normalized','fontsize',.2000,'FontWeight','bold','UserData',0,'callback',@add_markers,'enable','off');
            
    uicontrol(hPanA,'Style','text','string','Fly Postion','Units','normalized','Position',[.05 .700 .3 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold');
    uicontrol(hPanA,'Style','text','string','Fly Rotation','Units','normalized','Position',[.37 .700 .3 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold');
    uicontrol(hPanA,'Style','text','string','Rotation Amount','Units','normalized','Position',[.68 .700 .3 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold');
            
    fly_position = uicontrol(hPanA,'Style','popup','string',[{'Top View'};{'Bottom View'}],'Units','normalized','Position',[.05 .650 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',1,'callback',@toggle_fly_view);
    fly_rot_opt =  uicontrol(hPanA,'Style','popup','string',[{'No Rotation'};{'Flies Aligned'}],'Units','normalized','Position',[.37 .650 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_fly_view);     
    fly_rot_amt = uicontrol(hPanA,'Style','popup','string',{'No Rotation'},'Units','normalized','Position',[.68 .650 .3 .050],'enable','off',...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_fly_view);               
%    fly_rotation = uicontrol(hPanA,'Style','popup','string',[{'No Rotation'};{'top(90)'};{'left(0)'};{'down (270)'};{'right (180'}],'Units','normalized','Position',[.68 .650 .3 .050],...
%         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@toggle_fly_view);          
            

    uicontrol(hPanA,'Style','text','string',sprintf('Select Data Filter'),'Units','normalized','Position',[.05 .600 .9 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0);
            
    All_Data = uicontrol(hPanA,'Style','pushbutton','string','All Flies','Units','normalized','Position',[.03 .525 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_filter_list);
    Jumpers_Only = uicontrol(hPanA,'Style','pushbutton','string','Jumpers Only','Units','normalized','Position',[.35 .525 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_filter_list);                
    Centered_Flies = uicontrol(hPanA,'Style','pushbutton','string','Centered Flies','Units','normalized','Position',[.68 .525 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_filter_list);
    
    uicontrol(hPanA,'Style','text','string',sprintf('Select Sort Order'),'Units','normalized','Position',[.05 .460 .9 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0);

    No_Order = uicontrol(hPanA,'Style','pushbutton','string','No Sorting','Units','normalized','Position',[.03 .400 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_sort_order);
    Rand_Order = uicontrol(hPanA,'Style','pushbutton','string','Random Order','Units','normalized','Position',[.35 .400 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_sort_order,'enable','off');
    Time_of_Jump = uicontrol(hPanA,'Style','pushbutton','string','Time Of Jump','Units','normalized','Position',[.68 .400 .3 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3000,'FontWeight','bold','UserData',0,'callback',@set_sort_order);                
     
    uicontrol(hPanA,'Style','text','string',sprintf('Select Download Range'),'Units','normalized','Position',[.05 .33 .9 .040],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0);
     
    Full_Video = uicontrol(hPanA,'Style','pushbutton','string','Download Full Video','Units','normalized','Position',[.05 .270 .425 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2700,'FontWeight','bold','UserData',1,'callback',@toggle_rate);
    Around_jump = uicontrol(hPanA,'Style','pushbutton','string','Around Jump Frame','Units','normalized','Position',[.5 .270 .425 .050],...
         'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2700,'FontWeight','bold','UserData',0,'callback',@toggle_rate);
     
    Frame_Input = uicontrol(hPanA,'Style','edit','string','10','Units','normalized','Position',[.80 .20 .25 .050],...
                 'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3500,'FontWeight','bold','UserData',0,'callback',@change_frame_rate);     
     
    Frame_Range = uicontrol(hPanA,'Style','text','string','Download Every ____  Frames','Units','normalized','Position',[.05 .20 .725 .050],...
                 'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3500,'FontWeight','bold','UserData',0);
             
             
        uicontrol(hPanA,'Style','pushbutton','string','Refresh Sample Image','Units','normalized','Position',[.05 .1 .9 .07],...
                 'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3500,'FontWeight','bold','UserData',0,'callback',@refresh_img);                          
        uicontrol(hPanA,'Style','pushbutton','string','Make Video','Units','normalized','Position',[.05 .025 .9 .07],...
                 'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3500,'FontWeight','bold','UserData',0,'callback',@make_video);             

    function filter_id_list(hObj,~)
        user_selected = get(hObj,'Label');
        uni_collect = unique(collect_ids);
        matching_logic = ismember(Collection.Saved_Collection.User_ID,user_selected);
        
        collectionNames = get(Collection.Saved_Collection(matching_logic,:),'ObsName');
        
        [locA,locB] = ismember(collectionNames,uni_collect);
        uni_collect = uni_collect(locB(locA));
        collection_info = Collection.Saved_Collection(matching_logic,:);
       
        new_string = cellfun(@(x,y) sprintf('%s :: %s',x,y),uni_collect,collection_info.Collection_Name,'UniformOutput',false);
        set(collect_table,'string',['Select Collection';new_string],'callback',@filter_geno_list);
    end
    function switch_view(~,~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% default options
        set(hPanB,'Visible','Off');
        set(hPanA,'Visible','On');
        
        set_defaults
        
        sample_data = Experiment_ID(expIDlist{1});
        sample_data.parse_data;
        chrim_logic = cellfun(@(x) contains(x,'None'),sample_data.parsed_data.Stimuli_Type);
        stimuli_used = sample_data.parsed_data.Stimuli_Type;
        stimuli_used(chrim_logic) = cellfun(@(y) y{1}, sample_data.parsed_data(chrim_logic,:).Photo_Activation,'UniformOutput',false);
        sample_data.parsed_data.Stimuli_Type = stimuli_used;    
    
        [primary_stimuli,secondary_stimuli] = get_stimuli_info(sample_data.parsed_data);
        if contains(primary_stimuli,'Intensity') && contains(secondary_stimuli,'None') 
            stim_type = 'chrim';
        elseif contains(primary_stimuli,'Intensity') && contains(secondary_stimuli,'loom') 
            stim_type = 'combo';
        elseif contains(primary_stimuli,'loom') && contains(secondary_stimuli,'None') 
            stim_type = 'loom';        
        elseif contains(primary_stimuli,'wall') && contains(secondary_stimuli,'loom') 
            stim_type = 'loom';
        end    

        frame_count = 1;

        if strcmp(stim_type,'chrim')            %if chrim pulse, do not show stim opts
            set(show_stimuli,'enable','off')
            set(stimuli_color,'enable','off')
            set(stimuli_size,'enable','off')
            set(stimuli_plot_opts,'enable','off')
        end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% default variables    
         hImageAxis = axes('Parent',hFigA,'Position',[.2 0 .8 1],'color','w','tickdir','in','nextplot','replacechildren','xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');

    %    [frmFullD,all_markers,all_stimuli] = vidMontage_testing(expIDlist,stim_type,'sort_order','time_of_jump','frame_count',frame_count);
         [frmFullD,all_markers,all_stimuli,sample_data] = vidMontage_testing(expIDlist,'frame_count',frame_count,'sort_order',sort_order,'center_mass_opts',center_mass_opts,'rotate_opt','none',...
             'Show_center',center_disp,'Show_Stimuli',stimuli_disp,'Show_Border',border_disp,'Logic_Filter',fly_logic,'Download_Frames',download_frames,'Download_Range',download_rate,...
             'view_opt',fly_view,'rotate_opt',fly_rot,'rotate_amt',fly_align);


         fly_image = image('Parent',hImageAxis,'CData',frmFullD);
         set(hImageAxis,'Ylim',[0 size(frmFullD,1)],'Xlim',[0 size(frmFullD,2)])
    end
    function set_defaults(~,~)
        set_filter_list(All_Data)
        toggle_rate(Full_Video)
        set_sort_order(No_Order)
    end    
    function toggle_center(~,~)
        if sum(get(show_center,'backgroundcolor') == [.8 .8 .8]) == 3
            set(show_center,'backgroundcolor',rgb('very light blue'));
            set(center_color,'enable','on');
            set(center_size,'enable','on');
            set(center_plot_opts,'enable','on')
        elseif sum(get(show_center,'backgroundcolor') == rgb('very light blue')) == 3
            set(show_center,'backgroundcolor',[.8 .8 .8]);
            set(center_color,'enable','off');
            set(center_size,'enable','off');
            set(center_plot_opts,'enable','off');

            center_mass_opts = 'all';
            fly_image = image('Parent',hImageAxis,'CData',frmFullD);
        end        
        add_markers        
    end
    function center_opts(hObj,~)
        if get(hObj,'value') == 1
            center_mass_opts = 'all';
        elseif get(hObj,'value') == 2
            center_mass_opts = 'single';            
        end
    end
    function toggle_stim(~,~)
        if sum(get(show_stimuli,'backgroundcolor') == [.8 .8 .8]) == 3
            set(show_stimuli,'backgroundcolor',rgb('very light blue'));
            set(stimuli_color,'enable','on');
            set(stimuli_size,'enable','on');
            set(stimuli_plot_opts,'enable','on')
            add_markers
        elseif sum(get(show_stimuli,'backgroundcolor') == rgb('very light blue')) == 3
            set(show_stimuli,'backgroundcolor',[.8 .8 .8]);
            set(stimuli_color,'enable','off');
            set(stimuli_size,'enable','off');
            set(stimuli_plot_opts,'enable','off')
            fly_image = image('Parent',hImageAxis,'CData',frmFullD);
        end     
        add_markers
    end
    function toggle_border(~,~)
        if sum(get(show_grid,'backgroundcolor') == [.8 .8 .8]) == 3
            set(show_grid,'backgroundcolor',rgb('very light blue'));
            set(border_color,'enable','on')
            border_disp = true;
        elseif sum(get(show_grid,'backgroundcolor') == rgb('very light blue')) == 3
            set(show_grid,'backgroundcolor',[.8 .8 .8]);
            set(border_color,'enable','off')
            border_disp = false;
            fly_image = image('Parent',hImageAxis,'CData',frmFullD);
        end        
        add_markers
    end
    function add_markers(~,~)
        stimuli_disp = false;
        center_disp = false;
        size_index = get(center_size,'value');  size_opts = get(center_size,'string');
        if size_index == 1
            size_choice_c = 3;
        else
            size_choice_c = str2double(size_opts(size_index));
        end
           
        color_index = get(center_color,'value');  color_opts = get(center_color,'string');
        if color_index == 1
            color_choice_c = 'red';
        else
            color_choice_c = color_opts(color_index);
        end 
        
        size_index = get(stimuli_size,'value');  size_opts = get(stimuli_size,'string');
        if size_index == 1
            size_choice_s = 3;
        else
            size_choice_s = str2double(size_opts(size_index));
        end
           
        color_index = get(stimuli_color,'value');  color_opts = get(stimuli_color,'string');
        if color_index == 1
            color_choice_s = 'red';
        else
            color_choice_s = color_opts(color_index);
        end         
   
        
        if sum(get(show_stimuli,'backgroundcolor') == rgb('very light blue')) == 3
            stimuli_disp = true;
        end
        if sum(get(show_center,'backgroundcolor') == rgb('very light blue')) == 3
            center_disp = true;
        end
        
        curr_image = frmFullD;
           
        if center_disp        
            frmFullD_center = insertMarker(curr_image,[all_markers(:,1) all_markers(:,2)+100],'o','size',size_choice_c,'color',color_choice_c);       %need to offset y_cord by size ot textfrm (100)
        else
            frmFullD_center = curr_image;
        end
        if stimuli_disp
            frmFullD_stim = frmFullD_center;
            for iterM = 1:length(all_stimuli)
                frmFullD_stim = insertMarker(frmFullD_stim,[all_stimuli{iterM}{1} all_stimuli{iterM}{2}+100],'o','size',size_choice_s,'color',color_choice_s);       %need to offset y_cord by size ot textfrm (100)
            end
        else
            frmFullD_stim = frmFullD_center;
        end        
        fly_image = image('Parent',hImageAxis,'CData',frmFullD_stim);
        
        if sum(get(show_grid,'backgroundcolor') == rgb('very light blue')) == 3
            draw_grid
            border_disp = true;
        end
    end
    function draw_grid(~,~)
        color_index = get(border_color,'value');  color_opts = get(border_color,'string');
        if color_index == 1
            color_choice = 'red';
        else
            color_choice = color_opts(color_index);
        end         
        for iterM = 1:length(all_stimuli)
            
            x_pos = mod(iterM,10);
            y_pos = (floor((iterM)/10));
            if x_pos == 0
                y_pos = y_pos - 1;
                x_pos = 10;
            end
            
            curr_image = get(fly_image,'Cdata');

            frmFullD_line = insertShape(curr_image, 'line', [192*(x_pos-1) 100+192*(y_pos) 192*(x_pos) 100+192*(y_pos)],'LineWidth',1,'color',color_choice);
            frmFullD_line = insertShape(frmFullD_line, 'line', [192*(x_pos-1) 100+192*(y_pos+1)   192*(x_pos) 100+192*(y_pos+1)],'LineWidth',1,'color',color_choice);
        
            frmFullD_line = insertShape(frmFullD_line, 'line', [0+192*(x_pos-1)  100+192*(y_pos) 0+192*(x_pos-1)  100+192*(y_pos+1)],'LineWidth',1,'color',color_choice);
            frmFullD_line = insertShape(frmFullD_line, 'line', [192*(x_pos)  100+192*(y_pos) 192*(x_pos)  100+192*(y_pos+1)],'LineWidth',2,'color',color_choice);
            
            color_border = color_choice;
            fly_image = image('Parent',hImageAxis,'CData',frmFullD_line);
        end
    end
    function set_sort_order(hObj,~)
        if hObj == No_Order
            set(No_Order,'backgroundcolor',rgb('light green'),'UserData',1);
            set(Rand_Order,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Time_of_Jump,'backgroundcolor',[.8 .8 .8],'UserData',0);
            sort_order = 'none';            
        elseif hObj == Rand_Order
            set(No_Order,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Rand_Order,'backgroundcolor',rgb('light green'),'UserData',1);
            set(Time_of_Jump,'backgroundcolor',[.8 .8 .8],'UserData',0);
            sort_order = 'random';
        elseif hObj == Time_of_Jump
            set(No_Order,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Rand_Order,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Time_of_Jump,'backgroundcolor',rgb('light green'),'UserData',1);
            sort_order = 'time_of_jump';            
        end           
    end
    function set_filter_list(hObj,~)
        if hObj == All_Data
            set(All_Data,'backgroundcolor',rgb('light green'),'UserData',1);
            set(Jumpers_Only,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Centered_Flies,'backgroundcolor',[.8 .8 .8],'UserData',0);
            fly_logic = 'none';            
        elseif hObj == Jumpers_Only
            set(All_Data,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Jumpers_Only,'backgroundcolor',rgb('light green'),'UserData',1);
            set(Centered_Flies,'backgroundcolor',[.8 .8 .8],'UserData',0);
            fly_logic = 'jumpers_only_auto';
        elseif hObj == Centered_Flies
            set(All_Data,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Jumpers_Only,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Centered_Flies,'backgroundcolor',rgb('light green'),'UserData',1);
            fly_logic = 'Centered_Flies';            
        end        
    end
    function toggle_rate(hObj,~)
        if hObj == Full_Video
            set(Full_Video,'backgroundcolor',rgb('light green'),'UserData',1);
            set(Around_jump,'backgroundcolor',[.8 .8 .8],'UserData',0);
            download_frames = 'all';
            
        elseif hObj == Around_jump
            set(Full_Video,'backgroundcolor',[.8 .8 .8],'UserData',0);
            set(Around_jump,'backgroundcolor',rgb('light green'),'UserData',1);
            download_frames = 'Jumpers';
        end
        set_frame_opts
    end
    function set_frame_opts(~,~)
        if get(Full_Video,'UserData') == 1
            set(Frame_Range,'string','Download Every ____  Frames');
        elseif get(Around_jump,'UserData') == 1
            set(Frame_Range,'string','Frames Around Jump: ');
        end
        set(Frame_Input,'string',num2str(download_rate));
    end
    function change_frame_rate(~,~)        
        download_rate = get(Frame_Input,'string');
    end

    function make_video(~,~)
        [file,path,~] = uiputfile('Z:\Montage_vid_test\sample_montage.mp4');

        usable_data = [vertcat(sample_data.Complete_usuable_data);vertcat(sample_data.Videos_Need_To_Work)];
        total_vids = height(usable_data);
        
        num_loops = ceil(total_vids/30);
        if num_loops > 5
            num_loops = 5;
        end
        for iterS = 1:num_loops
            tstart = tic;
            if iterS*30 < total_vids
                if isnumeric(sort_order)
                    sort_order = sort_order + (iterS-1)*30;
                end
            else
                if isnumeric(sort_order)
                    sort_order = ((iterS-1)*30+1):total_vids;
                end                    
            end                
            vidMontage_testing(expIDlist,'test_data',sample_data,'sort_order',sort_order,'center_mass_opts',center_mass_opts,'Center_Size',size_choice_c,'Center_Color',color_choice_c,...
                'Stimuli_Size',size_choice_s,'Stimuli_Color',color_choice_s,'Show_center',center_disp,'Show_Stimuli',stimuli_disp,'Show_Border',border_disp,'Border_Color',color_border,...
                'Logic_Filter',fly_logic,'Download_Frames',download_frames,'Download_Range',download_rate,'view_opt',fly_view,'rotate_opt',fly_rot,'rotate_amt',fly_align,'sort_order',sort_order,...
                'video_index',iterS,'save_path',path,'filename',file); 
                
            fprintf('video took %4.4f seconds\n',toc(tstart));
        end
    end
    function refresh_img(~,~)
        set(fly_image,'CData',uint8(zeros(1059,1920,3)));
        hold all
        text(1920/2,1059/2,'Refreshing Image','color',rgb('white'),'fontsize',20,'HorizontalAlignment','center')
        drawnow;        
        refresh_timer = tic;
        clear frmFullD all_markers all_stimuli
        [frmFullD,all_markers,all_stimuli,sample_data] = vidMontage_testing(expIDlist,'test_data',sample_data,'sort_order',sort_order,'center_mass_opts',center_mass_opts,'Center_Size',size_choice_c,'Center_Color',color_choice_c,...
            'Stimuli_Size',size_choice_s,'Stimuli_Color',color_choice_s,'Show_center',center_disp,'Show_Stimuli',stimuli_disp,'Show_Border',border_disp,'Border_Color',color_border,...
            'Logic_Filter',fly_logic,'Download_Frames',download_frames,'Download_Range',download_rate,'view_opt',fly_view,'rotate_opt',fly_rot,'rotate_amt',fly_align','frame_count',1);         

        hold off
        
        delete(get(hImageAxis,'Children'));
        
        fly_image = image('Parent',hImageAxis,'CData',frmFullD);
        drawnow;
        set(hImageAxis,'Ylim',[0 size(frmFullD,1)],'Xlim',[0 size(frmFullD,2)])
        toc(refresh_timer);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function toggle_view(hObj,~)
        if hObj == m_select
            set(hPanA,'Visible','Off');
            set(hPanB,'Visible','On');
            set(fly_image,'CData',uint8(zeros(1059,1920,3)));
            set(hImageAxis,'Position',[.5 0 .5 1]);
        elseif hObj == m_display
            if isempty(expIDlist)
                warning('no id selected')
            else
                set(hPanB,'Visible','Off');
                set(hPanA,'Visible','On');
                set(hImageAxis,'Position',[.2 0 .8 1]);
            end
        end
    end
    function toggle_fly_view(hObj,~)
        if hObj == fly_position
            selection = get(hObj,'Value');
            if selection == 1
                fly_view = 'top';
                fly_rot = 'none';
                set(fly_rot_opt,'Enable','Off','String','No Rotation','value',1);
                set(fly_rot_amt,'Enable','Off','String','No Rotation','value',1);
            end
            if selection == 2
                fly_view = 'bottom';
                fly_rot = 'none';
                set(fly_rot_opt,'Enable','On','String',[{'No Rotation'};{'Flies Aligned'}]);
                set(fly_rot_amt,'Enable','Off','String','No Rotation');
            end  
        elseif hObj == fly_rot_opt
            selection = get(hObj,'Value');
            if selection == 1
                set(fly_rot_amt,'Enable','Off','String','No Rotation');
                fly_rot = 'none';
                set(fly_rot_amt,'value',1);
            else
                set(fly_rot_amt,'string',[{'top(90)'};{'left(0)'};{'down (270)'};{'right (180'}],'enable','on');
                fly_rot = 'rotate';
                fly_align = 90;
            end 
        elseif hObj == fly_rot_amt
            selection = get(hObj,'value');
            switch selection
                case 1
                    fly_align = 90;
                case 2
                    fly_align = 0;
                case 3 
                    fly_align = -90;
                case 4
                    fly_align = 180;
            end
        end
    end
    function filter_geno_list(hObj,~)
        collect_index = get(hObj,'Value')-1;
        matching_valid_list = valid_id_list(ismember(collect_ids,uni_collect(collect_index)));
        collect_select = uni_collect(collect_index);
        geno_ids = (cellfun(@(x) x(5:12),matching_valid_list,'UniformOutput',false));
        uni_geno = unique(geno_ids);
        
        [locA,locB] = ismember(uni_geno,get(Genotypes.Saved_Genotypes ,'ObsName'));
        
        geno_string = cellfun(@(x,y,z) sprintf('%s :: %s \tX\t %s',x,y,z),...
            uni_geno,Genotypes.Saved_Genotypes(locB(locA),:).ParentA_name,Genotypes.Saved_Genotypes(locB(locA),:).ParentB_name,'UniformOutput',false);
        set(geno_table,'string',['Select Genotype';geno_string],'callback',@filter_protocol,'value',1);
    end
    function filter_protocol(hObj,~)
        geno_index = get(hObj,'Value')-1;
        geno_select = uni_geno(geno_index);
        
        matching_valid_list = valid_id_list(cellfun(@(x) contains(x,sprintf('%s%s',collect_select{1},geno_select{1})),valid_id_list));
        proto_ids = (cellfun(@(x) x(13:16),matching_valid_list,'UniformOutput',false));
        uni_proto = unique(proto_ids);

        [locA,locB] = ismember(uni_proto,get(Protocols.Saved_Protocols_new_version ,'ObsName'));
        parsed_data = Protocols.Saved_Protocols_new_version(locB(locA),:);
        chrim_logic = cellfun(@(x) contains(x,'None'),parsed_data.Stimuli_Type);
        stimuli_used = parsed_data.Stimuli_Type;
        stimuli_used(chrim_logic) = cellfun(@(y) y{1}, parsed_data(chrim_logic,:).Photo_Activation,'UniformOutput',false);
        parsed_data.Stimuli_Type = stimuli_used;
        for iterP = 1:1:size(parsed_data,1)
            [primary_stimuli(iterP),secondary_stimuli(iterP)] = get_stimuli_info(parsed_data(iterP,:));            %#ok<AGROW>
        end
        no_second = cellfun(@(x) strcmp(x,'None'), secondary_stimuli);
        secondary_stimuli(no_second) = {''};


        proto_string = cellfun(@(x,y,z) sprintf('%s :: %s  \t %s',x,y,z),uni_proto,primary_stimuli',secondary_stimuli','UniformOutput',false);
        set(proto_table,'string',['Select Protocol';proto_string],'callback',@merge_opts,'value',1);
        
        
    end
    function merge_opts(hObj,~)
        proto_index = get(hObj,'Value')-1;
        proto_select = uni_proto(proto_index);
        expIDlist = sprintf('%s%s%s',collect_select{1},geno_select{1},proto_select{1});
        if ischar(expIDlist)
            expIDlist = {expIDlist};
        end
        hold all
        text(1920/2,1059/2,'Generating Image Frame','color',rgb('white'),'fontsize',20,'HorizontalAlignment','center')
        drawnow;        

        switch_view 
    end
end
function [primary_stimuli,secondary_stimuli] = get_stimuli_info(parsed_data)
    stim_list = parsed_data.Stimuli_Type;

    has_chrim_logic = cellfun(@(x) contains(x,'intensity'),stim_list);          %_pulse  to end
    has_loom_logic = cellfun(@(x) contains(x,'loom'),stim_list);                %loom to .mat
    has_wall_logic = cellfun(@(x) contains(x,'wall'),stim_list);                %wall to _loom


    Elevation = str2double(parsed_data.Stimuli_Vars.Elevation);
    Azimuth = str2double(parsed_data.Stimuli_Vars.Azimuth);

    if sum(has_chrim_logic) > 0
        chrim_stim = cellfun(@(x) x(strfind(x,'pulse'):end),stim_list(has_chrim_logic),'UniformOutput',false);
        chrim_stim = convert_proto_string(chrim_stim,0,0);
        chrim_stim = cellfun(@(x) strtrim(x),chrim_stim,'UniformOutput',false);
    end        
    if sum(has_loom_logic) > 0
        if contains(stim_list(has_loom_logic),'.mat')
            loom_stim = cellfun(@(x) x(strfind(x,'loom'):(strfind(x,'.mat')-1)),stim_list(has_loom_logic),'UniformOutput',false);
        else
            loom_stim = cellfun(@(x) x(strfind(x,'loom'):end),stim_list(has_loom_logic),'UniformOutput',false);
        end
        loom_stim = convert_proto_string(loom_stim, Elevation(has_loom_logic),Azimuth(has_loom_logic));
        loom_stim = cellfun(@(x) strtrim(x),loom_stim,'UniformOutput',false);            
    end

    if sum(has_wall_logic) > 0
        wall_stim = cellfun(@(x) x(strfind(x,'wall'):(strfind(x,'_loom')-1)),stim_list(has_wall_logic),'UniformOutput',false);
        wall_stim = convert_proto_string(wall_stim,0,0);
        wall_stim = cellfun(@(x) strtrim(x),wall_stim,'UniformOutput',false);
    end

    primary_stimuli   = repmat({'None'},length(stim_list),1);
    secondary_stimuli = repmat({'None'},length(stim_list),1);

    if sum(has_loom_logic) > 0
        primary_stimuli(~has_chrim_logic & has_loom_logic & ~has_wall_logic)  = loom_stim(~has_chrim_logic(has_loom_logic)  & ~has_wall_logic(has_loom_logic));      %looming stimuli only
    end
    if sum( has_wall_logic) > 0
        primary_stimuli(~has_chrim_logic & ~has_loom_logic & has_wall_logic)  = wall_stim(~has_chrim_logic(has_wall_logic)  & ~has_loom_logic(has_wall_logic));      %wall stimuli only
    end
    if sum(has_chrim_logic) > 0
        primary_stimuli(has_chrim_logic & ~has_loom_logic & ~has_wall_logic)  = chrim_stim(~has_loom_logic(has_chrim_logic) & ~has_wall_logic(has_chrim_logic));     %chrim pulse only
    end

    if sum(has_chrim_logic) > 0 && sum(has_loom_logic) > 0
        primary_stimuli(has_chrim_logic & has_loom_logic & ~has_wall_logic)   = chrim_stim(has_loom_logic(has_chrim_logic) & ~has_wall_logic(has_chrim_logic));    %chrim first loom_second
        secondary_stimuli(has_chrim_logic & has_loom_logic & ~has_wall_logic) = loom_stim(has_chrim_logic(has_loom_logic)  & ~has_wall_logic(has_loom_logic));     %chrim first loom_second
    end
    if sum(has_wall_logic) > 0 && sum( has_loom_logic) > 0
        primary_stimuli(~has_chrim_logic & has_loom_logic & has_wall_logic)   = wall_stim(has_loom_logic(has_wall_logic) & has_loom_logic(has_wall_logic));        %wall first loom_second
        secondary_stimuli(~has_chrim_logic & has_loom_logic & has_wall_logic) = loom_stim(has_wall_logic(has_loom_logic) & has_wall_logic(has_loom_logic));        %wall first loom_second
    end
end
function new_protocol_labels = convert_proto_string(proto_string,elevation,azimuth)    %converts proto string into readable text

    wall_string  = cell(length(proto_string),1);
    loom_string  = cell(length(proto_string),1);
    chrim_string = cell(length(proto_string),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    wall_logic = cellfun(@(x) contains(x,'wall'),proto_string);
    if sum(wall_logic) > 0
        test_string = proto_string(wall_logic);

        width_index = cellfun(@(x) strfind(x,'_w'),test_string);
        height_index = cellfun(@(x) strfind(x,'_h'),test_string);
        at_index = cellfun(@(x) strfind(x,'at'),test_string,'UniformOutput',false);
        score_index = cellfun(@(x) strfind(x,'_'),test_string,'UniformOutput',false);
        score_index = cell2mat(score_index);        
        score_index = num2cell(score_index(:,2));

        wall_width = cellfun(@(x,y,z) x((y+2):(z(1)-1)),test_string,num2cell(width_index),at_index,'UniformOutput',false);
        wall_height = cellfun(@(x,y,z) x((y+2):(z(2)-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);

        wall_width_loc = cellfun(@(x,y,z) x((z(1)+2):(y-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);
        wall_height_loc = cellfun(@(x,y,z) x((z(2)+2):(y-1)),test_string,score_index,at_index,'UniformOutput',false);

        wall_string(wall_logic) = cellfun(@(x,y,z,a) sprintf('wall_w%03sat%03s_h%03sat%03s',x,y,z,a),wall_width,wall_width_loc,wall_height,wall_height_loc,'UniformOutput',false);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    chrim_logic = cellfun(@(x) contains(x,'intensity'),proto_string);
    if sum(chrim_logic) > 0
        photo_str = proto_string(chrim_logic);
        intensity_index = cellfun(@(x) strfind(x,'intensity'),photo_str);
        duration_start = cellfun(@(x) strfind(x,'Begin'),photo_str);
        duration_end = cellfun(@(x) strfind(x,'_widthEnd'),photo_str);
        intensity_used = cellfun(@(x,y) str2double(x(y+9:end)),photo_str,num2cell(intensity_index));
        duration_used = cellfun(@(x,y,z) str2double(x(y+5:z-1)),photo_str,num2cell(duration_start),num2cell(duration_end));
        chrim_string(chrim_logic) = cellfun(@(x,y) sprintf('Intensity_%03.0fPct_%03.0fms',x,y),num2cell(intensity_used),num2cell(duration_used),'uniformoutput',false);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    loom_logic = cellfun(@(x) contains(x,'loom'),proto_string);
    if sum(loom_logic) > 0
        test_string = proto_string(loom_logic);
        cut_point = cellfun(@(x) strfind(x,'.mat'),test_string,'UniformOutput',false);
        missing_mat = cellfun(@(x) isempty(x),cut_point);
        cut_point(missing_mat) = cellfun(@(x) length(x),cut_point(missing_mat),'UniformOutput',false);

        no_cut_point  = cellfun(@(x) x <= 1, cut_point);
        has_cut_point = cellfun(@(x) x > 1, cut_point);
        test_string(has_cut_point) = cellfun(@(x,y) x(strfind(x,'loom'):(y-1)),test_string(has_cut_point),cut_point(has_cut_point),'UniformOutput',false);
        test_string( no_cut_point) = cellfun(@(x) x(strfind(x,'loom'):end),test_string( no_cut_point),'UniformOutput',false);

        test_string = cellfun(@(x) regexprep(x,'_blackonwhite',''),test_string,'UniformOutput',false);

        try
            to_index = cellfun(@(x) strfind(x,'to'),test_string);
            lv_index = cellfun(@(x) strfind(x,'lv'),test_string);
    %            score_index = cellfun(@(x) max(strfind(x,'_')),test_string);
            start_angle = cellfun(@(x,y) x(6:(y-1)),test_string,num2cell(to_index),'uniformoutput',false);
            ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
    %            loverv = cellfun(@(x,y,z) x((y+2):(z-1)),test_string,num2cell(lv_index),num2cell(score_index),'uniformoutput',false);
            loverv = cellfun(@(x,y) x((y+2):end),test_string,num2cell(lv_index),'uniformoutput',false);
            loom_string(loom_logic) = cellfun(@(x,y,z,a,b) sprintf('loom_%03sto%03s_lv%03s  Azi :: %03.0f  Ele :: %03.0f',x,y,z,a,b), start_angle,ending_angle,loverv,num2cell(azimuth(loom_logic)),num2cell(elevation(loom_logic)),'uniformoutput',false);        
        catch
            loom_string(loom_logic) = test_string;
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    new_protocol_labels = cellfun(@(x,y,z) sprintf('%s %s %s',x,y,z),wall_string,loom_string,chrim_string,'UniformOutput',false);
end

function graph_layout_gui_shell
    clc
    repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'pat_test_programs'))   
    
    set_up_iosr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
%% user parameters
    temp_range = [22.5,24.5];
%    humidity_cut_off = 40;
    humidity_cut_off = 37.5;
    azi_off = 22.5;
    %azi_off = 90;

    %remove_low = true;
    remove_low = false;
    low_count = 0; %low_count = 5;
    exp_cut = 100;
    
    stimuli_list = struct2dataset(dir('Z:\pez3000_variables\visual_stimuli'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%% variables used in program
    curr_collection = ' ';          curr_group = [];                    combine_data = [];              m_parent_name = [];             m_parent_id = [];                 
    m_incubator = [];               m_food = [];                        m_stimuli = [];                 exp_dir = [];                   saved_collections = [];
    saved_groups = [];              hCollectdrop  = [];                 hGroupdrop  = [];               h_load_data = [];
    h_summary_count = [];           h_table_counts  = [];               num_list_1 = [];                var_list = [];                  filt_var_list = [];
    filt_num_list = [];             load_files = [];                    filt_label_index = [];
    result_table = [];              filt_data = [];                     geno_results = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    try
        poolobj = parpool;
    catch
        poolobj = gcp;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets labels and background
    screen2use = 2;         % in multi screen setup, this determines which screen to be used
    screen2cvr = 0.8;       % portion of the screen to cover
    
    monPos = get(0,'MonitorPositions');
    if size(monPos,1) == 1,screen2use = 1; end
    scrnPos = monPos(screen2use,:);    
    backColor = [0 0 0.2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% figure axis
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2), (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
    hFigC = figure('NumberTitle','off','Name','Experimental Design Gui',...
           'menubar','none','units','pix','Color',backColor,'pos',FigPos,'colormap',gray(256),'CloseRequestFcn',@close_graph);
    hPanA = uipanel('Position',[0 0 1 1],'Visible','On','BackgroundColor',rgb('light grey'));           
    graph_table = uitable(hPanA,'units','normalized','position',[.02 .025 .955 .690]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   
    start_space = .025;                     spacing = (.950-(.01*4))/5;
    h_lines_count = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+0*(spacing+.01) .8900 spacing .025],'String','Experiments Run :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_total_count = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+1*(spacing+.01) .8900 spacing .025],'String','Total Videos :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_total_days =  uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+2*(spacing+.01) .8900 spacing .025],'String','Total Days Run :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_total_runs =  uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+3*(spacing+.01) .8900 spacing .025],'String','Total Runs On Pez :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_tot_analyized=uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+4*(spacing+.01) .8900 spacing .025],'String','Need To Annotate :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('red'));
    
    h_VPL = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+0*(spacing+.01) .8600 spacing .025],'String','Videos Per Line :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_VPD = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+1*(spacing+.01) .8600 spacing .025],'String','Videos Per Day :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_VPR = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+2*(spacing+.01) .8600 spacing .025],'String','Videos Per Run :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_RPD = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+3*(spacing+.01) .8600 spacing .025],'String','Runs Per Day :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
    h_UPR = uicontrol(hPanA,'Style','text','Units','normalized','position',[start_space+4*(spacing+.01) .8600 spacing .025],'String','Usuable Videos Per Line :: 0','fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('blue'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   
    string_val = [{'NIDAQ / Pez  Issues'},{'Multi / Blank'},{'Fly Issues'}, {'Failed Location'},{'Failed Tracking'},{'Out Of Range'},{'Usuable Videos'}];

    str_entries = length(string_val);
    header_spacing = (.95-(.01*(str_entries-1)))/(str_entries);              val_spacing = (.95-(.01*(((str_entries)*2)-1)))/((str_entries)*2);
    h_count_values = zeros(str_entries,1);                                   h_pct_values = zeros(str_entries,1);                 h_index = 0;
       
    for iterA = 1:2:(2*str_entries)
        h_index = h_index + 1;
        uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+(h_index-1)*(header_spacing+.01) .8150 header_spacing .025],'String',string_val{h_index},'fontunits','normalized','fontsize',0.4250);
        h_count_values(h_index) = uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+ (iterA-1)*(val_spacing+.01) .7850 val_spacing .025],'String','0','fontunits','normalized','fontsize',0.5000);
        h_pct_values(h_index)   = uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+ iterA*(val_spacing+.01) .7850 val_spacing .025],'String','0','fontunits','normalized','fontsize',0.5000);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
    load_user_data
    set_header_info
    draw_border_lines
    menu_tabs
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets up headers, menu list and default options
    function load_user_data(~,~)
        op_sys = system_dependent('getos');
        if contains(op_sys,'Microsoft Windows')
            file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
            analysis_path = '\\Dm11\cardlab\Data_pez3000_analyzed';
        else
            file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
            analysis_path = '/Volumes/cardlab/Data_pez3000_analyzed';            
        end     

        new_file_path = struct2dataset(dir(analysis_path));        
        saved_collections = load([file_dir filesep 'Saved_Collection.mat']);            saved_collections = saved_collections.Saved_Collection;   
        saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);            saved_groups = saved_groups.Saved_Group_IDs;        
        exp_dir =  new_file_path.name;                                                  exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));       
        exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= exp_cut,exp_dir));

        saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:);
        [~,sort_idx] = sort(lower(regexprep(saved_groups.Properties.RowNames,' ','')));
        saved_groups = saved_groups(sort_idx,:);   
        saved_users   = unique(saved_collections.User_ID); 
        spacing = (.950-(.01*2))/3;

        uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025 .9600 spacing .025],'String','Select User','fontunits','normalized','fontsize',0.5000);
        hUserdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025 .9300 spacing .025],'String',[' ';unique(saved_users)],...
            'horizontalalignment','center','fontunits','normalized','fontsize',0.5000,'enable','on','callback',@populatecollect);           
        uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+1*(spacing+.01) .9600 spacing .025],'String','Select Collection','fontunits','normalized','fontsize',0.5000);
        hCollectdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025+1*(spacing+.01) .9300 spacing .025],'String',' ','fontunits','normalized','fontsize',0.5000,'enable','off');
        uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+2*(spacing+.01) .9600 spacing .025],'String','Select Group','fontunits','normalized','fontsize',0.5000);
        hGroupdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025+2*(spacing+.01) .9300 spacing .025],'String',' ','fontunits','normalized','fontsize',0.5000,'enable','off','callback',@parse_group_list);
    end
    function set_header_info
        num_list_1 = [{'Vials|Run'},{'Total|Videos'},{'Pez|Issues'},{'Multi|Blank'},{'Wing|Issues'},{'Failed|Location'},{'Failed|Tracking'},{'Out Of|Range'},{'Need To|Work'},{'Usuable|Complete'}];        
        var_list = [{'ParentA|Name'},{'ParentA|Robot ID'},{'ParentB|Name'},{'ParentB|Robot ID'},{'Incubator|Info'},{'Food Type| '},{'Stimulus|Shown'}];
        filt_var_list = true(1,length(var_list));
        filt_num_list = true(1,length(num_list_1));         
        
        spacing = (.95-(.01*2))/3;
        h_load_data     = uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+0*(spacing+.01) .7400 spacing .025],'String','.....','fontunits','normalized','fontsize',0.5000,'fontweight','bold');
        h_summary_count = uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+1*(spacing+.01) .7400 spacing .025],'String','.....','fontunits','normalized','fontsize',0.5000,'fontweight','bold');
        h_table_counts  = uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+2*(spacing+.01) .7400 spacing .025],'String','.....','fontunits','normalized','fontsize',0.5000,'fontweight','bold');        
    end
    function menu_tabs(~,~)                                 % sets up the menu options
        m_variables = uimenu(hFigC,'Label','Table Variables');
        m_special = uimenu(hFigC,'Label','Video Summary Options');
            uimenu(m_special,'label','Pez Usage Summary','callback',@summary_of_pez_use);
            uimenu(m_special,'label','Total Video By Genotype','callback',@geno_summary);
            uimenu(m_special,'label','Total Video By Pez','callback',@pez_summary);
            uimenu(m_special,'label','Pez Stat Summary','callback',@pez_run_counts);
            uimenu(m_special,'label','Total Video For Fixed Stimuli Position Experiments','callback',@fixed_position_pez_summary);
            uimenu(m_special,'label','Nidaq Traces by Pez','callback',@Nidaq_Summary);
            
        m_pos = uimenu(hFigC,'Label','Fly position');
            uimenu(m_pos,'label','Poistion on Prism Grid','callback',@prism_grid);
            
            
        m_master = uimenu(hFigC,'Label','Master plot');
            uimenu(m_master,'label','Master Plot By Gender','callback',@master_plot_gender);
            uimenu(m_master,'label','Master Plot For Wall Stimuli','callback',@wall_postion_data);         
        m_jump = uimenu(hFigC,'Label','Esape Tracking Plots'); 
            uimenu(m_jump,'label','Jump angle Relative to Stim pos','callback',@jump_angle_rel_stim);
        m_take_off = uimenu(hFigC,'Label','Gender Split Plots');
            uimenu(m_take_off,'label','pre_stim rotation','callback',@pre_stim_rotation);       
            uimenu(m_take_off,'label','take_off_pct','callback',@take_off_pct);
            uimenu(m_take_off,'label','take_off probabilty','callback',@take_probabilty);
            uimenu(m_take_off,'label','take_off by size','callback',@take_off_by_size);            
        m_heat = uimenu(hFigC,'Label','Heat Map Plots');            
            uimenu(m_heat,'label','Complete Azimuth Sweep','callback',@rebin_azimuth_positions);                
        m_montage = uimenu(hFigC,'Label','Create Montage Vidoes');
            uimenu(m_montage,'label','Show All Videos','callback',@make_montages,'UserData',1);
            uimenu(m_montage,'label','Only Show Jumping Videos','callback',@make_montages,'UserData',2);
            uimenu(m_montage,'label','Plot Center of Mass Change','callback',@plot_center_mass_change);
        m_quit = uimenu(hFigC,'Label','Quit','Callback',@close_graph);
    end
    function new_dataset(~,~)                               % resets everything back to default options
        set(graph_table,'Data',[],'RowName',[]);        
        set(h_lines_count,'String','Experiments Run :: 0');                 set(h_total_count,'String','Total Videos :: 0');
        set(h_total_days,'String','Total Days Run :: 0');                   set(h_total_runs,'String','Total Runs On Pez :: 0');
        set(h_tot_analyized,'String','Need To Annotate :: 0');              set(h_VPL,'String','Videos Per Line :: 0');
        set(h_VPD,'String','Videos Per Day :: 0');                          set(h_VPR,'String','Videos Per Run :: 0');   
        set(h_RPD,'String','Runs Per Day :: 0');                            set(h_UPR,'String','Usuable Videos Per Line :: 0');

        set(h_count_values,'string','0');           set(h_pct_values,'string','0');
        curr_group = [];
        set(h_load_data,'String','.....','backgroundcolor',rgb('light grey'));
        set(h_summary_count,'String','.....','backgroundcolor',rgb('light grey'));
        set(h_table_counts,'String','.....','backgroundcolor',rgb('light grey'));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% finds data list
    function populatecollect(hObj,~)                        % select User
        curr_collection = ' ';
        new_dataset;
        index = get(hObj,'value');
        list = get(hObj,'string');              %selected User
        
        collect_list = saved_collections(strcmp(saved_collections.User_ID,list(index)),:).Collection_Name;
        collect_ids = get(saved_collections(strcmp(saved_collections.User_ID,list(index)),:),'ObsNames');
        new_collect_list = cellfun(@(x,y) [x,'  ::  ',y],collect_ids,collect_list,'UniformOutput',false);
        set(hCollectdrop,'string',[' ';new_collect_list],'value',1,'enable','on','callback',@populatelist);
        test_data = saved_groups(strcmp(list{index},saved_groups.User_ID),:);
        if ~isempty(test_data)
            set(hGroupdrop,'string',[' ';unique(test_data.Properties.RowNames,'stable')],'value',1,'enable','on','callback',@parse_group_list);
        else
            set(hGroupdrop,'string','No Groups Found for this User','value',1,'enable','off');
        end
    end
    function parse_group_list(hObj,~)                       % called if Collection
        new_dataset
        set(hCollectdrop,'value',1);            index = get(hObj,'value');              list = get(hObj,'string');
        curr_group  = saved_groups(strcmp(list{index},saved_groups.Properties.RowNames),:).Experiment_IDs{1};
        curr_group = strtrim(curr_group);
        if ~iscell(curr_group)
            curr_group =  cellstr(curr_group);           
        end
        curr_collection = cellfun(@(x) x(1:4), curr_group,'uniformoutput',false);
        curr_collection = unique(curr_collection);
        
        set_up_info
    end
    function populatelist(hObj,~)                           % called if Group
        new_dataset
        set(hGroupdrop,'value',1);             index = get(hObj,'value');             list = get(hObj,'string');
        list = cellfun(@(x) x(strfind(x,'::')+4:end),list(index),'uniformoutput',false);
        curr_collection = get(saved_collections(ismember(saved_collections.Collection_Name,list),:),'ObsName');
        set_up_info
    end
    function set_up_info(~,~)                               % brings in data and sets up the table
        get_analyized_file
        populate_summary_data
        set_filt_list                          %sets default filtering
        populate_table_data
        get_count_info;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reads in the data and cleans it up  
    function clean_up_load(~,~)
        load_files(cellfun(@(x) contains(x,'010500002421'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'010700002421'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'006700001843'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'006700001717'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'0108') & contains(x,'0739') ,load_files)) = [];

        load_files(cellfun(@(x) contains(x,'0119') & contains(x,'2523') ,load_files)) = [];             
        load_files(cellfun(@(x) contains(x,'0119') & contains(x,'2524') ,load_files)) = [];             
        load_files(cellfun(@(x) contains(x,'0119') & contains(x,'2525') ,load_files)) = [];             
        load_files(cellfun(@(x) contains(x,'0119') & contains(x,'2526') ,load_files)) = [];                     
        load_files(cellfun(@(x) contains(x,'0121') & contains(x,'2528') ,load_files)) = [];
        
        load_files(cellfun(@(x) contains(x,'0128') & contains(x,'0741') ,load_files)) = [];
        
        load_files(cellfun(@(x) contains(x,'0138') & contains(x,'00002535') ,load_files)) = [];         %remove 15B parent stock, not healthy        
        
        load_files(cellfun(@(x) contains(x,'0138') & contains(x,'0586') ,load_files)) = [];             % wrong version of 90, 45
        load_files(cellfun(@(x) contains(x,'0138') & contains(x,'0775') ,load_files)) = [];             % wrong version of 90, 0        
        
        load_files(cellfun(@(x) contains(x,'0216') & contains(x,'1401') ,load_files)) = [];             %collection is fixed stim, this proto is wrong
    end
    function post_load_cleanup
        for iterZ = 1:length(combine_data)
%             remove_logic = cellfun(@(x) contains(x,'pez3003'),combine_data(iterZ).Complete_usuable_data.Properties.RowNames);
%             combine_data(iterZ).Complete_usuable_data(remove_logic,:) = [];
%             
%             remove_logic = cellfun(@(x) contains(x,'pez3004'),combine_data(iterZ).Complete_usuable_data.Properties.RowNames);
%             combine_data(iterZ).Complete_usuable_data(remove_logic,:) = [];            
            
%            remove_logic =  combine_data(iterZ).Complete_usuable_data.Error_logic == 1;
%            combine_data(iterZ).Complete_usuable_data(remove_logic,:) = [];                        
        end
    end
    function get_analyized_file(~,~)                        % load in all the data
        % reads in the data
        set(hFigC, 'Pointer', 'watch');
        set(h_load_data,'string','Loading Data ....','backgroundcolor',rgb('light red'));    
        drawnow
        collect_match = curr_collection;
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
        combine_data = [];
        clean_up_load
                
        steps = length(load_files);
        tic
        parfor iterZ = 1:steps
%        for iterZ = 1:steps
            test_data =  Experiment_ID(load_files{iterZ});
            test_data.temp_range = temp_range;
            test_data.humidity_cut_off = humidity_cut_off;
            test_data.remove_low = remove_low;
            test_data.low_count = low_count;
            test_data.azi_off = azi_off;
            test_data.ignore_graph_table = true;
%            test_data.ignore_graph_table = false;
            try
                test_data.load_data;
                test_data.make_tables;
            catch               
                warning('id with no graph table');
            end
            combine_data = [combine_data;test_data];                             
        end
        clc
        steps = length(combine_data);
        combine_data(arrayfun(@(x) isempty(combine_data(x).Complete_usuable_data),1:1:steps)',:) = [];
        steps = length(combine_data);
        ids_usuable_data = arrayfun(@(x) height(combine_data(x).Complete_usuable_data),1:1:steps)';
        combine_data(ids_usuable_data == 0,:) = [];
        
        post_load_cleanup
        
        steps = length(combine_data);
        for iterZ = 1:steps
            try
                combine_data(iterZ).get_tracking_data;
            catch
                warning('tracking error?');
            end
        end 
        for iterZ = 1:steps
            combine_data(iterZ).display_data
        end 
        %remove experiments where everything failed
        ids_usuable_data = arrayfun(@(x) isempty(combine_data(x).Complete_usuable_data) & isempty(combine_data(x).Videos_Need_To_Work),1:1:steps);
        combine_data(ids_usuable_data == 1,:) = [];

        steps = length(combine_data);
        ids_usuable_data = arrayfun(@(x) height(combine_data(x).Complete_usuable_data) + height(combine_data(x).Videos_Need_To_Work),1:1:steps);
        combine_data(ids_usuable_data == 0,:) = [];
        
        num_parse_entries = arrayfun(@(x) size(combine_data(x).parsed_data,1),1:1:steps);
        if sum(num_parse_entries > 1) > 0
            combine_data(num_parse_entries > 1).parsed_data = combine_data(num_parse_entries > 1).parsed_data(1,:);
        end
        
        set(h_load_data,'string',sprintf('Data took %4.4f seconds to load',toc),'backgroundcolor',rgb('light green'));
        set(hFigC, 'Pointer', 'arrow');    
        drawnow
    end
    function populate_summary_data(~,~)
        tic
        set(h_summary_count,'string','Caculating Summary Stats','backgroundcolor',rgb('light red'));
        
        table_data = vertcat(combine_data(:).total_counts);
        summary_data = sum(cell2mat(table2cell(table_data)),1);
        raw_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work)];
        date_list = cellfun(@(x) str2double(x(16:23)),raw_data.Properties.RowNames);
        collect_list = cellfun(@(x) str2double(x(29:32)),raw_data.Properties.RowNames);
        date_list = unique(date_list);       
                
        set(h_total_days,'String',sprintf('Total Days Run :: %4.0f',length(date_list)));                   

        set(h_lines_count,'string',sprintf('Experiments Run :: %4.0f',length(combine_data)));
        run_count = sum(table_data.Vials_Run);                all_data = sum(table_data.Total_Videos);
        set(h_total_runs,'string',sprintf('Total Runs On Pez :: %4.0f',run_count));                
        set(h_total_count,'string', sprintf('Total Videos  :: %4.0f',all_data));
        
        set(h_VPD,'string',sprintf('Videos Per Day :: %4.2f',all_data / length(date_list)));
        set(h_RPD,'string',sprintf('Runs Per Day :: %4.2f',run_count / length(date_list)));
        set(h_VPL,'string',sprintf('Videos Per Line :: %4.2f',all_data / length(combine_data)));
        set(h_VPR,'string',sprintf('Videos Per Run :: %4.2f',all_data / run_count));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        need_to_annotate = sum(table_data.Need_To_Annotate);            currated = all_data;
        tot_pct = (need_to_annotate / all_data) * 100;                  set(h_tot_analyized,'string',sprintf('Need To Annotate :: %4.0f (%2.3f%%)', need_to_annotate,tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        value = sum(table_data.Pez_Issues);                             tot_pct = (value /  currated) * 100; 
        set(h_count_values(1),'string',num2str(value));                 set(h_pct_values(1),'string',sprintf('%2.3f%%',tot_pct));               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        value = sum(table_data.Multi_Blank);                            tot_pct = (value /  currated) * 100; 
        set(h_count_values(2),'string',num2str(value));                 set(h_pct_values(2),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        value = sum(table_data.Balancers);                              tot_pct = (value /  currated) * 100;         
        set(h_count_values(3),'string',num2str(value));                 set(h_pct_values(3),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        value = sum(table_data.Failed_Location);                        tot_pct = (value /  currated) * 100; 
        set(h_count_values(4),'string',num2str(value));                 set(h_pct_values(4),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                
        value = sum(table_data.Vid_Not_Tracked) + sum(table_data.Bad_Tracking);                     
        tot_pct = (value /  currated) * 100; 
        set(h_count_values(5),'string',num2str(value));                 set(h_pct_values(5),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                
        value = sum(table_data.Out_Of_Range);                           tot_pct = (value /  currated) * 100; 
        set(h_count_values(6),'string',num2str(value));                 set(h_pct_values(6),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
        value = sum(table_data.Usuable_Complete) + need_to_annotate; 
        tot_pct = (value /  currated) * 100; 
        set(h_count_values(7),'string',num2str(value));                 set(h_pct_values(7),'string',sprintf('%2.3f%%',tot_pct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
        set(h_UPR,'string',sprintf('Usuable Videos Per Line :: %4.2f',(sum(table_data.Usuable_Complete) + need_to_annotate) / length(combine_data)));
        set(h_summary_count,'string',sprintf('Data took %4.4f seconds to Populate',toc),'backgroundcolor',rgb('light green')); 
    end
    function set_filt_list(~,~)
        filt_var_list = true(1,length(var_list));
        name_status = get(m_parent_name,'checked');         %1 and 3
        robot_status = get(m_parent_id,'checked');          %2 and 4        
        incu_status = get(m_incubator,'checked');           %5
        food_status = get(m_food,'checked');                %6        
        stimuli_status = get(m_stimuli,'checked');          %7        
        
        if strcmp(name_status,'off')
            filt_var_list([1,3]) = false;
        end
        if strcmp(robot_status,'off')
            filt_var_list([2,4]) = false;
        end
        if strcmp(incu_status,'off')
            filt_var_list(5) = false;
        end
        if strcmp(food_status,'off')
            filt_var_list(6) = false;
        end        
        if strcmp(stimuli_status,'off')
            filt_var_list(7) = false;
        end        
        populate_table_data;        
    end
    function populate_table_data(~,~)
        set(h_table_counts,'String','Creating Table','backgroundcolor',rgb('light red'));
        tic
        drawnow        

        table_data = vertcat(combine_data(:).total_counts);
        new_data = [table_data.Properties.RowNames,table2cell(table_data)];            
        if sum(filt_num_list) < length(num_list_1)
            num_list = num_list_1(filt_num_list);
            num_list(3) = {'All Failed|Videos'};
            new_data(:,4) = num2cell(sum(cell2mat(new_data(:,4:7)),2));
            new_data(:,5:7) = [];
        else
            num_list = num_list_1;
        end
        collection_list = ['Experiment ID',num_list,var_list(filt_var_list)];
        
        if (size(new_data,2)-1) > length(num_list)
            new_data(:,8) = num2cell(cell2mat(new_data(:,8))+cell2mat(new_data(:,9)));      %rolls up track fails into single column
            new_data(:,9) = [];
        end
        
        var_size = length(num_list);        
        
        new_data(:,1) = cellfun(@(x) sprintf('%22s',x),new_data(:,1),'uniformoutput',false);
        new_data(:,2:end) = cellfun(@(x) sprintf('%13s',num2str(x)),new_data(:,2:end),'uniformoutput',false);
        
        parsed_data = vertcat(combine_data(:).parsed_data);         
        parsed_data.ParentB_name = convert_background_labels(parsed_data.ParentB_name);
        incubator = cellstr(parsed_data.Name);
                
        stim_list = parsed_data.Stimuli_Type;        
        stim_list(cellfun(@(x) contains(x,'None'),parsed_data.Stimuli_Type)) = cellfun(@(y) y{1}, parsed_data(cellfun(@(x) contains(x,'None'),parsed_data.Stimuli_Type),:).Photo_Activation,'UniformOutput',false);
                        
        Elevation = str2double(parsed_data.Elevation);
        Azimuth = str2double(parsed_data.Azimuth);
        
        Stim_shown = convert_proto_string(stim_list,Elevation,Azimuth);
        filt_parse = [];
        part_2_spacing = []; %{400,100,400,100,250,200,500};
        for iterP = 1:sum(filt_var_list)
            switch collection_list{iterP+11}
                case {'ParentA|Name'}
                   filt_parse = [filt_parse, parsed_data.ParentA_name];
                   part_2_spacing = [part_2_spacing,400];
                case {'ParentA|Robot ID'}
                    filt_parse = [filt_parse,parsed_data.ParentA_ID];
                    part_2_spacing = [part_2_spacing,100];
                case {'ParentB|Name'}
                    filt_parse = [filt_parse,parsed_data.ParentB_name];
                    part_2_spacing = [part_2_spacing,400];
                case {'ParentB|Robot ID'}
                    filt_parse = [filt_parse,parsed_data.ParentB_ID];
                    part_2_spacing = [part_2_spacing,100];
                case {'Incubator|Info'}
                    filt_parse = [filt_parse,incubator];
                    part_2_spacing = [part_2_spacing,250];
                case {'Food Type| '}
                    filt_parse = [filt_parse,parsed_data.Food_Type];
                    part_2_spacing = [part_2_spacing,200];
                case {'Stimulus|Shown'}
                    filt_parse = [filt_parse,Stim_shown];
                    part_2_spacing = [part_2_spacing,500];
            end
        end
       
        part_2_spacing = num2cell(part_2_spacing);       
        new_data = [new_data,filt_parse];
        
        exp_id_only = cellfun(@(y) y(1:12),cellfun(@(x) strtrim(x),new_data(:,1),'uniformoutput',false),'uniformoutput',false);
        sortlist = cellfun(@(x,y) sprintf('%s_%s',x,y),exp_id_only,new_data(:,end),'uniformoutput',false);
        [~,sort_idx] = sort(sortlist);
        new_data = new_data(sort_idx,:);
        
        col_list_first = cellfun(@(x) ['<html><font size=+1>' ,x,'</html>'],collection_list(1),'uniformoutput',false);
        string_sep = num2cell(cellfun(@(x) strfind(x,'|'),collection_list(2:end)));
        part1 = cellfun(@(x,y) ['<html><font size=+1>' ,x(1:(y-1)),'</html>'],collection_list(2:end),string_sep,'uniformoutput',false);
        part2 = cellfun(@(x,y) ['<html><font size=+1>' ,x((y+1):end),'</html>'],collection_list(2:end),string_sep,'uniformoutput',false);
        col_list_number = cellfun(@(x,y) [x,'|',y],part1,part2,'uniformoutput',false);
        col_list = [col_list_first, col_list_number];
        
        new_rows = num2cell((1:1:length(combine_data))');
        row_list = cellfun(@(x) ['<html><font size=+0>' ,num2str(x),'</html>'],new_rows,'uniformoutput',false);
        set(graph_table,'RowName',row_list,'ColumnName',col_list,'ColumnEditable',false(1,16));
        add_table_sorting(graph_table);
        drawnow
                
%        set(graph_table,'columnwidth',[{175},num2cell(repmat(110,1,var_size)),part_2_spacing]);
        set(graph_table,'columnwidth',[{150},num2cell(repmat(95,1,var_size)),part_2_spacing]);
        if ~isempty(get(graph_table,'Data'))
            resize_rowname(graph_table);
        end   
        set(graph_table,'Data',new_data,'FontSize',10);        
        
        set(h_table_counts,'string',sprintf('Table Took took %4.4f seconds to Populate',toc),'backgroundcolor',rgb('light green')); 
        drawnow
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% display code for gui
    function draw_border_lines(~,~)                         % adds some lines for visual
        line_fig(1) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .990 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);        
        line_fig(2) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .9225 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);        
        line_fig(3) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[.015 .8500 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);       
        line_fig(4) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .7710 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);                
        line_fig(5) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.015 .7260 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);                                    
        line_fig(6) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.015 .7260 .005 .269],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);            
        line_fig(7) = axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.980 .7260 .005 .269],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);              %#ok<*NASGU>
    end
    function add_table_sorting(new_table)                   % adds java sorting to the table
        [jscrollpane,~,~,~] = findjobj(new_table);
        jtable = jscrollpane.getViewport.getView;   

        % Now turn the JIDE sorting on
        jtable.setColumnAutoResizable(false);
        jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
        jtable.setEditingColumn(true);
        jtable.setAutoResort(true);
        jtable.setMultiColumnSortable(true);
        jtable.setPreserveSelectionsAfterSorting(true);
        jtable.setNonContiguousCellSelection(false);
        jtable.setColumnSelectionAllowed(false);
        jtable.setRowSelectionAllowed(true);
    end
    function resize_rowname(new_table)                      % java command to resize row length
        jscroll=findjobj(new_table);
        rowHeaderViewport=jscroll.getComponent(4);
        rowHeader=rowHeaderViewport.getComponent(0);
        rowHeader.setSize(80,360)

        %resize the row header
        newWidth = 50;
        rowHeaderViewport.setPreferredSize(java.awt.Dimension(newWidth,0));
        height=rowHeader.getHeight;
        rowHeader.setPreferredSize(java.awt.Dimension(newWidth,height));
        rowHeader.setSize(newWidth,height); 
    end
    function set_up_iosr(~,~)
        currdir = cd;
        cd([fileparts(which(mfilename('fullpath'))) filesep '..']);
        directory = pwd;
        directory = [fileparts(directory) filesep 'IoSR-Surrey-MatlabToolbox-4bff1bb'];

        cd(directory);
        addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);

        %% start SOFA    
        SOFAstart(0);    
        cd(currdir); % return to original directory
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% clean up functions for plotting
    function get_count_info(~,~)                        %gets total and jump counts by genotype/protocol/pez
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        jump_logic = get_timing_info;
        [~,matching_exp_info] = ismember(cellfun(@(x) x(29:44),filt_data.Properties.RowNames,'UniformOutput',false),get(exp_info,'ObsNames'));
        
        parsed_data = exp_info(matching_exp_info,:);
        stim_list = parsed_data.Stimuli_Type;
        
        has_chrim_logic = cellfun(@(x) contains(x,'intensity'),stim_list);          %_pulse  to end
        has_loom_logic = cellfun(@(x) contains(x,'loom'),stim_list);                %loom to .mat
        has_wall_logic = cellfun(@(x) contains(x,'wall'),stim_list);                %wall to _loom
        
        Elevation = str2double(parsed_data.Elevation);
        Azimuth = str2double(parsed_data.Azimuth);
        
        if sum(has_chrim_logic) > 0
            chrim_stim = cellfun(@(x) x(strfind(x,'pulse'):end),stim_list(has_chrim_logic),'UniformOutput',false);
            chrim_stim = convert_proto_string(chrim_stim,0,0);
            chrim_stim = cellfun(@(x) strtrim(x),chrim_stim,'UniformOutput',false);
        end        
        if sum(has_loom_logic) > 0
            loom_stim = cellfun(@(x) x(strfind(x,'loom'):(strfind(x,'.mat')-1)),stim_list(has_loom_logic),'UniformOutput',false);
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
        
        Food_type = parsed_data.Food_Type;
        Stim_Delay = parsed_data.Stimuli_Delay;
        Photo_Delay = parsed_data.Photo_Delay;
        
        Stimuli_Delays = arrayfun(@(x,y) sprintf('%4.0f_%4.0f',x,y),Photo_Delay,Stim_Delay,'UniformOutput',false);
        
                                
%        [~,~,~,count_labels,filt_label_index] = crosstab(geno_results.Parent_A_DN,geno_results.Parent_B_Convert,primary_stimuli,secondary_stimuli,Stimuli_Delays,Food_type);
%        [~,~,~,count_labels] = crosstab(geno_results.Parent_A_DN,geno_results.Parent_B_Convert,primary_stimuli,secondary_stimuli,Stimuli_Delays,Food_type);
        [~,~,~,count_labels] = crosstab(geno_results.Parent_A,geno_results.Parent_B_Convert,primary_stimuli,secondary_stimuli,Stimuli_Delays,Food_type);
        

%        [~,locB_1] = ismember(geno_results.Parent_A_DN,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,1)),1));
        [~,locB_1] = ismember(geno_results.Parent_A,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,1)),1));
        [~,locB_2] = ismember(geno_results.Parent_B_Convert,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,2)),2));
        [~,locB_3] = ismember(primary_stimuli,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,3)),3));
        [~,locB_4] = ismember(secondary_stimuli,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,4)),4));
        [~,locB_5] = ismember(Stimuli_Delays,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,5)),5));
        [~,locB_6] = ismember(Food_type,count_labels(cellfun(@(x) ~isempty(x),count_labels(:,6)),6));
        filt_label_index = [locB_1,locB_2,locB_3,locB_4,locB_5,locB_6];
        
        unique_label_index = unique(filt_label_index,'rows');
        all_ids = [];
        result_struct = repmat(struct('Parent_A',[],'Parent_B',[],'Label_Index',[],'First_Protocol',[],'Second_Protocol',[],'Food_Type',[],'Photo_Delay',[],'Stimuli_Delay',[],'Azimuth',[],'Elevation',[],'Total_Downloaded',[],'Total_Counts',[],'Jump_Counts',[],'Take_off_Pct',[],'Video_data',[],'Annotated_Jumpers',[],'Short_Pathway_Count',[],'Short_Pathway_pct',[]),size(unique_label_index,1),1);
        
        for iterZ = 1:size(unique_label_index,1)
            result_struct(iterZ,:).Parent_A = count_labels(unique_label_index(iterZ,1),1);
            result_struct(iterZ,:).Parent_B = count_labels(unique_label_index(iterZ,2),2);
            result_struct(iterZ,:).First_Protocol = count_labels(unique_label_index(iterZ,3),3);
            result_struct(iterZ,:).Second_Protocol = count_labels(unique_label_index(iterZ,4),4);
            result_struct(iterZ,:).Food_Type = count_labels(unique_label_index(iterZ,6),6);
            logical_vect = sum(filt_label_index == unique_label_index(iterZ,:),2) == 6;
            result_struct(iterZ,:).Label_Index = find(logical_vect == 1);

%            parent_a_logic = ismember(geno_results.Parent_A_DN,count_labels(unique_label_index(iterZ,1),1));
            parent_a_logic = ismember(geno_results.Parent_A,count_labels(unique_label_index(iterZ,1),1));
            parent_b_logic = ismember(geno_results.Parent_B_Convert,count_labels(unique_label_index(iterZ,2),2));
            proto_1_logic = ismember(primary_stimuli,count_labels(unique_label_index(iterZ,3),3));
            proto_2_logic = ismember(secondary_stimuli,count_labels(unique_label_index(iterZ,4),4));
            delay_logic = ismember(Stimuli_Delays,count_labels(unique_label_index(iterZ,5),5));
            food_logic = ismember(Food_type,count_labels(unique_label_index(iterZ,6),6));
           
            matching_logic = (parent_a_logic & parent_b_logic & proto_1_logic &proto_2_logic & delay_logic & food_logic);
            
            geno_id = unique(cellfun(@(x) x(5:16),get(parsed_data(matching_logic,:),'ObsNames'),'UniformOutput',false));
            if size(geno_id,1) > 1
                geno_id = geno_id(1,:);
%                warning('dups')
            end
            all_ids = [all_ids;geno_id];
            sample_data = filt_data(matching_logic,:);
            if isempty(sample_data)
                continue
            end            
        
            geno_id_used = unique(cellfun(@(x) x(29:44),sample_data.Properties.RowNames,'UniformOutput',false));
            [locA,locB] = ismember(geno_id_used,get(exp_info,'ObsNames'));
            matching_table = vertcat(combine_data(locB(locA)).video_table);
            try
                total_download = sum(matching_table.Variables);
            catch
                warning('error')
            end

            filt_jump_logic = jump_logic(matching_logic);
                            
            result_struct(iterZ,:).Photo_Delay =  unique(Photo_Delay(matching_logic));
            result_struct(iterZ,:).Stimuli_Delay =  unique(Stim_Delay(matching_logic));
            result_struct(iterZ,:).Food_Type =  unique(Food_type(matching_logic));
            
            result_struct(iterZ,:).Elevation =  unique(Elevation(matching_logic));
            result_struct(iterZ,:).Azimuth   =  unique(Azimuth(matching_logic));

            result_struct(iterZ,:).Total_Downloaded = total_download(:,1);

            result_struct(iterZ,:).Total_Counts = height(sample_data);

            jump_data = sample_data(filt_jump_logic,:);
            result_struct(iterZ,:).Jump_Counts = height(jump_data);
            result_struct(iterZ,:).Video_data = jump_data;
            result_struct(iterZ,:).Annotated_Jumpers = sum(cellfun(@(x) ~isempty(x),jump_data.frame_of_leg_push));
            jump_data(cellfun(@(x) isempty(x),jump_data.frame_of_leg_push),:) = [];
            result_struct(iterZ,:).Short_Pathway_Count = sum(((cell2mat(jump_data.frame_of_take_off) - cell2mat(jump_data.frame_of_wing_movement)) /6) <= 7);

            result_struct(iterZ,:).Take_off_Pct =  (result_struct(iterZ,:).Jump_Counts ./result_struct(iterZ,:).Total_Counts);
            result_struct(iterZ,:).Short_Pathway_pct =  (result_struct(iterZ,:).Short_Pathway_Count ./result_struct(iterZ,:).Annotated_Jumpers);
        end
        
        result_table = struct2table(result_struct);
        try
            result_table(cellfun(@(x) isempty(x),result_table.Total_Downloaded),:) = [];        %if has missing will be cell
            result_table(cell2mat(result_table.Total_Counts) == 0,:) = [];
        catch
            result_table(arrayfun(@(x) isempty(x),result_table.Total_Downloaded),:) = [];       %if none are mising will be array
            result_table(result_table.Total_Counts == 0,:) = [];
        end
        result_table.Properties.RowNames = all_ids;
    end
    function jump_logic = get_timing_info(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        filt_data = [];
        
        loom_string = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'uniformoutput',false);
        chrim_logic = cellfun(@(x) contains(x,'None'),loom_string);
        photo_string = cellfun(@(x) x{1}, exp_info(chrim_logic,:).Photo_Activation,'uniformoutput',false);
        
        proto_string = loom_string;
        proto_string(chrim_logic) = photo_string;
                
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');        
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];                
            if contains(uni_parent{iterZ},'Chrimson')
                good_data = find_good_data(parent_logic,'in_range');            
            else
                good_data = find_good_data(parent_logic,'in_range');
% %                good_data = find_good_data(uni_parent{iterZ},parent_logic,'azimuth_sweep');
            end
            filt_data = [filt_data;good_data]; %#ok<*AGROW>
        end
        
        jump_logic = get_jump_info;
        
        leg_frame = filt_data.frame_of_leg_push;
        try
            leg_frame(cellfun(@(x) isempty(x),leg_frame)) = num2cell(filt_data.autoFot(cellfun(@(x) isempty(x),leg_frame)));
        catch
            leg_frame(cellfun(@(x) isempty(x),leg_frame)) = filt_data.autoFrameOfTakeoff(cellfun(@(x) isempty(x),leg_frame));
        end
            
%         leg_frame(cell2mat(leg_frame) == 0) = filt_data.Start_Frame(cell2mat(leg_frame) == 0);        %error check for bad auto frame
%         ontime_logic = (cellfun(@(x) isnan(x), leg_frame) | ~(cell2mat(leg_frame) < cell2mat(filt_data.Start_Frame) & cell2mat(leg_frame) ~= 20));
%                  
%         filt_data = filt_data(ontime_logic,:);
%         jump_logic = jump_logic(ontime_logic,:);
        
        geno_string = cellfun(@(x) x(33:40),filt_data.Properties.RowNames,'uniformoutput',false);
        [locA,locB] = ismember(geno_string,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'UniformOutput',false));
        full_parent_B = exp_info.ParentB_name(locB(locA));
        Parent_B = convert_background_labels(full_parent_B);
                
        geno_results = cell2table([convert_labels(geno_string,exp_info,'exp_str_4'),full_parent_B,Parent_B]);
        geno_results.Properties.RowNames = filt_data.Properties.RowNames;
        geno_results.Properties.VariableNames = [{'Exp_ID'},{'Parent_A'},{'Parent_A_Convert'},{'Parent_A_DN'},{'Parent_B'},{'Parent_B_Convert'}];
     end
    function good_data = find_good_data(parent_logic,flag)
        if strcmp(flag,'in_range')
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];                
        elseif strcmp(flag,'all_data')
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work);...
                vertcat(combine_data(parent_logic).Vid_Not_Tracked);vertcat(combine_data(parent_logic).Bad_Tracking);vertcat(combine_data(parent_logic).Out_Of_Range)];
        elseif strcmp(flag,'azimuth_sweep')
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work);...
                vertcat(combine_data(parent_logic).Out_Of_Range)];            
         end        
    end
    function jump_logic = get_jump_info(~,~)
        new_start_frame = cell2mat(filt_data.Start_Frame);
        chrim_logic = cellfun(@(x) ~isempty(x),filt_data.photoactivation_info);
        
        new_start_frame(chrim_logic) = cellfun(@(x) find(x.nidaq_data <= 50,1,'first'),filt_data(chrim_logic,:).photoactivation_info);
                
    
        not_work = cellfun(@(x) isempty(x), filt_data.frame_of_leg_push);
        complete = cellfun(@(x) ~isempty(x), filt_data.frame_of_leg_push);
        done_jump = cellfun(@(x) ~isnan(x), filt_data(complete,:).frame_of_leg_push);

        try
            jump_logic = filt_data.autoJumpTest;
            jump_logic(filt_data.autoFot == 0) = cell2mat(filt_data(filt_data.autoFot == 0,:).jumpTest);
        catch
            jump_logic = filt_data.jumpTest;
        end
        
        
        if iscell(jump_logic)
            jump_logic = cell2mat(jump_logic);
        end
        jump_logic(cell2mat(filt_data.autoFrameOfTakeoff) == 20) = false;
        
        if ~islogical(jump_logic)
            jump_logic = jump_logic == 1;
        end
        jump_logic(complete) = done_jump;
        
        rem_records = cellfun(@(x,y) isempty(x) & isempty(y),filt_data.frame_of_leg_push,filt_data.final_frame_tracked);
        filt_data(rem_records,:) = [];

        %these records aren't tracked and auto jump is wrong
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
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% label convert functions
    function exp_info = correct_exp_info(exp_info)                                     %corrects parents so parent A is genotype, parent B is effector
        flip_logic = cellfun(@(x) contains(x,'1150416') | contains(x,'1117481') | contains(x,'3017823'),exp_info.ParentA_ID);
                                            % Chrimson                % Kir                %    TNT
        temp_par_b_id = exp_info.ParentB_ID(flip_logic);
        temp_par_b_name = exp_info.ParentB_name(flip_logic);
        
        exp_info.ParentB_ID(flip_logic) = exp_info.ParentA_ID(flip_logic);        exp_info.ParentA_ID(flip_logic) = temp_par_b_id;
        exp_info.ParentB_name(flip_logic) = exp_info.ParentA_name(flip_logic);    exp_info.ParentA_name(flip_logic) = temp_par_b_name;
        
        exp_info.ParentB_name = convert_background_labels(exp_info.ParentB_name);
    end
    function Parent_B = convert_background_labels(Parent_B)                            %conversion for background, makes shorter string
        Parent_B(cellfun(@(x) contains(x,'DL_UAS_Kir21_3_0090'),Parent_B)) = {'DL_UAS_Kir21'};
        Parent_B(cellfun(@(x) contains(x,'pJFRC315-10XUAS-IVS-tdtomato::Kir2.1 in su(Hw)attP5'),Parent_B)) = {'tdtomato_Kir21_in_su(Hw)attP5'};
        Parent_B(cellfun(@(x) contains(x,'pJFRC315-10XUAS-IVS-tdtomato::Kir2.1 in VK00027'),Parent_B)) = {'tdtomato_Kir21_in_VK00027'};
        Parent_B(cellfun(@(x) contains(x,'pJFRC49-10XUAS-IVS-eGFPKir2.1 in VK00005 '),Parent_B)) = {'eGFPKir2.1_in_VK00005'};
        Parent_B(cellfun(@(x) contains(x,'FCF_DL_1500090'),Parent_B)) = {'CTRL_DL_1500090'};
        
        Parent_B(cellfun(@(x) contains(x,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'),Parent_B)) = {'DL_UAS_Kir21'};
        Parent_B(cellfun(@(x) contains(x,'UAS_Chrimson_Venus_X_0070VZJ_K_45195'),Parent_B)) = {'UAS_Chrimson_Venus_X_0070'};
        Parent_B(cellfun(@(x) contains(x,'CTRL_DL_1500090_0028FCF_DL_1500090'),Parent_B)) = {'CTRL_DL_1500090'};
        
    end
    function label_results = convert_labels(old_labels,exp_info,str_type)              %flips 8 digit number into parent information
        not_in_sheet_id = [   {'2502522'};      {'3020007'};      {'2135398'};    {'2135420'};     {'3026909'};          {'2135384'}];            
        not_in_sheet_conv_1 = [{'LC4(0315)'};   {'LC6(77B)'};    {'LPLC1(29B)'};  {'LPLC2(48B)'};  {' L1,L2(797)'};      {'LC11 (15B)'}];
        not_in_sheet_conv_2 = [{'LC4'};         {'LC6'};         {'LPLC1'};       {'LPLC2'};       {' L1,L2'};           {'LC11'}];
          

        [~,~,raw] = xlsread('Z:\Pez3000_Gui_folder\DN_name_conversion.xlsx','Hiros List');      %loads in DN table list
        header_list = raw(1,1:6);
        header_list = regexprep(header_list,' ','_');
        dn_table = cell2table(raw(2:end,1:6));
        dn_table.Properties.VariableNames = header_list;

        switch str_type
            case 'geno_string'
                [locA,locB] = ismember(old_labels,exp_info.ParentA_name);  %if sends name string
            case 'exp_str_8'
                [locA,locB] = ismember(old_labels,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'uniformoutput',false));   %if sends 8 digit geno string
            case 'exp_str_4'
                [locA,locB] = ismember(old_labels,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'uniformoutput',false));   %if sends 4 digit geno string

        end     
        old_id_list = exp_info(locB(locA),:).ParentA_ID;                
        old_id_name = exp_info(locB(locA),:).ParentA_name;                                        

        label_results = [old_labels,old_id_name,repmat({nan},length(old_labels),2)];

        [match_logic_sheet,match_pos_sheet] = ismember(str2double(old_id_list),dn_table.robot_ID);          %find records matching hiros table
        [match_logic_table,match_pos_table] = ismember(old_id_list,not_in_sheet_id);                        %find records matching manual table                

        matching_list = dn_table(match_pos_sheet(match_logic_sheet),:);
        label_results(match_logic_sheet,3) = matching_list.old_name;
        label_results(match_logic_sheet,4) = matching_list.new_name;       

        label_results(match_logic_table,3) = not_in_sheet_conv_1(match_pos_table(match_logic_table));
        label_results(match_logic_table,4) = not_in_sheet_conv_2(match_pos_table(match_logic_table));

        label_results(cellfun(@(x) sum(isnan(x)) == 1, label_results(:,3)),3) = label_results(cellfun(@(x) sum(isnan(x)) == 1, label_results(:,3)),2);
        label_results(cellfun(@(x) sum(isnan(x)) == 1, label_results(:,4)),4) = label_results(cellfun(@(x) sum(isnan(x)) == 1, label_results(:,4)),2);
        
        label_results = add_spacing_control_labels(label_results);
    end
    function new_protocol_labels = convert_proto_string(proto_string,elevation,azimuth)    %converts proto string into readable text
        
        wall_string  = cell(length(proto_string),1);
        loom_string  = cell(length(proto_string),1);
        chrim_string = cell(length(proto_string),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        wall_logic = cellfun(@(x) contains(x,'wall'),proto_string);
        if sum(wall_logic) > 0
            test_string = proto_string(wall_logic);

            try
                width_index = cellfun(@(x) strfind(x,'_w'),test_string);
            catch
                warning('no wall')
            end
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
                start_angle = cellfun(@(x,y) x(6:(y-1)),test_string,num2cell(to_index),'uniformoutput',false);
                ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
                loverv = cellfun(@(x,y) x((y+2):end),test_string,num2cell(lv_index),'uniformoutput',false);
                loom_string(loom_logic) = cellfun(@(x,y,z,a,b) sprintf('loom_%03sto%03s_lv%03s  Azi :: %03.0f  Ele :: %03.0f',x,y,z,a,b), start_angle,ending_angle,loverv,num2cell(azimuth(loom_logic)),num2cell(elevation(loom_logic)),'uniformoutput',false);        
            catch
                stim_parms = parse_offaxis_loom(test_string);
                stim_parms = num2cell(stim_parms);
                loom_string(loom_logic) = cellfun(@(x,y,z,a,b,c) sprintf('loom_r%01.4f_d%01.4f_lv%03.0f_t%03.0f_ele%03.0f_azi%03.0f',b,c,a,x,y,z),stim_parms(:,2),stim_parms(:,3),stim_parms(:,4),stim_parms(:,1),stim_parms(:,5),stim_parms(:,6),'uniformoutput',false);        
            end            
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        new_protocol_labels = cellfun(@(x,y,z) sprintf('%s %s %s',x,y,z),wall_string,loom_string,chrim_string,'UniformOutput',false);
    end
    function new_labels = add_spacing_control_labels(new_labels)                        %adds spacing for control lines
        dl_logic = cellfun(@(x) (contains(x,'DL Wildtype')),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('    %s',x),new_labels(dl_logic),'uniformoutput',false);
        
        dl_logic = cellfun(@(x) (contains(x,'SS01062')),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);        
        
        gf_logic = cellfun(@(x) (contains(x,'Giant Fiber') | contains(x,'SS27721') | contains(x,'SS00727')),new_labels);                
        new_labels(gf_logic) = cellfun(@(x) sprintf('  %s',x),new_labels(gf_logic),'uniformoutput',false);                
        
        dl_logic = cellfun(@(x) (contains(x,'L1, L2') | contains(x,'SS00797')),new_labels);
        new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function Nidaq_Summary(~,~)
        %plots nidaq traces for the 4 pezes, seperating between good and  "bad"
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        pez_used = cellfun(@(x) x(8:14),summary_table.Properties.RowNames,'UniformOutput',false);        
        date_used = cellfun(@(x) x(16:23),summary_table.Properties.RowNames,'UniformOutput',false);
        
        collection = cellfun(@(x) x(29:32),summary_table.Properties.RowNames,'UniformOutput',false);
%        date_filt = cellfun(@(x) str2double(x) < 20190401,date_used);
%        date_used(date_filt) = [];
%        pez_used(date_filt) = [];
%        summary_table(date_filt,:) = [];
        
        pct_good_flips = (summary_table.Val_Count ./ summary_table.Flip_Count)*100;

        [y_data,x_data,group_data] = iosr.statistics.tab2box(collection,pct_good_flips,pez_used);
        [x_data,sort_idx] = sort(x_data);
        
        [~,pez_idx] = sort(group_data{1});
        y_data = y_data(:,sort_idx,pez_idx);
        y_data(:,arrayfun(@(x) isnan(x), y_data(1,:,:))) = -10;
        
        x_data = cellfun(@(x) regexprep(x,'2019',''),x_data,'UniformOutput',false);
        
        figure;
        for iterZ = 1:4
            subplot(2,2,iterZ)
            h = iosr.statistics.boxPlot(1:length(x_data),y_data(:,:,iterZ),'symbolColor','k','medianColor','k','symbolMarker','+',...
                         'showScatter', true,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',50,'linewidth',2,'linecolor',rgb('black'));                                
            set(gca,'Ylim',[0 100],'Ytick',0:20:100,'Ygrid','on','Xtick',[])
            
            hxLabel = get(gca,'XLabel');                             set(hxLabel,'Units','data');
            xLabelPosition = get(hxLabel,'Position');                y = xLabelPosition(2);
            y = repmat(y,length(x_data),1);
            hText = text(1:1:length(x_data), y, x_data,'parent',gca);
            set(hText,'Rotation',45,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none');
            
%             for iterL = 1:6
%                 line_idx = find(cellfun(@(x) str2double(x(1:2)),x_data) == iterL,1,'first')-1;
%                 if ~isempty(line_idx)
%                     line([line_idx+.5 line_idx+.5],[0 100],'color',rgb('gray'),'linewidth',.8,'parent',gca)
%                 end
%             end
        end

    end
    function summary_table = create_base_summary_table(~,~)
        [~,~,~,cross_labels] = crosstab(result_table.Parent_A,result_table.Parent_B,result_table.First_Protocol,result_table.Second_Protocol,result_table.Food_Type);

        summary_table = cell(height(result_table),5);
        [~,locB] = ismember(result_table.Parent_A,cross_labels(cellfun(@(x) ~isempty(x), cross_labels(:,1)),1));
        summary_table(:,1) = cross_labels(locB,1);
        
        [~,locB] = ismember(result_table.Parent_B,cross_labels(cellfun(@(x) ~isempty(x), cross_labels(:,2)),2));
        summary_table(:,2) = cross_labels(locB,2);
        [~,locB] = ismember(result_table.First_Protocol,cross_labels(cellfun(@(x) ~isempty(x), cross_labels(:,3)),3));
        summary_table(:,3) = cross_labels(locB,3);
        [~,locB] = ismember(result_table.Second_Protocol,cross_labels(cellfun(@(x) ~isempty(x), cross_labels(:,4)),4));
        summary_table(:,4) = cross_labels(locB,4);
        [~,locB] = ismember(result_table.Food_Type,cross_labels(cellfun(@(x) ~isempty(x), cross_labels(:,5)),5));
        summary_table(:,5) = cross_labels(locB,5);
    end
    function geno_summary(~,~)                                                  %Counts for each protocol for each genotype
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);

        summary_table = create_base_summary_table;
        
        [locA,locB] = ismember(cellfun(@(x) x(33:44),filt_data.Properties.RowNames,'UniformOutput',false),result_table.Properties.RowNames);
        index_table = tabulate(locB(locA));
        summary_table = [summary_table,num2cell(index_table(:,2))];
       
        [locA,locB] = ismember(cellfun(@(x) x(33:44),filt_data(cell2mat(filt_data.jumpTest),:).Properties.RowNames,'UniformOutput',false),result_table.Properties.RowNames);
        index_table = tabulate(locB(locA));
        summary_table = [summary_table,num2cell(index_table(:,2))];

        summary_table = cell2table(summary_table);
        summary_table.Properties.RowNames = result_table.Properties.RowNames;
        summary_table.Properties.VariableNames = {'Parent_A','Parent_B','First_Protocol','Second_Protocol','Food_Used','Good_Videos','Jumpers'};        
        [~,sort_idx] = sort(summary_table.First_Protocol);
        summary_table = summary_table(sort_idx,:);
    end
    function pez_summary(~,~)                                                   %videos, jumpers and shorts by genotype, protocol and pez used
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        date_cut = 20190624;

        pez_counts = zeros(length(exp_info),4);
        jump_counts = zeros(length(exp_info),4);
        for iterZ = 1:length(exp_info)
            good_data = [vertcat(combine_data(iterZ).Complete_usuable_data);vertcat(combine_data(iterZ).Videos_Need_To_Work);...
                    vertcat(combine_data(iterZ).Vid_Not_Tracked);vertcat(combine_data(iterZ).Bad_Tracking);vertcat(combine_data(iterZ).Out_Of_Range)];

            good_data = [vertcat(combine_data(iterZ).Complete_usuable_data);vertcat(combine_data(iterZ).Videos_Need_To_Work)];
              
            pez_list = cellfun(@(x) x(8:14),good_data.Properties.RowNames,'UniformOutput',false);
            pez_counts(iterZ,1) = sum(cellfun(@(x) contains(x,'pez3001'),pez_list));
            pez_counts(iterZ,2) = sum(cellfun(@(x) contains(x,'pez3002'),pez_list));
            pez_counts(iterZ,3) = sum(cellfun(@(x) contains(x,'pez3003'),pez_list));
            pez_counts(iterZ,4) = sum(cellfun(@(x) contains(x,'pez3004'),pez_list));
            
            jump_data = good_data(cell2mat(good_data.jumpTest) == 1,:);            
            pez_list = cellfun(@(x) x(8:14),jump_data.Properties.RowNames,'UniformOutput',false);
            jump_counts(iterZ,1) = sum(cellfun(@(x) contains(x,'pez3001'),pez_list));
            jump_counts(iterZ,2) = sum(cellfun(@(x) contains(x,'pez3002'),pez_list));
            jump_counts(iterZ,3) = sum(cellfun(@(x) contains(x,'pez3003'),pez_list));
            jump_counts(iterZ,4) = sum(cellfun(@(x) contains(x,'pez3004'),pez_list));
            
        end

        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable'); 
        all_counts = [];
        all_jump_counts = [];
        all_pez_data = [];
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work);...
               vertcat(combine_data(parent_logic).Out_Of_Range)];
            bad_track = [vertcat(combine_data(parent_logic).Vid_Not_Tracked);vertcat(combine_data(parent_logic).Bad_Tracking)];

            pez_list = cellfun(@(x) x(8:14),good_data.Properties.RowNames,'UniformOutput',false);
            bad_pez_list = cellfun(@(x) x(8:14),bad_track.Properties.RowNames,'UniformOutput',false);
            for iterP = 1:4
                pez_logic = cellfun(@(x) contains(x,sprintf('pez300%1.0f',iterP)),pez_list);
                bad_pez_logic = cellfun(@(x) contains(x,sprintf('pez300%1.0f',iterP)),bad_pez_list);
                angle_counts = histc(good_data(pez_logic,:).Stim_Fly_Saw_At_Trigger,-202.5:45:202.5);
                angle_counts(end) = [];
                angle_counts(end) = angle_counts(end) + angle_counts(1);
                angle_counts(1) = [];
                angle_counts = [angle_counts',height(bad_track(bad_pez_logic,:))];
                all_pez_data = [all_pez_data;angle_counts];
                    
            end
        end
        all_pez_data(:,10) = all_pez_data(:,9);
        all_pez_data(:,9) = all_pez_data(:,1);
        all_pez_data(:,1) = [];
        
        
        summary_table = create_base_summary_table;
        pez_list = cellfun(@(x) x(8:14),filt_data.Properties.RowNames,'UniformOutput',false);
        date_logic = cellfun(@(x) str2double(x( 16:23)) >= date_cut,filt_data.Properties.RowNames);
        uni_pez = unique(pez_list);
        
        sum_index = 1:1:length(summary_table(:,1));
        total_table = [];
        jump_table = [];
        for iterP = 1:length(uni_pez)
            pez_logic = ismember(pez_list,uni_pez{iterP});
            full_logic = pez_logic & date_logic;
            
            table_counts = arrayfun(@(x) sum(full_logic(cell2mat(result_table(x,:).Label_Index))),1:1:height(result_table))';
            jump_cts = arrayfun(@(z) sum(ismember(cellfun(@(x) x(8:14),result_table.Video_data{z}.Properties.RowNames,'UniformOutput',false),uni_pez{iterP}) & ...
                cellfun(@(x) str2double(x(16:23)),result_table.Video_data{z}.Properties.RowNames)>= date_cut),1:1:height(result_table))';
            
            total_table = [total_table,table_counts];
            jump_table = [jump_table,jump_cts];
            
        end
        jump_label = cellfun(@(x) sprintf('%s_Jumpers',x),uni_pez','UniformOutput',false);
        summary_table = [summary_table,num2cell(total_table),num2cell(jump_table)];
        summary_table = cell2table(summary_table);
        summary_table.Properties.RowNames = result_table.Properties.RowNames;
        summary_table.Properties.VariableNames = [{'Parent_A','Parent_B','First_Protocol','Second_Protocol','Food_Used'},uni_pez',jump_label];        
        [~,sort_idx] = sort(summary_table.First_Protocol);
        summary_table = summary_table(sort_idx,:);
        
        date_list = cellfun(@(x) x(16:23),filt_data.Properties.RowNames,'UniformOutput',false);
        exp_id_list = cellfun(@(x) x(29:44),filt_data.Properties.RowNames,'UniformOutput',false);
        
        [cross_table,~,~,cross_label] = crosstab(exp_id_list,date_list);
        [~,sort_idx] = sort(cross_label(cellfun(@(x) ~isempty(x), cross_label(:,2)),2));
        cross_table = cross_table(:,sort_idx);
        
        jump_logic = find_jump_data(filt_data);
        
        [jump_table,~,~,jump_label] = crosstab(exp_id_list(jump_logic),date_list(jump_logic));       
        [~,sort_idx] = sort(jump_label(cellfun(@(x) ~isempty(x), jump_label(:,2)),2));
        jump_table = jump_table(:,sort_idx);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function rebin_azimuth_positions(~,~)
        azi_offset = 22.5;            %width of the rebined angle
        azi_angles = 0:(azi_offset*2):180;      %what angle to center the new azimuth on
                
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        
        position_summary = get_position_table(summary_table,azi_angles,azi_offset);
    end
    function position_summary = get_position_table(summary_table,azi_angles,azi_offset)
        Stimuli_info = vertcat(summary_table.visual_stimulus_info{:});
        elevation = vertcat(Stimuli_info.elevation);
        
        stim_str = struct2dataset(Stimuli_info);
        lv_used = get_lv_used(stim_str.method);
        uni_speed = unique(lv_used);
        
        uni_ele = unique(elevation);
               
        index = 1;
        position_summary = zeros(length(uni_speed)*length(uni_ele)*length(azi_angles),7);
        jump_logic = find_jump_data(summary_table);        
        for iterL = 1:length(uni_speed)
            for iterE = 1:length(uni_ele)
                for iterZ = azi_angles
                    stim_fly_saw = abs(summary_table.Stim_Fly_Saw_At_Trigger);
    %                stim_fly_saw = (summary_table.Stim_Fly_Saw_At_Trigger);
                    position_summary(index,1) = str2double(uni_speed{iterL});
                    position_summary(index,2) = uni_ele(iterE);
                    position_summary(index,3) = iterZ;
                    if uni_ele(iterE) == 90
                        filt_table = summary_table(ismember(elevation,uni_ele(iterE)) & ismember(lv_used,uni_speed(iterL)),:);
                        position_summary(index,4) = height(filt_table);
                    else
                        filt_table = summary_table(stim_fly_saw >= (iterZ-azi_offset) & stim_fly_saw < (iterZ+azi_offset) & ismember(elevation,uni_ele(iterE)) & ismember(lv_used,uni_speed(iterL)),:);
                        position_summary(index,4) = height(filt_table);
                    end

                    jump_table = filt_table(cell2mat(filt_table.jumpTest),:);                    
                    position_summary(index,5) = height(jump_table);

                    jump_table(cellfun(@(x) isempty(x),jump_table.frame_of_leg_push),:) = [];                    
                    position_summary(index,6) = height(jump_table);
%                    wing_cycle = cellfun(@(x,y) log((x-y)/6),jump_table.wing_down_stroke,jump_table.frame_of_wing_movement);
%                    short_table = jump_table(wing_cycle <= log(3.66),:);
%                    position_summary(index,7) = height(short_table);

                    index = index + 1;
                end
            end
        end
        position_summary = cell2table(num2cell(position_summary));
        position_summary.Properties.VariableNames = [{'LV_Used'},{'Elevation'},{'Azimuth'},{'Total_Videos'},{'Total_Jumpers'},{'Annotated_Jumpers'},{'Short_Pathway'}];
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [jump_data,stay_data] = split_jump_stay_data(summary_table)
        stimuli_pos_info = vertcat(summary_table.visual_stimulus_info{:});
        not_done_logic = cellfun(@(x) isempty(x), summary_table.frame_of_leg_push);
        missing_data = summary_table(not_done_logic,:).autoFrameOfTakeoff;
        missing_logic = cell2mat(summary_table(not_done_logic,:).jumpTest);
        missing_data(~missing_logic) = {NaN};

        summary_table(not_done_logic,:).frame_of_take_off = missing_data;
        summary_table(not_done_logic,:).frame_of_leg_push = num2cell(cell2mat(missing_data) - 30);
        
        jump_logic = cellfun(@(x) ~isnan(x),summary_table.frame_of_leg_push);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% split data between jumpers and stay
        jump_data = summary_table(jump_logic,:);
        stay_data = summary_table(~jump_logic,:);

    end
%% azimuth sweep functions for looming stimuli
    function [test_data,angle_vect] = get_jump_angle(test_data,gender,curr_plot,norm_frame,plot_type)
        not_done_logic = cellfun(@(x) isempty(x), test_data.frame_of_take_off);
        test_data(not_done_logic,:).frame_of_take_off = test_data(not_done_logic,:).autoFrameOfTakeoff;
        test_data(not_done_logic,:).frame_of_leg_push = num2cell(cell2mat(test_data(not_done_logic,:).frame_of_take_off) - 60);
        test_data(cell2mat(test_data.frame_of_leg_push) < 0,:) = [] ;
        
%         test_data(cellfun(@(x) isempty(x),test_data.frame_of_leg_push),:) = [];
%         test_data(cellfun(@(x) isnan(x),test_data.frame_of_leg_push),:) = [];
        test_data(cellfun(@(x,y) size(x(:,3),1) < y, test_data.bot_points_and_thetas,test_data.frame_of_take_off),:) = [];
        if isempty(test_data)
            angle_vect = [];
            return
        end
        
        if strcmp(norm_frame,'start')
            normalized_cords = cellfun(@(x,y) [x(y,1) - x(:,1),(x(y,2) - x(:,2))],test_data.bot_points_and_thetas,test_data.Start_Frame,'UniformOutput',false);
        else
            normalized_cords = cellfun(@(x,y) [x(y,1) - x(:,1),(x(y,2) - x(:,2))],test_data.bot_points_and_thetas,test_data.frame_of_leg_push,'UniformOutput',false);
        end
        filterd_list = cellfun(@(x,y,z) x(y:z,:),normalized_cords,test_data.frame_of_leg_push,test_data.frame_of_take_off,'UniformOutput',false); 
        
        if strcmp(norm_frame,'start')
            rotate_value = cellfun(@(x,y) x(y,3).*(180/pi),test_data.bot_points_and_thetas,test_data.Start_Frame,'UniformOutput',false);
        else
            rotate_value = cellfun(@(x,y) x(y,3).*(180/pi),test_data.bot_points_and_thetas,test_data.frame_of_leg_push,'UniformOutput',false);
        end
        rotate_value = rem(rem(cell2mat(rotate_value),360)+360,360);  
        
        rotated_cords = cellfun(@(x,y) rotation([x(:,1) x(:,2)],[0 0],360-y,'degrees'), filterd_list,num2cell(rotate_value),'UniformOutput',false);
        
        dist_moved = cell2mat(cellfun(@(x,y) x(end,:) - x(1,:),rotated_cords,'UniformOutput',false));                
        escape_azi_angle = arrayfun(@(x,y) atan(x /y).*180/pi,dist_moved(:,2),dist_moved(:,1));
        
        back_right = dist_moved(:,1) < 0 & dist_moved(:,2) >0;
        escape_azi_angle(back_right) = 180-escape_azi_angle(back_right);
        
        back_left = dist_moved(:,1) < 0 & dist_moved(:,2) < 0;
        escape_azi_angle(back_left) = escape_azi_angle(back_left)+90;
        

        front_right = dist_moved(:,1) > 0 & dist_moved(:,2) >= 0;
        escape_azi_angle(front_right) = escape_azi_angle(front_right) * -1;
        
        front_left = dist_moved(:,1) > 0 & dist_moved(:,2) < 0;
        escape_azi_angle(front_left) = escape_azi_angle(front_left) * -1;
        
        
        escape_azi_angle = escape_azi_angle .* pi/180;
        escape_azi_angle(escape_azi_angle > pi) = escape_azi_angle(escape_azi_angle > pi) - 2*pi;
        escape_azi_angle(escape_azi_angle < -pi) = escape_azi_angle(escape_azi_angle < -pi) + 2*pi;
        
        
        ele_escape = cellfun(@(x,y,z) x(y:z,:),test_data.top_points_and_thetas,test_data.frame_of_leg_push,test_data.frame_of_take_off,'UniformOutput',false);
        dist_moved_e = cell2mat(cellfun(@(x,y) x(end,:) - x(1,:),ele_escape,'UniformOutput',false));
        dist_moved_e(:,2) = dist_moved(:,2) * -1;
        ele_angle = arrayfun(@(x,y) abs(atan(x / y)),dist_moved_e(:,2),dist_moved_e(:,1));
         
        if strcmp(gender,'All')
            gender_logic = true(length(test_data.Gender),1);
        else
            gender_logic = cellfun(@(x) strcmp(x,gender),test_data.Gender);
        end
        move_cords = [dist_moved(:,1),dist_moved(:,2),abs(dist_moved_e(:,2))];
        
        if plot_type == 1
            circ_plot(escape_azi_angle(gender_logic),'pat_special',[],(360/(45/4)),true,true,'linewidth',2,'color','r',.3,'parent',curr_plot);
            h_title = title(sprintf('Escape Azimuth Angle\n for %s Flies only',gender),'HorizontalAlignment','center');
            old_pos = get(h_title,'position');  old_pos(2) =  old_pos(2) + .02;      set(h_title,'position',old_pos);
            angle_vect = escape_azi_angle(gender_logic);        
        elseif plot_type == 2
            wing_path = cellfun(@(x,y) ((x-y)/6),test_data(gender_logic,:).wing_down_stroke,test_data(gender_logic,:).frame_of_wing_movement);
            ttc_leg = cellfun(@(x,y,z) (z-(x+y))/6,test_data(gender_logic,:).Start_Frame,test_data(gender_logic,:).Stimuli_Duration,test_data(gender_logic,:).frame_of_leg_push);
%             [hist_counts,hist_edges,hist_bins] = histcounts(wing_path,[0:1:5,10:10:50,100,200]);
%             colors_to_use = colormap(jet(length(hist_counts)));
%             color_index = colors_to_use(hist_bins,:); 
%            scatter_plot_ele_azi(escape_azi_angle,ele_angle,gender_logic,color_index,wing_path,ttc_leg)
            scatter_plot_ele_azi(escape_azi_angle,ele_angle,gender_logic,wing_path,ttc_leg)
        else
            angle_vect = [escape_azi_angle(gender_logic),ele_angle(gender_logic)];        
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function jump_angle_rel_stim(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);

        
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        summary_table = summary_table(cellfun(@(x) ~contains(x,'wall'),summary_table.Stimuli_Used),:);
        
        [jump_data,~] = split_jump_stay_data(summary_table);
        stim_parms = parse_loom_stim(jump_data.Stimuli_Used);
        stim_info = struct2dataset(vertcat(jump_data.visual_stimulus_info{:}));
        elevation = stim_info.elevation;
        
        
        filt_logic = str2double(stim_parms(:,3)) == 40 & elevation == 45;
        
        [filt_jump_data,jump_angles] = get_jump_angle(jump_data(filt_logic,:),'All',[],'leg_frame',0);
        
        
        fly_pos_jump = cellfun(@(x,y) x(y,3).*180/pi,filt_jump_data.bot_points_and_thetas,filt_jump_data.frame_of_leg_push);
        fly_pos_jump = rem(rem(fly_pos_jump,360)+360,360);  
        stim_position = (cell2mat(filt_jump_data.stimulus_azimuth) + 2*pi).*180/pi;
        stim_position = rem(rem(stim_position,360)+360,360);  
        
        stim_diff = stim_position - fly_pos_jump;
        stim_diff(stim_diff> 180) = stim_diff(stim_diff> 180)-360;
        stim_diff(stim_diff< -180) = stim_diff(stim_diff< -180)+360;
        
        geno_string = cellfun(@(x) x(33:40), filt_jump_data.Properties.RowNames,'UniformOutput',false);
        [locA,locB] = ismember(geno_string,geno_results.Exp_ID);
        
        geno_string = geno_results(locB(locA),:).Parent_A_DN;
        uni_geno = unique(geno_string);
        for iterG = 1:length(uni_geno)
            figure;
            geno_logic = ismember(geno_string,uni_geno(iterG));
            azi_cuts = -135:45:180;
            plot_pos = [7,8,9,6,3,2,1,4];
            for iterZ = 1:length(azi_cuts)
                subplot(3,3,plot_pos(iterZ))
                if azi_cuts(iterZ) == 180
                     stim_logic = (abs(stim_diff) >= (azi_cuts(iterZ) - 22.5));
                else                
                    stim_logic = (stim_diff >= (azi_cuts(iterZ) - 22.5) & stim_diff < (azi_cuts(iterZ)+22.5));
                end
                circ_plot(jump_angles(stim_logic & geno_logic,1),'pat_special',[],(360/(45/4)),true,true,'linewidth',2,'color','r',.3,'parent',gca);
    %            scatter(jump_angles(stim_logic,2),jump_angles(stim_logic,1));
    %            set(gca,'Ylim',[-pi pi],'Xlim',[0 pi/2])
                h_title = title(sprintf('Stimuli relative to fly at %4.0f\n number of jumpers:: %4.0f',azi_cuts(iterZ),sum(stim_logic & geno_logic)),'Interpreter','none','HorizontalAlignment','center');
                curr_pos = get(h_title,'Position');     curr_pos(2) = curr_pos(2) + 0.065;
                set(h_title,'Position',curr_pos);

                [x_start,y_start] = pol2cart(azi_cuts(iterZ)*pi/180,.3);
                [x_end,y_end] = pol2cart(azi_cuts(iterZ)*pi/180,.25);
                set(gca,'nextplot','add')
                quiver(x_start,y_start,x_end-x_start,y_end-y_start,2,'color',rgb('orange'),'MaxHeadSize',5,'LineWidth',2);
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function stim_parms = parse_offaxis_loom(stimuli_string)
        has_azi90 = cellfun(@(x) contains(x,'azi90'),stimuli_string);
        azi_pos = zeros(length(stimuli_string),1);
        azi_pos(has_azi90) = 90;
        
        stimuli_string(has_azi90) = cellfun(@(x) regexprep(x,'_azi90',''),stimuli_string(has_azi90),'UniformOutput',false);
        stimuli_string = cellfun(@(x) regexprep(x,'p','.'),stimuli_string,'UniformOutput',false);
        stimuli_string = cellfun(@(x) regexprep(x,'.mat',''),stimuli_string,'UniformOutput',false);
        
        under_score_index = cell2mat(cellfun(@(x) strfind(x,'_'),stimuli_string,'UniformOutput',false));
        off_angle = cellfun(@(x,y,z) str2double(x(y+2:z-1)),stimuli_string,num2cell(under_score_index(:,1)),num2cell(under_score_index(:,2)));
        ele_used = cellfun(@(x,y,z) str2double(x(y+3:z-1)),stimuli_string,num2cell(under_score_index(:,2)),num2cell(under_score_index(:,3)));
        lv_used = cellfun(@(x,y,z) str2double(x(y+3:z-1)),stimuli_string,num2cell(under_score_index(:,3)),num2cell(under_score_index(:,4)));
        rho_used = cellfun(@(x,y,z) str2double(x(y+2:z-1)),stimuli_string,num2cell(under_score_index(:,4)),num2cell(under_score_index(:,5)));
        delta_used = cellfun(@(x,y) str2double(x(y+2:end)),stimuli_string,num2cell(under_score_index(:,5)));
        
        stim_parms = [lv_used,off_angle,ele_used,azi_pos,rho_used,delta_used];
    end
    function stim_parms = parse_loom_stim(test_string)
        test_string = cellfun(@(x) regexprep(x,'p','.'),test_string,'UniformOutput',false);
        test_string = cellfun(@(x) regexprep(x,'_blackonwhite.mat',''),test_string,'UniformOutput',false);
        
        to_index = cellfun(@(x) strfind(x,'to'),test_string);
        lv_index = cellfun(@(x) strfind(x,'lv'),test_string);
        start_angle = cellfun(@(x,y) x(6:(y-1)),test_string,num2cell(to_index),'uniformoutput',false);
        ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
        loverv = cellfun(@(x,y) x((y+2):end),test_string,num2cell(lv_index),'uniformoutput',false);
        
        stim_parms = [start_angle,ending_angle,loverv];
    end

    function usable_data = filter_center_flies(usable_data)
        roi_pos = cell2mat(cellfun(@(x,y) [x(1,1),x(3,1),x(1,2),x(2,2)],usable_data.Adjusted_ROI,'UniformOutput',false));
        fly_pos = cell2mat(cellfun(@(x,y) x(y,:), usable_data.bot_points_and_thetas,usable_data.Start_Frame,'UniformOutput',false));
        
        boundry = 60;
        offset = 832-384;
        fly_pos(:,2) = fly_pos(:,2) + offset;      
        center_x = (roi_pos(:,2) - roi_pos(:,1))/2 + roi_pos(:,1);
        center_y = (roi_pos(:,4) - roi_pos(:,3))/2 + roi_pos(:,3);
                
        
        x_off  = fly_pos(:,1) - center_x;
        y_off = fly_pos(:,2) - center_y;
               
%        dist_from_center = sqrt(x_off.^2 + y_off.^2);
        
        in_range_vids = abs(x_off) <= boundry & abs(y_off) <= boundry;
        usable_data = usable_data(in_range_vids,:);
                
%        [~,sort_idx] = sort(dist_from_center(in_range_vids),'descend');
%        usable_data = usable_data(sort_idx,:);
    end
    function plot_center_mass_change(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);        
        geno_list = get(exp_info,'ObsNames');
        
%        stim_parms = parse_offaxis_loom(exp_info.Stimuli_Type);
        
        full_string_list = cellfun(@(x,y,z,a,b) sprintf('%s_%s_%s_%s_%s',x,y,z,a,b),exp_info.ParentA_name,exp_info.ParentB_name,exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS02292',''),full_string_list,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS00934',''),full_string_list,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS02256',''),full_string_list,'UniformOutput',false);
        unique_data = unique(full_string_list);
%        unique_data(cellfun(@(x) contains(x,'SS49024'),unique_data)) = [];

        timing_index = 40./tan([10:10:180].*pi/360); %#ok<NBRAK>
        timing_index(end) = 0;
        timing_index = -6*(timing_index - timing_index(1));     %frames after start frame
        timing_index = round(timing_index);
        legend_key = unique(cellfun(@(y) y(1:cellfun(@(x) strfind(x,'loom'),unique_data)-2),unique_data,'UniformOutput',false),'stable');
        
        rotate_amt =  -90;
        x_avg = zeros(length(unique_data),length(timing_index));
        y_avg = zeros(length(unique_data),length(timing_index));
        
        for iterZ = 1:length(unique_data)
            filt_logic = ismember(full_string_list,unique_data{iterZ});
            video_data = [vertcat(combine_data(filt_logic).Complete_usuable_data);vertcat(combine_data(filt_logic).Videos_Need_To_Work)];
            video_data = filter_center_flies(video_data);
            
            pos_vect_x = zeros(height(video_data),length(timing_index));
            pos_vect_y = zeros(height(video_data),length(timing_index));
            for iterP = 1:height(video_data)
                samp_vid_pos = cell2mat(video_data(iterP,:).bot_points_and_thetas);
                samp_vid_pos = samp_vid_pos(video_data(iterP,:).Start_Frame{1}:end,:);
                samp_vid_pos(:,1) = samp_vid_pos(:,1) - samp_vid_pos(1,1);
                samp_vid_pos(:,2) = samp_vid_pos(:,2) - samp_vid_pos(1,2);
                bot_data = [samp_vid_pos(:,1),samp_vid_pos(:,2)];
                
                rotate_amount = rotate_amt-(samp_vid_pos(1,3).*180/pi);
                rot_bot_data = rotation(bot_data,[0 0],-rotate_amount,'degree');
                
                for iterT = 1:length(timing_index)
                    if size(rot_bot_data,1) >= (timing_index(iterT)+1)
                        pos_vect_x(iterP,iterT) = rot_bot_data(timing_index(iterT)+1,1);
                        pos_vect_y(iterP,iterT) = rot_bot_data(timing_index(iterT)+1,2);
                    else
                        pos_vect_x(iterP,iterT) = -360;
                        pos_vect_y(iterP,iterT) = -360;
                    end
                end
            end
            pos_vect_x(pos_vect_x == -360) = NaN;
            pos_vect_y(pos_vect_y == -360) = NaN;
            
            x_avg(iterZ,:) = mean(pos_vect_x,1,'omitnan');
            y_avg(iterZ,:) = mean(pos_vect_y,1,'omitnan');
        end
        figure
        make_scatter_move_plot(1,y_avg,unique_data,'45_0',legend_key);             title('Loom_10to180_Lv40    Azimuth 0 (from infront),  Center of mass front/back movement','Interpreter','none');
        make_scatter_move_plot(2,x_avg,unique_data,'45_0',legend_key);             title('Loom_10to180_Lv40    Azimuth 0 (from infront),  Center of mass left/right movement','Interpreter','none');
        make_scatter_move_plot(3,y_avg,unique_data,'45_180',legend_key);           title('Loom_10to180_Lv40    Azimuth 180 (from behind),  Center of mass front/back movement','Interpreter','none');
        make_scatter_move_plot(4,x_avg,unique_data,'45_180',legend_key);           title('Loom_10to180_Lv40    Azimuth 180 (from behind),  Center of mass left/right movement','Interpreter','none');
    end
    function make_scatter_move_plot(index,plot_data,unique_data,stim_string,legend_key)
        subplot(2,2,index);             plot(10:10:180,plot_data(cellfun(@(x) contains(x,stim_string),unique_data),:),'-o');     
        set(gca,'Ylim',[-50 50],'Ytick',-50:25:50,'Ygrid','on')
        h_len = legend(legend_key,'location','north','Interpreter','none');
        xlabel('size of stimuli (degrees)')
        ylabel('center of mass movement (avgerage pixels');
        
    end
    function make_montages(hObj,~)
        plot_type = get(hObj,'UserData');

        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);        
        geno_list = get(exp_info,'ObsNames');
        
%        stim_parms = parse_offaxis_loom(exp_info.Stimuli_Type);
        
        full_string_list = cellfun(@(x,y,z,a,b) sprintf('%s_%s_%s_%s_%s',x,y,z,a,b),exp_info.ParentA_name,exp_info.ParentB_name,exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS02292',''),full_string_list,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS00934',''),full_string_list,'UniformOutput',false);
        full_string_list = cellfun(@(x) regexprep(x,'GMR_SS02256',''),full_string_list,'UniformOutput',false);
        
        
        all_res = [];
        unique_data = unique(full_string_list);
%        unique_data(cellfun(@(x) contains(x,'1500090'),unique_data)) = [];
        unique_data(cellfun(@(x) contains(x,'UAS_Chrimson_Venus'),unique_data)) = [];

%        unique_data = unique_data(cellfun(@(x) contains(x,'1554'),unique_data));
        for iterZ = 1:length(unique_data)
            filt_logic = ismember(full_string_list,unique_data{iterZ});
            total_counts = vertcat(combine_data(filt_logic).total_counts);
            total_counts = total_counts.Variables;
%            total_counts = sum(total_counts);
            video_data = [vertcat(combine_data(filt_logic).Complete_usuable_data);vertcat(combine_data(filt_logic).Videos_Need_To_Work)];
            center_count = get_center_count(video_data);
            
            result_sum = [unique_data(iterZ),num2cell([total_counts(1),total_counts(2),total_counts(11),center_count])];
            all_res = [all_res;result_sum];
        end


        for iterZ = 1:length(unique_data)
            filt_logic = ismember(full_string_list,unique_data{iterZ});
            if plot_type == 1       %use all data
                video_data = [vertcat(combine_data(filt_logic).Complete_usuable_data);vertcat(combine_data(filt_logic).Videos_Need_To_Work)];
%                logical_filter = true(height(video_data),1);
%                sort_order = 1:1:30;                
                sort_order = 'none';
            elseif plot_type == 2   %use only jumpers
                done_data = vertcat(combine_data(filt_logic).Complete_usuable_data);
                need_to_work = vertcat(combine_data(filt_logic).Videos_Need_To_Work);
                logical_filter = [cellfun(@(x) ~isnan(x),done_data.frame_of_leg_push);false(height(need_to_work),1)];
                sort_order = 'time_of_jump';
                video_data = [done_data;need_to_work];
            end
            
%            video_data = trim_to_center_img(video_data);
%            video_data = filter_center_flies(video_data);
            
            %total_vids = sum(logical_filter);
            total_vids = size(video_data,1);
            
            num_loops = ceil(total_vids/30);
            if num_loops > 5
                num_loops = 5;
            end
            num_loops = 1;
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
                if iterS > num_loops
                    continue
                end

                
%                vidMontage_testing(geno_list(iterZ),'loom',combine_data(filt_logic),logical_filter,sort_order,'top','none',iterS);
%                vidMontage_testing(geno_list(filt_logic),'loom','test_data',video_data,'logical_filter',logical_filter,'sort_order',sort_order,...
%                vidMontage_testing(geno_list(filt_logic),'test_data',video_data,'logical_filter',logical_filter,'sort_order',sort_order,...


%                vidMontage_testing(geno_list(iterZ),'stim_type','loom','test_data',combine_data(filt_logic),'Logic_Filter','Centered_Flies',...
                vidMontage_testing(unique_data(iterZ),'stim_type','loom','test_data',combine_data(filt_logic),'Logic_Filter','jumpers_only_auto',...
                    'view_opt','bottom','rotate_opt','rotate','video_index',iterS,...                
                    'center_mass_opts','all','Center_Size',8,'Center_Color','red',...
                    'Stimuli_Size',8,'Stimuli_Color','cyan','Show_center',true,'Show_Stimuli',true,'Show_Border',false,'Border_Color','white',...
                    'Download_Frames','all','Download_Range',10,'view_opt','bottom','rotate_opt','rotate','rotate_amt',90);                 
                
                
%                 if vidCount < total_vids
%                     total_vids = vidCount;
%                     num_loops = ceil(total_vids/30);
%                 end
                
                fprintf('video took %4.4f seconds\n',toc(tstart));
                
%                 tstart = tic;
%                 vidMontage_testing(geno_list(iterZ),'stim_type','loom','test_data',combine_data(filt_logic),'Logic_Filter','Centered_Flies','sort_order',sort_order,...
%                     'view_opt','bottom','rotate_opt','rotate','video_index',iterS,...                
%                     'center_mass_opts','all','Center_Size',8,'Center_Color','red',...
%                     'Show_center',true,'Show_Stimuli',false,'Show_Border',true,'Border_Color','white',...
%                     'Download_Frames','all','Download_Range',100,'view_opt','top','rotate_opt','none');
%                 
%                 fprintf('video took %4.4f seconds\n',toc(tstart));        
            end
        end    
    end
    function center_count = get_center_count(usable_data)
        roi_pos = cell2mat(cellfun(@(x,y) [x(1,1),x(3,1),x(1,2),x(2,2)],usable_data.Adjusted_ROI,'UniformOutput',false));
        fly_pos = cell2mat(cellfun(@(x,y) x(y,:), usable_data.bot_points_and_thetas,usable_data.Start_Frame,'UniformOutput',false));
        
        boundry = 60;
        offset = 832-384;
        fly_pos(:,2) = fly_pos(:,2) + offset;      
        center_x = (roi_pos(:,2) - roi_pos(:,1))/2 + roi_pos(:,1);
        center_y = (roi_pos(:,4) - roi_pos(:,3))/2 + roi_pos(:,3);
                
        
        x_off  = fly_pos(:,1) - center_x;
        y_off = fly_pos(:,2) - center_y;
               
%        dist_from_center = sqrt(x_off.^2 + y_off.^2);
        
        in_range_vids = abs(x_off) <= boundry & abs(y_off) <= boundry;
        usable_data = usable_data(in_range_vids,:);
        center_count = height(usable_data);
    end
    function close_graph(~,~)
        try
            delete(poolobj);
        catch
        end
        delete(hFigC)
    end
end
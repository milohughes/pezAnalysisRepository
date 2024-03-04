function graph_layout_gui_martin_v2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
%% pathing for support programs
    clc
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    
    repositoryDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(repositoryDir,'pat_test_programs'))   
    
    save_path = [filesep filesep 'DM11' filesep 'cardlab' filesep 'Matlab_Save_Plots'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
%% user parameters
    temp_range = [22.5,24.0];
    humidity_cut_off = 40;
    azi_off = 22.5;
    remove_low = true;
    low_count = 5;
    exp_cut = 100;
    ignore_graph_table = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%% variables used in program
    curr_collection = ' ';          curr_group = [];                    combine_data = [];              m_parent_name = [];             m_parent_id = [];                 
    m_incubator = [];               m_food = [];                        m_stimuli = [];                 exp_dir = [];                   saved_collections = [];
    saved_groups = [];              hCollectdrop  = [];                 hGroupdrop  = [];               h_load_data = [];
    h_summary_count = [];           h_table_counts  = [];               num_list_1 = [];                var_list = [];                  filt_var_list = [];
    filt_num_list = [];             load_files = [];                    struct_result = [];             save_on = [];                   save_off = [];
    curr_user = [];                 collect_name = [];                  group_name = [];                struct_result_sep = [];         struct_result_combine = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%% starts parallel processing
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
        saved_groups = saved_groups(cellfun(@(x) contains(x,'Active'),saved_groups.Status),:);
        
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
        num_list_1 = [{'Vials|Run'},{'Total|Videos'},{'Pez|Issues'},{'Multi/Blank|Fly Vids'},{'Balancers|Sticky Wing'},{'Failed|Location'},{'Videos Not|Tracked'},{'Short or Bad|Tracking'},{'Out Of|Range'},{'Need To|Annotate'},{'Usuable|Complete'}];        
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
            m_parent_opts = uimenu(m_variables,'Label','Parent Info');
                m_parent_name = uimenu(m_parent_opts,'Label','Show Parent Names','checked','on','Callback',@change_info);           %default on
                m_parent_id = uimenu(m_parent_opts,'Label','Show Robot Ids','checked','off','Callback',@change_info);               %default off
            m_other_opts = uimenu(m_variables,'Label','Other Information');
                m_incubator = uimenu(m_other_opts,'Label','Show Incubator Used','checked','off','Callback',@change_info);           %default off
                m_food = uimenu(m_other_opts,'Label','Show Food Used','checked','off','Callback',@change_info);                     %default off
                m_stimuli = uimenu(m_other_opts,'Label','Show Stimuli Used','checked','on','Callback',@change_info);                %default on        
        m_martin = uimenu(hFigC,'Label','Plots for Martins Data');            

            uimenu(m_martin,'label','Pathway Scatter Plots','callback',@pathway_scatter);
        m_take_off = uimenu(hFigC,'label','New Take off Plots');
            uimenu(m_take_off,'label','New Take off Plots :: Genotype Split By  Azimuth','callback',@take_off_plots,'UserData',1.0);        
            uimenu(m_take_off,'label','New Take off Plots :: Genotype Split By L/V','callback',@take_off_plots,'UserData',1.1);
            uimenu(m_take_off,'label','New Take off Plots :: L/V Split By Azimuth','callback',@take_off_plots,'UserData',2.0);
            uimenu(m_take_off,'label','New Take off Plots :: L/V Split By Genotype','callback',@take_off_plots,'UserData',2.1);
        m_pathway  = uimenu(hFigC,'label','Pathway Histograms');
            uimenu(m_pathway,'label','Pathway Hist :: Full Pathway','callback',@pathway_histogram,'UserData',1);
            uimenu(m_pathway,'label','Pathway Hist :: Wing Cycle Only','callback',@pathway_histogram,'UserData',2);            
        m_pathway_1  = uimenu(hFigC,'label','Timing Plots');
            uimenu(m_pathway_1,'label','Time of Wing Lift','callback',@timing_scatter_plot,'UserData',1);
            uimenu(m_pathway_1,'label','Pathway Hist :: Full Pathway','callback',@pathway_histogram_split);
            uimenu(m_pathway_1,'label','Pathway :: Short Percent','callback',@pathway_short_pct);
            
        m_special  = uimenu(hFigC,'label','Special Testing Plot');
            uimenu(m_special,'label','Chrim Testing Plot','callback',@chrim_compare_plot);
            uimenu(m_special,'label','Center Movement','callback',@center_of_mass_move);
        m_save = uimenu(hFigC,'label','Save Options');
            save_on = uimenu(m_save,'Label','Save On','checked','off','Callback',@save_plot_toggle);                %default on        
            save_off = uimenu(m_save,'Label','Save Off','checked','on','Callback',@save_plot_toggle);                %default on        
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
        curr_user = list(index);
        
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
        group_name = list{index};
        
        
        set_up_info
    end
    function populatelist(hObj,~)                           % called if Group
        new_dataset
        set(hGroupdrop,'value',1);             index = get(hObj,'value');             list = get(hObj,'string');
        collect_name = cellfun(@(x) ['Collect_',x(1:strfind(x,'::')-2)],list(index),'uniformoutput',false);        
        list = cellfun(@(x) x(strfind(x,'::')+4:end),list(index),'uniformoutput',false);
        curr_collection = get(saved_collections(ismember(saved_collections.Collection_Name,list),:),'ObsName');
        set_up_info
    end
    function set_up_info(~,~)                               % brings in data and sets up the table
        get_analyized_file
        populate_summary_data
        set_filt_list                          %sets default filtering
        populate_table_data
        [struct_result_sep, struct_result_combine] = genotype_profile;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reads in the data and cleans it up  
    function clean_up_load(~,~)
%        load_files(cellfun(@(x) ~isempty(strfind(x,'009800002402')),load_files)) = [];
%        load_files(cellfun(@(x) ~isempty(strfind(x,'009800002403')),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'010500002421'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'010700002421'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'006700001843'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'006700001717'),load_files)) = [];
        load_files(cellfun(@(x) contains(x,'0108') & contains(x,'0739') ,load_files)) = [];
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
            test_data.ignore_graph_table = ignore_graph_table;
            try
                test_data.load_data;
                test_data.make_tables;
                combine_data = [combine_data;test_data]; 
            catch
                warning('id with no graph table');
            end
        end
        clc
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
        ids_usuable_data = arrayfun(@(x) height(combine_data(x).Complete_usuable_data) + height(combine_data(x).Videos_Need_To_Work),1:1:steps);
        combine_data(ids_usuable_data == 0,:) = [];
        
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

        index = 13;
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
        
        var_size = length(num_list);        
        
        new_data(:,1) = cellfun(@(x) sprintf('%22s',x),new_data(:,1),'uniformoutput',false);
        new_data(:,2:end) = cellfun(@(x) sprintf('%13s',num2str(x)),new_data(:,2:end),'uniformoutput',false);
        
        parsed_data = vertcat(combine_data(:).parsed_data);         filt_parse = dataset2cell(parsed_data(:,1:4));        
        incubator = cellstr(parsed_data.Name);
                
        stim_list = parsed_data.Stimuli_Type;        
        Elevation = parsed_data.Elevation;
        Azimuth = parsed_data.Azimuth;
        
        loom_logic = ~strcmp(stim_list,'None');
        to_index = cellfun(@(x) strfind(x,'to'),stim_list(loom_logic));
        lv_index = cellfun(@(x) strfind(x,'lv'),stim_list(loom_logic));
        score_index = cellfun(@(x) max(strfind(x,'_')),stim_list(loom_logic));
        start_angle = cellfun(@(x,y) x(6:(y-1)),stim_list(loom_logic),num2cell(to_index),'uniformoutput',false);
        ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),stim_list(loom_logic),num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
        loverv = cellfun(@(x,y,z) x((y+2):(z-1)),stim_list(loom_logic),num2cell(lv_index),num2cell(score_index),'uniformoutput',false);
        tail_str = cellfun(@(x,y) x((y+1):end),stim_list(loom_logic),num2cell(score_index),'uniformoutput',false);
        stim_list(loom_logic) = cellfun(@(x,y,z,a,b,c) sprintf('loom_%03sto%03s_lv%03s_%s :: Ele :: %02s     Azi :: %03s',x,y,z,a,b,c), start_angle,ending_angle,loverv,tail_str,Elevation(loom_logic),Azimuth(loom_logic),'uniformoutput',false);
                
        chrm_type_list = parsed_data.Photo_Activation;
        try
            chrm_count = cellfun(@(x) ~strcmp(x,'None') , chrm_type_list);
            chrm_count = sum(chrm_count,2);
        catch
            chrm_count = cellfun(@(x) sum(~strcmp(x,'None')) , chrm_type_list);
        end

        chrm_opts = cellfun(@(x) (~strcmp(x,'None')) , chrm_type_list,'uniformoutput',false);
        chrim_str = cell(length(chrm_opts(:,1)),1);
        chrim_str(cellfun(@(x) sum(x), chrm_opts) == 1) = chrm_type_list(cellfun(@(x) sum(x), chrm_opts)==1,1);

        chrim_str(chrm_count == 0) = {'No Chrimson Trace'};
        chrim_str(chrm_count >= 2) = {'Multiple Chrimson Traces'};       
        
        cell_logic = cellfun(@(x) iscell(x), chrim_str);
        if sum(cell_logic) > 0
            chrim_str(cell_logic) = cellfun(@(x) x(1), chrim_str(cell_logic));
        end         
        
        Stim_shown = cell(length(stim_list),1);
        Stim_shown(cellfun(@(x) strcmp(x,'None'),stim_list)) = chrim_str(cellfun(@(x) strcmp(x,'None'),stim_list));
        Stim_shown(cellfun(@(x) strcmp(x,'No Chrimson Trace'),chrim_str)) = stim_list(cellfun(@(x) strcmp(x,'No Chrimson Trace'),chrim_str));
        
        part_2 = [filt_parse(2:end,2:end),incubator,parsed_data.Food_Type,Stim_shown];
        part_2_spacing = {400,100,400,100,250,200,400};
        part_2 = part_2(:,filt_var_list);   part_2_spacing = part_2_spacing(filt_var_list);
        new_data = [new_data,part_2];
        
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
                
        set(graph_table,'columnwidth',[{175},num2cell(repmat(110,1,var_size)),part_2_spacing]);
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
    function change_info(hObj,~)
        logic_vect = true(1,length(var_list));
        status = get(hObj,'checked');
        if strcmp(status,'on')
            set(hObj,'checked','off')
        else
            set(hObj,'checked','on')
        end
        set_filt_list
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% pareses data into a structure for all plotting
    function [struct_result_sep, struct_result_combine] = genotype_profile(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = correct_exp_info(exp_info);
                        
        good_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work)];
        jump_logic = get_jump_info(good_data);
        
        geno_id = cellfun(@(x) x(33:40),good_data.Properties.RowNames,'UniformOutput',false);
        [new_labels_sep,new_labels_combine] = convert_labels(geno_id,'DN_convert',exp_info,'exp_str_8');
        new_stimuli = convert_stimuli(good_data.Stimuli_Used);
        
        struct_result_sep = make_struct_res(new_stimuli,good_data,new_labels_sep,jump_logic);
        struct_result_combine = make_struct_res(new_stimuli,good_data,new_labels_combine,jump_logic);
    end
    function struct_result = make_struct_res(new_stimuli,good_data,new_labels,jump_logic)
        [data_table,~,~,data_protocol] = crosstab(new_stimuli,abs(good_data.Stim_Pos_At_Trigger),new_labels);
        [jump_table,~,~,jump_protocol] = crosstab(new_stimuli(jump_logic),abs(good_data(jump_logic,:).Stim_Pos_At_Trigger),new_labels(jump_logic));

%         [~,locB] = ismember(data_protocol(:,3),jump_protocol(:,3));
%         jump_protocol(:,3) = jump_protocol(locB,3);
%         jump_table = jump_table(:,:,locB);
        
                
        geno_list = data_protocol(cellfun(@(x) ~isempty(x),data_protocol(:,3)),3);
        struct_result = struct([]);
        
        for iterZ = 1:length(geno_list)
            struct_result(iterZ).genotype = geno_list(iterZ);
            
            samp_table = cell2table(num2cell(data_table(:,:,iterZ)));
            samp_table.Properties.RowNames = data_protocol(cellfun(@(x) ~isempty(x),data_protocol(:,1)),1);
            samp_table.Properties.VariableNames = cellfun(@(x) sprintf('azimuth_%03s',x),data_protocol(cellfun(@(x) ~isempty(x),data_protocol(:,2)),2),'UniformOutput',false);
            struct_result(iterZ).videos = samp_table;
            
            samp_jump_table = cell2table(num2cell(jump_table(:,:,iterZ)));
            samp_jump_table.Properties.RowNames = jump_protocol(cellfun(@(x) ~isempty(x),jump_protocol(:,1)),1);
            samp_jump_table.Properties.VariableNames = cellfun(@(x) sprintf('azi_%03s',x),jump_protocol(cellfun(@(x) ~isempty(x),jump_protocol(:,2)),2),'UniformOutput',false);
            struct_result(iterZ).jumpers = samp_jump_table;
                        
%            temp_data = good_data(ismember(new_labels,geno_list{iterZ}) & jump_logic,:);
            for iterR = 1:length(samp_jump_table.Properties.RowNames)
                for iterV = 1:length(samp_jump_table.Properties.VariableNames)
                    stim_azi = arrayfun(@(x) sprintf('azi_%03.0f',x),abs(good_data.Stim_Pos_At_Trigger),'UniformOutput',false);
                    matching_logic = ismember(new_labels,geno_list{iterZ}) & ismember(new_stimuli,samp_jump_table.Properties.RowNames{iterR}) & ismember(stim_azi,samp_jump_table.Properties.VariableNames{iterV});
                    matching_data = good_data(matching_logic & jump_logic,:);
                    
                    string_1 = samp_jump_table.Properties.RowNames{iterR};                    string_1 = string_1(~isspace(string_1));
                    string_2 = samp_jump_table.Properties.VariableNames{iterV};               string_2 = string_2(~isspace(string_2));
                    new_string = sprintf('%s_%s',string_1,string_2);
                    new_string  = regexprep(new_string,'%','');
                    
                    struct_result(iterZ).(new_string) = matching_data;
                end
            end
        end
        [~,sort_idx] = sort(vertcat(struct_result.genotype));
        struct_result = struct_result(:,sort_idx);
    end
    function control_logic = get_control_logic(geno_labels)
        control_genotypes = [{'DL Wildtype'};{'CTRL_DL_1500090'};{'L1, L2'};{'SS00797'};{'SS01062'};{'DNp01'};{'Giant Fiber'};{'P1'}];
        geno_labels = cellfun(@(x) strtrim(x),geno_labels,'UniformOutput',false);
        
        new_label_length = cellfun(@(x) length(x),geno_labels,'UniformOutput',false);
        parens_index = cellfun(@(x) strfind(x,'(')-1,geno_labels,'UniformOutput',false);
        parens_index(cellfun(@(x) isempty(x),parens_index)) = new_label_length(cellfun(@(x) isempty(x),parens_index));
        geno_labels = cellfun(@(x,y) x(1:y),geno_labels,parens_index,'UniformOutput',false);
        geno_labels = cellfun(@(x) strtrim(x), geno_labels,'UniformOutput',false);

        control_logic = ismember(geno_labels,control_genotypes);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% clean up functions for plotting
    function exp_info = correct_exp_info(exp_info)
        flip_logic = cellfun(@(x) contains(x,'1150416') | contains(x,'1117481') | contains(x,'1500383'),exp_info.ParentA_ID);
        temp_par_b_id = exp_info.ParentB_ID(flip_logic);
        temp_par_b_name = exp_info.ParentB_name(flip_logic);
        
        exp_info.ParentB_ID(flip_logic) = exp_info.ParentA_ID(flip_logic);        exp_info.ParentA_ID(flip_logic) = temp_par_b_id;
        exp_info.ParentB_name(flip_logic) = exp_info.ParentA_name(flip_logic);    exp_info.ParentA_name(flip_logic) = temp_par_b_name;
                
        exp_info.ParentB_name(cellfun(@(x) contains(x,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'),exp_info.ParentB_name)) = {'DL_UAS_Kir21_3_0090'};
        exp_info.ParentB_name(cellfun(@(x) contains(x,'UAS_Chrimson_Venus_X_0070VZJ_K_45195'),exp_info.ParentB_name)) = {'UAS_Chrimson_Venus_X_0070'};                
        exp_info.ParentB_name(cellfun(@(x) contains(x,'CTRL_DL_1500090_0028FCF_DL_1500090'),exp_info.ParentB_name)) = {'CTRL_DL_1500090'};
    end
    function jump_logic = get_jump_info(all_data)
        chrim_logic = cellfun(@(x) ~isempty(x),all_data.photoactivation_info);
                    
        not_work = cellfun(@(x) isempty(x), all_data.frame_of_leg_push);
        complete = cellfun(@(x) ~isempty(x), all_data.frame_of_leg_push);
        done_jump = cellfun(@(x) ~isnan(x), all_data(complete,:).frame_of_leg_push);
        
        jump_logic = all_data.autoJumpTest == 1;
        jump_logic(complete) = done_jump;
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
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% label convert functions
    function [sort_order,new_labels,sort_labels] = make_sort_order(new_labels)
        dl_logic = cellfun(@(x) (contains(x,'DL Wildtype')),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('    %s',x),new_labels(dl_logic),'uniformoutput',false);
        
        dl_logic = cellfun(@(x) (contains(x,'SS01062')),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);        
        
        gf_logic = cellfun(@(x) (contains(x,'Giant Fiber')),new_labels);                
        new_labels(gf_logic) = cellfun(@(x) sprintf('  %s',x),new_labels(gf_logic),'uniformoutput',false);                
        
        gf_logic = cellfun(@(x) (contains(x,'DNp01')),new_labels);
        new_labels(gf_logic) = cellfun(@(x) sprintf('  %s',x),new_labels(gf_logic),'uniformoutput',false);        

        single_logic = cellfun(@(x) ~contains(x,','),new_labels);
        new_labels(single_logic) = cellfun(@(x) sprintf(' %s',x),new_labels(single_logic),'uniformoutput',false);                                
        
        dl_logic = cellfun(@(x) (contains(x,'L1, L2')),new_labels);
        new_labels(dl_logic) = cellfun(@(x) sprintf(' %s',x),new_labels(dl_logic),'uniformoutput',false);
        
        [sort_labels,sort_order] = sort(new_labels);
    end
    function [new_labels_sep,new_labels_combine] = convert_labels(old_labels,flag,exp_info,str_type)                         %flips 8 digit number into parent information
        switch flag
            case 'DN_convert'
                not_in_sheet_id = [    {'1500090'};  {'3015823'};  {'2502522'};   {'3020007'};   {'2135398'};      {'2135419'};    {'2135420'};     {'1500437'}; {'3026909'}];
                not_in_sheet_conv = [{'DL Wildtype'};{'SS01062'};  {'LC4(0315)'}; {'LC6(77B)'};  {'LPLC1(29B)'};  {'LPLC2(47B)'}; {'LPLC2(48B)'};  {'FCF_pBDP'};{' L1, L2'}];
                
%                [~,~,raw] = xlsread('C:\Users\breadsp\Documents\new_martin_counts.xlsx','Hiros List');
                [~,~,raw] = xlsread('Z:\Pez3000_Gui_folder\DN_name_conversion.xlsx','Hiros List');
                header_list = raw(1,1:end);
                header_list = regexprep(header_list,' ','_');
                dn_table = cell2table(raw(2:end,1:end));
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
                new_labels = old_id_name;
                new_labels_sep = old_id_name;
                new_labels_combine = old_id_name;
                
                [match_logic_sheet,match_pos_sheet] = ismember(str2double(old_id_list),dn_table.robot_ID);          %find records matching hiros table
                [match_logic_table,match_pos_table] = ismember(old_id_list,not_in_sheet_id);            %find records matching manual table                
                
%                new_labels(match_logic_sheet) = dn_table.old_name(match_pos_sheet(match_logic_sheet));
                new_labels_sep(match_logic_sheet) = dn_table.import_name(match_pos_sheet(match_logic_sheet));
                new_labels_combine(match_logic_sheet) = dn_table.new_name(match_pos_sheet(match_logic_sheet));                
                
                new_labels_sep(match_logic_table) = not_in_sheet_conv(match_pos_table(match_logic_table));
                new_labels_combine(match_logic_table) = not_in_sheet_conv(match_pos_table(match_logic_table));

%                [~,new_labels]  = make_sort_order(new_labels);                
        end
    end    
    function new_stimuli = convert_stimuli(Stimuli_Used)
        loom_logic = cellfun(@(x) contains(x,'loom'),Stimuli_Used);
        chrim_logic = cellfun(@(x) ~contains(x,'loom'),Stimuli_Used);
        new_stimuli = cell(length(Stimuli_Used),1);
        
        photo_str = Stimuli_Used(chrim_logic);
        if ~isempty(photo_str)
            intensity_index = cellfun(@(x) strfind(x,'intensity'),photo_str);
            duration_start = cellfun(@(x) strfind(x,'Begin'),photo_str);
            duration_end = cellfun(@(x) strfind(x,'_widthEnd'),photo_str);
            intensity_used = cellfun(@(x,y) str2double(x(y+9:end)),photo_str,num2cell(intensity_index));
            duration_used = cellfun(@(x,y,z) str2double(x(y+5:z-1)),photo_str,num2cell(duration_start),num2cell(duration_end));
            new_stimuli(chrim_logic) = cellfun(@(x,y) sprintf('Intensity_%3.0f%%_%5.0fms',x,y),num2cell(intensity_used),num2cell(duration_used),'uniformoutput',false);
        end
                                
        loom_str = Stimuli_Used(loom_logic);
        if ~isempty(loom_str)
            to_index = cellfun(@(x) strfind(x,'to'),loom_str);
            lv_index = cellfun(@(x) strfind(x,'lv'),loom_str);
            score_index = cellfun(@(x) max(strfind(x,'_')),loom_str);
            start_angle = cellfun(@(x,y) x(6:(y-1)),loom_str,num2cell(to_index),'uniformoutput',false);
            ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),loom_str,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
            loverv = cellfun(@(x,y,z) x((y+2):(z-1)),loom_str,num2cell(lv_index),num2cell(score_index),'uniformoutput',false);
%            new_stimuli(~chrim_logic) = cellfun(@(x,y,z) sprintf('loom_%03sto%03s_lv%03s',x,y,z), start_angle,ending_angle,loverv,'uniformoutput',false);
            new_stimuli(~chrim_logic) = cellfun(@(x) sprintf('lv%03s',x),loverv,'uniformoutput',false);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% various plotting functions
    function take_off_plots(hObj,~)             %makes various take off percent plots
        selection = get(hObj,'UserData');
        figure
        new_labels = vertcat(struct_result_sep.genotype);
        
        [sort_order,~,new_labels] = make_sort_order(new_labels);
        sort_struct = struct_result_sep(:,sort_order);
        control_logic = get_control_logic(new_labels);        
        
        if selection == 1.0  ||  selection == 1.1     %split take off by genotype
            total_plots = length(sort_struct);
            [x_plot,y_plot] = split_fig(total_plots);
            for iterZ = 1:total_plots
                subplot(x_plot,y_plot,iterZ)
                video_data = table2cell(sort_struct(iterZ).videos);                
                jump_data = table2cell(sort_struct(iterZ).jumpers);                
                
                jump_pcts = cellfun(@(x,y) (x./y), jump_data,video_data);
                if selection == 1.0                     %group by  azimuth (each bar is an LV)
                    jump_pcts = reshape(jump_pcts,1,[]);    
                    line_cut = height(sort_struct(iterZ).jumpers);
                    line_count = (width(sort_struct(iterZ).jumpers));
                    plot_labels = sort_struct(iterZ).jumpers.Properties.VariableNames;
                    x_labels = repmat(sort_struct(iterZ).jumpers.Properties.RowNames,width(sort_struct(iterZ).jumpers),1);
                    plot_name = 'Take_off_pct_geno_azi';
                elseif selection == 1.1                 %group by Lv (each bar is azimuth)
                    jump_pcts = reshape(jump_pcts',1,[]);
                    line_cut = width(sort_struct(iterZ).jumpers);
                    line_count = (height(sort_struct(iterZ).jumpers));
                    plot_labels = sort_struct(iterZ).jumpers.Properties.RowNames;
                    x_labels = repmat(sort_struct(iterZ).jumpers.Properties.VariableNames,1,height(sort_struct(iterZ).jumpers));
                    plot_name = 'Take_off_pct_geno_lv';
                end
                hb = bar(jump_pcts);
                if line_count > 1                                
                    for iterL = 1:line_count
                        line([(line_cut*iterL)+.5 (line_cut*iterL)+.5],[0 1],'linewidth',1,'color',rgb('black'));
                        x_cord = (line_cut+1)/2+(line_cut*(iterL-1));       y_cord = .95;
                        text(x_cord,y_cord,sprintf('%s',plot_labels{iterL}),'Interpreter','none','fontsize',10,'HorizontalAlignment','center');
                    end
                end
                title(sprintf('%s',sort_struct(iterZ).genotype{1}),'Interpreter','none','fontsize',12,'HorizontalAlignment','center');
                
                set(gca,'Xlim',[0.5 length(x_labels)+.5]);                
                add_text_labels(x_labels,0,'center');
            end 
        elseif selection == 2.0 ||  selection == 2.1             %split take off by lv
            lv_used = sort_struct(1).videos.Properties.RowNames;
            total_plots = length(lv_used);
            geno_count = length(sort_struct);
            [x_plot,y_plot] = split_fig(total_plots);
            for iterZ = 1:total_plots
                subplot(x_plot,y_plot,iterZ)
                video_data = cell2mat(arrayfun(@(x) cell2mat(table2cell(sort_struct(x).videos(lv_used{iterZ},:))),1:1:geno_count,'UniformOutput',false)');
                jump_data = cell2mat(arrayfun(@(x) cell2mat(table2cell(sort_struct(x).jumpers(lv_used{iterZ},:))),1:1:geno_count,'UniformOutput',false)');
                jump_pcts = arrayfun(@(x,y) (x./y), jump_data,video_data);
                if selection == 2.0                     %group by  azimuth (each bar is an LV)
                    video_data = reshape(video_data,1,[]);    
                    jump_data = reshape(jump_data,1,[]);    
                    jump_pcts = reshape(jump_pcts,1,[]);    
                    line_cut = geno_count;
                    line_count = (width(sort_struct(iterZ).jumpers));
                    plot_labels = sort_struct(iterZ).jumpers.Properties.VariableNames;
                    x_labels = repmat(vertcat(sort_struct.genotype),width(sort_struct(iterZ).jumpers),1);
                    plot_name = 'Take_off_pct_lv_azi';
                                        
                elseif selection == 2.1                     %group by  azimuth (each bar is an LV)
                    video_data = reshape(video_data',1,[]);    
                    jump_data = reshape(jump_data',1,[]);                        
                    jump_pcts = reshape(jump_pcts',1,[]);
                    line_cut = (width(sort_struct(iterZ).jumpers));
                    line_count = geno_count;
                    plot_labels = vertcat(sort_struct.genotype);
                    x_labels = repmat(sort_struct(iterZ).jumpers.Properties.VariableNames,1,geno_count);
                    plot_name = 'Take_off_pct_lv_geno';
                end
                hb = bar(jump_pcts);
                if line_count > 1
                    for iterL = 1:line_count
                        line([(line_cut*iterL)+.5 (line_cut*iterL)+.5],[0 1],'linewidth',1,'color',rgb('black'));
                        x_cord = (line_cut+1)/2+(line_cut*(iterL-1));       y_cord = .95;
                        text(x_cord,y_cord,sprintf('%s',plot_labels{iterL}),'Interpreter','none','fontsize',10,'HorizontalAlignment','center');
                    end              
                end
                if selection == 2
                    control_logic = get_control_logic(x_labels);
                    patch_ctrl_lines(hb,x_labels,rgb('gray'),control_logic);
                    patch_ctrl_lines(hb,x_labels,rgb('light blue'),~control_logic);
                    post_hoc(jump_data, video_data,length(plot_labels),.9,'take_off_pct',2);
                end
                
                title(sprintf('%s',lv_used{iterZ}),'Interpreter','none','fontsize',12,'HorizontalAlignment','center');
                set(gca,'Xlim',[0.5 length(x_labels)+.5],'Ylim',[0 1]);                
                add_text_labels(x_labels,45,'right');
            end
        end
%         if  get(save_on,'checked')
%             make_save_plot(plot_name)
%         end
        if cellfun(@(x) contains(x,'Intensity'),lv_used) && selection == 2.0
            filter_logic = cellfun(@(x) contains(x,'DNp04'),x_labels) | cellfun(@(x) contains(x,'DNp02'),x_labels) | cellfun(@(x) contains(x,'DNp06'),x_labels);
            filter_jumpers = jump_data(filter_logic);
            filter_totals = video_data(filter_logic);
            filter_labels = x_labels(filter_logic);
            
            filter_labels = cellfun(@(x) x(1:(strfind(x,'(')-1)),filter_labels,'UniformOutput',false);
            [filter_labels,~,ic] = unique(filter_labels,'stable');
            
            rolled_up_jumpers = zeros(max(ic),1);       rolled_up_totals = zeros(max(ic),1);
            p_value = zeros(max(ic),1);                 chi2stat = zeros(max(ic),1);
            for iterZ = 1:max(ic)
                rolled_up_jumpers(iterZ) = sum(filter_jumpers(ic == iterZ));
                rolled_up_totals(iterZ) = sum(filter_totals(ic == iterZ));
            end
            figure
            jump_pcts = rolled_up_jumpers ./ rolled_up_totals;
            hb = bar(jump_pcts);
            set(gca,'Xlim',[0.5 length(filter_labels)+.5],'Ylim',[0 1]);                
            add_text_labels(filter_labels,45,'right');
            post_hoc(rolled_up_jumpers, rolled_up_totals,1,.9,'take_off_pct',2);
            
            expected_values = jump_pcts(2) * rolled_up_totals;
            for iterZ = 1:max(ic)
                chi2stat(iterZ) = sum((rolled_up_jumpers(iterZ)-expected_values(iterZ)).^2 ./ expected_values(iterZ));
                p_value(iterZ) = 1 - chi2cdf(chi2stat(iterZ),1);
            end
            plot_name = 'multi_to_p4_compare';
            make_save_plot(plot_name)
            curr_date = datevec(now());
        
            date_string = sprintf('%04.0f%02.0f%02.0f',curr_date(1),curr_date(2),curr_date(3));
            filename = [save_path filesep curr_user{1} filesep 'lc4dn_cschr' filesep 'chi_sq_test_dn04_' date_string '.mat'];
        
            if ~exist([save_path filesep curr_user{1} filesep 'lc4dn_cschr'],'dir')
                mkdir([save_path filesep curr_user{1} filesep 'lc4dn_cschr'])
            end   
        
            save(filename,'chi2stat','p_value');  
        end
    end
    function pathway_histogram(hObj,~)
        selection = get(hObj,'UserData');
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = correct_exp_info(exp_info);     
        
        new_labels = vertcat(struct_result_combine.genotype);
        [sort_order,~,new_labels] = make_sort_order(new_labels);
        sort_struct = struct_result_combine(:,sort_order);
        control_logic = get_control_logic(new_labels);        
        
        uni_labels = vertcat(sort_struct.genotype);
        %use this to remove chrimson lines
        %remove_logic = cellfun(@(x) contains(x,'A7') | contains(x,'ESC') | contains(x,'DL') | contains(x,'SS01062') ,uni_labels);
        
        %use this to remove looming/kir lines
        remove_logic = cellfun(@(x) contains(x,'A7') | contains(x,'L1, L2') | contains(x,'P7') ,uni_labels);        
        control_logic(remove_logic) = [];
        sort_struct(:,remove_logic) = [];
        uni_labels(remove_logic) = [];
        
        table_groups = fieldnames(sort_struct);
        %group_clusters = [{'Intensity'};{'lv_sweep_azi_090'};{'lv040_azi_000'};{'lv040_azi_090'};{'lv040_azi_180'}];
        group_clusters = [{'Intensity'};{'lv010_azi_090'};{'lv020_azi_090'};{'lv040_azi_090'};{'lv080_azi_090'}];
        
        table_results = cell(length(uni_labels),length(group_clusters));
        
        for iterZ = 1:length(uni_labels)
            for iterT = 1:length(group_clusters)
                label_match = table_groups(cellfun(@(x) contains(x,group_clusters{iterT}),table_groups));
                if ~isempty(label_match)
                    test_struct = arrayfun(@(x) sort_struct(iterZ).(label_match{x}),1:1:length(label_match),'UniformOutput',false)';
                    table_results(iterZ,iterT) = {vertcat(test_struct{:})};
                end
            end
        end
        no_data = sum(cellfun(@(x,y) ~isempty(x), table_results)) == 0;
        group_clusters(no_data) = [];            table_results(:,no_data)= [];
        
        filt_results = [];
        for iterZ = 1:size(table_results,2)
            table_height = cellfun(@(x) height(x),table_results(:,iterZ));
            random_count = ones(length(table_height),1)*25;
            random_count(table_height < 25) = table_height(table_height<25);
            random_order = arrayfun(@(x,y) randperm(x, y), table_height,random_count,'UniformOutput',false);
            filt_results = [filt_results,cellfun(@(x,y) x(y,:), table_results(:,iterZ),random_order,'UniformOutput',false)]; %#ok<AGROW>
        end

        %code to combine all stimuli
       % table_results = arrayfun(@(x)vertcat(table_results{x,:}),1:1:length(table_results),'UniformOutput',false)';     
        filt_results = arrayfun(@(x)vertcat(filt_results{x,:}),1:1:length(filt_results),'UniformOutput',false)';     
        
        %height_offset = .3;            %use for chimson data
        height_offset = .15;            %use for looming data
        new_x_data = [0 .5 1 3 5 7 10 20 35 50 100 250 500 1000];        
        
        plot_number = size(filt_results,2);
        for iterP = 1:plot_number
            height_index = 0;
        
            low_counts = cellfun(@(x) height(x) < 20,filt_results(:,iterP));
            filt_table_results = filt_results(~low_counts,iterP);
            filt_uni_labels = uni_labels(~low_counts);

            if length(filt_uni_labels) < 1
                continue
            end
            all_data = []; 
            short_data = [];
        
            figure
            rem_labels = [];

            for iterZ = 1:length(filt_uni_labels)
                good_data = filt_table_results{iterZ};
                good_data(cellfun(@(x) isempty(x),good_data.frame_of_take_off),:) = [];
                good_data(cellfun(@(x) isnan(x),good_data.frame_of_take_off),:) = [];
                if isempty(good_data)
                    rem_labels = [rem_labels;filt_uni_labels(iterZ)]; %#ok<AGROW>
                    continue
                end
                if selection == 1
                   full_diff = cellfun(@(x,y) log((x-y)/6),good_data.frame_of_take_off,good_data.frame_of_wing_movement);
                   offset = 7;      x_start = 0;
                   plot_name = [group_clusters{iterP} '_Full_Pathway_stacked_hist'];
                elseif selection == 2
                    full_diff = cellfun(@(x,y) log((x-y)/6),good_data.wing_down_stroke,good_data.frame_of_wing_movement);
                    offset = 9;     x_start = -2;
                    plot_name = [group_clusters{iterP} '_Wing_Cycle_stacked_hist'];
                end
                x_data = x_start:0.10:7;
                [f,x] = hist(full_diff,x_data);
                all_data = [all_data,{full_diff}]; %#ok<AGROW>
                short_data = [short_data,{full_diff(full_diff < log(7))}]; %#ok<AGROW>
                f = (f ./ sum(f));

                hb = bar(x,f,'hist');
                set(gca,'nextplot','add');

                old_x_data = get(hb,'Xdata');
                old_y_data = get(hb,'Ydata');
                old_y_data = old_y_data + ((height_index)*height_offset);
                height_index = height_index + 1;

                delete(hb);
    %            patch(old_x_data + (iterZ-1)*(offset+1),old_y_data,rgb('light blue'));              
                patch(old_x_data,old_y_data,rgb('light blue'));              
            end
            y_max = height_offset*height_index;        
            set(gca,'Ytick',[0,height_offset],'Ylim',[0 y_max]);

            y_height = height_offset/2:height_offset:(height_offset*height_index);
            set(gca,'Xlim',[x_start offset-1]);        

            if ~isempty(rem_labels)
                filt_uni_labels(ismember(filt_uni_labels,rem_labels)) = [];
            end
            p_compare = add_post_hoc_test(all_data);
            samp_size = cellfun(@(x) size(x,1),all_data);
            short_size = cellfun(@(x) size(x,1),short_data);
            add_hist_labels(filt_uni_labels,y_height,p_compare,selection,samp_size)

            if selection == 1
                line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',gca);
            elseif selection == 2
                line([log(3.5) log(3.5)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',gca);
            end
            set(gca,'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12);
            if  get(save_on,'checked')
                make_save_plot(plot_name)
            end
            
            short_pct = short_size ./ samp_size;
            figure

            hb = bar(1:1:length(short_size),short_pct,'barwidth',.8);
            post_hoc(short_size, samp_size,1,1.0,'short_pct',2);
            add_text_labels(filt_uni_labels,45,'right');
            
            if  get(save_on,'checked')
                plot_name = 'Percent_short_escape';
                make_save_plot(plot_name)
            end            
        end
    end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% formating functions for bar plots
    function add_text_labels(x_data,rotation,align)
        set(gca,'Xtick',[]);
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(x_data),1);                          new_x_pos = 1:1:length(x_data);
%        y = y - .025;
        hText = text(new_x_pos, y, x_data,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',10);
    end
    function patch_ctrl_lines(plot_handle,new_labels,patch_color,ctrl_logic) 
        matching_data = new_labels(ctrl_logic);
        for iterZ = 1:sum(ctrl_logic)
            patch_bars(plot_handle,matching_data(iterZ),new_labels,patch_color);
        end        
    end
    function patch_bars(hb,test_label,new_labels,bar_color)
        bar_x_data = get(hb,'Xdata');   bar_y_data = get(hb,'Ydata');
        new_labels(cellfun(@(x) isempty(x),new_labels)) = [];
                
        dl_pos = cellfun(@(x) contains(x,test_label),new_labels);
        dl_pos = find(dl_pos>0);
        for iterZ = 1:length(dl_pos)
            if dl_pos(iterZ) > 0
                patch([(bar_x_data(dl_pos(iterZ))-.4) (bar_x_data(dl_pos(iterZ))-.4) (bar_x_data(dl_pos(iterZ))+.4) (bar_x_data(dl_pos(iterZ))+.4)],...
                      [0 bar_y_data(dl_pos(iterZ)) bar_y_data(dl_pos(iterZ)) 0],bar_color,'parent',gca);
            end
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function wsi = get_error_bars(jumpers,total)                        %finds error bars
        x = jumpers;
        n = total;
        alpha = .05;
        phat =  x./n;
        z=sqrt(2).*erfcinv(alpha);
        den=1+(z^2./n);xc=(phat+(z^2)./(2*n))./den;
        halfwidth=(z*sqrt((phat.*(1-phat)./n)+(z^2./(4*(n.^2)))))./den;
        wsi=[xc(:) xc(:)]+[-halfwidth(:) halfwidth(:)];
%        wsi = wsi .* 100;
    end
    function add_error_bars(curr_plot,jumpers, total)                   %draws error bars on the graph
        wsi = get_error_bars(jumpers,total);
                
        for iterZ = 1:length(jumpers)
            line([iterZ iterZ],[wsi(iterZ,1) wsi(iterZ,2)],'parent',curr_plot,'linewidth',.7,'color',rgb('black'));
        end        
    end
    function result_matrix = find_p_values(jumpers,total_counts,file_type)        %calcualtes p values for take off pct compare
        result_matrix = zeros(length(jumpers));
        z_score = zeros(length(jumpers));
        
        if iscell(jumpers)
            jumpers = cell2mat(jumpers);
        end
        if iscell(total_counts)
            total_counts = cell2mat(total_counts);
        end        
        
        for iterZ = 1:length(jumpers)
            for iterL = 1:length(jumpers)
                pulled_p = (jumpers(iterZ) + jumpers(iterL)) / (total_counts(iterZ) + total_counts(iterL));
                bot_val = sqrt(pulled_p * (1-pulled_p) * ((1/total_counts(iterZ))+(1/total_counts(iterL))));
                top_val = abs(jumpers(iterZ)/total_counts(iterZ) - jumpers(iterL) / total_counts(iterL));
                z_score(iterZ,iterL) = top_val ./ bot_val;
                result_matrix(iterZ,iterL) =  2*(1-normcdf(z_score(iterZ,iterL)));
            end
        end
        group_cat =[];
        
        if isempty(group_name); group_cat = collect_name; end
        if isempty(collect_name); group_cat = group_name; end
        
        if ~exist([save_path filesep curr_user{1} filesep group_cat],'dir')
            mkdir([save_path filesep curr_user{1} filesep group_cat])
        end        

        curr_date = datevec(now());
        date_string = sprintf('%04.0f%02.0f%02.0f',curr_date(1),curr_date(2),curr_date(3));
       
        filename = [save_path filesep curr_user{1} filesep group_cat filesep file_type '_' date_string '.mat'];
        save(filename,'z_score','result_matrix');
    end
    function post_hoc(jump_counts,total_counts,split_count,compare_height,file_type,index)                         %adds astericks for sig tests
        add_error_bars(gca,jump_counts,total_counts);
        set(gca,'Ylim',[0 1.1]);
        

        compare_count = length(jump_counts) / split_count;
        for iterZ = 1:split_count
            comp_index = (1:1:compare_count) + compare_count*(iterZ-1);
            result_matrix = find_p_values(num2cell(jump_counts(comp_index)),num2cell(total_counts(comp_index)),file_type);
            dl_compare = result_matrix(index,:);        %compare to SS01062
            
            num_samp = length(dl_compare) - 1;      %bonferroni correction
            for iterD  = 1:length(dl_compare)
                if dl_compare(iterD) < (0.001/num_samp)
                    text(iterD+compare_count*(iterZ-1),compare_height,'***','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                elseif dl_compare(iterD) < (0.01/num_samp)
                    text(iterD+compare_count*(iterZ-1),compare_height,'**','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                elseif dl_compare(iterD) < (0.05/num_samp)
                    text(iterD+compare_count*(iterZ-1),compare_height,'*','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                end
                text(iterD,1.05,num2str(total_counts(iterD)),'HorizontalAlignment','center');
            end
            
        end
%        set(gca,'Ylim',[0 1.1]);
    end
    function p_compare = add_post_hoc_test(all_data)                    %man whitney test for pathway compare
        p_compare = zeros(length(all_data));
        test_stat = zeros(length(all_data));
        for iterZ = 1:length(all_data)
            for iterQ = 1:length(all_data)
               [p_compare(iterZ,iterQ),~,stats_vect] = ranksum(all_data{iterZ},all_data{iterQ});
               test_stat(iterZ,iterQ) = stats_vect.ranksum;
            end
        end
        group_cat =[];
        
        if isempty(group_name); group_cat = collect_name; end
        if isempty(collect_name); group_cat = group_name; end

        curr_date = datevec(now());
        date_string = sprintf('%04.0f%02.0f%02.0f',curr_date(1),curr_date(2),curr_date(3));
       
        filename = [save_path filesep curr_user{1} filesep group_cat filesep 'man_whitney_pathawy_' date_string '.mat'];
        
        if ~exist([save_path filesep curr_user{1} filesep group_cat],'dir')
            mkdir([save_path filesep curr_user{1} filesep group_cat])
        end   
        
        save(filename,'test_stat','p_compare');        
    end
    function add_hist_labels(uni_labels,y_height,p_compare,toggle,samp_size)
        sig_test = cell(length(p_compare(:,1)),1);
        sig_test(p_compare(:,1) < 0.05) = {'*'};
        sig_test(p_compare(:,1) < 0.001) = {'**'};
        sig_test(p_compare(:,1) < 0.0005) = {'***'};
        
        new_text_str = cellfun(@(x,y,z) sprintf('%s(%4.0f)\n%s',x,y,z),uni_labels,num2cell(samp_size'),sig_test,'UniformOutput',false);
        if toggle == 1
            hText = text(ones(length(uni_labels),1)*-.20, y_height', new_text_str,'parent',gca);
        else
             hText = text(ones(length(uni_labels),1)*-2.25, y_height', new_text_str,'parent',gca);
        end
        set(hText,'Rotation',0,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',15);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function chrim_compare_plot(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = correct_exp_info(exp_info);
        
        new_labels = vertcat(struct_result.genotype);
        [sort_order,~,new_labels] = make_sort_order(new_labels);
        sort_struct = struct_result(:,sort_order);
        sort_struct(:,cellfun(@(x) contains(x,'DL Wildtype') | contains(x,'SS01062') | contains(x,'47B'),new_labels)) = [];
        new_labels(cellfun(@(x) contains(x,'DL Wildtype') | contains(x,'SS01062') | contains(x,'47B') ,new_labels)) = [];
        
        all_data = vertcat(sort_struct.Intensity_50_50ms_azi_000);
        jump_counts = arrayfun(@(x) height(sort_struct(x).Intensity_50_50ms_azi_000),1:1:length(new_labels),'UniformOutput',false);
        geno_list = cellfun(@(x,y) repmat({x},y,1),new_labels,jump_counts','UniformOutput',false);
        geno_list = vertcat(geno_list{:});
        
        missing_data = cellfun(@(x) isempty(x), all_data.frame_of_leg_push);
        all_data(missing_data,:) = [];      geno_list(missing_data) = [];
        
        non_jump_data = cellfun(@(x) isnan(x), all_data.frame_of_leg_push);
        all_data(non_jump_data,:) = [];      geno_list(non_jump_data) = [];        
        
        figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        light_on_wing_lift = (cell2mat(all_data.frame_of_wing_movement) - cell2mat(all_data.Start_Frame))/6;
        light_on_wing_lift = log10(light_on_wing_lift./25)./log10(2);
        subplot(2,1,1)
        [y_data,x_data,~] = iosr.statistics.tab2box(geno_list,light_on_wing_lift);
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'),...
               'showViolin', true,'violinColor',rgb('very light blue'),'violinAlpha',0.5);
        line([.5 length(new_labels)+.5],[1 1],'color',rgb('black'),'linewidth',1,'parent',gca)
        y_tick_lab = [6.25,12.5,25,50,100,200,400];
        y_tick_marks = log10([6.25,12.5,25,50,100,200,400]./25)./log10(2);
%        set(gca,'Xlim',[0.5 length(new_labels)+.5],'Ylim',[0 300],'Ytick',[0,25,50,100:50:300],'Ygrid','on');           
        title('Lights on to Start of Wing lift');
        set(gca,'Xlim',[0.5 length(new_labels)+.5],'XTickLabel',new_labels,'Ytick',y_tick_marks,'YTickLabel',y_tick_lab,'Ygrid','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        subplot(2,1,2)
        wing_cycle = (cell2mat(all_data.wing_down_stroke) - cell2mat(all_data.frame_of_wing_movement))/6;
        wing_cycle = log10(wing_cycle)./log10(2);
        [y_data,x_data,~] = iosr.statistics.tab2box(geno_list,wing_cycle);
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'),...
               'showViolin', true,'violinColor',rgb('very light blue'),'violinAlpha',0.5);
        y_tick_lab = [0.5,1,3,5,10,25,50,100,250,500,750,1000];
        y_tick_marks = log10(y_tick_lab)./log10(2);
        line([.5 length(new_labels)+.5],[log10(3.5)/log10(2) log10(3.5)/log10(2)],'color',rgb('black'),'linewidth',1,'parent',gca)
        title('Duration from Wing lift to Wing Downstroke');
        set(gca,'Xlim',[0.5 length(new_labels)+.5],'XTickLabel',new_labels,'Ytick',y_tick_marks,'YTickLabel',y_tick_lab,'Ygrid','on');    
    end
    function pathway_histogram_split(~,~)
        new_labels = vertcat(struct_result_combine.genotype);
        [sort_order,~,new_labels] = make_sort_order(new_labels);
        sort_struct = struct_result_combine(:,sort_order);
        control_logic = get_control_logic(new_labels); 
        
        table_groups = fieldnames(sort_struct);
        group_clusters = [{'Intensity'};{'lv010_azi_090'};{'lv020_azi_090'};{'lv040_azi_090'};{'lv080_azi_090'}];
        
        uni_labels = vertcat(sort_struct.genotype);
        table_results = cell(length(uni_labels),length(group_clusters));        
        for iterZ = 1:length(uni_labels)
            for iterT = 1:length(group_clusters)
                label_match = table_groups(cellfun(@(x) contains(x,group_clusters{iterT}),table_groups));
                if ~isempty(label_match)
                    test_struct = arrayfun(@(x) sort_struct(iterZ).(label_match{x}),1:1:length(label_match),'UniformOutput',false)';
                    table_results(iterZ,iterT) = {vertcat(test_struct{:})};
                end
            end
        end
        loom_logic = cellfun(@(x) contains(x,'lv'),group_clusters)';      
        looming_table = arrayfun(@(x) vertcat(table_results{x,loom_logic}),1:1:6,'UniformOutput',false)';
        table_results(:,2) = looming_table;             table_results(:,3:end) = [];

        split_factors = length(uni_labels);
        figure
        x_start = 0;        offset = 7;
        x_data = x_start:0.10:7;        
        for iterZ = 1:split_factors
            plot_handles((2*iterZ)-1) = subplot(split_factors,2,((2*iterZ)-1));
            plot_handles((2*iterZ)) = subplot(split_factors,2,((2*iterZ)));
            switch iterZ
                case 1  %DL
                    full_diff = log((cell2mat(table_results{iterZ,2}.frame_of_take_off) - cell2mat(table_results{iterZ,2}.frame_of_wing_movement)) ./ 6);
                    [f,x] = hist(full_diff,x_data);
                    f = f ./ max(f);
                    bar(plot_handles((2*iterZ)-1),x,f,'hist')           %dL X Kir
                    bar(plot_handles((2*iterZ)),x,f,'hist')
                    title(sprintf('%s X Kir2.1',uni_labels{iterZ}),'Interpreter','none','parent',plot_handles((2*iterZ)-1))
                    title(sprintf('%s X Kir2.1',uni_labels{iterZ}),'Interpreter','none','parent',plot_handles((2*iterZ)))
                case 2  %GF
                    full_diff = log((cell2mat(table_results{iterZ,2}.frame_of_take_off) - cell2mat(table_results{iterZ,2}.frame_of_wing_movement)) ./ 6);
                    [f,x] = hist(full_diff,x_data);
                    f = f ./ max(f);
                    bar(plot_handles((2*iterZ)),x,f,'hist')         %gf X Kir
                    ctrl_group_kir = full_diff;
                    
                    full_diff = log((cell2mat(table_results{iterZ,1}.frame_of_take_off) - cell2mat(table_results{iterZ,1}.frame_of_wing_movement)) ./ 6);
                    [f,x] = hist(full_diff,x_data);
                    f = f ./ max(f);
                    bar(plot_handles((2*iterZ)-1),x,f,'hist')       %gf X Chrim
                    ctrl_group_chrim = full_diff;
                    
                    title(sprintf('%s X Chrimson',uni_labels{iterZ}),'Interpreter','none','parent',plot_handles((2*iterZ)-1))
                    title(sprintf('%s X Kir2.1',uni_labels{iterZ}),'Interpreter','none','parent',plot_handles((2*iterZ)))
                    
                otherwise
                    full_diff = log((cell2mat(table_results{iterZ,1}.frame_of_take_off) - cell2mat(table_results{iterZ,1}.frame_of_wing_movement)) ./ 6);
                    [f,x] = hist(full_diff,x_data);
                    f = f ./ max(f);
                    bar(plot_handles((2*iterZ)-1),x,f,'hist')       %dn X Chrim                    
                    bar(plot_handles((2*iterZ)),x,f,'hist')         %dn X Chrim                    
                    
                    [p_kir, ~, stats_kir] = ranksum(full_diff,ctrl_group_kir);
                    [p_chrim, ~, stats_chrim] = ranksum( full_diff,ctrl_group_chrim);
                    title(sprintf('%s\n Z-score :: %4.4f  P-value :: %4.4f',uni_labels{iterZ},stats_chrim.zval,p_chrim),'Interpreter','none','parent',plot_handles((2*iterZ)-1))
                    title(sprintf('%s\n Z-score :: %4.4f  P-value :: %4.4f',uni_labels{iterZ},stats_kir.zval,p_kir),'Interpreter','none','parent',plot_handles((2*iterZ)))
            end
            set(plot_handles((2*iterZ)-1),'Xlim',[x_start offset-1],'Ylim',[0 1.1]);
            set(plot_handles((2*iterZ)),'Xlim',[x_start offset-1],'Ylim',[0 1.1]);
            y_max = 1.1;
            line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',plot_handles((2*iterZ)-1));
            line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',plot_handles((2*iterZ)));
        end
    end
    function pathway_short_pct(~,~)
        new_labels = vertcat(struct_result_combine.genotype);
        [sort_order,~,new_labels] = make_sort_order(new_labels);
        sort_struct = struct_result_combine(:,sort_order);
        control_logic = get_control_logic(new_labels); 
        
        table_groups = fieldnames(sort_struct);
        group_clusters = [{'Intensity'};{'lv010_azi_090'};{'lv020_azi_090'};{'lv040_azi_090'};{'lv080_azi_090'}];
        
        uni_labels = vertcat(sort_struct.genotype);
        
        table_results = cell(length(uni_labels),length(group_clusters));        
        for iterZ = 1:length(uni_labels)
            for iterT = 1:length(group_clusters)
                label_match = table_groups(cellfun(@(x) contains(x,group_clusters{iterT}),table_groups));
                if ~isempty(label_match)
                    test_struct = arrayfun(@(x) sort_struct(iterZ).(label_match{x}),1:1:length(label_match),'UniformOutput',false)';
                    table_results(iterZ,iterT) = {vertcat(test_struct{:})};
                end
            end
        end
        uni_labels(1) = [];
        table_results(1,:) = [];
        
        loom_logic = cellfun(@(x) contains(x,'lv'),group_clusters)';      
        looming_table = arrayfun(@(x) vertcat(table_results{x,loom_logic}),1:1:length( uni_labels),'UniformOutput',false)';
        table_results(:,2) = looming_table;             table_results(:,3:end) = [];
        
        short_chrim_count = cellfun(@(x) sum(((cell2mat(x.frame_of_take_off) - cell2mat(x.frame_of_wing_movement)) ./ 6) <= 7),table_results(:,1));
        total_chrim_count = cellfun(@(x) height(x),table_results(:,1));
        
        short_kir_count = cellfun(@(x) sum(((cell2mat(x.frame_of_take_off) - cell2mat(x.frame_of_wing_movement)) ./ 6) <= 7),table_results(:,2));
        total_kir_count = cellfun(@(x) height(x),table_results(:,2));
        
        short_kir_count(total_kir_count == 0) = short_chrim_count(total_kir_count == 0);
        total_kir_count(total_kir_count == 0) = total_chrim_count(total_kir_count == 0);
        
        figure
        subplot(2,1,1)
        jump_pcts = short_chrim_count ./ total_chrim_count;
        hb = bar(jump_pcts);
        set(gca,'Xlim',[0.5 length(uni_labels)+.5],'Ylim',[0 1]);                
        add_text_labels(uni_labels,45,'right');
        post_hoc(short_chrim_count, total_chrim_count,1,.9,'take_off_pct',1);
        title('Chrimson activaction')
        
        subplot(2,1,2)
        jump_pcts = short_kir_count ./ total_kir_count;
        hb = bar(jump_pcts);
        set(gca,'Xlim',[0.5 length(uni_labels)+.5],'Ylim',[0 1]);                
        add_text_labels(uni_labels,45,'right');
        post_hoc(short_kir_count, total_kir_count,1,.9,'take_off_pct',1);        
        title('Kir Silencing')

        make_save_plot('percent_short_full_pathway');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function timing_scatter_plot(hObj,~)
        selection = get(hObj,'UserData');
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = correct_exp_info(exp_info);     
        
        new_labels = vertcat(struct_result.genotype);
        [sort_order,~,~] = make_sort_order(new_labels);
        sort_struct = struct_result(:,sort_order);
        sort_struct = sort_struct(3:end);
        
        uni_labels = vertcat(sort_struct.genotype);
        table_groups = fieldnames(sort_struct);
        table_group_names = table_groups(4:end);
        [x_plot,y_plot] = split_fig(length(table_group_names));
        figure
        for iterZ = 1:length(table_group_names)
            subplot(x_plot,y_plot,iterZ)
            samp_data = vertcat(sort_struct.(table_group_names{iterZ}));
            samp_data(cellfun(@(x) isempty(x), samp_data.frame_of_leg_push),:) = [];
            samp_data(cellfun(@(x) isnan(x), samp_data.frame_of_leg_push),:) = [];
            wing_timing = cellfun(@(x,y) (x-y)/6, samp_data.frame_of_wing_movement,samp_data.Start_Frame);
            geno_id = cellfun(@(x) x(33:40), samp_data.Properties.RowNames,'UniformOutput',false);
            
            new_labels = convert_labels(geno_id,'DN_convert',exp_info,'exp_str_8');
            wing_timing = log10(wing_timing ./ 50) / log10(2);

            [y_data,x_data,~] = iosr.statistics.tab2box(new_labels,wing_timing);
            h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
               'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));            
            
        end
    end
    function center_of_mass_move(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = correct_exp_info(exp_info);     
        
        new_labels = vertcat(struct_result.genotype);
        [sort_order,~,~] = make_sort_order(new_labels);
        sort_struct = struct_result(:,sort_order);
        sort_struct = sort_struct(3:end);     
        all_distance = [];
        all_geno = [];
        
        figure;
        for iterZ = 1:4
            subplot(2,2,iterZ)
            current_video = sort_struct(iterZ).Intensity_50_50ms_azi_000;
            current_video(cellfun(@(x) isempty(x), current_video.frame_of_leg_push),:) = [];

            start_frame = cell2mat(current_video.Start_Frame);
            last_frame = cell2mat(current_video.frame_of_leg_push);
            last_frame(arrayfun(@(x) isnan(x) ,last_frame)) = cell2mat(current_video(arrayfun(@(x) isnan(x) ,last_frame),:).Start_Frame) + (50*6);
            
            no_track_logic = current_video.trkEnd < last_frame;
            start_frame(no_track_logic) = []; 
            last_frame(no_track_logic) = []; 
            current_video(no_track_logic,:) = []; 

            pathway = cellfun(@(x,y) (x-y)/6, current_video.frame_of_leg_push,current_video.frame_of_wing_movement);
            tracking_points_all = cellfun(@(x,y,z) z(x:y,:),num2cell(start_frame),num2cell(last_frame),current_video.bot_points_and_thetas,'UniformOutput',false);
            distance_traveled = cellfun(@(x) sqrt((x(2:end,1) - x(1:(end-1),1)).^2 + (x(2:end,2) - x(1:(end-1),2)).^2),tracking_points_all,'UniformOutput',false);
            new_distance = cellfun(@(x) remove_low_dist(x) ,distance_traveled,'uniformoutput',false);
            new_distance = cellfun(@(x) sum(x) ,new_distance);
            
%            all_distance = [all_distance;distance_traveled];
            curr_geno = repmat(sort_struct(iterZ).genotype,length(last_frame),1);
%            all_geno = [all_geno;curr_geno];

            color_group = cell(length(last_frame),1);
            color_group(pathway > 3.5,:) = repmat({'long path'},sum(pathway > 3.5),1);
            color_group(pathway <= 3.5,:) = repmat({'short path'},sum(pathway <= 3.5),1);
            color_group(isnan(pathway),:) = repmat({'no jump'},sum(isnan(pathway)),1);

            duration = ((last_frame - start_frame)/6);
            obj = gmdistribution.fit((log10(duration)/log10(2)),2);
            new_x = 0:.01:10;
            new_y = pdf(obj,new_x');

            set(gca,'nextplot','add')
            [f,x] = hist(log10(duration)/log10(2),2:.25:10);
            f = f ./ max(f);
            new_y = new_y ./ max(new_y);
            
            [ax1,h1,h2] = plotyy(x,f,new_x,new_y,'bar','line');
            set(h1,'barwidth',1,'facecolor',rgb('light blue'));
            set(h2,'linewidth',1.5,'color',rgb('red'));
            set(ax1,'Xlim',[2 10]);
            light_off = log10(50)/log10(2);
            line([light_off light_off],[0 1],'color',rgb('black'),'linewidth',.8);
            
            
%             [y_data,x_data,~] = iosr.statistics.tab2box(color_group,new_distance ./ duration);
%             h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
%                'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'),...
%                'showViolin', true,'violinColor',rgb('very light blue'),'violinAlpha',0.5);

            title(sprintf('%s',sort_struct(iterZ).genotype{1}),'HorizontalAlignment','center','Interpreter','none');
        end
    end
    function x = remove_low_dist(x)
        %x(x < .05) = 0;
    end
    function save_plot_toggle(hObj,~)
        if hObj == save_on  && get(hObj,'checked')
            set(save_off,'checked','off')
        end
        if hObj == save_off  && get(hObj,'checked')
            set(save_on,'checked','off')
        end
    end
    function make_save_plot(plot_name)
        save_path = ['\\DM11' filesep 'cardlab' filesep 'Matlab_Save_Plots'];
        
        old_pos = get(gcf,'position');
        set(gcf,'Position',[ 1          41        2560        1484]);       %full screen for saving
        if ~exist([save_path filesep curr_user{1}],'dir')
            mkdir([save_path filesep curr_user{1}])
        end
        group_cat =[];
        
        if isempty(group_name); group_cat = collect_name; end
        if isempty(collect_name); group_cat = group_name; end
        
        if ~exist([save_path filesep curr_user{1} filesep group_cat],'dir')
            mkdir([save_path filesep curr_user{1} filesep group_cat])
        end        
        
        curr_date = datevec(now());
        date_string = sprintf('%04.0f%02.0f%02.0f',curr_date(1),curr_date(2),curr_date(3));
        
        filename = [save_path filesep curr_user{1} filesep group_cat filesep plot_name '_' date_string '.pdf'];
        export_fig(filename ,'-pdf');
        set(gcf,'Position',old_pos);        %restore to org pos
    end
    function close_graph(~,~)
        try
            delete(poolobj);
        catch
        end
        delete(hFigC)
    end
end

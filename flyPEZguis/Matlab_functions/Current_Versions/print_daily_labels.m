function print_daily_labels()
    
    sort_type = 'JIDE';

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
file_dir = fullfile(fileDir,'Pez3000_Gui_folder','Gui_saved_variables');
file_path = fullfile(fileDir,'Data_pez3000_analyzed');
  
    
    exptSumName = 'experimentSummary.mat';
    exptSumPath = fullfile(file_path,exptSumName);
    experimentSummary = load(exptSumPath);
    experimentSummary = experimentSummary.experimentSummary;  
         
    saved_collections = load([file_dir filesep 'Saved_Collection.mat']);
    saved_collections = saved_collections.Saved_Collection;
    
    saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);
    saved_groups = saved_groups.Saved_Group_IDs;    
      
    saved_exps = load_variables(file_dir, 'Saved_Experiments.mat'); 
    exp_dir = get(saved_exps,'ObsNames');
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 0,exp_dir));
        
    saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:); 
    
    saved_users   = unique([saved_collections.User_ID;saved_groups.User_ID]);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets labels and background
    screen2use = 1;         % in multi screen setup, this determines which screen to be used
    screen2cvr = 0.8;       % portion of the screen to cover
    
    monPos = get(0,'MonitorPositions');
    if size(monPos,1) == 1,screen2use = 1; end
    scrnPos = monPos(screen2use,:);    
    backColor = [0 0 0.2];    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    add_list = [];             collection_list = [];                         filtered_data = [];
    num_list = [{'Total|Videos'},{'Passed|Curation'},{'Tracking|Complete'},{'Status'}];             
    var_size = length(num_list);        org_list = [];                   filter = [];
    
    col_width = num2cell([175,repmat(90,1,var_size),100,400,100,400,400,100,400,300,150,300,300,300]);
    columnformat = cell(1,17);                                 columnformat(1:var_size) = {'numeric'};      
    columnformat(var_size+1) = {{'Active' 'Archived'}};        columnformat((var_size+2):end) = {'char'};
    col_edit = [false(1,(var_size)),true,false(1,12)];    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% figure axis
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
        (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
    hFigC = figure('NumberTitle','off','Name','Experiment ID Manager',...
           'menubar','none','units','pix','Color',backColor,'pos',FigPos,'colormap',gray(256));
    hPanA = uipanel('Position',[0 0 1 1],'Visible','On','BackgroundColor',rgb('light grey'),'parent',hFigC);
    
    all_data_table   = uitable(hPanA,'units','normalized','position',[.015 .375 .970 .330]);
    printing_table   = uitable(hPanA,'units','normalized','position',[.015 .025 .970 .330]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user, collection and date info
    spacing = (.950-(.01*2))/3;
    uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025 .9600 spacing .025],'String','Select User','fontunits','normalized','fontsize',0.5000);
    hUserdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025 .9300 spacing .025],'String',[' ';unique(saved_users)],...
        'horizontalalignment','center','fontunits','normalized','fontsize',0.5000,'enable','on','callback',@populatecollect);           
    
    uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+1*(spacing+.01) .9600 spacing .025],'String','Select Collection','fontunits','normalized','fontsize',0.5000);
    hCollectdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025+1*(spacing+.01) .9300 spacing .025],'String',' ','fontunits','normalized','fontsize',0.5000,'enable','on','callback',@get_collection_info);       
    
    uicontrol(hPanA,'Style','text','Units','normalized','position',[0.025+2*(spacing+.01) .9600 spacing .025],'String','Select Group','fontunits','normalized','fontsize',0.5000);
    hGroupdrop  = uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.025+2*(spacing+.01) .9300 spacing .025],'String',' ','fontunits','normalized','fontsize',0.5000,'enable','on','callback',@get_group_info);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
    string_val = [{'Set Status Toggle'}, {'Archive Collection'}, {'Delete Group'}, {'Save Group'}];
    str_entries = length(string_val);
    header_spacing = (.95-(.01*(str_entries-1)))/(str_entries);

    uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+(1-1)*(header_spacing+.01) .8900 header_spacing .025],'String',string_val{1},'fontunits','normalized','fontsize',0.4250);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[.025+(2-1)*(header_spacing+.01) .8900 header_spacing .025],'String',string_val{2},'fontunits','normalized','fontsize',0.4250,'callback',@arch_collect);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[.025+(3-1)*(header_spacing+.01) .8900 header_spacing .025],'String',string_val{3},'fontunits','normalized','fontsize',0.4250,'callback',@delete_group);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[.025+(4-1)*(header_spacing+.01) .8900 header_spacing .025],'String',string_val{4},'fontunits','normalized','fontsize',0.4250,'callback',@save_group);

    status_drop = uicontrol(hPanA,'Style','popup','Units','normalized','position',[.025+(1-1)*(header_spacing+.01) .8600 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400,'callback',@flip_toggle);
    arch_collect_drop = uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+(2-1)*(header_spacing+.01) .8600 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400);
    delete_group_drop = uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+(3-1)*(header_spacing+.01) .8600 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400);
    save_group_drop = uicontrol(hPanA,'Style','edit','Units','normalized','position',[.025+(4-1)*(header_spacing+.01) .8600 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
    string_val = [{'Experiment ID'}, {'  Date  '}, {'Variable 1'}, {'Variable 2'},{'Varaible 3'}];
    str_entries = length(string_val);
    header_spacing = (.95-(.01*(str_entries-1)))/(str_entries);
    h_index = 0;
       
    for iterA = 1:2:(2*str_entries)
        h_index = h_index + 1;        
        uicontrol(hPanA,'Style','text','Units','normalized','position',[.025+(h_index-1)*(header_spacing+.01) .8150 header_spacing .025],'String',string_val{h_index},'fontunits','normalized','fontsize',0.4250);
    end
    curr_date = datevec(now());
    curr_date = sprintf('%04s%02s%02s',num2str(curr_date(1)),num2str(curr_date(2)),num2str(curr_date(3)));
    
    exp_drop = uicontrol(hPanA,'Style','popup','Units','normalized','position',[.025+(1-1)*(header_spacing+.01) .7840 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400);
    date_str = uicontrol(hPanA,'Style','edit','Units','normalized','position',[.025+(2-1)*(header_spacing+.01) .7850 header_spacing .025],'String',curr_date,'fontunits','normalized','fontsize',0.5000);
    var1_opt = uicontrol(hPanA,'Style','popup','Units','normalized','position',[.025+(3-1)*(header_spacing+.01) .7840 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400,'callback',@reorder_columns);
    var2_opt = uicontrol(hPanA,'Style','popup','Units','normalized','position',[.025+(4-1)*(header_spacing+.01) .7840 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400,'callback',@reorder_columns);
    var3_opt = uicontrol(hPanA,'Style','popup','Units','normalized','position',[.025+(5-1)*(header_spacing+.01) .7840 header_spacing .025],'String','...','fontunits','normalized','fontsize',0.5400,'callback',@reorder_columns);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
    spacing = (.95-(.01*3))/4;
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[0.025+0*(spacing+.01) .7400 spacing .025],'String','Add Lines To Group','fontunits','normalized','fontsize',0.5000,'fontweight','bold','callback',@add_lines);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[0.025+1*(spacing+.01) .7400 spacing .025],'String','Remove Lines From Group','fontunits','normalized','fontsize',0.5000,'fontweight','bold','callback',@remove_lines);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[0.025+2*(spacing+.01) .7400 spacing .025],'String','Print Group','fontunits','normalized','fontsize',0.5000,'fontweight','bold','callback',@print_lines);
    uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[0.025+3*(spacing+.01) .7400 spacing .025],'String','Save Experiment IDs','fontunits','normalized','fontsize',0.5000,'fontweight','bold','callback',@save_exp_ids);
    draw_border_lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
    function populatecollect(hObj,~)                        % select User
        index = get(hObj,'value');
        list = get(hUserdrop,'string');
        collect_list = saved_collections(strcmp(saved_collections.User_ID,list(index)),:).Collection_Name;
        collect_ids = get(saved_collections(strcmp(saved_collections.User_ID,list(index)),:),'ObsNames');
        new_collect_list = cellfun(@(x,y) [x,'  ::  ',y],collect_ids,collect_list,'UniformOutput',false);
        set(hCollectdrop,'string',[' ';new_collect_list],'value',1);

        test_data = saved_groups(strcmp(list{index},saved_groups.User_ID),:);
        if ~isempty(test_data)
            set(hGroupdrop,'string',[' ';unique(test_data.Properties.RowNames,'stable')],'value',1);
        else
            set(hGroupdrop,'string',' ','value',1);
        end
    end
    function get_collection_info(hObj,~)
        index = get(hObj,'value');              list = get(hCollectdrop,'string');
        collect_index = cellfun(@(x) x(1:4),list(index),'uniformoutput',false);
        exp_names = exp_dir(cellfun(@(x) strcmp(x(1:4),collect_index{1}),exp_dir));
        set(arch_collect_drop,'String',list{index});
        set(delete_group_drop,'String','');
        set(save_group_drop,'String','');
        set(hGroupdrop,'value',1)
        
        exp_names(cellfun(@(x) contains(x,'0108') & contains(x,'0739') ,exp_names)) = [];
        for iterZ = 1:length(exp_names)
            proto_id = cellfun(@(x) x(13:16),exp_names(iterZ),'uniformoutput',false);

            if str2double(proto_id) > 100
                result = parse_expid_v2(exp_names{iterZ});
            else
                [~,result] = parse_expid(exp_names{iterZ});
            end            
            
            if strcmp(result,'error')
                continue
            end
            if ~iscell(result.Record_Rate)
                result.Record_Rate = {result.Record_Rate};
            end
            outputdata = result;
            if iterZ == 1
                all_data = outputdata;
            else
                all_data = [all_data;outputdata];
            end
        end
        if isempty(outputdata)
            return
        end
        setup_table(all_data)
    end
    function get_group_info(hObj,~)
        index = get(hObj,'value');              list = get(hGroupdrop,'string');       
        exp_names = vertcat(saved_groups(list{index},:).Experiment_IDs{:});
        exp_names = cellfun(@(x) strtrim(x),exp_names,'uniformoutput',false);
%        exp_names = exp_names(ismember(exp_names,exp_dir),:);
        
        set(delete_group_drop,'String',list{index})
        set(save_group_drop,'String',list{index});
        set(arch_collect_drop,'String','');
        set(hCollectdrop,'value',1)
        
        for iterZ = 1:length(exp_names)
            [~,temp_list] = parse_expid(exp_names{iterZ});
            if strcmp(temp_list,'error')
                temp_list = parse_expid_v2(exp_names{iterZ});
            end            
            if iterZ == 1
                add_list = temp_list;
            else
                add_list = [add_list;temp_list]; %#ok<*AGROW>
            end
        end
        if isempty(add_list)
            return
        end
        setup_table(add_list)
        add_group_to_print
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    function setup_table(sample_summary)       % populates the table and sets row/column names
        populate_table_data(sample_summary)
        set(all_data_table,'Data',filtered_data,'FontSize',10);
       
        new_rows = num2cell((1:1:length(filtered_data(:,1)))');
        row_list = cellfun(@(x) ['<html><font size=+0>' ,num2str(x),'</html>'],new_rows,'uniformoutput',false);
        set(all_data_table,'RowName',[]);
        
        col_list_last = cellfun(@(x) ['<html><font size=+1>' ,x,'</html>'],collection_list((var_size+1):end),'uniformoutput',false);
        col_list_first = cellfun(@(x) ['<html><font size=+1>' ,x,'</html>'],collection_list(1),'uniformoutput',false);
        string_sep = num2cell(cellfun(@(x) strfind(x,'|'),collection_list(2:(var_size))));
        part1 = cellfun(@(x,y) ['<html><font size=+1>' ,x(1:(y-1)),'</html>'],collection_list(2:(var_size)),string_sep,'uniformoutput',false);
        part2 = cellfun(@(x,y) ['<html><font size=+1>' ,x((y+1):end),'</html>'],collection_list(2:(var_size)),string_sep,'uniformoutput',false);
        col_list_number = cellfun(@(x,y) [x,'|',y],part1,part2,'uniformoutput',false);
        col_list = [col_list_first, col_list_number, col_list_last];

        set(all_data_table,'RowName',row_list,'ColumnName',col_list,'ColumnFormat',columnformat,'ColumnEditable',col_edit);
        set(printing_table,'RowName',[],'ColumnName',col_list,'ColumnFormat',columnformat,'ColumnEditable',col_edit);
               
        add_table_sorting(all_data_table);
        add_table_sorting(printing_table);
        set(all_data_table,'columnwidth',col_width);
        set(printing_table,'columnwidth',col_width);
%        resize_rowname(all_data_table);
        add_counts(all_data_table)
        set(status_drop,'String',[{'....'},{'Set All Lines To Active'},{'Archive All Lines'}]);
    end
    function populate_table_data(sample_data)            % creates the data for the table
        chrim_str = cell(length(sample_data),1);
        try
            stim_list = sample_data.Stimuli_Type;
            loom_logic = ~strcmp(stim_list,'None');
            to_index = cellfun(@(x) strfind(x,'to'),stim_list(loom_logic));
            lv_index = cellfun(@(x) strfind(x,'lv'),stim_list(loom_logic));
            score_index = cellfun(@(x) max(strfind(x,'_')),stim_list(loom_logic));
            start_angle = cellfun(@(x,y) x(6:(y-1)),stim_list(loom_logic),num2cell(to_index),'uniformoutput',false);
            ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),stim_list(loom_logic),num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
            loverv = cellfun(@(x,y,z) x((y+2):(z-1)),stim_list(loom_logic),num2cell(lv_index),num2cell(score_index),'uniformoutput',false);
            tail_str = cellfun(@(x,y) x((y+1):end),stim_list(loom_logic),num2cell(score_index),'uniformoutput',false);

%            start_angle(cellfun(@(x) ~isempty(strfind(x,'whiteonwhite')),tail_str)) = cellstr(repmat('0',sum(cellfun(@(x) ~isempty(strfind(x,'whiteonwhite')),tail_str)),1));
%            ending_angle(cellfun(@(x) ~isempty(strfind(x,'whiteonwhite')),tail_str)) = cellstr(repmat('0',sum(cellfun(@(x) ~isempty(strfind(x,'whiteonwhite')),tail_str)),1));

            stim_list(loom_logic) = cellfun(@(x,y,z,a) sprintf('loom_%03sto%03s_lv%03s_%s',x,y,z,a), start_angle,ending_angle,loverv,tail_str,'uniformoutput',false);        
        catch
            warning('mistake');
        end
        chrm_count = cellfun(@(x) sum(~strcmp(x,'None')) , sample_data.Photo_Activation);
        cell_logic = cellfun(@(x) iscell(x) , sample_data.Photo_Activation);
        chrim_str(~cell_logic) = sample_data.Photo_Activation(~cell_logic);
        
        chrm_opts = cellfun(@(x) x(~strcmp(x,'None')) , sample_data.Photo_Activation,'uniformoutput',false);
        cell_logic = cellfun(@(x) length(x)==1,chrm_opts);        
        try
            chrim_str(cell_logic) = vertcat(chrm_opts{cell_logic});
        catch
            chrim_str(cell_logic) = chrm_opts(cell_logic);
        end
        
        chrim_str(chrm_count == 0) = {'No Chrimson Trace'};
        chrim_str(chrm_count >= 2) = {'Multiple Chrimson Traces'};
        
        sample_data = dataset2struct(sample_data);
        collection_list = fieldnames(sample_data)';
        stimuli_dataset = struct2dataset(vertcat(sample_data.Stimuli_Vars));
        try
            azi_ele_str = cellfun(@(v,w,x) sprintf('%03s_%03s_%s',num2str(v),num2str(w),num2str(x)),stimuli_dataset.Azimuth,stimuli_dataset.Elevation,num2cell(stimuli_dataset.Azimuth_Opts),'uniformoutput',false);      
        catch
            azi_ele_str = cellfun(@(v,w,x) sprintf('%03s_%03s_%s',v,w,num2str(x)),cellstr(stimuli_dataset.Azimuth),cellstr(stimuli_dataset.Elevation),num2cell(stimuli_dataset.Azimuth_Opts),'uniformoutput',false);
        end
        stimuli_str = cellfun(@(x,y) [x '--' y],stim_list,azi_ele_str,'uniformoutput',false);        
        
        filter_options
        incubator_info = dataset2cell(struct2dataset(vertcat(sample_data.Incubator_Info)));
        exp_ids = vertcat({sample_data.ObsNames})';
        sample_data = rmfield(sample_data,'ObsNames');
        filtered_data = struct2dataset(sample_data);

        try
            new_food_var = cellfun(@(x,y) sprintf('%s -- Foilded :: %s',x,y),filtered_data.Food_Type,filtered_data.Foiled,'uniformoutput',false);
        catch
             new_food_var = sprintf('%s -- Foilded :: %s',filtered_data.Food_Type,filtered_data.Foiled);
        
            %new_food_var = arrayfun(@(x,y) sprintf('%s -- Foilded :: %s',x,y),filtered_data.Food_Type,filtered_data.Foiled,'uniformoutput',false);
        end
        filtered_data = filtered_data(:,ismember( fieldnames(sample_data),collection_list));        
        
        num_data = cell(length(filtered_data(:,1)),var_size);
        incu_1 = cellfun(@(x,y) [x,' :: ',y],incubator_info(2:end,1),incubator_info(2:end,5),'uniformoutput',false);        

        filtered_data = dataset2cell(filtered_data);        
        filtered_data = [filtered_data(2:end,1:7),incu_1,incubator_info(2:end,2),new_food_var];
        filtered_data = [exp_ids,num_data,filtered_data,stimuli_str,chrim_str];
        populate_drop_downs
    end
    function add_group_to_print(~,~)
        new_data = get(all_data_table,'data');
        old_data = get(printing_table,'data');
        new_data = [old_data;new_data];
        [~,IA,~] = unique(new_data(:,1));
        new_data = new_data(IA,:);        
        row_list = 1:1:length(new_data(:,1));
        
        set(printing_table,'data',new_data,'RowName',row_list,'FontSize',10);
        resize_rowname(printing_table);                       
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    function add_table_sorting(new_table)                   % adds java sorting to the table
        jscrollpane = findjobj(new_table);
        jtable = jscrollpane.getViewport.getView;   

        if ~strcmp(sort_type,'JIDE')           
            path_list = javaclasspath;
            if strcmp(path_list,[file_dir filesep 'tablefilter-swing-5.1.1.jar'])
                filter = net.coderazzi.filters.gui.TableFilterHeader(jtable);
                filter.setAutoChoices(net.coderazzi.filters.gui.AutoChoices.ENABLED);
            else
                javaaddpath([file_dir filesep 'tablefilter-swing-5.1.1.jar'])
                filter = net.coderazzi.filters.gui.TableFilterHeader(jtable);
                filter.setAutoChoices(net.coderazzi.filters.gui.AutoChoices.ENABLED);
            end        
        end
        % Now turn the JIDE sorting on
        if strcmp(sort_type,'JIDE')           
           jtable.setSortable(true);
        else
            jtable.setSortable(false);
        end
        jtable.setEditingColumn(true);
        jtable.setAutoResort(true);
        jtable.setMultiColumnSortable(true);
        jtable.setPreserveSelectionsAfterSorting(true);
        jtable.setNonContiguousCellSelection(false);
        jtable.setColumnSelectionAllowed(false);
        jtable.setRowSelectionAllowed(true);
    end
    function resize_rowname(new_table)                      % java command to resize row length
        if isempty(new_table)
            return
        end
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    function filter_options(~,~)                            % filters display options on for table                
        collection_list = collection_list(cellfun(@(x) ~contains(x,'ObsNames'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'male') && ~contains(x,'Male'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Chromosome'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'No_Balancers'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Stimuli'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Photo'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'table_data'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'annotations'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'auto_res'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'tracked'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Collection'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Compression'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Download'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Time'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Trigger'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Notes'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Temp'),collection_list));
        collection_list = collection_list(cellfun(@(x) ~contains(x,'Record'),collection_list));
        collection_list = ['Experiment ID',num_list,collection_list(1:7),'Incubator Name','Location','Food Type','Looming Stimuli (Azi_Ele_Opts)','Chrimson_Opts'];
        org_list = collection_list;
    end
    function add_counts(samp_table)                         % adds the counts to the table
        old_data = get(samp_table,'Data'); 
        [~,locb] = ismember(old_data(:,1),experimentSummary.Properties.RowNames);
        
        old_data(locb>0,2) = cellstr(num2str((experimentSummary(locb(locb>0),:).Total_Videos)));
        old_data(locb==0,2) = cellstr(num2str((0)));        
        old_data(locb>0,3) = cellstr(num2str((experimentSummary(locb(locb>0),:).Total_Passing)));
        old_data(locb==0,3) = cellstr(num2str((0)));
        old_data(locb>0,4) = cellstr(num2str((experimentSummary(locb(locb>0),:).Analysis_Complete)));
        old_data(locb==0,4) = cellstr(num2str((0)));
        old_data(locb>0,5) = experimentSummary(locb(locb>0),:).Status;
        old_data(locb==0,5) = repmat({'Active'},sum(locb==0),1);
        
        
        old_data(:,(1:var_size)) = cellfun(@(x,y) ['       ' ,num2str(x)],old_data(:,(1:var_size)),'uniformoutput',false);
        new_rows = num2cell((1:1:length(old_data(:,1)))');
        set(samp_table,'Data',old_data,'RowName',new_rows);
    end
    function draw_border_lines(~,~)
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .990 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);        
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .9225 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);        
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[.015 .8500 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);       
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                            'Position',[0.015 .7710 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);                
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.015 .7260 .970 .005],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);                                    
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.015 .7260 .005 .269],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);            
        axes('box','off','Xtick',[],'Ytick',[],'xticklabel',[],'yticklabel',[],'Color',rgb('black'),'Clipping','off','Units','normalized',...
                                'Position',[0.980 .7260 .005 .269],'Xlim',[0 1],'Ylim',[0 1],'visible','on','parent',hPanA);             
    end   
    function populate_drop_downs(~,~)
        set(exp_drop,'String',[{'Hidden'},{'Show As Number'},{'Show As Barcode'}],'value',3)
        set(var1_opt,'String',collection_list(2:end),'value',2)
        set(var2_opt,'String',collection_list(2:end),'value',3)
        set(var3_opt,'String',collection_list(2:end),'value',4)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function reorder_columns(~,~)
        collection_list = org_list;
        var1_opt_str = get(var1_opt,'string');          var1_opt_indx = get(var1_opt,'value');           var1_option = var1_opt_str{var1_opt_indx};
        var2_opt_str = get(var2_opt,'string');          var2_opt_indx = get(var2_opt,'value');           var2_option = var2_opt_str{var2_opt_indx};
        var3_opt_str = get(var3_opt,'string');          var3_opt_indx = get(var3_opt,'value');           var3_option = var3_opt_str{var3_opt_indx};        
        
        loca = ismember(collection_list,[{var1_option},{var2_option},{var3_option}]);
        no_match = collection_list(~loca);
        collection_list = [collection_list(1),{var1_option},{var2_option},{var3_option},no_match((2:end))];
                
        logic_index = cellfun(@(x) contains(x,'|'),collection_list);
        
        col_list_last = cellfun(@(x) ['<html><font size=+1>' ,x,'</html>'],collection_list(~logic_index),'uniformoutput',false);

        string_sep = num2cell(cellfun(@(x) strfind(x,'|'),collection_list(logic_index)));
        part1 = cellfun(@(x,y) ['<html><font size=+1>' ,x(1:(y-1)),'</html>'],collection_list(logic_index),string_sep,'uniformoutput',false);
        part2 = cellfun(@(x,y) ['<html><font size=+1>' ,x((y+1):end),'</html>'],collection_list(logic_index),string_sep,'uniformoutput',false);
        col_list_number = cellfun(@(x,y) [x,'|',y],part1,part2,'uniformoutput',false);
        
        new_header = cell(1,length(logic_index));
        new_header(logic_index) = col_list_number;
        new_header(~logic_index) = col_list_last;

        old_header = get(all_data_table,'columnName');
        [~,locb] =ismember(new_header',old_header);
        
        col_width = col_width(locb);                    columnformat = columnformat(locb);                  col_edit = col_edit(locb);
        old_data = get(all_data_table,'data');         
        set(all_data_table,'data',old_data(:,locb),'ColumnName',new_header','columnwidth',col_width,'ColumnFormat',columnformat,'ColumnEditable',col_edit);
        
        old_header = get(printing_table,'columnName');
        [~,locb] =ismember(new_header',old_header);
        
        old_data = get(printing_table,'data');       
        if ~isempty(old_data)
            set(printing_table,'data',old_data(:,locb),'ColumnName',new_header','columnwidth',col_width,'ColumnFormat',columnformat,'ColumnEditable',col_edit);        
        else
            set(printing_table,'ColumnName',new_header','columnwidth',col_width,'ColumnFormat',columnformat,'ColumnEditable',col_edit);        
        end
    end
    function save_group(~,~)
        save_str = get(save_group_drop,'String');
        if isempty(save_str)
            return
        end
        all_data = get(printing_table,'data');
        Saved_Group_IDs = saved_groups;
        logic_match = ismember(Saved_Group_IDs.Properties.RowNames,save_str);         %#ok<*NASGU>                 
        if sum(logic_match) == 0
            col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
            entry = cell(1,3);                       index = get(hUserdrop,'value');               list = get(hUserdrop,'string');
            entry(1,1) = list(index);                entry(1,2) = {all_data(:,1)};                 entry(1,3) = {'Active'};
            entries = cell2table(entry);             entries.Properties.RowNames = {save_str};     entries.Properties.VariableNames = col_list;            
            Saved_Group_IDs = [Saved_Group_IDs;entries];
            save([file_dir filesep 'Saved_Group_IDs_table.mat'],'Saved_Group_IDs');
        else
            Saved_Group_IDs(logic_match,:).Experiment_IDs =  {all_data(:,1)};
            save([file_dir filesep 'Saved_Group_IDs_table.mat'],'Saved_Group_IDs');
        end
    end
    function delete_group(~,~)
        delete_str = get(delete_group_drop,'String');
        if isempty(delete_str)
            return
        end
        Saved_Group_IDs = saved_groups;
        Saved_Group_IDs(ismember(Saved_Group_IDs.Properties.RowNames,delete_str),:) = [];         %#ok<*NASGU>        
        save([file_dir filesep 'Saved_Group_IDs_table.mat'],'Saved_Group_IDs');
    end
    function arch_collect(~,~)
        curr_collect = get(arch_collect_drop,'String');
        exp_names = exp_dir(cellfun(@(x) strcmp(x(1:4),curr_collect(1:4)),exp_dir));

        [~,locb] = ismember(exp_names,experimentSummary.Properties.RowNames);
        experimentSummary(locb,:).Status = cellstr(repmat('Archive',length(locb),1));
%        save(exptSumPath,'experimentSummary');       
    end
    function save_exp_ids(~,~)
        all_data = get(all_data_table,'data');
        all_data(str2double(all_data(:,2)) == 0,:) = [];
        [~,locb] = ismember(strtrim(all_data(:,1)),experimentSummary.Properties.RowNames);
        experimentSummary(locb,:).Status = all_data(:,5);
        save(exptSumPath,'experimentSummary');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function add_lines(~,~)        
%         old_lines = get(all_data_table,'Data');
%         old_lines = strtrim(old_lines(:,1));
%         request_lines = {'0047000015210343','0047000015220346','0047000017070346','0047000017100346','0047000017110343','0047000017120346','0047000017130343','0047000017140346',...
%                          '0047000017760343','0047000017770346','0047000017900343','0047000017910346','0047000017940343','0047000017950346','0047000017960343','0047000017970346',...
%                          '0047000018160343','0047000018170346','0047000018250343','0047000018270343','0047000018360343','0047000018380343','0047000018430343','0047000018460343',...
%                          '0047000018480346','0047000018500346','0047000018590346','0047000018610346','0047000018660346','0047000018690346','0047000019130343','0047000019160343',...
%                          '0047000019230343','0047000019350346','0047000019380346','0047000019450346','0047000019670343','0047000019690343','0047000019720343','0047000019740343',...
%                          '0047000019780343','0047000019810343','0047000019890346','0047000019910346','0047000019940346','0047000019960346','0047000020000346','0047000020030346',...
%                          '0047000020060346','0047000020090343'};

        
%        [~,locb] = ismember(old_lines,request_lines);        
        jscrollpane = findjobj(all_data_table);
        jtable = jscrollpane.getViewport.getView;           
        row_list = get(jtable,'SelectedRows');  
        org_order = get(jtable.getModel,'Indexes');
        
        if ~isempty(org_order)
            row_list = org_order(row_list+1) + 1;
        else
            row_list = row_list + 1;
        end
                
        row_list = unique([row_list;str2double(cellstr(get(printing_table,'RowName')))]);
        row_list = row_list(row_list > 0);
        
        old_data = get(all_data_table,'data');
        set(printing_table,'data',old_data(row_list,:),'RowName',row_list,'FontSize',10);
        resize_rowname(printing_table);
    end
    function remove_lines(~,~)
        [jscrollpane,~,~,~] = findjobj(printing_table);
        jtable = jscrollpane.getViewport.getView;   
        row_list = get(jtable,'SelectedRows') + 1;    
        org_order = get(jtable.getModel,'Indexes');
        if ~isempty(org_order)
            row_list = org_order(row_list+1) + 1;   
        end
       
        old_data = get(printing_table,'data');
        old_data(row_list,:) = [];
        new_row_list = str2double(cellstr(get(printing_table,'RowName')));
        new_row_list(row_list) = [];
        set(printing_table,'data',old_data,'RowName',new_row_list);
        resize_rowname(printing_table);        
    end
    function print_lines(~,~)
        print_data = get(printing_table,'data');
        if isempty(print_data)
            return
        end
        
        exp_opt_str = get(exp_drop,'string');           exp_opt_indx = get(exp_drop,'value');            exp_option = exp_opt_str{exp_opt_indx};
        var1_opt_str = get(var1_opt,'string');          var1_opt_indx = get(var1_opt,'value');           var1_option = var1_opt_str{var1_opt_indx};
        var2_opt_str = get(var2_opt,'string');          var2_opt_indx = get(var2_opt,'value');           var2_option = var2_opt_str{var2_opt_indx};
        var3_opt_str = get(var3_opt,'string');          var3_opt_indx = get(var3_opt,'value');           var3_option = var3_opt_str{var3_opt_indx};
        
        var1_data = print_data(:,ismember(collection_list,var1_option));
        var2_data = print_data(:,ismember(collection_list,var2_option));
        var3_data = print_data(:,ismember(collection_list,var3_option));        
        
        %^XA start the string and ^XZ ends the string
        %^FO is field orgion
        %^FD is field data
        %^TB is text  box
        %^B are various barcode styles and formats
        
        datvec = get(date_str,'string');

        print_list = [var1_data,var2_data,var3_data];
        part_list = [{var1_option},{var2_option},{var3_option}];
        print_str = cellstr(repmat(['^XA^CF0,15^SLS,1^FO25,20^TBN,330,85^FD ',datvec],length(print_list(:,1)),1));        
        part_list = repmat(part_list,length(print_list(:,1)),1);
        
         for iterZ = 1:3
 %             if value_list{iterZ} == 1
                  print_str = cellfun(@(a,x,y)[a,[' ---  ',x,'::  ',y,]],print_str,part_list(:,iterZ),print_list(:,iterZ),'uniformoutput',false);      
 %             end
         end
%        print_str = cellfun(@(a,z)[a,'^FS^FO125,82^TBN,330,13^FD',z],print_str, print_data(:,1),'uniformoutput',false);
        if strcmp(exp_option,'Hidden')
            print_str = cellfun(@(a)[a,'^XZ'],print_str,'uniformoutput',false);            
        elseif strcmp(exp_option,'Show As Number')
            print_str = cellfun(@(a,z)[a,'^FS^FO125,82^TBN,330,13^FD',z,'^XZ'],print_str, strtrim(print_data(:,1)),'uniformoutput',false);
        elseif strcmp(exp_option,'Show As Barcode')
            print_str = cellfun(@(a,z)[a,'^FS^FO125,82^TBN,330,13^FD',z],print_str, strtrim(print_data(:,1)),'uniformoutput',false);
            print_str = cellfun(@(a,z)[a,'^FS^FO25,100^B2N,10,N,N,N^BY2,.66,15^FD',z,'^XZ'],print_str, strtrim(print_data(:,1)),'uniformoutput',false);
        end
        
        port = 9100;
%        ip = '10.103.40.85';
%       ip = '129.236.161.087';
%% MAKE SURE TO CHANGE IP ADDRESS HERE IF PRINTER IS MOVED
ip = '129.236.162.027';
port = 9100;
        %JTCPOBJ = JTCP('REQUEST',ip,PORT);
        jobj = jtcp('request',ip,port,'serialize',false);
        msgCount = numel(print_str);
        for iterPrint = 1:msgCount
            jtcp('write',jobj,int8(print_str{iterPrint}))
        end
        jtcp('close',jobj)        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function flip_toggle(hObj,~)
        index = get(hObj,'Value');
        old_data = get(all_data_table,'data');
        if index == 2
            old_data(:,5) = cellstr(repmat('Active',length(old_data(:,5)),1));
        elseif index == 3
            old_data(:,5) = cellstr(repmat('Archive',length(old_data(:,5)),1));
        end
        set(all_data_table,'data',old_data);
    end
end
function saved_variable = load_variables(file_dir, file_path)
    load([file_dir filesep file_path]);
    try
        saved_variable = Saved_Experiments;
    catch
        saved_variable = saved_experiments;
    end
end
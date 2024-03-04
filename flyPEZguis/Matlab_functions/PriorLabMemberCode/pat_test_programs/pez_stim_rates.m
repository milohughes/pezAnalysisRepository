function pez_stim_rates
    set_up_iosr
%% run thought all runs to create a trigger summary file
    summary_table = get_summary_table;
%%  update summary file to show curation data
    [updated_summary_table,stimuli_start_index] = get_curation_info(summary_table);
    [locA,~] = ismember(updated_summary_table.Properties.RowNames,stimuli_start_index(:,2));
    updated_summary_table = updated_summary_table(locA,:);
    
    
    [locA,locB] = ismember(stimuli_start_index(:,2),updated_summary_table.Properties.RowNames);
    matching_stim_list = updated_summary_table.Stimuli_Shown(locB(locA));
    
    bad_record = cellfun(@(x) contains(x,'stripe'),matching_stim_list);
    matching_stim_list(bad_record) = [];
    stimuli_start_index(bad_record,:) = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    [y_data,x_data] = iosr.statistics.tab2box(matching_stim_list,cell2mat(stimuli_start_index(:,4)));

    [x_data,sort_idx] = sort(x_data);
    y_data = y_data(:,sort_idx,:);
    y_data = y_data ./ 6;       %convert into milli seconds

    make_boxplots(x_data,y_data);
    set(gca,'fontsize',15,'Ytick',0:100:500,'Ygrid','on')
    ylabel('Time Delay to start frame (Milliseconds)','fontsize',15)
    title(sprintf('Timing delay between start of video\n and the first frame of the stimuli'),'FontSize',25);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rolled_up_group = cell(length(stimuli_start_index(:,3)),1);
    rolled_up_group(cellfun(@(x) contains(x,'loom')  & contains(x,'Intensity'),matching_stim_list)) = repmat({'Chrim + Loom'},sum(cellfun(@(x) contains(x,'loom')  & contains(x,'Intensity'),matching_stim_list)),1);
    rolled_up_group(cellfun(@(x) ~contains(x,'loom') & contains(x,'Intensity'),matching_stim_list)) = repmat({'Chrim Pulse'},sum(cellfun(@(x) ~contains(x,'loom') & contains(x,'Intensity'),matching_stim_list)),1);
    rolled_up_group(cellfun(@(x) contains(x,'loom') & ~contains(x,'wall') & ~contains(x,'Intensity'),matching_stim_list)) = repmat({'Looming Stimuli'},sum(cellfun(@(x) contains(x,'loom') & ~contains(x,'wall') & ~contains(x,'Intensity'),matching_stim_list)),1);
    rolled_up_group(cellfun(@(x) contains(x,'loom') & contains(x,'wall') & ~contains(x,'Intensity'),matching_stim_list)) = repmat({'Loom + Wall'},sum(cellfun(@(x) contains(x,'loom') & contains(x,'wall') & ~contains(x,'Intensity'),matching_stim_list)),1);
    
    
    [y_data,x_data,group_labels] = iosr.statistics.tab2box(rolled_up_group,cell2mat(stimuli_start_index(:,4)),stimuli_start_index(:,3));

    [x_data,sort_idx] = sort(x_data);
    y_data = y_data(:,sort_idx,:);
    y_data = y_data ./ 6;       %convert into milli seconds

    figure
    iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                 'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
    set(gca,'XTickLabel',x_data)
    
    set(gca,'fontsize',15,'Ytick',0:100:500,'Ygrid','on')
    ylabel('Time Delay to start frame (Milliseconds)','fontsize',15)
    title(sprintf('Timing delay between start of video\n and the first frame of the stimuli'),'FontSize',25);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    uni_group = unique(rolled_up_group);
    for iterZ = 1:length(uni_group)
        if contains(uni_group{iterZ},'Looming Stimuli')
            subplot(2,3,[4,5,6])
        else
            subplot(2,3,iterZ)
        end
        group_logic = ismember(rolled_up_group,uni_group{iterZ});
        collection_used = cellfun(@(x) x(1:4),stimuli_start_index(group_logic,1),'UniformOutput',false);
            [y_data,x_data] = iosr.statistics.tab2box(collection_used,cell2mat(stimuli_start_index(group_logic,4)));

    [x_data,sort_idx] = sort(x_data);
    y_data = y_data(:,sort_idx,:);
    y_data = y_data ./ 6;       %convert into milli seconds

    iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                 'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
    set(gca,'XTickLabel',x_data)
    
    set(gca,'fontsize',15,'Ytick',0:100:500,'Ygrid','on','ylim',[0 500])
    ylabel('Time Delay to start frame (Milliseconds)','fontsize',15)
    title(sprintf('%s',uni_group{iterZ}),'Interpreter','none','HorizontalAlignment','center','FontSize',25);

    end


end
function make_boxplots(x_data,y_data)
    figure
    set(gca,'nextplot','add')
    pos_offset = 0;
    chrim_data = cellfun(@(x) contains(x,'Intensity') & ~contains(x,'Combo'),x_data);
    
    chim_box = iosr.statistics.boxPlot((1:1:sum(chrim_data))+pos_offset,y_data(:,chrim_data),'symbolColor','k','medianColor','k','symbolMarker','+', ...
                         'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
    set(chim_box,'boxColor',rgb('red'));
    x_tick_pos(1) = mean((1:1:sum(chrim_data))+pos_offset);   x_tick_label(1) = {'Chrimson'};
                     
    pos_offset = pos_offset + sum(chrim_data);
    loom_data = cellfun(@(x) contains(x,'loom') &  ~contains(x,'wall')  & ~contains(x,'Combo')  ,x_data);
    
    set(gca,'nextplot','add')
    loom_box = iosr.statistics.boxPlot((1:1:sum(loom_data))+pos_offset,y_data(:,loom_data),'symbolColor','k','medianColor','k','symbolMarker','+', ...
                         'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));    
    set(loom_box,'boxColor',rgb('green'));
    x_tick_pos(2) = mean((1:1:sum(loom_data))+pos_offset);   x_tick_label(2) = {'Looming'};

    pos_offset = pos_offset + sum(loom_data);
    wall_data = cellfun(@(x) contains(x,'loom') &  contains(x,'wall') & ~contains(x,'Combo') ,x_data);
    
    set(gca,'nextplot','add')
    wall_box = iosr.statistics.boxPlot((1:1:sum(wall_data))+pos_offset,y_data(:,wall_data),'symbolColor','k','medianColor','k','symbolMarker','+', ...
                         'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                     
    set(wall_box,'boxColor',rgb('blue'));                     
    x_tick_pos(3) = mean((1:1:sum(wall_data))+pos_offset);   x_tick_label(3) = {'Looming + Wall'};
    
    pos_offset = pos_offset + sum(wall_data);
    combo_data = cellfun(@(x) contains(x,'Combo') ,x_data);
    
    set(gca,'nextplot','add')
    combo_box = iosr.statistics.boxPlot((1:1:sum(combo_data))+pos_offset,y_data(:,combo_data),'symbolColor','k','medianColor','k','symbolMarker','+', ...
                         'showScatter', false,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                     
    set(combo_box,'boxColor',rgb('purple'));
    x_tick_pos(4) = mean((1:1:sum(combo_data))+pos_offset);   x_tick_label(4) = {'Looming + Chrim'};    
    
                     
    pos_offset = pos_offset + sum(combo_data);
    set(gca,'Xlim',[0 pos_offset + 1]);
    set(gca,'Xtick',x_tick_pos,'XTickLabel',x_tick_label);
end
function [updated_summary_table,stimuli_start_index] = get_curation_info(summary_table)
    curation_data = cell(100,6);
    index = 1;

    uni_id = unique(summary_table.Experiment_ID);

    stimuli_start_index = [];
    for iterZ = 1:length(uni_id)
        experiment_logic = ismember(summary_table.Experiment_ID,uni_id{iterZ});
        matching_records = summary_table(experiment_logic,:);
        
        test_data =  Experiment_ID(uni_id{iterZ});
        test_data.temp_range = [22.5,24.0];                             test_data.humidity_cut_off = 40;
        test_data.remove_low = false;                                   test_data.low_count = 5;
        test_data.azi_off = 22.5;                                       test_data.ignore_graph_table = true;

        error_loading_value = test_data.load_data;
        if error_loading_value  > 0
            continue        %error loading in data, skip this experiment
        end
        for iterM = 1:height(matching_records)
            matching_logic = ismember(cellfun(@(x) x(1:23),test_data.Complete_usuable_data.Properties.RowNames,'UniformOutput',false),matching_records(iterM,:).Properties.RowNames);
            if sum(matching_logic) == 0
                continue
            end
            filtered_test_data = Experiment_ID(uni_id{iterZ});
            filtered_test_data.temp_range = [22.5,24.0];                    filtered_test_data.humidity_cut_off = 40;
            filtered_test_data.remove_low = false;                          filtered_test_data.low_count = 5;
            filtered_test_data.azi_off = 22.5;                              filtered_test_data.ignore_graph_table = true;
                
            filtered_test_data.Complete_usuable_data = test_data.Complete_usuable_data(matching_logic,:);        %filter records into date range of interest
            filtered_test_data.make_tables;            

            if ~isempty(filtered_test_data.Complete_usuable_data)
                expermient_id = repmat(uni_id(iterZ),height(filtered_test_data.Complete_usuable_data),1);
                pez_used = cellfun(@(x) x(8:14),filtered_test_data.Complete_usuable_data.Properties.RowNames,'UniformOutput',false);
                exp_path = cellfun(@(x) x(1:23),filtered_test_data.Complete_usuable_data.Properties.RowNames,'UniformOutput',false);
                try
                    stimuli_start_index = [stimuli_start_index;[expermient_id,exp_path,pez_used,filtered_test_data.Complete_usuable_data.Start_Frame]]; %#ok<AGROW>                
                catch
                    warning('dim issue?')
                end
            end

            curation_data(index,1) = matching_records(iterM,:).Properties.RowNames;
            if isempty(filtered_test_data.Complete_usuable_data)
                curation_data(index,2) = {0};
            else
                curation_data(index,2) = {height(filtered_test_data.Complete_usuable_data)};                   %all videos passing curation
            end                
            if isempty(filtered_test_data.Multi_Blank)
                curation_data(index,3) = {0};                             %Multi/Blank videos
            else
                curation_data(index,3) = {height(filtered_test_data.Multi_Blank)};                             %Multi/Blank videos
            end
            if isempty(filtered_test_data.Pez_Issues)
                curation_data(index,4) = {0};                              %Pez Issues
            else
                curation_data(index,4) = {height(filtered_test_data.Pez_Issues)};                              %Pez Issues
            end
            if isempty(filtered_test_data.Balancer_Wings)
                curation_data(index,5) = {0};                          %Any Wing issues
            else
                curation_data(index,5) = {height(filtered_test_data.Balancer_Wings)};                          %Any Wing issues
            end
            if isempty(filtered_test_data.Failed_Location)
                curation_data(index,6) = {0};                          %Bad orgional tracking
            else
                curation_data(index,6) = {height(filtered_test_data.Failed_Location)};                         %Bad orgional tracking
            end           

            index = index + 1;
        end

    end
    curation_table = cell2table(curation_data(:,2:end));
    curation_table.Properties.RowNames = curation_data(:,1);
    curation_table.Properties.VariableNames = {'Passed_Curation','Multi_Blank_Videos','Pez_Issues','Fly_Wing_Issues','Bad_Trigger_Tracking'};
    
    updated_summary_table = [summary_table(curation_table.Properties.RowNames,:),curation_table];
end
function summary_table = get_summary_table
    data_path = 'Z:\Data_pez3000';
    table_data = struct2table(dir(data_path));
%    run_dates = table_data(cellfun(@(x) str2double(x) > 20181001,table_data.name),:).name;
    run_dates = table_data(cellfun(@(x) str2double(x) >= 20190301,table_data.name),:).name;
    index = 1;
    summary_data = cell(100,4);

    for iterR = 1:length(run_dates)
        run_table_list = struct2table(dir([data_path filesep run_dates{iterR}]));
        exp_info = run_table_list(cellfun(@(x) contains(x,'run'),run_table_list.name),:).name;
%        exp_info(cellfun(@(x) contains(x,'pez3003'),exp_info)) = [];
%        exp_info(cellfun(@(x) contains(x,'pez3004'),exp_info)) = [];
        for iterE = 1:length(exp_info)
            try
                trigger_data = load([data_path filesep run_dates{iterR} filesep exp_info{iterE} filesep 'inspectionResults' filesep exp_info{iterE} '_autoAnalysisResults.mat']);
                trigger_data =  trigger_data.autoResults;
            catch
                continue
            end

            exp_meta_info = load([data_path filesep run_dates{iterR} filesep exp_info{iterE} filesep exp_info{iterE} '_experimentIDinfo.mat']);
            exp_meta_info = exp_meta_info.exptInfo;

            try
                summary_data(index,1) = exp_info(iterE);                        %date and run of experiment (unique)
                summary_data(index,2) = get(exp_meta_info,'ObsNames');          %experiment Id
            catch
                summary_data(index,:) = [];
                continue
            end
            try
            if iscell(exp_meta_info.Photo_Activation{1})
                if strcmp(exp_meta_info.Photo_Activation{1}{1},'None')
                    exp_meta_info.Photo_Activation = {'None'};
                end
            end
                
            if ~iscell(exp_meta_info.Photo_Activation{1}) && ~contains(exp_meta_info.Stimuli_Type,'None')       %looming stimuli
                summary_data(index,3) = {exp_meta_info.Stimuli_Type};
                summary_data(index,3) = convert_proto_string(summary_data{index,3});
            elseif iscell(exp_meta_info.Photo_Activation{1}) && contains(exp_meta_info.Stimuli_Type,'None')    %photo and  no loom
                summary_data(index,3) = {exp_meta_info.Photo_Activation{1}{1}};
                summary_data(index,3) = convert_proto_string(summary_data{index,3});
            elseif iscell(exp_meta_info.Photo_Activation{1}) && ~contains(exp_meta_info.Stimuli_Type,'None')    %photo and loom
                combo_stim = cellfun(@(x,y) sprintf('Combo :: %s_%s',x,y),convert_proto_string(exp_meta_info.Stimuli_Type),convert_proto_string(exp_meta_info.Photo_Activation{1}{1}),'UniformOutput',false);
                summary_data(index,3) = combo_stim;
            elseif ~iscell(exp_meta_info.Photo_Activation{1}) && contains(exp_meta_info.Stimuli_Type,'None')    %no photo and no loom
                summary_data(index,3) = {exp_meta_info.Photo_Activation{1}{1}};
            end
            catch
                warning('bad proto')
            end
            
            summary_data(index,4) = {size(trigger_data,1)};                 %total number of triggers

            summary_data(index,6) = {sum(trigger_data.empty_count) + sum(trigger_data.multi_count)};            %total amount of multi/blank videos auto detect
            trigger_data(trigger_data.empty_count | trigger_data.multi_count,:) = [];

            summary_data(index,10) = {0};
            summary_data(index,10) = {sum(cellfun(@(x) isempty(x),trigger_data.diode_decision))};                %count of where no diode failures (chrim pulses has this empty)
            trigger_data(cellfun(@(x) isempty(x),trigger_data.diode_decision),:) = [];
            try
                summary_data(index,5) = {sum(trigger_data.single_count & cellfun(@(x) contains(x,'good photodiode'),trigger_data.diode_decision))}; %total count of single flies with good nidaq trace
                summary_data(index,5) = {cell2mat(summary_data(index,5)) + cell2mat(summary_data(index,10))};
                summary_data(index,10) = {0};
            catch
                warning('empty choice?')
            end
            summary_data(index,7) = {sum(cellfun(@(x) contains(x,'visual stimulus incomplete'),trigger_data.diode_decision))};
            summary_data(index,8) = {sum(cellfun(@(x) contains(x,'frames were dropped'),trigger_data.diode_decision))};        
            summary_data(index,9) = {sum(cellfun(@(x) contains(x,'signal to noise ratio insufficient'),trigger_data.diode_decision))};

            if summary_data{index,4} == (summary_data{index,5} + summary_data{index,6} + summary_data{index,7} + summary_data{index,8} + summary_data{index,9} + summary_data{index,10})
            else
                warning('missing')
            end
            index = index + 1;
        end
    end
    summary_table = cell2table(summary_data(:,2:(end-1)));
    summary_table.Properties.RowNames = summary_data(:,1);
    summary_table.Properties.VariableNames = {'Experiment_ID','Stimuli_Shown','Total_Triggers','Downloaded_Videos','Mutli_Blank_Triggers','Stimuli_Incomplete','Dropped_Frames','Noise_Error'};
end
function new_protocol_labels = convert_proto_string(proto_string)    %converts proto string into readable text
    if ~iscell(proto_string)
        proto_string = {proto_string};
    end
    if cellfun(@(x) contains(x,'intensity'),proto_string)
        photo_str = proto_string;
        intensity_index = cellfun(@(x) strfind(x,'intensity'),photo_str);
        duration_start = cellfun(@(x) strfind(x,'Begin'),photo_str);
        duration_end = cellfun(@(x) strfind(x,'_widthEnd'),photo_str);
        intensity_used = cellfun(@(x,y) str2double(x(y+9:end)),photo_str,num2cell(intensity_index));
        duration_used = cellfun(@(x,y,z) str2double(x(y+5:z-1)),photo_str,num2cell(duration_start),num2cell(duration_end));
        chrim_labels = cellfun(@(x,y) sprintf('Intensity_%03.0fPct_%03.0fms',x,y),num2cell(intensity_used),num2cell(duration_used),'uniformoutput',false);
        new_protocol_labels = chrim_labels;
    end                                  
    if cellfun(@(x) contains(x,'loom'),proto_string)
        test_string = proto_string;
        to_index = cellfun(@(x) strfind(x,'to'),test_string);
        lv_index = cellfun(@(x) strfind(x,'lv'),test_string);
        score_index = cellfun(@(x) max(strfind(x,'_')),test_string);
        start_angle = cellfun(@(x,y) x(6:(y-1)),test_string,num2cell(to_index),'uniformoutput',false);
        ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
        loverv = cellfun(@(x,y,z) x((y+2):(z-1)),test_string,num2cell(lv_index),num2cell(score_index),'uniformoutput',false);
        loom_labels = cellfun(@(x,y,z) sprintf('loom_%03sto%03s_lv%03s',x,y,z), start_angle,ending_angle,loverv,'uniformoutput',false);        
        new_protocol_labels = loom_labels;
    end
    if cellfun(@(x) contains(x,'wall'),proto_string)
        test_string = proto_string;
        to_index = cellfun(@(x) strfind(x,'to'),test_string);
        lv_index = cellfun(@(x) strfind(x,'lv'),test_string);
        loom_index = cellfun(@(x) strfind(x,'loom'),test_string);
        start_angle = cellfun(@(x,y,z) x((z+5):(y-1)),test_string,num2cell(to_index),num2cell(loom_index),'uniformoutput',false);
        ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);
        loverv = cellfun(@(x,y) x((y+2):end),test_string,num2cell(lv_index),'UniformOutput',false);
        loom_labels = cellfun(@(x,y,z) sprintf('loom_%03sto%03s_lv%03s',x,y,z), start_angle,ending_angle,loverv,'uniformoutput',false);        
        
        width_index = cellfun(@(x) strfind(x,'_w'),test_string);
        height_index = cellfun(@(x) strfind(x,'_h'),test_string);
        at_index = cellfun(@(x) strfind(x,'at'),test_string,'UniformOutput',false);
        
        wall_width = cellfun(@(x,y,z) x((y+2):(z(1)-1)),test_string,num2cell(width_index),at_index,'UniformOutput',false);
        wall_height = cellfun(@(x,y,z) x((y+2):(z(2)-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);
        
        wall_width_loc = cellfun(@(x,y,z) x((z(1)+2):(y-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);
        wall_height_loc = cellfun(@(x,y,z) x((z(2)+2):(y-2)),test_string,num2cell(loom_index ),at_index,'UniformOutput',false);
        
        new_protocol_labels = cellfun(@(x,y,z,a,b) sprintf('wall_w%03sat%03s_h%03sat%03s_%s',x,y,z,a,b),wall_width,wall_width_loc,wall_height,wall_height_loc,loom_labels,'UniformOutput',false);
    end
    if cellfun(@(x) contains(x,'stripe'),proto_string)
        new_protocol_labels = proto_string;
    end
end
function set_up_iosr(~,~)
    currdir = cd;
    cd([fileparts(which(mfilename('fullpath'))) filesep '..']);
    directory = pwd;
    directory = [directory filesep 'IoSR-Surrey-MatlabToolbox-4bff1bb'];

    cd(directory);
    addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);

    %% start SOFA    
    SOFAstart(0);    
    cd(currdir); % return to original directory
end
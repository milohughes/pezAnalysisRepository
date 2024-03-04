function pez_compare_rates    
    repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(repositoryDir,'Support_Programs'))    
    addpath(fullfile(repositoryDir,'Current_Versions'))
    addpath(fullfile(repositoryDir,'Current_Versions'))
    addpath(fullfile(repositoryDir,'Current_Versions','Analysis Programs'))

    exp_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
    exp_list = exp_list(cellfun(@(x) length(x) == 16, exp_list.name),:).name;
    exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) == 212, exp_list));

    load_files = exp_list(cellfun(@(x) contains(x,'00000430'),exp_list));
    steps = length(load_files);
    
    set_up_iosr

    combine_data = [];
    %%
    parfor iterZ = 1:steps
        test_data =  Experiment_ID(load_files{iterZ});
        test_data.temp_range = [22.5,24.5];
        test_data.humidity_cut_off = 40;
        test_data.remove_low = false;
        test_data.low_count = 0;
        test_data.azi_off = 180;
        test_data.ignore_graph_table = true;
        try
            test_data.load_data;
            test_data.make_tables;
        catch               
            warning('id with no graph table');
        end
        combine_data = [combine_data;test_data];                             
    end

    %%
    clc
    steps = length(combine_data);
    combine_data(arrayfun(@(x) isempty(combine_data(x).Complete_usuable_data),1:1:steps)',:) = [];
    steps = length(combine_data);
    ids_usuable_data = arrayfun(@(x) height(combine_data(x).Complete_usuable_data),1:1:steps)';
    combine_data(ids_usuable_data == 0,:) = [];

    stim_info = vertcat(combine_data(:).parsed_data);
    stim_parms = parse_offaxis_loom(stim_info.Stimuli_Type);            stim_parms = num2cell(stim_parms);
    rem_data = cell2mat(stim_parms(:,1)) == 20 | cell2mat(stim_parms(:,4)) == 90;
    stim_parms(rem_data,:) = [];
    stim_info(rem_data,:) = [];
    combine_data(rem_data,:) = [];
     
    proto_string = cellfun(@(x,y,z,a,b,c) sprintf('loom_r%01.4f_d%01.4f_lv%03.0f_t%04.0f_ele%03.0f_azi%03.0f',b,c,a,x,y,z),stim_parms(:,2),stim_parms(:,3),stim_parms(:,4),stim_parms(:,1),stim_parms(:,5),stim_parms(:,6),'uniformoutput',false);             
    proto_name = cellfun(@(x) x(13:16),get(stim_info,'ObsNames'),'UniformOutput',false);
     
    all_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Multi_Blank);vertcat(combine_data(:).Pez_Issues);vertcat(combine_data(:).Balancer_Wings);vertcat(combine_data(:).Failed_Location)];   
    good_data = vertcat(combine_data(:).Complete_usuable_data);
        
    all_data(cellfun(@(x) strcmp(x,'Unexpected supplement frame count'), all_data.Data_Acquisition),:) = [];
    all_data(cellfun(@(x) isempty(x), all_data.NIDAQ),:) = [];       
    all_data(cellfun(@(x) isempty(x),all_data.Stimuli_Used),:) = [];
    all_data(cellfun(@(x) contains(x,'_azi90'),all_data.Stimuli_Used),:) = [];    
        
    good_data(cellfun(@(x) strcmp(x,'Unexpected supplement frame count'), good_data.Data_Acquisition),:) = [];
    good_data(cellfun(@(x) isempty(x), good_data.NIDAQ),:) = [];       
    good_data(cellfun(@(x) isempty(x),good_data.Stimuli_Used),:) = [];
    good_data(cellfun(@(x) contains(x,'_azi90'),good_data.Stimuli_Used),:) = [];

    
    stim_parms = parse_offaxis_loom(all_data.Stimuli_Used);
    proto_list = cellfun(@(x) x(41:44),all_data.Properties.RowNames,'UniformOutput',false);
    combo_list = cellfun(@(x,y,z) sprintf('%0.4f_%03.0f_%s',x,y,z),num2cell(stim_parms(:,5)),num2cell(stim_parms(:,2)),proto_list,'UniformOutput',false);
    full_table = tabulate(combo_list);
    [~,sort_idx] = sort(full_table(:,1));
    full_table = full_table(sort_idx,:);

    [locA,locB] = ismember(cellfun(@(x) x(end-3:end),full_table(:,1),'UniformOutput',false),cellfun(@(x) x(13:16), get(stim_info,'ObsNames'),'UniformOutput',false));
    incubator = struct2dataset(stim_info(locB(locA),:).Incubator_Info);
    date_list = cellfun(@(x) (x(16:23)),all_data.Properties.RowNames,'UniformOutput',false);
     
    last_date = zeros(length(full_table(:,1)),1);
    for iterZ = 1:length(full_table(:,1))
        last_date(iterZ) = max(str2double(date_list(ismember(combo_list,full_table{iterZ,1}))));
    end
    new_table_list = [num2cell(cell2mat(cellfun(@(x,y) [str2double(x(1:6)),str2double(x(8:10)),str2double(x(12:15)),y],full_table(:,1),full_table(:,2),'UniformOutput',false))),num2cell(last_date),incubator.Name];
    new_table_list = new_table_list(cellfun(@(x) contains(x,'#DD'),new_table_list(:,6)),:);
    
    
    samp_str = sort(cellfun(@(x,y,z,a) sprintf('%2.4f_%04.0f_%8.0f_%4.0f',x,y,z,a),new_table_list(:,1),new_table_list(:,2),new_table_list(:,5),new_table_list(:,3),'UniformOutput',false));
    samp_idx = unique(cellfun(@(x,y) sprintf('%2.4f_%04.0f',x,y),new_table_list(:,1),new_table_list(:,2),'UniformOutput',false));
    samp_str = samp_str(cellfun(@(x) find(contains(samp_str,x),1,'last'),samp_idx));
    filt_proto_list = cellfun(@(x) x(end-3:end),samp_str,'UniformOutput',false);
    [locA,~] = ismember(cell2mat(new_table_list(:,3)),str2double(filt_proto_list));
    new_table_list = new_table_list(locA,:);
    
    
    
    full_table = tabulate(cellfun(@(x) x(41:44), all_data.Properties.RowNames,'UniformOutput',false));
    
    done_data = all_data(cellfun(@(x) ~isempty(x), good_data.frame_of_leg_push),:);
    vid_table = tabulate(cellfun(@(x) x(41:44), done_data.Properties.RowNames,'UniformOutput',false));
    done_data = done_data(cellfun(@(x) ~isnan(x), done_data.frame_of_leg_push),:);
    jump_table = tabulate(cellfun(@(x) x(41:44), done_data.Properties.RowNames,'UniformOutput',false));

    [locA_f,locB_f] = ismember(cell2mat(new_table_list(:,3)),str2double(full_table(:,1)));
    [locA_v,locB_v] = ismember(cell2mat(new_table_list(:,3)),str2double(vid_table(:,1)));
    [locA_j,locB_j] = ismember(cell2mat(new_table_list(:,3)),str2double(jump_table(:,1)));
    
    final_table = [new_table_list(:,3),full_table(locB_f(locA_f),2),vid_table(locB_v(locA_v),2),jump_table(locB_j(locA_j),2)];
    
    
    
    all_data = all_data(cellfun(@(x) isempty(x), all_data.frame_of_leg_push),:);    
    
    date_list = cellfun(@(x) (x(16:23)),all_data.Properties.RowNames,'UniformOutput',false);
    [date_list,sort_idx] = sort(date_list);
    all_data = all_data(sort_idx,:);
    
    [locA,locB] = ismember(cellfun(@(x) x(41:44),all_data.Properties.RowNames,'UniformOutput',false),proto_name); 
    proto_string = proto_string(locB(locA));
    
    [new_table,~,~,new_labels] = crosstab(proto_string,date_list);
        
    has_jump = cellfun(@(x) ~isempty(x), all_data.jumpTest);
    all_data = all_data(has_jump,:);
    new_proto_string = proto_string(has_jump);
    jump_table = tabulate(new_proto_string(cell2mat(all_data.jumpTest) == 1));

end
function stim_parms = parse_offaxis_loom(stimuli_string)
    stimuli_string = cellfun(@(x) regexprep(x,'p','.'),stimuli_string,'UniformOutput',false);
    stimuli_string = cellfun(@(x) regexprep(x,'.mat',''),stimuli_string,'UniformOutput',false);
    
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
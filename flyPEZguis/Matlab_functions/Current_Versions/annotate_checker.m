repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(repositoryDir,'Support_Programs'))
%addpath(fullfile(repositoryDir,'Current_Versions'))

exp_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
exp_list = exp_list(cellfun(@(x) length(x) == 16, exp_list.name),:).name;
%exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) >= 100, exp_list));
exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) >= 200, exp_list));
%exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) <= 175, exp_list));

%exp_list(cellfun(@(x) str2double(x(1:4)) == 153, exp_list)) = [];

% 
% proto_list = cellfun(@(x) parse_expid_v2(x),exp_list,'UniformOutput',false);
% proto_list = vertcat(proto_list{:});
% exp_list = get(proto_list,'ObsNames');
%exp_list = exp_list(cellfun(@(x) contains(x,'00000430'),exp_list));

result_data = cell(length(exp_list),5);
all_dates  = [];
all_wing_up = [];
all_wing_down = [];
all_leg_push =  [];
all_collect = [];
all_dates_run =[];

for iterZ = 1:length(exp_list)
    temp_data = Experiment_ID(exp_list{iterZ});
    temp_data.ignore_graph_table = true;
    temp_data.load_data;
    
    if strcmp(temp_data.parsed_data.Download_Opts,'Full Rate')
        warning('Full Rate Vid, can not annotate');
        continue
    end
       
%     try
%         logic_vect = cellfun(@(z) str2double(z(16:23)) >= 20190101, temp_data.Complete_usuable_data.Properties.RowNames);
%         temp_data.Complete_usuable_data = temp_data.Complete_usuable_data(logic_vect,:);    
%     catch
%         warning('Id was never run');
%         continue
%     end
    if isempty(temp_data.Complete_usuable_data)
        warning('no videos')
        continue
    end
      
    done_data = temp_data.Complete_usuable_data;
    done_data(cellfun(@(x) isempty(x), done_data.frame_of_take_off),:) =  [];
    done_data(cellfun(@(x) isnan(x), done_data.frame_of_take_off),:) =  [];

    result_data(iterZ,1) =  exp_list(iterZ);
    try        
        result_data(iterZ,2) = {height(temp_data.Complete_usuable_data)};     %total videos
    catch
        result_data(iterZ,2) = {0};     %total videos
        warning('no videos for this id');
        continue
    end
    filt_table = temp_data.Complete_usuable_data;
    filt_table(cellfun(@(x) sum(x == 0) == 1, filt_table.trigger_timestamp),:) = [];
    
    if isempty(filt_table)
        continue
    end
    
    date_list = cellfun(@(x) datenum(str2double(x(16:19)),str2double(x(20:21)),str2double(x(22:23))),filt_table.Properties.RowNames);
    all_dates_run = [all_dates_run;date_list];
    
    collect_list = cellfun(@(x) x(29:32),filt_table.Properties.RowNames,'UniformOutput',false);
    all_collect = [all_collect;collect_list];
    
    run_times = datevec(filt_table.trigger_timestamp);
    run_times = run_times(:,4);
    morning_runs = sum(run_times >= 7 & run_times < 12);
    afternoon_runs = sum(run_times >= 12 & run_times <= 17);
    evening_runs = sum(run_times > 17);
    
    time_of_day = 'Morning';
    if afternoon_runs > morning_runs
        time_of_day = 'Afternoon';
    end
    if evening_runs > afternoon_runs
        time_of_day = 'Evening';
    end
    
    run_table = tabulate(cellfun(@(x) x(1:23),filt_table.Properties.RowNames,'UniformOutput',false));
    run_table(:,3) = repmat({time_of_day},size(run_table(:,3),1),1);    
    result_data(iterZ,4) = {run_table};    
    
    need_to_work_logic = cellfun(@(x,y,z) isempty(x) | (strcmp(y,'Unknown') & strcmp(z,'Single')),filt_table.frame_of_leg_push,filt_table.Gender,filt_table.Fly_Count);
    filt_table = filt_table(need_to_work_logic,:);
        
    if ~isempty(filt_table)
        error_logic = cellfun(@(x,y) isempty(x) & isempty(y),filt_table.frame_of_leg_push,filt_table.Gender);
        filt_table(error_logic,:) = [];
    end
    
    
    if ~isempty(filt_table)
        date_list = cellfun(@(x) datenum(str2double(x(16:19)),str2double(x(20:21)),str2double(x(22:23))),filt_table.Properties.RowNames);
        [date_table,date_edge,hist_bin] = histcounts(date_list,datenum(2016,01,01):1:datenum(2020,12,01));
        date_edge(end) = [];
        try
            result_data(iterZ,3) = num2cell(sum(cell2mat(cellfun(@(x) x == 1, filt_table.jumpTest,'UniformOutput',false))));
        catch
            warning('not cell?');
        end
    else
        date_table = tabulate(cellfun(@(x) (x(16:23)),filt_table.Properties.RowNames,'UniformOutput',false));
        date_edge = [];
        result_data(iterZ,3) = {0};
    end
    result_data(iterZ,5) = {date_table};
    all_dates = [all_dates,date_edge]; %#ok<AGROW>
end

[new_table,~,~,new_label]=crosstab(all_dates_run,all_collect);
date_list = cellfun(@(x) datestr(str2double(x)), new_label(:,1),'UniformOutput',false);
collect_list = str2double(new_label(:,2)');

for iterZ = 1:5
    result_data(cellfun(@(x) isempty(x), result_data(:,iterZ)),:) = [];
end

group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],result_data(:,1),'uniformoutput',false);

date_table = cell2table(num2cell(cell2mat(result_data(:,5))));
all_dates = unique(all_dates);
date_string = cell2mat(arrayfun(@(x) datevec(x),all_dates,'UniformOutput',false)');
date_list = arrayfun(@(x,y,z) sprintf('date_%02.f_%02.f_%04.f',x,y,z),date_string(:,2),date_string(:,3),date_string(:,1),'UniformOutput',false);

date_table.Properties.VariableNames = date_list;
date_table(:,sum(date_table.Variables) == 0) = [];
date_table.Properties.RowNames = result_data(:,1);

new_row_labels = cellfun(@(x) regexprep(x,'date_',''),date_table.Properties.VariableNames,'UniformOutput',false);

group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');
group_ids = group_ids.Saved_Group_IDs;
group_ids(cellfun(@(x) contains(x,'Data Need to Annotate'),group_ids.Properties.RowNames),:) = [];
%%
for iterM = 1:12
    june_logic = cellfun(@(x) str2double(x(1:2)) == iterM,new_row_labels);

    june_table = date_table(:,june_logic);
    june_table(sum(june_table.Variables,2) == 0,:) = [];
    june_match = result_data(ismember(result_data(:,1),june_table.Properties.RowNames),:);

    if ~isempty(june_match)
        switch iterM
            case 1
                group_name =  {'Data Need to Annotate :: January'};
            case 2
                group_name =  {'Data Need to Annotate :: February'};
            case 3 
                group_name =  {'Data Need to Annotate :: March'};
            case 4
                group_name =  {'Data Need to Annotate :: April'};
            case 5
                group_name =  {'Data Need to Annotate :: May'};
            case 6
                group_name =  {'Data Need to Annotate :: June'};
            case 7
                group_name =  {'Data Need to Annotate :: July'};
            case 8
                group_name =  {'Data Need to Annotate :: August'};
            case 9
                group_name =  {'Data Need to Annotate :: September'};
            case 10
                group_name =  {'Data Need to Annotate :: October'};
            case 11
                group_name =  {'Data Need to Annotate :: November'};
            case 12
                group_name =  {'Data Need to Annotate :: December'};
        end       
%        group_name =  {'Data Need to Annotate'};
        group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
        group_exp_id = june_match(:,1);

        col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
        entry = cell(1,3);                       
        entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
        entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

        group_ids = [group_ids;entries];
    end
end
%%
Saved_Group_IDs = group_ids;
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');

clear all %#ok<CLALL>
clc
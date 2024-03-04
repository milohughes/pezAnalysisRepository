file_dir = struct2dataset(dir('Z:\Data_pez3000'));
this_year = file_dir(cellfun(@(x) str2double(x) > 20180000, file_dir.name),:).name;
all_run_ids = [];
for iterZ = 1:length(this_year)
    exp_dir = struct2dataset(dir(['Z:\Data_pez3000\' this_year{iterZ}]));
    run_list = exp_dir(cellfun(@(x) contains(x,'run'),exp_dir.name),:).name;
    for iterR = 1:length(run_list)
        try
        curr_exp = load(['Z:\Data_pez3000\' this_year{iterZ} filesep run_list{iterR} filesep run_list{iterR} '_experimentIDinfo.mat']);
        run_id = get(curr_exp.exptInfo,'ObsNames');
        all_run_ids = [all_run_ids;run_id];
        catch
            warning('no id')
        end
    end
end
all_run_ids = unique(all_run_ids);
all_run_ids(cellfun(@(x) str2double(x(1:4)) == 100,all_run_ids)) = [];
%%
group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],all_run_ids,'uniformoutput',false);
group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');
group_name = {'Pez Runs 2018'};

col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
entry = cell(1,3);                       
entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

group_ids = group_ids.Saved_Group_IDs;
group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
Saved_Group_IDs = [group_ids;entries];
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');

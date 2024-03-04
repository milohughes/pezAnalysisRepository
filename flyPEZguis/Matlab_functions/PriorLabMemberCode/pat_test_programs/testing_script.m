excel_path = 'C:\Users\breadsp\Documents\20161202_FlyPezAnalysis.xlsx';
[~,~,raw] = xlsread(excel_path);
raw(1,:) = [];
excel_data = cell2table(raw);
excel_data.Properties.VariableNames = [{'Robot_ID'},{'Alias'},{'Stock_Name'},{'Cell_Type'},{'More_Detail'}];

used_genotypes = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Genotypes.mat');
used_genotypes = used_genotypes.Saved_Genotypes;

robot_id_logic = arrayfun(@(x) ~isnan(x), excel_data.Robot_ID);

match_1 = ismember(excel_data(robot_id_logic,:).Robot_ID,str2double(used_genotypes.ParentA_ID));
match_2 = ismember(excel_data(robot_id_logic,:).Robot_ID,str2double(used_genotypes.ParentB_ID));
data_match = excel_data(robot_id_logic,:);
no_match = data_match(~match_1 & ~match_2,:);

match_parentA = ismember(str2double(used_genotypes.ParentA_ID),excel_data(robot_id_logic,:).Robot_ID);
match_parentB = ismember(str2double(used_genotypes.ParentB_ID),excel_data(robot_id_logic,:).Robot_ID);

matching_data = [used_genotypes(match_parentA,:);used_genotypes(match_parentB,:)];

no_id_found = [excel_data(~robot_id_logic,:);no_match];

matches_parent_A = data_match(match_1,:);
matches_parent_B = data_match(match_2,:);

new_alias = regexprep(no_id_found.Alias,'JRC_','');
parentA_alias = regexprep(used_genotypes.ParentA_name,'GMR_','');
parentB_alias = regexprep(used_genotypes.ParentB_name,'GMR_','');

match_parentA = ismember(parentA_alias,new_alias);
match_parentB = ismember(parentB_alias,new_alias);

matching_data = [matching_data;[used_genotypes(match_parentA,:);used_genotypes(match_parentB,:)]];


exp_dir = struct2dataset(dir('Y:\Data_pez3000_analyzed'));
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir.name),:).name;

matching_list = exp_dir(ismember(cellfun(@(x) x(5:12),exp_dir,'uniformoutput',false),get(matching_data,'ObsNames')));

filt_list = matching_list;

clear results


group_name = {'DN Collection'};


group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],filt_list,'uniformoutput',false);
group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');

col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
entry = cell(1,3);                       
entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                    entry(1,3) = {'Active'};
entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

group_ids = group_ids.Saved_Group_IDs;
group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
%Saved_Group_IDs = group_ids;
Saved_Group_IDs = [group_ids;entries];
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');
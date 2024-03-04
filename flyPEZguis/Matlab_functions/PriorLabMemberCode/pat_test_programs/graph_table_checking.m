repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(repositoryDir,'Support_Programs'))

exp_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
exp_list = exp_list(cellfun(@(x) length(x) == 16, exp_list.name),:).name;
exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) >= 200, exp_list));

%exp_list(cellfun(@(x) str2double(x(1:4)) == 113, exp_list)) = [];

result_data = cell(length(exp_list),3);
for iterZ = 1:length(exp_list)
    
    result_data(iterZ,1) =  exp_list(iterZ);
    try
        auto_table = load(['Z:\Data_pez3000_analyzed' filesep exp_list{iterZ} filesep exp_list{iterZ} '_rawDataAssessment.mat']);    
        auto_table  = auto_table.assessTable;

        result_data(iterZ,2) = num2cell(height(auto_table));
    catch
        warning('no files in this folder')
        continue
    end
    try
        graph_table = load(['Z:\Data_pez3000_analyzed' filesep exp_list{iterZ} filesep exp_list{iterZ} '_dataForVisualization.mat']);    
        graph_table = graph_table.graphTable;
        result_data(iterZ,3) = num2cell(height(graph_table));
    catch
        warning('no graph table')
        result_data(iterZ,3) = {0}
    end
end
result_data(cellfun(@(x) isempty(x), result_data(:,2)),:) = [];


result_data(cellfun(@(x) isempty(x), result_data(:,1)),:) = [];
result_data(cellfun(@(x) strcmp(x(1:4),'0153'),result_data(:,1)),:) = [];
result_data(cellfun(@(x) strcmp(x(1:4),'0173'),result_data(:,1)),:) = [];
result_data(cellfun(@(x) strcmp(x(1:4),'0184'),result_data(:,1)),:) = [];

filt_results = result_data(cell2mat(result_data(:,3)) > 0 | cell2mat(result_data(:,4)) > 0,1);
result_data = result_data(cell2mat(result_data(:,3)) > 0 | cell2mat(result_data(:,4)) > 0,:);
group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],filt_results,'uniformoutput',false);

date_table = cell2table(num2cell(cell2mat(result_data(:,5))));
all_dates = unique(all_dates);

date_string = cell2mat(arrayfun(@(x) datevec(x),all_dates,'UniformOutput',false)');
date_list = arrayfun(@(x,y,z) sprintf('date_%02.f_%02.f_%04.f',x,y,z),date_string(:,2),date_string(:,3),date_string(:,1),'UniformOutput',false);
date_table.Properties.VariableNames = date_list(1:(end-1));
date_table(:,sum(date_table.Variables) == 0) = [];
date_table.Properties.RowNames = result_data(:,1);

new_row_labels = cellfun(@(x) regexprep(x,'date_',''),date_table.Properties.VariableNames,'UniformOutput',false);

group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');
group_name =  {'Data Need to Annotate'};

col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
entry = cell(1,3);                       
entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

group_ids = group_ids.Saved_Group_IDs;
group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
Saved_Group_IDs = [group_ids;entries];
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');

clear all %#ok<CLALL>
clc